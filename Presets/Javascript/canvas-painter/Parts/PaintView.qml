import QtQuick

Item {
    id: root
    property var config: ({
            tool: "brush",
            color: "#ffededed",
            width: 12,
            opacity: 1,
            filled: false
        })
    property color backgroundColor: "transparent"
    property bool checkerboard: false
    property bool interactive: true
    property bool remoteDrawing: false
    property bool sampling: false
    onConfigChanged: {
        sampling = false;
        if (painter)
            painter.cancelSample();
    }
    onBackgroundColorChanged: {
        sampling = false;
        if (painter)
            painter.cancelSample();
    }
    readonly property bool drawing: pointer.pressed || remoteDrawing
    signal gesture(var event)
    signal committed(var command)
    signal sampled(color color)

    function load(doc) {
        sampling = false;
        remoteDrawing = false;
        pointer.localStroke = false;
        painter.loadCommands(doc.strokes);
    }
    function receive(event) {
        if (!event)
            return;
        if (event.action === "begin") {
            pointer.localStroke = false;
            remoteDrawing = true;
            painter.beginStroke(event.config, event.x, event.y);
        } else if (event.action === "move" && remoteDrawing) {
            painter.extendStroke(event.x, event.y);
        } else if (event.action === "end" && remoteDrawing) {
            painter.extendStroke(event.x, event.y);
            painter.endStroke();
            remoteDrawing = false;
        } else if (event.action === "cancel") {
            painter.cancelStroke();
            remoteDrawing = false;
        }
    }
    Item {
        id: artboard
        width: Math.min(root.width, root.height * 1280 / 720)
        height: width * 720 / 1280
        anchors.centerIn: parent
        clip: true
        Rectangle {
            anchors.fill: parent
            color: "#363a38"
            visible: root.checkerboard
        }
        Repeater {
            model: root.checkerboard ? 20 * 12 : 0
            Rectangle {
                required property int index
                width: artboard.width / 20
                height: artboard.height / 12
                x: (index % 20) * width
                y: Math.floor(index / 20) * height
                color: ((index % 20) + Math.floor(index / 20)) % 2 ? "#454b47" : "#363a38"
            }
        }
        PaintSurface {
            id: painter
            anchors.fill: parent
            fillColor: root.backgroundColor
            onColorSampled: function (color) {
                if (!root.sampling || root.config.tool !== "eyedropper")
                    return;
                root.sampling = false;
                root.sampled(color);
            }
        }
        MouseArea {
            id: pointer
            anchors.fill: parent
            enabled: root.interactive
            acceptedButtons: Qt.LeftButton
            hoverEnabled: true
            preventStealing: true
            cursorShape: root.config.tool === "eyedropper" ? Qt.PointingHandCursor : Qt.CrossCursor
            property bool localStroke: false
            function px(value) {
                return Math.max(0, Math.min(1280, value * 1280 / width));
            }
            function py(value) {
                return Math.max(0, Math.min(720, value * 720 / height));
            }
            onPressed: function (mouse) {
                if (root.remoteDrawing) {
                    mouse.accepted = false;
                    return;
                }
                forceActiveFocus(Qt.MouseFocusReason);
                if (root.config.tool === "eyedropper") {
                    root.sampling = true;
                    painter.sampleColor(px(mouse.x), py(mouse.y));
                    return;
                }
                localStroke = true;
                painter.beginStroke(root.config, px(mouse.x), py(mouse.y));
                root.gesture({
                    action: "begin",
                    config: root.config,
                    x: px(mouse.x),
                    y: py(mouse.y)
                });
            }
            onPositionChanged: function (mouse) {
                if (!pressed || !localStroke)
                    return;
                painter.extendStroke(px(mouse.x), py(mouse.y));
                root.gesture({
                    action: "move",
                    x: px(mouse.x),
                    y: py(mouse.y)
                });
            }
            onReleased: function (mouse) {
                if (!localStroke)
                    return;
                painter.extendStroke(px(mouse.x), py(mouse.y));
                root.gesture({
                    action: "end",
                    x: px(mouse.x),
                    y: py(mouse.y)
                });
                localStroke = false;
                root.committed(painter.endStroke());
            }
            onCanceled: {
                if (!localStroke)
                    return;
                localStroke = false;
                painter.cancelStroke();
                root.gesture({
                    action: "cancel"
                });
            }
        }
    }
}
