import Score
import QtQuick
import "TextRender.js" as TextRender

Script {
    id: root

    TextureInlet {
        id: texFill
        objectName: "Fill Texture"
    }

    ValueInlet {
        id: textContent
        objectName: "Text"
    }
    ValueInlet {
        id: textStyleIn
        objectName: "Style"
    }
    FloatSlider {
        id: masterOpacity
        objectName: "Opacity"
        min: 0; max: 1; init: 1
    }
    FloatSlider {
        id: writeOn
        objectName: "Write On"
        min: 0; max: 1; init: 1
    }
    HSVSlider {
        id: colorOverride
        objectName: "Color"
    }

    TextureOutlet {
        objectName: "Output"
        item: Item {
            id: outputRoot
            anchors.fill: parent

            // Hidden container: parents the texture inlet item into the scene
            // graph so ShaderEffectSource can render from it.
            Item {
                id: texFillContainer
                anchors.fill: parent
                visible: false

                Component.onCompleted: {
                    if (texFill.item) {
                        texFill.item.parent = texFillContainer;
                        texFill.item.width = Qt.binding(function() { return texFillContainer.width; });
                        texFill.item.height = Qt.binding(function() { return texFillContainer.height; });
                    }
                }
            }

            // Bridge: ShaderEffectSource mirrors the inlet's texture as a
            // proper QML item (with engine), so grabToImage() works on it.
            ShaderEffectSource {
                id: texBridge
                anchors.fill: parent
                sourceItem: texFill.item
                visible: false
                live: true
            }

            Canvas {
                id: textCanvas
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative

                property int ver: root.stateVersion
                onVerChanged: requestPaint()
                onImageLoaded: requestPaint()

                onPaint: {
                    var ctx = getContext("2d");
                    // For texture fill, pass the grabbed image URL (Canvas-drawable)
                    // instead of the QQuickRhiItem (which Canvas can't draw).
                    var texItem = null;
                    if (root.textState.fillType === "texture"
                        && root.texGrabUrl
                        && isImageLoaded(root.texGrabUrl))
                    {
                        texItem = root.texGrabUrl;
                    }
                    TextRender.paintText(ctx, width, height,
                        root.textState, root.getInletValues(), texItem);
                }
            }
        }
    }

    property var textState: TextRender.defaultState()
    property int stateVersion: 0
    property real lastSentW: 0
    property real lastSentH: 0
    property real prevOpacity: -1
    property real prevWriteOn: -1
    property string prevText: ""
    property real elapsed: 0
    property real lastTickMs: 0
    property bool needsContinuousRepaint: false

    // Texture grab state for Canvas-based texture fill
    property var texGrabResult: null
    property string texGrabUrl: ""
    property bool texGrabPending: false

    function getInletValues() {
        var vals = {
            opacity: masterOpacity.value,
            writeOn: writeOn.value,
            elapsed: root.elapsed
        };
        if (root.prevText)
            vals.text = root.prevText;
        if (colorOverride.value && colorOverride.value.w > 0)
            vals.colorOverride = colorOverride.value;
        return vals;
    }

    loadState: function(state) {
        if (state && state.textState) {
            try {
                var s = typeof state.textState === "string"
                    ? JSON.parse(state.textState) : state.textState;
                root.textState = TextRender.mergeState(
                    TextRender.defaultState(), s);
            } catch(e) {
                root.textState = TextRender.defaultState();
            }
        } else {
            root.textState = TextRender.defaultState();
        }
        root.stateVersion++;
    }

    stateUpdated: function(k, v) {
        if (k === "textState") {
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.textState = TextRender.mergeState(
                    TextRender.defaultState(), s);
            } catch(e) { return; }
            root.stateVersion++;
        }
    }

    uiEvent: function(message) {
        if (!message) return;
        if (message.type === "updateStyle") {
            root.textState = TextRender.mergeState(
                TextRender.defaultState(), message.style || {});
            root.stateVersion++;
        } else if (message.type === "retrigger") {
            root.elapsed = 0;
            root.lastTickMs = Date.now();
            root.stateVersion++;
        }
    }

    tick: function(token, state) {
        var changed = false;

        // Accumulate elapsed time for animations
        var now = Date.now();
        if (root.lastTickMs > 0) {
            root.elapsed += (now - root.lastTickMs) / 1000;
        }
        root.lastTickMs = now;

        // Check if continuous repaint is needed (scroll or wave active)
        var ts = root.textState;
        root.needsContinuousRepaint =
            (ts.scrollMode && ts.scrollMode !== "none")
            || ts.charWaveEnabled
            || ts.charAnimEnabled
            || (writeOn.value < 1 && ts.writeOnMode === "scramble")
            || ts.fillType === "texture";

        if (root.needsContinuousRepaint) changed = true;

        if (textContent.value !== undefined && textContent.value !== null) {
            var t = String(textContent.value);
            if (t !== root.prevText) {
                root.prevText = t;
                changed = true;
            }
        }
        if (masterOpacity.value !== root.prevOpacity) {
            root.prevOpacity = masterOpacity.value;
            changed = true;
        }
        if (writeOn.value !== root.prevWriteOn) {
            root.prevWriteOn = writeOn.value;
            changed = true;
        }
        if (textStyleIn.value !== undefined && textStyleIn.value !== null) {
            try {
                var so = typeof textStyleIn.value === "string"
                    ? JSON.parse(textStyleIn.value) : textStyleIn.value;
                root.textState = TextRender.mergeState(root.textState, so);
                changed = true;
            } catch(e) {}
        }

        // Grab texture inlet content for Canvas use.
        // Canvas drawImage() can't render QQuickRhiItem directly,
        // so we snapshot it via a ShaderEffectSource bridge (which is a
        // proper QML item with an engine) to an image URL Canvas can draw.
        if (root.textState.fillType === "texture" && texFill.item && !root.texGrabPending) {
            root.texGrabPending = true;
            var oldUrl = root.texGrabUrl;
            texBridge.grabToImage(function(result) {
                if (oldUrl) textCanvas.unloadImage(oldUrl);
                root.texGrabResult = result; // prevent GC
                root.texGrabUrl = result.url;
                root.texGrabPending = false;
                textCanvas.loadImage(result.url);
            });
        }

        if (changed) root.stateVersion++;

        var cw = textCanvas.width, ch = textCanvas.height;
        if (cw !== root.lastSentW || ch !== root.lastSentH) {
            root.lastSentW = cw;
            root.lastSentH = ch;
            uiSend({ type: "renderSize", width: cw, height: ch });
        }
    }

    start: function() {
        root.elapsed = 0;
        root.lastTickMs = 0;
    }
}
