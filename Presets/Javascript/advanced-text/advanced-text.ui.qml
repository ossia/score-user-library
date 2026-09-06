import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "TextRender.js" as TextRender
import OssiaUI as S

// Advanced Text — style editor.
//
// One scrolling column of collapsible sections, each a thin binding onto a key
// of `style`. Widgets come from the shared OssiaUI kit, so this editor, the mapper and the
// tracking-zones editor share one look; nothing here styles a control itself.
Score.ScriptUI {
    id: root
    anchors.fill: parent
    implicitWidth: 380
    implicitHeight: 780

    property var style: TextRender.defaultState()
    property int stateVersion: 0
    property real renderWidth: 0
    property real renderHeight: 0

    // ---------------- state plumbing ----------------

    // Read a style key. Touching stateVersion inside makes every binding that
    // calls this re-evaluate when the document changes (undo, preset load).
    function sty(key, fallback) {
        root.stateVersion;
        var v = root.style[key];
        return (v === undefined || v === null) ? fallback : v;
    }

    function sendLive() {
        root.executionSend({ type: "updateStyle", style: root.style });
    }
    function saveStyle(action) {
        root.beginUpdateState(action || "Edit text");
        root.updateState("textState", JSON.stringify(root.style));
        root.endUpdateState();
    }
    // live preview only: no stateVersion bump, so a drag does not fight the
    // binding that feeds the widget
    function setLive(key, val) {
        root.style[key] = val;
        sendLive();
    }
    function setAndSave(key, val, action) {
        root.style[key] = val;
        root.stateVersion++;
        sendLive();
        saveStyle(action);
    }

    loadState: function(state) {
        if (state && state.textState) {
            try {
                var s = typeof state.textState === "string"
                    ? JSON.parse(state.textState) : state.textState;
                root.style = TextRender.mergeState(TextRender.defaultState(), s);
            } catch(e) {
                root.style = TextRender.defaultState();
            }
        }
        root.stateVersion++;
    }
    stateUpdated: function(k, v) {
        if (k === "textState") {
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.style = TextRender.mergeState(TextRender.defaultState(), s);
            } catch(e) { return; }
            root.stateVersion++;
        }
    }
    executionEvent: function(message) {
        if (message && message.type === "renderSize") {
            root.renderWidth = message.width;
            root.renderHeight = message.height;
        }
    }

    // scripted UI actions, for the test harness and the Command inlet
    function uiAction(m) {
        switch (m.action) {
        case "grab": root.grabToImage(function (res) { res.saveToFile(m.path); }); break;
        case "set": root.setAndSave(m.key, m.value, "Set " + m.key); break;
        case "section": {
            for (var i = 0; i < sections.children.length; i++) {
                var c = sections.children[i];
                if (c.title === m.name) c.expanded = !!m.value;
            }
            break;
        }
        case "dumpstate":
            Util.writeFile(m.path, JSON.stringify({
                style: root.style,
                renderWidth: root.renderWidth,
                renderHeight: root.renderHeight
            }, null, 1));
            break;
        }
    }

    // ---------------- layout ----------------

    S.ThemedPage {
        anchors.fill: parent

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: S.Theme.gap
            spacing: S.Theme.gap

            S.SPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true

                ScrollView {
                    id: sv
                    anchors.fill: parent
                    anchors.margins: S.Theme.pad
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    contentWidth: availableWidth

                    ColumnLayout {
                        id: sections
                        width: sv.availableWidth
                        spacing: S.Theme.gapSm

                        // ======================== CONTENT ========================
                        S.SSection {
                            title: "Content"

                            ScrollView {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 74
                                clip: true

                                TextArea {
                                    id: textArea
                                    text: root.sty("text", "")
                                    wrapMode: TextEdit.Wrap
                                    font.pixelSize: S.Theme.fontLg
                                    color: S.Theme.text
                                    placeholderText: "Enter text…"
                                    placeholderTextColor: S.Theme.textMuted
                                    selectByMouse: true
                                    selectionColor: S.Theme.accentFill
                                    selectedTextColor: S.Theme.accentText
                                    padding: S.Theme.gap
                                    background: Rectangle {
                                        color: S.Theme.control
                                        radius: S.Theme.radius
                                        border.width: 1
                                        border.color: textArea.activeFocus ? S.Theme.accent : S.Theme.border
                                    }
                                    onTextChanged: {
                                        if (root.style.text !== text) { root.style.text = text; root.sendLive(); }
                                    }
                                    onActiveFocusChanged: if (!activeFocus) root.saveStyle("Edit text")
                                }
                            }
                            S.SComboRow {
                                label: "Transform"
                                options: ["none", "uppercase", "lowercase", "titlecase"]
                                value: root.sty("textTransform", "none")
                                onEdited: function (v) { root.setAndSave("textTransform", v, "Change transform"); }
                            }
                        }

                        // ========================= FONT =========================
                        S.SSection {
                            title: "Font"

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: S.Theme.gap
                                S.SFieldLabel { text: "Family" }
                                S.SCombo {
                                    id: fontCombo
                                    Layout.fillWidth: true
                                    editable: true

                                    property string family: root.sty("fontFamily", "")
                                    // Prepend the stored family when it is not installed on this
                                    // machine, so the field shows what the document actually asks
                                    // for (the render host may well have the font) instead of
                                    // blanking on a currentIndex of -1.
                                    model: {
                                        var l = Qt.fontFamilies();
                                        return (family.length && l.indexOf(family) < 0) ? [family].concat(l) : l;
                                    }
                                    currentIndex: Math.max(0, model.indexOf(family))
                                    onActivated: root.setAndSave("fontFamily", currentText, "Change font")
                                    onAccepted: root.setAndSave("fontFamily", editText, "Change font")
                                }
                            }
                            S.SSliderRow {
                                label: "Size"; from: 4; to: 500; stepSize: 1; decimals: 0; suffix: " px"
                                defaultValue: 72
                                value: root.sty("fontSize", 72)
                                onMoved: function (v) { root.setLive("fontSize", v); }
                                onCommitted: root.saveStyle("Change size")
                            }
                            S.SComboRow {
                                label: "Weight"
                                options: ["normal", "bold"]
                                value: root.sty("fontWeight", "normal")
                                onEdited: function (v) { root.setAndSave("fontWeight", v, "Change weight"); }
                            }
                            S.SComboRow {
                                label: "Style"
                                options: ["normal", "italic"]
                                value: root.sty("fontStyle", "normal")
                                onEdited: function (v) { root.setAndSave("fontStyle", v, "Change style"); }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: S.Theme.gapLg
                                S.SCheck {
                                    text: "Underline"; font.pixelSize: S.Theme.fontMd
                                    checked: root.sty("underline", false)
                                    onToggled: root.setAndSave("underline", checked, "Toggle underline")
                                }
                                S.SCheck {
                                    text: "Strike"; font.pixelSize: S.Theme.fontMd
                                    checked: root.sty("strikethrough", false)
                                    onToggled: root.setAndSave("strikethrough", checked, "Toggle strikethrough")
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }

                        // ========================= FILL =========================
                        S.SSection {
                            title: "Fill"

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: S.Theme.gap
                                S.SCheck {
                                    text: "Enabled"; font.pixelSize: S.Theme.fontMd
                                    checked: root.sty("fillEnabled", true) !== false
                                    onToggled: root.setAndSave("fillEnabled", checked, "Toggle fill")
                                }
                                S.SCombo {
                                    Layout.fillWidth: true
                                    model: ["solid", "linearGradient", "radialGradient", "texture"]
                                    currentIndex: Math.max(0, model.indexOf(root.sty("fillType", "solid")))
                                    onActivated: root.setAndSave("fillType", model[currentIndex], "Change fill type")
                                }
                            }
                            S.SColorRow {
                                visible: root.sty("fillType", "solid") === "solid"
                                label: "Colour"; value: root.sty("fillColor", "#ffffff")
                                onEdited: function (v) { root.setAndSave("fillColor", v, "Change fill colour"); }
                            }

                            ColumnLayout {
                                visible: {
                                    var t = root.sty("fillType", "solid");
                                    return t === "linearGradient" || t === "radialGradient";
                                }
                                Layout.fillWidth: true
                                spacing: S.Theme.gap

                                S.SColorRow {
                                    label: "Start"; value: root.sty("gradStartColor", "#ffffff")
                                    onEdited: function (v) { root.setAndSave("gradStartColor", v, "Change gradient start"); }
                                }
                                S.SColorRow {
                                    label: "End"; value: root.sty("gradEndColor", "#000000")
                                    onEdited: function (v) { root.setAndSave("gradEndColor", v, "Change gradient end"); }
                                }
                                S.SSliderRow {
                                    visible: root.sty("fillType", "solid") === "linearGradient"
                                    label: "Angle"; from: 0; to: 360; stepSize: 1; decimals: 0; suffix: "°"
                                    value: root.sty("gradAngle", 0)
                                    onMoved: function (v) { root.setLive("gradAngle", v); }
                                    onCommitted: root.saveStyle("Change angle")
                                }
                                S.SComboRow {
                                    label: "Scope"
                                    options: ["fullText", "perLine", "perWord", "perCharacter"]
                                    value: root.sty("gradientScope", "fullText")
                                    onEdited: function (v) { root.setAndSave("gradientScope", v, "Change gradient scope"); }
                                }
                            }

                            ColumnLayout {
                                visible: root.sty("fillType", "solid") === "texture"
                                Layout.fillWidth: true
                                spacing: S.Theme.gap

                                S.SLabel {
                                    Layout.fillWidth: true
                                    dim: true
                                    wrapMode: Text.Wrap
                                    elide: Text.ElideNone
                                    text: "Connect a video or image to the 'Fill Texture' inlet."
                                }
                                S.SSliderRow {
                                    label: "Scale X"; from: 0.1; to: 5; stepSize: 0.05; defaultValue: 1
                                    value: root.sty("texFillScaleX", 1)
                                    onMoved: function (v) { root.setLive("texFillScaleX", v); }
                                    onCommitted: root.saveStyle("Change texture scale")
                                }
                                S.SSliderRow {
                                    label: "Scale Y"; from: 0.1; to: 5; stepSize: 0.05; defaultValue: 1
                                    value: root.sty("texFillScaleY", 1)
                                    onMoved: function (v) { root.setLive("texFillScaleY", v); }
                                    onCommitted: root.saveStyle("Change texture scale")
                                }
                                S.SSliderRow {
                                    label: "Offset X"; from: -1; to: 1; stepSize: 0.01
                                    value: root.sty("texFillOffsetX", 0)
                                    onMoved: function (v) { root.setLive("texFillOffsetX", v); }
                                    onCommitted: root.saveStyle("Change texture offset")
                                }
                                S.SSliderRow {
                                    label: "Offset Y"; from: -1; to: 1; stepSize: 0.01
                                    value: root.sty("texFillOffsetY", 0)
                                    onMoved: function (v) { root.setLive("texFillOffsetY", v); }
                                    onCommitted: root.saveStyle("Change texture offset")
                                }
                            }
                        }

                        // ======================== STROKE ========================
                        S.SSection {
                            title: "Stroke"
                            tip: "Up to three stroke layers, drawn widest first."

                            Repeater {
                                model: [
                                    { n: 1, en: "strokeEnabled",  col: "strokeColor",  w: "strokeWidth",  j: "strokeJoin",  max: 50,  def: 3 },
                                    { n: 2, en: "stroke2Enabled", col: "stroke2Color", w: "stroke2Width", j: "stroke2Join", max: 80,  def: 8 },
                                    { n: 3, en: "stroke3Enabled", col: "stroke3Color", w: "stroke3Width", j: "stroke3Join", max: 100, def: 14 }
                                ]
                                ColumnLayout {
                                    id: strokeLayer
                                    required property var modelData
                                    Layout.fillWidth: true
                                    spacing: S.Theme.gap

                                    S.SSeparator { visible: strokeLayer.modelData.n > 1 }
                                    S.SCheck {
                                        text: "Layer " + strokeLayer.modelData.n
                                        font.pixelSize: S.Theme.fontMd
                                        checked: root.sty(strokeLayer.modelData.en, false)
                                        onToggled: root.setAndSave(strokeLayer.modelData.en, checked,
                                                                   "Toggle stroke " + strokeLayer.modelData.n)
                                    }
                                    S.SColorRow {
                                        label: "Colour"; value: root.sty(strokeLayer.modelData.col, "#000000")
                                        onEdited: function (v) { root.setAndSave(strokeLayer.modelData.col, v, "Change stroke colour"); }
                                    }
                                    S.SSliderRow {
                                        label: "Width"; from: 0.5; to: strokeLayer.modelData.max
                                        stepSize: 0.5; decimals: 1
                                        defaultValue: strokeLayer.modelData.def
                                        value: root.sty(strokeLayer.modelData.w, strokeLayer.modelData.def)
                                        onMoved: function (v) { root.setLive(strokeLayer.modelData.w, v); }
                                        onCommitted: root.saveStyle("Change stroke width")
                                    }
                                    S.SComboRow {
                                        label: "Join"
                                        options: ["round", "bevel", "miter"]
                                        value: root.sty(strokeLayer.modelData.j, "round")
                                        onEdited: function (v) { root.setAndSave(strokeLayer.modelData.j, v, "Change join"); }
                                    }
                                }
                            }
                        }

                        // ====================== BACKGROUND ======================
                        S.SSection {
                            title: "Background"

                            S.SCheck {
                                text: "Enabled"; font.pixelSize: S.Theme.fontMd
                                checked: root.sty("bgEnabled", false)
                                onToggled: root.setAndSave("bgEnabled", checked, "Toggle background")
                            }
                            S.SColorRow {
                                label: "Colour"; value: root.sty("bgColor", "#000000")
                                onEdited: function (v) { root.setAndSave("bgColor", v, "Change background colour"); }
                            }
                            S.SSliderRow {
                                label: "Opacity"; from: 0; to: 1; stepSize: 0.05; defaultValue: 0.5
                                value: root.sty("bgOpacity", 0.5)
                                onMoved: function (v) { root.setLive("bgOpacity", v); }
                                onCommitted: root.saveStyle("Change background opacity")
                            }
                            S.SSliderRow {
                                label: "Pad H"; from: 0; to: 200; stepSize: 1; decimals: 0; defaultValue: 20
                                value: root.sty("bgPaddingH", 20)
                                onMoved: function (v) { root.setLive("bgPaddingH", v); }
                                onCommitted: root.saveStyle("Change padding")
                            }
                            S.SSliderRow {
                                label: "Pad V"; from: 0; to: 200; stepSize: 1; decimals: 0; defaultValue: 10
                                value: root.sty("bgPaddingV", 10)
                                onMoved: function (v) { root.setLive("bgPaddingV", v); }
                                onCommitted: root.saveStyle("Change padding")
                            }
                            S.SSliderRow {
                                label: "Radius"; from: 0; to: 100; stepSize: 1; decimals: 0; defaultValue: 8
                                value: root.sty("bgCornerRadius", 8)
                                onMoved: function (v) { root.setLive("bgCornerRadius", v); }
                                onCommitted: root.saveStyle("Change radius")
                            }
                            S.SComboRow {
                                label: "Scope"
                                options: ["fullText", "perLine"]
                                value: root.sty("bgScope", "fullText")
                                onEdited: function (v) { root.setAndSave("bgScope", v, "Change bg scope"); }
                            }
                            S.SSeparator {}
                            S.SCheck {
                                text: "Border"; font.pixelSize: S.Theme.fontMd
                                checked: root.sty("bgBorderEnabled", false)
                                onToggled: root.setAndSave("bgBorderEnabled", checked, "Toggle bg border")
                            }
                            S.SColorRow {
                                label: "Border colour"; value: root.sty("bgBorderColor", "#ffffff")
                                onEdited: function (v) { root.setAndSave("bgBorderColor", v, "Change border colour"); }
                            }
                            S.SSliderRow {
                                label: "Border width"; from: 0.5; to: 20; stepSize: 0.5; decimals: 1; defaultValue: 1
                                value: root.sty("bgBorderWidth", 1)
                                onMoved: function (v) { root.setLive("bgBorderWidth", v); }
                                onCommitted: root.saveStyle("Change border width")
                            }
                        }

                        // ======================== LAYOUT ========================
                        S.SSection {
                            title: "Layout"

                            S.SComboRow {
                                label: "H align"
                                options: ["left", "center", "right"]
                                value: root.sty("hAlign", "center")
                                onEdited: function (v) { root.setAndSave("hAlign", v, "Change alignment"); }
                            }
                            S.SComboRow {
                                label: "V align"
                                options: ["top", "center", "bottom"]
                                value: root.sty("vAlign", "center")
                                onEdited: function (v) { root.setAndSave("vAlign", v, "Change alignment"); }
                            }
                            S.SCheck {
                                text: "Word wrap"; font.pixelSize: S.Theme.fontMd
                                checked: root.sty("wordWrap", false)
                                onToggled: root.setAndSave("wordWrap", checked, "Toggle word wrap")
                            }
                            S.SSliderRow {
                                visible: root.sty("wordWrap", false)
                                label: "Box width"; from: 0.1; to: 1; stepSize: 0.01; defaultValue: 0.8
                                value: root.sty("boundingBoxW", 0.8)
                                onMoved: function (v) { root.setLive("boundingBoxW", v); }
                                onCommitted: root.saveStyle("Change box width")
                            }
                            S.SSliderRow {
                                label: "Line spacing"; from: 0.5; to: 4; stepSize: 0.05; defaultValue: 1.3
                                value: root.sty("lineSpacing", 1.3)
                                onMoved: function (v) { root.setLive("lineSpacing", v); }
                                onCommitted: root.saveStyle("Change line spacing")
                            }
                            S.SSliderRow {
                                label: "Tracking"; from: -20; to: 50; stepSize: 0.5; decimals: 1
                                value: root.sty("tracking", 0)
                                onMoved: function (v) { root.setLive("tracking", v); }
                                onCommitted: root.saveStyle("Change tracking")
                            }
                        }

                        // ====================== TRANSFORM =======================
                        S.SSection {
                            title: "Transform"

                            S.SSliderRow {
                                label: "Pos X"; from: 0; to: 1; stepSize: 0.005; decimals: 3; defaultValue: 0.5
                                value: root.sty("posX", 0.5)
                                onMoved: function (v) { root.setLive("posX", v); }
                                onCommitted: root.saveStyle("Change position")
                            }
                            S.SSliderRow {
                                label: "Pos Y"; from: 0; to: 1; stepSize: 0.005; decimals: 3; defaultValue: 0.5
                                value: root.sty("posY", 0.5)
                                onMoved: function (v) { root.setLive("posY", v); }
                                onCommitted: root.saveStyle("Change position")
                            }
                            S.SSliderRow {
                                label: "Rotation"; from: -360; to: 360; stepSize: 1; decimals: 0; suffix: "°"
                                value: root.sty("rotation", 0)
                                onMoved: function (v) { root.setLive("rotation", v); }
                                onCommitted: root.saveStyle("Change rotation")
                            }
                            S.SSliderRow {
                                label: "Scale X"; from: 0.1; to: 5; stepSize: 0.05; defaultValue: 1
                                value: root.sty("scaleX", 1)
                                onMoved: function (v) { root.setLive("scaleX", v); }
                                onCommitted: root.saveStyle("Change scale")
                            }
                            S.SSliderRow {
                                label: "Scale Y"; from: 0.1; to: 5; stepSize: 0.05; defaultValue: 1
                                value: root.sty("scaleY", 1)
                                onMoved: function (v) { root.setLive("scaleY", v); }
                                onCommitted: root.saveStyle("Change scale")
                            }
                            S.SSliderRow {
                                label: "Skew X"; from: -60; to: 60; stepSize: 1; decimals: 0; suffix: "°"
                                value: root.sty("skewX", 0)
                                onMoved: function (v) { root.setLive("skewX", v); }
                                onCommitted: root.saveStyle("Change skew")
                            }
                            S.SSliderRow {
                                label: "Skew Y"; from: -60; to: 60; stepSize: 1; decimals: 0; suffix: "°"
                                value: root.sty("skewY", 0)
                                onMoved: function (v) { root.setLive("skewY", v); }
                                onCommitted: root.saveStyle("Change skew")
                            }
                            S.SComboRow {
                                label: "Anchor H"
                                options: ["left", "center", "right"]
                                value: root.sty("anchorH", "center")
                                onEdited: function (v) { root.setAndSave("anchorH", v, "Change anchor"); }
                            }
                            S.SComboRow {
                                label: "Anchor V"
                                options: ["top", "center", "bottom"]
                                value: root.sty("anchorV", "center")
                                onEdited: function (v) { root.setAndSave("anchorV", v, "Change anchor"); }
                            }
                            S.SSliderRow {
                                label: "Opacity"; from: 0; to: 1; stepSize: 0.01; defaultValue: 1
                                value: root.sty("opacity", 1)
                                onMoved: function (v) { root.setLive("opacity", v); }
                                onCommitted: root.saveStyle("Change opacity")
                            }
                        }

                        // ======================= WRITE-ON =======================
                        S.SSection {
                            title: "Write-on"
                            expanded: false

                            S.SComboRow {
                                label: "Mode"
                                options: ["typewriter", "fade", "scale", "slide", "scramble"]
                                value: root.sty("writeOnMode", "typewriter")
                                onEdited: function (v) { root.setAndSave("writeOnMode", v, "Change write-on mode"); }
                            }
                            S.SComboRow {
                                label: "Direction"
                                options: ["forward", "reverse", "fromCenter", "random"]
                                value: root.sty("writeOnDirection", "forward")
                                onEdited: function (v) { root.setAndSave("writeOnDirection", v, "Change write-on direction"); }
                            }
                            S.SComboRow {
                                label: "Scope"
                                options: ["character", "word", "line"]
                                value: root.sty("writeOnScope", "character")
                                onEdited: function (v) { root.setAndSave("writeOnScope", v, "Change write-on scope"); }
                            }
                            S.SSliderRow {
                                label: "Overlap"; from: 1; to: 50; stepSize: 1; decimals: 0; defaultValue: 5
                                value: root.sty("writeOnOverlap", 5)
                                onMoved: function (v) { root.setLive("writeOnOverlap", v); }
                                onCommitted: root.saveStyle("Change overlap")
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: S.Theme.gapLg
                                S.SCheck {
                                    text: "Cursor"; font.pixelSize: S.Theme.fontMd
                                    checked: root.sty("writeOnCursor", false)
                                    onToggled: root.setAndSave("writeOnCursor", checked, "Toggle cursor")
                                }
                                S.STextField {
                                    Layout.preferredWidth: 44
                                    horizontalAlignment: Text.AlignHCenter
                                    text: root.sty("writeOnCursorChar", "▌")
                                    onEditingFinished: root.setAndSave("writeOnCursorChar", text, "Change cursor char")
                                }
                                Item { Layout.fillWidth: true }
                            }
                        }

                        // ====================== SCROLLING =======================
                        S.SSection {
                            title: "Scrolling"
                            expanded: false

                            S.SComboRow {
                                label: "Mode"
                                options: ["none", "up", "down", "left", "right"]
                                value: root.sty("scrollMode", "none")
                                onEdited: function (v) { root.setAndSave("scrollMode", v, "Change scroll mode"); }
                            }
                            S.SSliderRow {
                                label: "Speed"; from: 1; to: 1000; stepSize: 1; decimals: 0; suffix: " px/s"
                                defaultValue: 50
                                value: root.sty("scrollSpeed", 50)
                                onMoved: function (v) { root.setLive("scrollSpeed", v); }
                                onCommitted: root.saveStyle("Change scroll speed")
                            }
                            S.SCheck {
                                text: "Loop"; font.pixelSize: S.Theme.fontMd
                                checked: root.sty("scrollLoop", true) !== false
                                onToggled: root.setAndSave("scrollLoop", checked, "Toggle scroll loop")
                            }
                            S.SSliderRow {
                                label: "Fade edge"; from: 0; to: 0.5; stepSize: 0.01; defaultValue: 0.1
                                value: root.sty("scrollFadeEdges", 0.1)
                                onMoved: function (v) { root.setLive("scrollFadeEdges", v); }
                                onCommitted: root.saveStyle("Change fade")
                            }
                        }

                        // ======================== WAVE ==========================
                        S.SSection {
                            title: "Wave animation"
                            expanded: false

                            S.SCheck {
                                text: "Enabled"; font.pixelSize: S.Theme.fontMd
                                checked: root.sty("charWaveEnabled", false)
                                onToggled: root.setAndSave("charWaveEnabled", checked, "Toggle wave")
                            }
                            S.SSliderRow {
                                label: "Amplitude"; from: 1; to: 100; stepSize: 1; decimals: 0; defaultValue: 10
                                value: root.sty("charWaveAmplitude", 10)
                                onMoved: function (v) { root.setLive("charWaveAmplitude", v); }
                                onCommitted: root.saveStyle("Change amplitude")
                            }
                            S.SSliderRow {
                                label: "Frequency"; from: 0.1; to: 20; stepSize: 0.1; decimals: 1; suffix: " Hz"
                                defaultValue: 2
                                value: root.sty("charWaveFrequency", 2)
                                onMoved: function (v) { root.setLive("charWaveFrequency", v); }
                                onCommitted: root.saveStyle("Change frequency")
                            }
                            S.SComboRow {
                                label: "Property"
                                options: ["posY", "posX", "rotation", "scale", "opacity"]
                                value: root.sty("charWaveProperty", "posY")
                                onEdited: function (v) { root.setAndSave("charWaveProperty", v, "Change wave property"); }
                            }
                        }

                        // =================== CHAR ANIMATION =====================
                        S.SSection {
                            title: "Char animation"
                            expanded: false
                            tip: "Resolume-style per-character cascade."

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: S.Theme.gapLg
                                S.SCheck {
                                    text: "Enabled"; font.pixelSize: S.Theme.fontMd
                                    checked: root.sty("charAnimEnabled", false)
                                    onToggled: root.setAndSave("charAnimEnabled", checked, "Toggle char anim")
                                }
                                Item { Layout.fillWidth: true }
                                S.SButton {
                                    text: "Retrigger"
                                    implicitHeight: S.Theme.rowH
                                    onClicked: root.executionSend({ type: "retrigger" })
                                }
                            }
                            S.SComboRow {
                                label: "Scope"
                                options: ["character", "word", "line"]
                                value: root.sty("charAnimScope", "character")
                                onEdited: function (v) { root.setAndSave("charAnimScope", v, "Change anim scope"); }
                            }
                            S.SComboRow {
                                label: "Order"
                                options: ["forward", "reverse", "random", "fromCenter", "toCenter"]
                                value: root.sty("charAnimOrder", "forward")
                                onEdited: function (v) { root.setAndSave("charAnimOrder", v, "Change anim order"); }
                            }
                            S.SSliderRow {
                                label: "Delay"; from: 0.01; to: 2; stepSize: 0.01; suffix: " s"; defaultValue: 0.1
                                value: root.sty("charAnimDelay", 0.1)
                                onMoved: function (v) { root.setLive("charAnimDelay", v); }
                                onCommitted: root.saveStyle("Change delay")
                            }
                            S.SSliderRow {
                                label: "Seed"; from: 1; to: 999; stepSize: 1; decimals: 0; defaultValue: 42
                                value: root.sty("charAnimRandomSeed", 42)
                                onMoved: function (v) { root.setLive("charAnimRandomSeed", v); }
                                onCommitted: root.saveStyle("Change seed")
                            }

                            S.SSeparator {}
                            S.SSectionLabel { text: "Offsets" }

                            S.SSliderRow {
                                label: "Pos X"; from: -500; to: 500; stepSize: 1; decimals: 0
                                value: root.sty("charAnimPosX", 0)
                                onMoved: function (v) { root.setLive("charAnimPosX", v); }
                                onCommitted: root.saveStyle("Change offset")
                            }
                            S.SSliderRow {
                                label: "Pos Y"; from: -500; to: 500; stepSize: 1; decimals: 0
                                value: root.sty("charAnimPosY", 0)
                                onMoved: function (v) { root.setLive("charAnimPosY", v); }
                                onCommitted: root.saveStyle("Change offset")
                            }
                            S.SSliderRow {
                                label: "Rotation"; from: -360; to: 360; stepSize: 1; decimals: 0; suffix: "°"
                                value: root.sty("charAnimRotation", 0)
                                onMoved: function (v) { root.setLive("charAnimRotation", v); }
                                onCommitted: root.saveStyle("Change rotation")
                            }
                            S.SSliderRow {
                                label: "Scale"; from: 0; to: 5; stepSize: 0.05; defaultValue: 1
                                value: root.sty("charAnimScale", 1)
                                onMoved: function (v) { root.setLive("charAnimScale", v); }
                                onCommitted: root.saveStyle("Change scale")
                            }
                            S.SSliderRow {
                                label: "Opacity"; from: 0; to: 1; stepSize: 0.01; defaultValue: 1
                                value: root.sty("charAnimOpacity", 1)
                                onMoved: function (v) { root.setLive("charAnimOpacity", v); }
                                onCommitted: root.saveStyle("Change opacity")
                            }
                            S.SColorRow {
                                label: "Fill colour"; value: root.sty("charAnimFillColor", "#ffffff")
                                onEdited: function (v) { root.setAndSave("charAnimFillColor", v, "Change anim colour"); }
                            }
                            S.SSliderRow {
                                label: "Char offset"; from: -50; to: 50; stepSize: 1; decimals: 0
                                value: root.sty("charAnimCharOffset", 0)
                                onMoved: function (v) { root.setLive("charAnimCharOffset", v); }
                                onCommitted: root.saveStyle("Change char offset")
                            }
                        }

                        Item { Layout.fillHeight: true; Layout.minimumHeight: S.Theme.pad }
                    }
                }
            }

            S.SStatusBar {
                hint: "Advanced Text — double-click a slider to reset it"
                detail: root.renderWidth > 0
                        ? (Math.round(root.renderWidth) + "×" + Math.round(root.renderHeight))
                        : ""
            }
        }
    }
}
