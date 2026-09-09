import Score
import QtQuick
import "TextRender.js" as TextRender
import OssiaUI as S

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
            }

            // Bridge: ShaderEffectSource mirrors the inlet's texture as a
            // proper QML item (with engine), so grabToImage() works on it.
            ShaderEffectSource {
                id: texBridge
                anchors.fill: parent
                sourceItem: texFill.item
                visible: false
                live: true
                // The inlet item may arrive after component completion, or be
                // replaced when its source changes.
                function attachSource() {
                    if (sourceItem) {
                        sourceItem.parent = texFillContainer;
                        sourceItem.width = Qt.binding(function() { return texFillContainer.width; });
                        sourceItem.height = Qt.binding(function() { return texFillContainer.height; });
                    }
                    root.invalidateTextureGrab(true);
                    Qt.callLater(root.grabTexture);
                }
                onSourceItemChanged: attachSource()
                Component.onCompleted: attachSource()
            }

            Canvas {
                id: textCanvas
                anchors.fill: parent
                renderStrategy: Canvas.Cooperative
                contextType: "2d"

                // A resized or recreated backing image is empty even when the
                // text is static. Repaint from resource events, not preview UI.
                onAvailableChanged: {
                    root.invalidateTextureGrab(true);
                    if (available) {
                        requestPaint();
                        Qt.callLater(root.grabTexture);
                    }
                }
                onCanvasSizeChanged: {
                    root.invalidateTextureGrab(false);
                    requestPaint();
                    Qt.callLater(root.grabTexture);
                }

                property int ver: root.stateVersion
                onVerChanged: requestPaint()
                property bool editing: inlineText.editing
                onEditingChanged: requestPaint()
                onImageLoaded: {
                    root.finishTextureGrab();
                    requestPaint();
                }

                onPaint: {
                    var ctx = getContext("2d");
                    if (!ctx) return;
                    // Keep the Canvas and its backing texture alive while the
                    // editor replaces the text; hiding it loses output resources.
                    if (editing) {
                        ctx.clearRect(0, 0, width, height);
                        return;
                    }
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
                        root.renderState, root.getInletValues(), texItem);
                }
            }

            MouseArea {
                anchors.fill: parent
                acceptedButtons: Qt.LeftButton
                onPressed: function(mouse) {
                    if (inlineText.editing) inlineText.finish(true);
                    if (!root.canEditText()) mouse.accepted = false;
                }
                onDoubleClicked: function(mouse) {
                    if (!root.canEditText() || !textCanvas.available) return;
                    var g = TextRender.editingGeometry(textCanvas.getContext("2d"),
                        outputRoot.width, outputRoot.height, root.renderState, root.getInletValues());
                    var det = g.a * g.d - g.b * g.c;
                    if (Math.abs(det) < 0.000001) return;
                    var dx = mouse.x - g.x, dy = mouse.y - g.y;
                    var x = (g.d * dx - g.c * dy) / det;
                    var y = (-g.b * dx + g.a * dy) / det;
                    if (x < 0 || y < 0 || x > g.width || y > g.height) return;
                    inlineText.geometry = g;
                    inlineText.editStyle = TextRender.mergeState({}, root.renderState);
                    inlineText.begin(String(root.textState.text || ""));
                }
            }

            S.SInlineTextEditor {
                id: inlineText
                // Hold the text block still while typing; the animation clock keeps running.
                property var geometry: ({a: 1, b: 0, c: 0, d: 1, x: 0, y: 0, width: 1, height: 1})
                property var editStyle: ({})
                width: geometry.width
                height: Math.max(geometry.height, contentHeight)
                padding: 0
                wrapMode: editStyle.wordWrap ? TextEdit.WordWrap : TextEdit.NoWrap
                horizontalAlignment: editStyle.hAlign === "left" ? TextEdit.AlignLeft
                    : (editStyle.hAlign === "right" ? TextEdit.AlignRight : TextEdit.AlignHCenter)
                font.family: editStyle.fontFamily || "Arial"
                font.pixelSize: editStyle.fontSize || 72
                font.bold: editStyle.fontWeight === "bold"
                font.italic: editStyle.fontStyle === "italic"
                font.underline: !!editStyle.underline
                font.strikeout: !!editStyle.strikethrough
                font.letterSpacing: editStyle.tracking || 0
                transform: Matrix4x4 {
                    matrix: Qt.matrix4x4(inlineText.geometry.a, inlineText.geometry.c, 0, inlineText.geometry.x,
                        inlineText.geometry.b, inlineText.geometry.d, 0, inlineText.geometry.y,
                        0, 0, 1, 0, 0, 0, 0, 1)
                }
                onEdited: function(value) {
                    root.textState.text = value;
                    root.stateVersion++;
                }
                onFinished: function(value, accepted) {
                    if (accepted && root.canEditText() && value !== String(editStyle.text || "")) {
                        root.storedTextState.text = value;
                        var serialized = JSON.stringify(root.storedTextState);
                        root.pendingCommits.push(serialized);
                        root.commitState("textState", serialized);
                        root.uiSend({type: "textState", style: serialized});
                    }
                    textCanvas.requestPaint();
                }
            }
        }
    }

    // Append ports: existing documents keep their original inlet / outlet indices.
    // These are offsets and factors over the saved style (and then Style inlet),
    // never replacements for it. Neutral values preserve the editor's styling.
    FloatSlider {
        id: positionXOffset
        objectName: "Position X Offset"
        min: -1; max: 1; init: 0
    }
    FloatSlider {
        id: positionYOffset
        objectName: "Position Y Offset"
        min: -1; max: 1; init: 0
    }
    FloatSlider {
        id: rotationOffset
        objectName: "Rotation Offset"
        min: -360; max: 360; init: 0
    }
    FloatSlider {
        id: scaleXFactor
        objectName: "Scale X Factor"
        min: 0.1; max: 5; init: 1
    }
    FloatSlider {
        id: scaleYFactor
        objectName: "Scale Y Factor"
        min: 0.1; max: 5; init: 1
    }
    FloatSlider {
        id: fontSizeFactor
        objectName: "Font Size Factor"
        min: 0.1; max: 5; init: 1
    }
    FloatSlider {
        id: trackingOffset
        objectName: "Tracking Offset"
        min: -50; max: 100; init: 0
    }
    FloatSlider {
        id: lineSpacingFactor
        objectName: "Line Spacing Factor"
        min: 0.1; max: 4; init: 1
    }

    property var textState: TextRender.defaultState()
    property var storedTextState: TextRender.defaultState()
    property var pendingCommits: []
    property int stateVersion: 0
    readonly property var renderState: {
        root.stateVersion; // Text edits mutate the saved-style copy in place.
        return TextRender.applyAutomation(root.textState, {
            posX: positionXOffset.value,
            posY: positionYOffset.value,
            rotation: rotationOffset.value,
            scaleX: scaleXFactor.value,
            scaleY: scaleYFactor.value,
            fontSize: fontSizeFactor.value,
            tracking: trackingOffset.value,
            lineSpacing: lineSpacingFactor.value
        });
    }
    onRenderStateChanged: {
        if (textCanvas) textCanvas.requestPaint();
    }
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
    property var nextTexGrabResult: null
    property int texGrabGeneration: 0
    readonly property bool textureFillActive: root.renderState.fillType === "texture"
    onTextureFillActiveChanged: {
        root.invalidateTextureGrab(true);
        if (textureFillActive) Qt.callLater(root.grabTexture);
    }

    function invalidateTextureGrab(discardCurrent) {
        ++root.texGrabGeneration;
        root.texGrabPending = false;
        if (root.nextTexGrabResult) {
            textCanvas.unloadImage(root.nextTexGrabResult.url);
            root.nextTexGrabResult = null;
        }
        if (discardCurrent) {
            if (root.texGrabUrl) textCanvas.unloadImage(root.texGrabUrl);
            root.texGrabUrl = "";
            root.texGrabResult = null;
        }
    }

    function finishTextureGrab() {
        var next = root.nextTexGrabResult;
        if (!next) return;
        if (textCanvas.isImageLoaded(next.url)) {
            var oldUrl = root.texGrabUrl;
            root.texGrabResult = next; // Keep the image provider alive.
            root.texGrabUrl = next.url;
            root.nextTexGrabResult = null;
            root.texGrabPending = false;
            if (oldUrl && oldUrl !== root.texGrabUrl) textCanvas.unloadImage(oldUrl);
            textCanvas.requestPaint();
        } else if (textCanvas.isImageError(next.url)) {
            textCanvas.unloadImage(next.url);
            root.nextTexGrabResult = null;
            root.texGrabPending = false;
        }
    }

    function grabTexture() {
        root.finishTextureGrab();
        if (root.textState.fillType !== "texture" || !texBridge.sourceItem
            || !textCanvas.available || texBridge.width <= 0 || texBridge.height <= 0
            || root.texGrabPending) return;
        var generation = root.texGrabGeneration;
        root.texGrabPending = true;
        // Rejection does not invoke the callback (e.g. during render target
        // teardown). Do not leave all future captures blocked in that case.
        var accepted = texBridge.grabToImage(function(result) {
            if (generation !== root.texGrabGeneration) return;
            root.nextTexGrabResult = result;
            textCanvas.loadImage(result.url);
            root.finishTextureGrab();
        });
        if (!accepted) root.texGrabPending = false;
    }

    function styleOverrides() {
        try {
            var value = textStyleIn.value;
            var style = typeof value === "string" ? JSON.parse(value) : value;
            return style && typeof style === "object" ? style : null;
        } catch (error) { return null; }
    }

    function canEditText() {
        // Keep the renderer's existing nonempty Text inlet precedence. A Style
        // inlet that supplies text owns that value even if it is an empty string.
        var value = textContent.value;
        if (root.prevText || (value !== undefined && value !== null && String(value))) return false;
        var style = root.styleOverrides();
        return !style || !Object.prototype.hasOwnProperty.call(style, "text");
    }

    function applyStoredStyle(style) {
        inlineText.finish(false);
        root.storedTextState = TextRender.mergeState(TextRender.defaultState(), style);
        root.textState = TextRender.mergeState(root.storedTextState, root.styleOverrides());
        root.stateVersion++;
    }

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
        var s = null;
        try {
            if (state && state.textState)
                s = typeof state.textState === "string" ? JSON.parse(state.textState) : state.textState;
        } catch (error) {}
        root.applyStoredStyle(s);
    }

    stateUpdated: function(k, v) {
        if (k === "textState") {
            var pending = root.pendingCommits.indexOf(v);
            if (pending >= 0) { root.pendingCommits.splice(pending, 1); return; }
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.applyStoredStyle(s);
            } catch(e) { return; }
        }
    }

    uiEvent: function(message) {
        if (!message) return;
        if (message.type === "updateStyle") {
            root.applyStoredStyle(message.style || {});
        } else if (message.type === "retrigger") {
            root.elapsed = 0;
            root.lastTickMs = Date.now();
            root.stateVersion++;
        }
    }

    tick: function(token, state) {
        var changed = false;
        if (inlineText.editing && !root.canEditText()) inlineText.finish(false);

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
            || (writeOn.value < 1 && ts.writeOnMode === "scramble");

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

        // Moving texture inputs still need one snapshot per execution frame.
        // Keep the last loaded snapshot until its replacement is drawable.
        root.grabTexture();

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
