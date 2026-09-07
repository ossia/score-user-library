import Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OssiaUI as S
import "PaintModel.js" as Model

ScriptUI {
    id: root
    anchors.fill: parent
    implicitWidth: 1200
    implicitHeight: 800
    property var doc: Model.defaults()
    property int revision: 0
    property string serialized: ""
    property var pendingCommits: []
    property string status: ""
    property bool alive: true
    Component.onDestruction: alive = false
    readonly property var config: {
        revision;
        return {
            tool: doc.config.tool,
            color: doc.config.color,
            width: doc.config.width,
            opacity: doc.config.opacity,
            filled: doc.config.filled,
            feather: doc.config.feather
        };
    }

    function apply(value) {
        if (value === serialized)
            return;
        try {
            doc = value ? Model.parse(value) : Model.defaults();
            serialized = value || JSON.stringify(doc);
            revision++;
            view.load(doc);
            status = "";
        } catch (error) {
            status = "Cannot load paint document: " + error;
        }
    }
    function sendLive() {
        root.executionSend({
            type: "document",
            doc: serialized
        });
    }
    function commit(label, reload) {
        serialized = JSON.stringify(doc);
        revision++;
        if (reload)
            view.load(doc);
        pendingCommits.push(serialized);
        root.beginUpdateState(label);
        root.updateState("paintDoc", serialized);
        root.endUpdateState();
        sendLive();
    }
    function setConfig(key, value) {
        if (config[key] === value || view.drawing)
            return;
        doc.config[key] = value;
        commit("Change paint " + key, false);
    }
    function previewConfig(key, value) {
        doc.config[key] = value;
        revision++;
        root.executionSend({
            type: "config",
            config: doc.config
        });
    }
    function setTool(tool, filled) {
        if (view.drawing)
            return;
        var shape = tool === "rectangle" || tool === "ellipse";
        if (config.tool === tool && (!shape || config.filled === filled))
            return;
        doc.config.tool = tool;
        if (shape)
            doc.config.filled = filled;
        commit("Change paint tool", false);
    }
    function setPaletteColor(index, color) {
        if (view.drawing || index < 0 || index >= doc.palette.length || !color)
            return;
        var value = color.toString();
        if (doc.palette[index] === value)
            return;
        doc.palette[index] = value;
        commit("Change paint palette", false);
    }
    function chooseColor(slot) {
        if (view.drawing)
            return;
        var originalDoc = doc;
        var originalRevision = revision;
        var initial = slot >= 0 ? doc.palette[slot] : slot === -2 ? doc.background : config.color;
        var title = slot >= 0 ? "Palette color" : slot === -2 ? "Background color" : "Foreground color";
        Util.openColorDialog(title, initial, function (color) {
            if (!root || !root.alive || !color || view.drawing || root.doc !== originalDoc || root.revision !== originalRevision)
                return;
            if (slot >= 0)
                root.setPaletteColor(slot, color);
            else if (slot === -2)
                root.setBackground(color);
            else
                root.setConfig("color", color.toString());
        });
    }
    function setBackground(color) {
        if (view.drawing || doc.background === color.toString())
            return;
        doc.background = color.toString();
        commit("Change paint background", false);
    }
    loadState: function (state) {
        apply(state && state.paintDoc);
    }
    stateUpdated: function (key, value) {
        if (key !== "paintDoc")
            return;
        var pending = pendingCommits.indexOf(value);
        if (pending >= 0) {
            pendingCommits.splice(pending, 1);
            return;
        }
        apply(value);
    }
    executionEvent: function (message) {
        if (!message)
            return;
        if (message.type === "gesture")
            view.receive(message.event);
        else
        // Runtime already submitted its own undoable process-state command.
        // Reflect it here, but never submit a duplicate editor transaction.
        if (message.type === "document")
            apply(message.doc);
    }
    Timer {
        interval: 0
        running: true
        onTriggered: root.executionSend({
            type: "hello"
        })
    }

    S.ThemedPage {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 8
            RowLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: 8
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: S.Theme.dark
                    border.color: S.Theme.border
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 8
                        PaintView {
                            id: view
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            checkerboard: true
                            config: root.config
                            backgroundColor: {
                                root.revision;
                                return root.doc.background;
                            }
                            onGesture: function (event) {
                                root.executionSend({
                                    type: "gesture",
                                    event: event
                                });
                            }
                            onCommitted: function (command) {
                                Model.append(root.doc, command);
                                root.commit("Paint " + command.tool, false);
                            }
                            onSampled: function (color) {
                                Model.pickColor(root.doc, color);
                                root.commit("Pick paint color", false);
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 256
                    Layout.fillHeight: true
                    color: S.Theme.base
                    border.color: S.Theme.border
                    ScrollView {
                        anchors.fill: parent
                        anchors.margins: 12
                        contentWidth: availableWidth
                        clip: true
                        ColumnLayout {
                            width: parent.width
                            spacing: 10
                            RowLayout {
                                Layout.fillWidth: true
                                S.SLabel {
                                    text: "Tools"
                                    font.bold: true
                                    dim: true
                                    Layout.fillWidth: true
                                }
                                S.SButton {
                                    text: "Clear"
                                    danger: true
                                    enabled: {
                                        root.revision;
                                        return root.doc.strokes.length > 0 && !view.drawing;
                                    }
                                    tip: "Clear all paint, keeping the background. Undo restores it."
                                    onClicked: {
                                        Model.append(root.doc, Model.clearCommand());
                                        root.commit("Clear paint", true);
                                    }
                                }
                            }
                            GridLayout {
                                columns: 2
                                Layout.fillWidth: true
                                rowSpacing: 5
                                columnSpacing: 5
                                Repeater {
                                    model: [
                                        {
                                            key: "brush",
                                            label: "Brush",
                                            tip: "Freehand stroke, with round caps"
                                        },
                                        {
                                            key: "eraser",
                                            label: "Eraser",
                                            tip: "Erase paint to reveal the background or transparency without changing the background"
                                        },
                                        {
                                            key: "line",
                                            label: "Line",
                                            tip: "Drag a straight line"
                                        },
                                        {
                                            key: "eyedropper",
                                            label: "Eyedropper",
                                            tip: "Pick the rendered color, including opacity"
                                        },
                                        {
                                            key: "rectangle",
                                            label: "Outline",
                                            filled: false,
                                            tip: "Rectangle outline: drag from one corner to the opposite"
                                        },
                                        {
                                            key: "rectangle",
                                            label: "Filled",
                                            filled: true,
                                            tip: "Filled rectangle: drag from one corner to the opposite"
                                        },
                                        {
                                            key: "ellipse",
                                            label: "Outline",
                                            filled: false,
                                            tip: "Ellipse outline: drag its bounding box"
                                        },
                                        {
                                            key: "ellipse",
                                            label: "Filled",
                                            filled: true,
                                            tip: "Filled ellipse: drag its bounding box"
                                        }
                                    ]
                                    S.SButton {
                                        id: toolButton
                                        required property var modelData
                                        Layout.fillWidth: true
                                        implicitHeight: 30
                                        text: modelData.label
                                        tip: modelData.tip
                                        readonly property bool shape: modelData.key === "rectangle" || modelData.key === "ellipse"
                                        lit: root.config.tool === modelData.key && (!shape || root.config.filled === modelData.filled)
                                        Accessible.name: shape ? (modelData.filled ? "Filled " : "Outline ") + modelData.key : modelData.label
                                        contentItem: RowLayout {
                                            spacing: 5
                                            Rectangle {
                                                visible: toolButton.shape
                                                Layout.preferredWidth: 18
                                                Layout.preferredHeight: 14
                                                radius: toolButton.modelData.key === "ellipse" ? 7 : 0
                                                color: toolButton.modelData.filled ? iconColor : "transparent"
                                                border.width: 1
                                                border.color: iconColor
                                                readonly property color iconColor: !toolButton.enabled ? S.Theme.textMuted : toolButton.lit ? S.Theme.textBright : S.Theme.text
                                            }
                                            Text {
                                                Layout.fillWidth: true
                                                text: toolButton.text
                                                font: toolButton.font
                                                color: !toolButton.enabled ? S.Theme.textMuted : toolButton.lit ? S.Theme.textBright : S.Theme.text
                                                horizontalAlignment: Text.AlignHCenter
                                                verticalAlignment: Text.AlignVCenter
                                                elide: Text.ElideRight
                                            }
                                        }
                                        enabled: !view.drawing
                                        onClicked: root.setTool(modelData.key, modelData.filled === true)
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: S.Theme.border
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                S.SLabel {
                                    text: "Width"
                                    Layout.fillWidth: true
                                }
                                S.SSpin {
                                    Layout.preferredWidth: 100
                                    from: 1
                                    to: 200
                                    value: root.config.width
                                    enabled: !view.drawing
                                    onValueModified: root.setConfig("width", value)
                                }
                                S.SLabel {
                                    text: "px"
                                    dim: true
                                }
                            }
                            S.SSlider {
                                Layout.fillWidth: true
                                from: 1
                                to: 200
                                stepSize: 1
                                value: root.config.width
                                enabled: !view.drawing
                                property bool edited: false
                                onMoved: {
                                    if (pressed) {
                                        edited = true;
                                        root.previewConfig("width", Math.round(value));
                                    } else
                                        root.setConfig("width", Math.round(value));
                                }
                                onPressedChanged: if (!pressed && edited) {
                                    edited = false;
                                    root.commit("Change paint width", false);
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                S.SLabel {
                                    text: "Opacity"
                                    Layout.fillWidth: true
                                }
                                S.SSpin {
                                    Layout.preferredWidth: 100
                                    from: 0
                                    to: 100
                                    value: Math.round(root.config.opacity * 100)
                                    enabled: !view.drawing
                                    onValueModified: root.setConfig("opacity", value / 100)
                                }
                                S.SLabel {
                                    text: "%"
                                    dim: true
                                }
                            }
                            S.SSlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1
                                stepSize: 0.01
                                value: root.config.opacity
                                enabled: !view.drawing
                                property bool edited: false
                                onMoved: {
                                    if (pressed) {
                                        edited = true;
                                        root.previewConfig("opacity", value);
                                    } else
                                        root.setConfig("opacity", value);
                                }
                                onPressedChanged: if (!pressed && edited) {
                                    edited = false;
                                    root.commit("Change paint opacity", false);
                                }
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                S.SLabel {
                                    text: "Feather"
                                    Layout.fillWidth: true
                                }
                                S.SSpin {
                                    Layout.preferredWidth: 100
                                    from: 0
                                    to: 100
                                    value: Math.round(root.config.feather * 100)
                                    enabled: root.config.tool === "brush" && !view.drawing
                                    onValueModified: root.setConfig("feather", value / 100)
                                }
                                S.SLabel {
                                    text: "%"
                                    dim: true
                                }
                            }
                            S.SSlider {
                                Layout.fillWidth: true
                                from: 0
                                to: 1
                                stepSize: 0.01
                                value: root.config.feather
                                enabled: root.config.tool === "brush" && !view.drawing
                                property bool edited: false
                                onMoved: {
                                    if (pressed) {
                                        edited = true;
                                        root.previewConfig("feather", value);
                                    } else
                                        root.setConfig("feather", value);
                                }
                                onPressedChanged: if (!pressed && edited) {
                                    edited = false;
                                    root.commit("Change paint feather", false);
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: S.Theme.border
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 6
                                S.SLabel {
                                    text: "Foreground"
                                }
                                S.SButton {
                                    id: foregroundButton
                                    Layout.fillWidth: true
                                    compact: true
                                    text: root.config.color
                                    tip: "Choose the foreground color"
                                    Accessible.name: "Foreground color " + text
                                    enabled: !view.drawing
                                    contentItem: RowLayout {
                                        spacing: 5
                                        Rectangle {
                                            Layout.preferredWidth: 22
                                            Layout.preferredHeight: 20
                                            color: root.config.color
                                            border.color: S.Theme.textDim
                                            radius: 2
                                        }
                                        Text {
                                            Layout.fillWidth: true
                                            text: foregroundButton.text
                                            font.pixelSize: S.Theme.fontSm
                                            font.family: "monospace"
                                            color: foregroundButton.enabled ? S.Theme.text : S.Theme.textMuted
                                            verticalAlignment: Text.AlignVCenter
                                            elide: Text.ElideRight
                                        }
                                    }
                                    onClicked: root.chooseColor(-1)
                                }
                            }
                            GridLayout {
                                columns: 6
                                Layout.fillWidth: true
                                columnSpacing: 5
                                rowSpacing: 5
                                Repeater {
                                    model: {
                                        root.revision;
                                        return root.doc.palette;
                                    }
                                    S.SButton {
                                        id: paletteButton
                                        required property string modelData
                                        required property int index
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        implicitHeight: 27
                                        compact: true
                                        enabled: !view.drawing
                                        text: modelData
                                        tip: "Select " + modelData + "; right-click to edit this palette color"
                                        Accessible.name: "Palette color " + (index + 1) + ": " + modelData
                                        contentItem: Rectangle {
                                            implicitWidth: 20
                                            implicitHeight: 23
                                            radius: 2
                                            color: paletteButton.modelData
                                            border.width: root.config.color === paletteButton.modelData ? 2 : 1
                                            border.color: root.config.color === paletteButton.modelData ? S.Theme.textBright : S.Theme.border
                                        }
                                        onClicked: root.setConfig("color", modelData)
                                        TapHandler {
                                            acceptedButtons: Qt.RightButton
                                            enabled: paletteButton.enabled
                                            onTapped: root.chooseColor(paletteButton.index)
                                        }
                                    }
                                }
                            }
                            Rectangle {
                                Layout.fillWidth: true
                                height: 1
                                color: S.Theme.border
                            }
                            S.SLabel {
                                text: "Background"
                                font.bold: true
                                dim: true
                            }
                            RowLayout {
                                Layout.fillWidth: true
                                S.SButton {
                                    Layout.fillWidth: true
                                    text: "Choose…"
                                    enabled: !view.drawing
                                    onClicked: root.chooseColor(-2)
                                }
                                S.SButton {
                                    Layout.fillWidth: true
                                    text: "Transparent"
                                    enabled: !view.drawing
                                    lit: {
                                        root.revision;
                                        return root.doc.background === "#00000000";
                                    }
                                    onClicked: root.setBackground("#00000000")
                                }
                            }
                        }
                    }
                }
            }
            S.SLabel {
                Layout.fillWidth: true
                visible: root.status.length > 0
                text: root.status
                wrapMode: Text.Wrap
            }
        }
    }
}
