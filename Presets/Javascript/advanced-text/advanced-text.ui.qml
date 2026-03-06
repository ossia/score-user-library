import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "TextRender.js" as TextRender

Score.ScriptUI {
    id: root
    anchors.fill: parent

    property var style: TextRender.defaultState()
    property int stateVersion: 0
    property real renderWidth: 0
    property real renderHeight: 0

    function sendLive() {
        root.executionSend({ type: "updateStyle", style: root.style });
    }
    function saveStyle(action) {
        root.beginUpdateState(action || "Edit text");
        root.updateState("textState", JSON.stringify(root.style));
        root.endUpdateState();
    }
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

    component Hdr: Rectangle {
        property string title
        property bool on: true
        width: parent ? parent.width : 100; height: 22
        color: on ? "#404040" : "#363636"
        Text {
            anchors { left: parent.left; leftMargin: 6; verticalCenter: parent.verticalCenter }
            text: (parent.on ? "\u25be " : "\u25b8 ") + parent.title
            color: "#ddd"; font.pixelSize: 11; font.bold: true
        }
        MouseArea { anchors.fill: parent; onClicked: parent.on = !parent.on }
    }

    component Lbl: Text {
        Layout.preferredWidth: 65; color: "#bbb"; font.pixelSize: 11
        elide: Text.ElideRight
    }

    component Val: Text {
        Layout.preferredWidth: 32; color: "#ddd"; font.pixelSize: 10
        horizontalAlignment: Text.AlignRight
    }

    component ColorRow: RowLayout {
        property string label
        property string key
        spacing: 4
        Lbl { text: label }
        Rectangle {
            width: 18; height: 18
            color: (root.stateVersion, root.style[key] || "#000")
            border.color: "#666"; border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colorDialog.targetKey = key;
                    colorDialog.targetLabel = label;
                    colorDialog.selectedColor = parent.color;
                    colorDialog.open();
                }
            }
        }
        TextField {
            Layout.fillWidth: true; Layout.preferredHeight: 22
            text: (root.stateVersion, root.style[key] || "#000000")
            font.pixelSize: 10; color: "#eee"
            verticalAlignment: Text.AlignVCenter
            background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
            onEditingFinished: root.setAndSave(key, text, "Change " + label.toLowerCase())
        }
    }

    component SliderRow: RowLayout {
        property string label
        property string key
        property real lo: 0
        property real hi: 1
        property real step: 0.01
        property int decimals: 2
        property string suffix: ""
        property real fallback: 0
        spacing: 4
        Lbl { text: label }
        Slider {
            Layout.fillWidth: true
            from: lo; to: hi; stepSize: step
            value: (root.stateVersion, root.style[key] !== undefined ? root.style[key] : fallback)
            onMoved: root.setLive(key, value)
            onPressedChanged: if (!pressed) root.saveStyle("Change " + label.toLowerCase())
        }
        Val {
            property real v: (root.stateVersion, root.style[key] !== undefined ? root.style[key] : fallback)
            text: (decimals > 0 ? v.toFixed(decimals) : Math.round(v)) + suffix
        }
    }

    ColorDialog {
        id: colorDialog
        property string targetKey: ""
        property string targetLabel: ""
        onAccepted: root.setAndSave(targetKey, selectedColor.toString(), "Change " + targetLabel.toLowerCase())
    }

    Pane {
        anchors.fill: parent
        padding: 0
        palette {
            window: "#222222"
            base: "#161514"
            alternateBase: "#1e1d1c"
            highlight: "#62400a"
            highlightedText: "#FDFDFD"
            windowText: "silver"
            text: "#d0d0d0"
            button: "#1d1c1a"
            buttonText: "#f0f0f0"
            toolTipBase: "#161514"
            toolTipText: "silver"
            midlight: "#62400a"
            light: "#c58014"
            mid: "#252930"
        }
    ScrollView {
        id: sv
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: sv.availableWidth
            spacing: 0

            // ======== CONTENT ========
            Hdr { id: hC; title: "Content"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hC.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                TextArea {
                    Layout.fillWidth: true; Layout.preferredHeight: 70
                    text: (root.stateVersion, root.style.text)
                    wrapMode: TextEdit.Wrap; font.pixelSize: 12; color: "#eee"
                    placeholderText: "Enter text..."
                    background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
                    onTextChanged: {
                        if (root.style.text !== text) { root.style.text = text; root.sendLive(); }
                    }
                    onFocusChanged: if (!focus) root.saveStyle("Edit text")
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Transform" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["none", "uppercase", "lowercase", "titlecase"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["none","uppercase","lowercase","titlecase"].indexOf(root.style.textTransform)); }
                        onActivated: root.setAndSave("textTransform", model[currentIndex], "Change transform")
                    }
                }
            }

            // ======== FONT ========
            Hdr { id: hF; title: "Font"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hF.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "Family" }
                    ComboBox {
                        id: fontCombo
                        Layout.fillWidth: true
                        editable: true
                        model: Qt.fontFamilies()
                        currentIndex: { root.stateVersion; return model.indexOf(root.style.fontFamily); }
                        onActivated: root.setAndSave("fontFamily", currentText, "Change font")
                        onAccepted: root.setAndSave("fontFamily", editText, "Change font")
                    }
                }
                SliderRow { label: "Size"; key: "fontSize"; lo: 4; hi: 500; step: 1; decimals: 0; fallback: 72; suffix: "px" }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Weight" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["normal", "bold"]
                        currentIndex: (root.stateVersion, root.style.fontWeight === "bold" ? 1 : 0)
                        onActivated: root.setAndSave("fontWeight", model[currentIndex], "Change weight")
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Style" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["normal", "italic"]
                        currentIndex: (root.stateVersion, root.style.fontStyle === "italic" ? 1 : 0)
                        onActivated: root.setAndSave("fontStyle", model[currentIndex], "Change style")
                    }
                }
                RowLayout {
                    spacing: 8
                    CheckBox {
                        text: "Underline"; font.pixelSize: 11
                        checked: (root.stateVersion, root.style.underline || false)
                        onToggled: root.setAndSave("underline", checked, "Toggle underline")
                    }
                    CheckBox {
                        text: "Strike"; font.pixelSize: 11
                        checked: (root.stateVersion, root.style.strikethrough || false)
                        onToggled: root.setAndSave("strikethrough", checked, "Toggle strikethrough")
                    }
                }
            }

            // ======== FILL ========
            Hdr { id: hFi; title: "Fill"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hFi.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    CheckBox {
                        text: "Enabled"; font.pixelSize: 11
                        checked: (root.stateVersion, root.style.fillEnabled !== false)
                        onToggled: root.setAndSave("fillEnabled", checked, "Toggle fill")
                    }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["solid", "linearGradient", "radialGradient", "texture"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["solid","linearGradient","radialGradient","texture"].indexOf(root.style.fillType)); }
                        onActivated: root.setAndSave("fillType", model[currentIndex], "Change fill type")
                    }
                }
                ColorRow {
                    visible: (root.stateVersion, !root.style.fillType || root.style.fillType === "solid")
                    Layout.fillWidth: true; label: "Color"; key: "fillColor"
                }
                ColumnLayout {
                    visible: (root.stateVersion, root.style.fillType === "linearGradient" || root.style.fillType === "radialGradient")
                    Layout.fillWidth: true; spacing: 4
                    ColorRow { Layout.fillWidth: true; label: "Start"; key: "gradStartColor" }
                    ColorRow { Layout.fillWidth: true; label: "End"; key: "gradEndColor" }
                    SliderRow {
                        visible: (root.stateVersion, root.style.fillType === "linearGradient")
                        Layout.fillWidth: true; label: "Angle"; key: "gradAngle"
                        lo: 0; hi: 360; step: 1; decimals: 0; suffix: "\u00b0"
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Scope" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["fullText", "perLine", "perWord", "perCharacter"]
                            currentIndex: { root.stateVersion; return Math.max(0, ["fullText","perLine","perWord","perCharacter"].indexOf(root.style.gradientScope)); }
                            onActivated: root.setAndSave("gradientScope", model[currentIndex], "Change gradient scope")
                        }
                    }
                }
                ColumnLayout {
                    visible: (root.stateVersion, root.style.fillType === "texture")
                    Layout.fillWidth: true; spacing: 4
                    Lbl { text: "Connect a video/image to the 'Fill Texture' inlet"; wrapMode: Text.Wrap; Layout.fillWidth: true }
                    SliderRow { label: "Scale X"; key: "texFillScaleX"; lo: 0.1; hi: 5; step: 0.05; decimals: 2; fallback: 1 }
                    SliderRow { label: "Scale Y"; key: "texFillScaleY"; lo: 0.1; hi: 5; step: 0.05; decimals: 2; fallback: 1 }
                    SliderRow { label: "Offset X"; key: "texFillOffsetX"; lo: -1; hi: 1; step: 0.01; decimals: 2 }
                    SliderRow { label: "Offset Y"; key: "texFillOffsetY"; lo: -1; hi: 1; step: 0.01; decimals: 2 }
                }
            }

            // ======== STROKE (up to 3 layers) ========
            Hdr { id: hS; title: "Stroke"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hS.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                // Layer 1
                CheckBox {
                    text: "Layer 1"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.strokeEnabled || false)
                    onToggled: root.setAndSave("strokeEnabled", checked, "Toggle stroke 1")
                }
                ColorRow { Layout.fillWidth: true; label: "Color"; key: "strokeColor" }
                SliderRow { label: "Width"; key: "strokeWidth"; lo: 0.5; hi: 50; step: 0.5; decimals: 1; fallback: 3 }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Join" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["round", "bevel", "miter"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["round","bevel","miter"].indexOf(root.style.strokeJoin)); }
                        onActivated: root.setAndSave("strokeJoin", model[currentIndex], "Change join")
                    }
                }
                // Layer 2
                Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 4 }
                CheckBox {
                    text: "Layer 2"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.stroke2Enabled || false)
                    onToggled: root.setAndSave("stroke2Enabled", checked, "Toggle stroke 2")
                }
                ColorRow { Layout.fillWidth: true; label: "Color 2"; key: "stroke2Color" }
                SliderRow { label: "Width 2"; key: "stroke2Width"; lo: 0.5; hi: 80; step: 0.5; decimals: 1; fallback: 8 }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Join 2" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["round", "bevel", "miter"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["round","bevel","miter"].indexOf(root.style.stroke2Join)); }
                        onActivated: root.setAndSave("stroke2Join", model[currentIndex], "Change join 2")
                    }
                }
                // Layer 3
                Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 4 }
                CheckBox {
                    text: "Layer 3"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.stroke3Enabled || false)
                    onToggled: root.setAndSave("stroke3Enabled", checked, "Toggle stroke 3")
                }
                ColorRow { Layout.fillWidth: true; label: "Color 3"; key: "stroke3Color" }
                SliderRow { label: "Width 3"; key: "stroke3Width"; lo: 0.5; hi: 100; step: 0.5; decimals: 1; fallback: 14 }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Join 3" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["round", "bevel", "miter"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["round","bevel","miter"].indexOf(root.style.stroke3Join)); }
                        onActivated: root.setAndSave("stroke3Join", model[currentIndex], "Change join 3")
                    }
                }
            }

            // ======== SHADOW (up to 2 layers) — disabled: Canvas shadow is too slow ========
            Hdr { id: hSh; title: "Shadow (slow)"; Layout.fillWidth: true; visible: false }
            ColumnLayout {
                visible: hSh.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                // Layer 1
                CheckBox {
                    text: "Layer 1"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.shadowEnabled || false)
                    onToggled: root.setAndSave("shadowEnabled", checked, "Toggle shadow 1")
                }
                ColorRow { Layout.fillWidth: true; label: "Color"; key: "shadowColor" }
                SliderRow { label: "Offset X"; key: "shadowOffsetX"; lo: -100; hi: 100; step: 1; decimals: 0; fallback: 4 }
                SliderRow { label: "Offset Y"; key: "shadowOffsetY"; lo: -100; hi: 100; step: 1; decimals: 0; fallback: 4 }
                SliderRow { label: "Blur"; key: "shadowBlur"; lo: 0; hi: 100; step: 1; decimals: 0; fallback: 10 }
                SliderRow { label: "Opacity"; key: "shadowOpacity"; lo: 0; hi: 1; step: 0.05; decimals: 2; fallback: 0.7 }
                // Layer 2
                Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 4 }
                CheckBox {
                    text: "Layer 2"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.shadow2Enabled || false)
                    onToggled: root.setAndSave("shadow2Enabled", checked, "Toggle shadow 2")
                }
                ColorRow { Layout.fillWidth: true; label: "Color 2"; key: "shadow2Color" }
                SliderRow { label: "Offset X 2"; key: "shadow2OffsetX"; lo: -200; hi: 200; step: 1; decimals: 0; fallback: 8 }
                SliderRow { label: "Offset Y 2"; key: "shadow2OffsetY"; lo: -200; hi: 200; step: 1; decimals: 0; fallback: 8 }
                SliderRow { label: "Blur 2"; key: "shadow2Blur"; lo: 0; hi: 200; step: 1; decimals: 0; fallback: 20 }
                SliderRow { label: "Opacity 2"; key: "shadow2Opacity"; lo: 0; hi: 1; step: 0.05; decimals: 2; fallback: 0.5 }
            }

            // ======== BACKGROUND ========
            Hdr { id: hB; title: "Background"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hB.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                CheckBox {
                    text: "Enabled"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.bgEnabled || false)
                    onToggled: root.setAndSave("bgEnabled", checked, "Toggle background")
                }
                ColorRow { Layout.fillWidth: true; label: "Color"; key: "bgColor" }
                SliderRow { label: "Opacity"; key: "bgOpacity"; lo: 0; hi: 1; step: 0.05; decimals: 2; fallback: 0.5 }
                SliderRow { label: "Pad H"; key: "bgPaddingH"; lo: 0; hi: 200; step: 1; decimals: 0; fallback: 20 }
                SliderRow { label: "Pad V"; key: "bgPaddingV"; lo: 0; hi: 200; step: 1; decimals: 0; fallback: 10 }
                SliderRow { label: "Radius"; key: "bgCornerRadius"; lo: 0; hi: 100; step: 1; decimals: 0; fallback: 8 }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Scope" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["fullText", "perLine"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["fullText","perLine"].indexOf(root.style.bgScope)); }
                        onActivated: root.setAndSave("bgScope", model[currentIndex], "Change bg scope")
                    }
                }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 2 }
                CheckBox {
                    text: "Border"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.bgBorderEnabled || false)
                    onToggled: root.setAndSave("bgBorderEnabled", checked, "Toggle bg border")
                }
                ColorRow { Layout.fillWidth: true; label: "Border Color"; key: "bgBorderColor" }
                SliderRow { label: "Border W"; key: "bgBorderWidth"; lo: 0.5; hi: 20; step: 0.5; decimals: 1; fallback: 1 }
            }

            // ======== LAYOUT ========
            Hdr { id: hL; title: "Layout"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hL.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "H Align" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["left", "center", "right"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["left","center","right"].indexOf(root.style.hAlign)); }
                        onActivated: root.setAndSave("hAlign", model[currentIndex], "Change alignment")
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "V Align" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["top", "center", "bottom"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["top","center","bottom"].indexOf(root.style.vAlign)); }
                        onActivated: root.setAndSave("vAlign", model[currentIndex], "Change alignment")
                    }
                }
                CheckBox {
                    text: "Word Wrap"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.wordWrap || false)
                    onToggled: root.setAndSave("wordWrap", checked, "Toggle word wrap")
                }
                SliderRow {
                    visible: (root.stateVersion, root.style.wordWrap || false)
                    label: "Box W"; key: "boundingBoxW"; lo: 0.1; hi: 1; step: 0.01; decimals: 2; fallback: 0.8
                }
                SliderRow { label: "Line Sp."; key: "lineSpacing"; lo: 0.5; hi: 4; step: 0.05; decimals: 2; fallback: 1.3 }
                SliderRow { label: "Tracking"; key: "tracking"; lo: -20; hi: 50; step: 0.5; decimals: 1 }
            }

            // ======== TRANSFORM ========
            Hdr { id: hT; title: "Transform"; Layout.fillWidth: true }
            ColumnLayout {
                visible: hT.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                SliderRow { label: "Pos X"; key: "posX"; lo: 0; hi: 1; step: 0.005; decimals: 3; fallback: 0.5 }
                SliderRow { label: "Pos Y"; key: "posY"; lo: 0; hi: 1; step: 0.005; decimals: 3; fallback: 0.5 }
                SliderRow { label: "Rotation"; key: "rotation"; lo: -360; hi: 360; step: 1; decimals: 0; suffix: "\u00b0" }
                SliderRow { label: "Scale X"; key: "scaleX"; lo: 0.1; hi: 5; step: 0.05; decimals: 2; fallback: 1 }
                SliderRow { label: "Scale Y"; key: "scaleY"; lo: 0.1; hi: 5; step: 0.05; decimals: 2; fallback: 1 }
                SliderRow { label: "Skew X"; key: "skewX"; lo: -60; hi: 60; step: 1; decimals: 0; suffix: "\u00b0" }
                SliderRow { label: "Skew Y"; key: "skewY"; lo: -60; hi: 60; step: 1; decimals: 0; suffix: "\u00b0" }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Anchor H" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["left", "center", "right"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["left","center","right"].indexOf(root.style.anchorH)); }
                        onActivated: root.setAndSave("anchorH", model[currentIndex], "Change anchor")
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Anchor V" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["top", "center", "bottom"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["top","center","bottom"].indexOf(root.style.anchorV)); }
                        onActivated: root.setAndSave("anchorV", model[currentIndex], "Change anchor")
                    }
                }
                SliderRow { label: "Opacity"; key: "opacity"; lo: 0; hi: 1; step: 0.01; decimals: 2; fallback: 1 }
            }

            // ======== WRITE-ON ========
            Hdr { id: hWo; title: "Write-On"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hWo.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "Mode" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["typewriter", "fade", "scale", "slide", "scramble"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["typewriter","fade","scale","slide","scramble"].indexOf(root.style.writeOnMode)); }
                        onActivated: root.setAndSave("writeOnMode", model[currentIndex], "Change write-on mode")
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Direction" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["forward", "reverse", "fromCenter", "random"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["forward","reverse","fromCenter","random"].indexOf(root.style.writeOnDirection)); }
                        onActivated: root.setAndSave("writeOnDirection", model[currentIndex], "Change write-on direction")
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Scope" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["character", "word", "line"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["character","word","line"].indexOf(root.style.writeOnScope)); }
                        onActivated: root.setAndSave("writeOnScope", model[currentIndex], "Change write-on scope")
                    }
                }
                SliderRow { label: "Overlap"; key: "writeOnOverlap"; lo: 1; hi: 50; step: 1; decimals: 0; fallback: 5 }
                RowLayout {
                    spacing: 8
                    CheckBox {
                        text: "Cursor"; font.pixelSize: 11
                        checked: (root.stateVersion, root.style.writeOnCursor || false)
                        onToggled: root.setAndSave("writeOnCursor", checked, "Toggle cursor")
                    }
                    TextField {
                        Layout.preferredWidth: 40; Layout.preferredHeight: 22
                        text: (root.stateVersion, root.style.writeOnCursorChar || "\u258c")
                        font.pixelSize: 11; color: "#eee"
                        horizontalAlignment: Text.AlignHCenter
                        background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
                        onEditingFinished: root.setAndSave("writeOnCursorChar", text, "Change cursor char")
                    }
                }
            }

            // ======== SCROLLING ========
            Hdr { id: hSc; title: "Scrolling"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hSc.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "Mode" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["none", "up", "down", "left", "right"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["none","up","down","left","right"].indexOf(root.style.scrollMode)); }
                        onActivated: root.setAndSave("scrollMode", model[currentIndex], "Change scroll mode")
                    }
                }
                SliderRow { label: "Speed"; key: "scrollSpeed"; lo: 1; hi: 1000; step: 1; decimals: 0; fallback: 50; suffix: "px/s" }
                CheckBox {
                    text: "Loop"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.scrollLoop !== false)
                    onToggled: root.setAndSave("scrollLoop", checked, "Toggle scroll loop")
                }
                SliderRow { label: "Fade Edge"; key: "scrollFadeEdges"; lo: 0; hi: 0.5; step: 0.01; decimals: 2; fallback: 0.1 }
            }

            // ======== WAVE ANIMATION ========
            Hdr { id: hWv; title: "Wave Animation"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hWv.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                CheckBox {
                    text: "Enabled"; font.pixelSize: 11
                    checked: (root.stateVersion, root.style.charWaveEnabled || false)
                    onToggled: root.setAndSave("charWaveEnabled", checked, "Toggle wave")
                }
                SliderRow { label: "Amplitude"; key: "charWaveAmplitude"; lo: 1; hi: 100; step: 1; decimals: 0; fallback: 10 }
                SliderRow { label: "Frequency"; key: "charWaveFrequency"; lo: 0.1; hi: 20; step: 0.1; decimals: 1; fallback: 2; suffix: "Hz" }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Property" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["posY", "posX", "rotation", "scale", "opacity"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["posY","posX","rotation","scale","opacity"].indexOf(root.style.charWaveProperty)); }
                        onActivated: root.setAndSave("charWaveProperty", model[currentIndex], "Change wave property")
                    }
                }
            }

            // ======== PER-CHARACTER ANIMATION (Resolume-style cascade) ========
            Hdr { id: hCa; title: "Char Animation"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hCa.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 8
                    CheckBox {
                        text: "Enabled"; font.pixelSize: 11
                        checked: (root.stateVersion, root.style.charAnimEnabled || false)
                        onToggled: root.setAndSave("charAnimEnabled", checked, "Toggle char anim")
                    }
                    Button {
                        text: "Retrigger"
                        font.pixelSize: 10
                        Layout.preferredHeight: 22
                        onClicked: root.executionSend({ type: "retrigger" })
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Scope" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["character", "word", "line"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["character","word","line"].indexOf(root.style.charAnimScope)); }
                        onActivated: root.setAndSave("charAnimScope", model[currentIndex], "Change anim scope")
                    }
                }
                RowLayout {
                    spacing: 4
                    Lbl { text: "Order" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["forward", "reverse", "random", "fromCenter", "toCenter"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["forward","reverse","random","fromCenter","toCenter"].indexOf(root.style.charAnimOrder)); }
                        onActivated: root.setAndSave("charAnimOrder", model[currentIndex], "Change anim order")
                    }
                }
                SliderRow { label: "Delay"; key: "charAnimDelay"; lo: 0.01; hi: 2; step: 0.01; decimals: 2; fallback: 0.1; suffix: "s" }
                SliderRow { label: "Seed"; key: "charAnimRandomSeed"; lo: 1; hi: 999; step: 1; decimals: 0; fallback: 42 }
                Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 2 }
                Lbl { text: "Offsets"; font.bold: true }
                SliderRow { label: "Pos X"; key: "charAnimPosX"; lo: -500; hi: 500; step: 1; decimals: 0 }
                SliderRow { label: "Pos Y"; key: "charAnimPosY"; lo: -500; hi: 500; step: 1; decimals: 0 }
                SliderRow { label: "Rotation"; key: "charAnimRotation"; lo: -360; hi: 360; step: 1; decimals: 0; suffix: "\u00b0" }
                SliderRow { label: "Scale"; key: "charAnimScale"; lo: 0; hi: 5; step: 0.05; decimals: 2; fallback: 1 }
                SliderRow { label: "Opacity"; key: "charAnimOpacity"; lo: 0; hi: 1; step: 0.01; decimals: 2; fallback: 1 }
                ColorRow { Layout.fillWidth: true; label: "Fill Color"; key: "charAnimFillColor" }
                SliderRow { label: "Char Offset"; key: "charAnimCharOffset"; lo: -50; hi: 50; step: 1; decimals: 0 }
            }

            Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
        }
    }
    }
}
