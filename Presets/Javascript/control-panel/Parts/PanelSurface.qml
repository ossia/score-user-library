import QtQuick
import Score as Score
import OssiaUI as S
import "PanelModel.js" as Model

Item {
    id: surface
    property var doc
    property string stateId: ""
    property int revision: 0
    property bool editing: false
    property string selectedId: ""
    property var panelState: { revision; return doc ? Model.stateById(doc, stateId) : null; }
    property var selected: { revision; return Model.objectById(panelState, selectedId); }
    property var frozenBounds: null
    readonly property var viewBounds: {
        revision;
        if (frozenBounds) return frozenBounds;
        var bounds = { x: 0, y: 0, w: doc ? doc.width : 1, h: doc ? doc.height : 1 };
        if (editing && panelState) {
            var right = bounds.w, bottom = bounds.h;
            panelState.objects.forEach(function(o) {
                bounds.x = Math.min(bounds.x, o.x); bounds.y = Math.min(bounds.y, o.y);
                right = Math.max(right, o.x + o.w); bottom = Math.max(bottom, o.y + o.h);
            });
            var margin = Math.max(24, Math.max(right - bounds.x, bottom - bounds.y) * 0.04);
            bounds.x -= margin; bounds.y -= margin;
            bounds.w = right - bounds.x + margin; bounds.h = bottom - bounds.y + margin;
        }
        return bounds;
    }
    readonly property real canvasScale: Math.max(0.001, Math.min(width / viewBounds.w, height / viewBounds.h))
    readonly property real canvasX: (width - viewBounds.w * canvasScale) / 2 - viewBounds.x * canvasScale
    readonly property real canvasY: (height - viewBounds.h * canvasScale) / 2 - viewBounds.y * canvasScale
    clip: true
    signal activated(string objectId)
    signal editPressed(string objectId, real logicalX, real logicalY, bool resize)
    signal editMoved(real logicalX, real logicalY)
    signal editReleased(bool canceled)
    signal textStarted(string objectId)
    signal textEdited(string objectId, string value)
    signal textFinished(string objectId, string value, bool accepted)
    function finishText(accept) { if (inlineEditor) inlineEditor.finish(accept); }
    onStateIdChanged: { finishText(true); if (pointer) pointer.cancelPress(); }
    onSelectedIdChanged: if (inlineEditor && inlineEditor.editing && selectedId !== inlineTarget) finishText(true);
    onEditingChanged: { if (!editing) finishText(true); if (pointer) pointer.cancelPress(); }
    property string inlineTarget: ""
    property var inlineObject: { revision; return Model.objectById(panelState, inlineTarget); }

    function assetUrl(path) {
        if (!path) return "";
        var local = Score.Editor.locateFilePath(path).replace(/\\/g, "/");
        var encoded = encodeURI(local).replace(/#/g, "%23").replace(/\?/g, "%3F");
        if (local.charAt(0) === "/") return "file://" + encoded;
        if (/^[A-Za-z]:\//.test(local)) return "file:///" + encoded;
        return encoded;
    }

    Rectangle { anchors.fill: parent; color: "#090b0d" }
    Item {
        id: canvas
        x: surface.canvasX; y: surface.canvasY
        width: surface.doc ? surface.doc.width : 0
        height: surface.doc ? surface.doc.height : 0
        scale: surface.canvasScale
        transformOrigin: Item.TopLeft
        clip: !surface.editing
        Rectangle { anchors.fill: parent; color: surface.panelState ? surface.panelState.color : "#17232b" }
        Image {
            id: background
            anchors.fill: parent
            source: surface.assetUrl(surface.panelState ? surface.panelState.image : "")
            fillMode: surface.panelState && surface.panelState.fit === "crop" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
            asynchronous: true
            visible: source.toString().length > 0
        }
        Text {
            anchors.centerIn: parent
            width: parent.width - 48
            text: "Background image could not be loaded\n" + (surface.panelState ? surface.panelState.image : "")
            color: "#ff6b6b"; font.pixelSize: 22; wrapMode: Text.WrapAnywhere
            horizontalAlignment: Text.AlignHCenter
            visible: background.status === Image.Error
        }
        Repeater {
            model: surface.panelState ? surface.panelState.objects.length : 0
            Item {
                id: objectItem
                property var objectData: { surface.revision; return surface.panelState ? surface.panelState.objects[index] : null; }
                x: objectData ? objectData.x : 0; y: objectData ? objectData.y : 0
                width: objectData ? objectData.w : 0; height: objectData ? objectData.h : 0
                opacity: objectData ? objectData.opacity : 1
                clip: true
                Rectangle {
                    anchors.fill: parent
                    visible: objectItem.objectData && objectItem.objectData.type === "button"
                    color: objectItem.objectData ? objectItem.objectData.fill : "transparent"
                    radius: objectItem.objectData ? objectItem.objectData.radius : 0
                    border.color: objectItem.objectData ? objectItem.objectData.borderColor : "transparent"
                    border.width: objectItem.objectData ? objectItem.objectData.borderWidth : 0
                }
                Image {
                    id: objectImage
                    anchors.fill: parent
                    visible: objectItem.objectData && objectItem.objectData.type === "image"
                    source: visible ? surface.assetUrl(objectItem.objectData.image) : ""
                    fillMode: objectItem.objectData && objectItem.objectData.fit === "crop" ? Image.PreserveAspectCrop : Image.PreserveAspectFit
                    asynchronous: true
                }
                Text {
                    anchors.fill: parent; anchors.margins: 8
                    visible: objectItem.objectData && (objectItem.objectData.type === "button" || objectItem.objectData.type === "label") && !(inlineEditor.editing && surface.inlineTarget === objectItem.objectData.id)
                    text: objectItem.objectData ? objectItem.objectData.label : ""
                    textFormat: Text.PlainText
                    font.pixelSize: objectItem.objectData ? objectItem.objectData.fontSize : 28
                    color: objectItem.objectData ? objectItem.objectData.textColor : "white"
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    wrapMode: Text.WordWrap
                }
                Rectangle {
                    anchors.fill: parent
                    color: "#3066bbcc"; border.color: "#66bbcc"; border.width: 1 / Math.max(0.01, surface.canvasScale)
                    visible: surface.editing && objectItem.objectData && objectItem.objectData.type === "hotspot"
                    Text {
                        anchors.centerIn: parent; width: parent.width - 8
                        visible: !(inlineEditor.editing && objectItem.objectData && surface.inlineTarget === objectItem.objectData.id)
                        text: objectItem.objectData ? objectItem.objectData.label : ""
                        color: "#c8f4ff"; font.pixelSize: 20; elide: Text.ElideRight; horizontalAlignment: Text.AlignHCenter
                    }
                }
                Rectangle {
                    anchors.fill: parent; color: "#bf381d1d"
                    visible: objectItem.objectData && objectItem.objectData.type === "image" && (objectImage.status === Image.Error || !objectItem.objectData.image)
                    Text {
                        anchors.fill: parent; anchors.margins: 8
                        text: objectImage.status === Image.Error ? "Image could not be loaded\n" + objectItem.objectData.image : "No image selected"
                        textFormat: Text.PlainText; color: "#ffb0a0"; font.pixelSize: 18
                        wrapMode: Text.WrapAnywhere; verticalAlignment: Text.AlignVCenter; horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }
    Rectangle {
        visible: surface.editing && !!surface.selected
        x: surface.canvasX + (surface.selected ? surface.selected.x : 0) * surface.canvasScale
        y: surface.canvasY + (surface.selected ? surface.selected.y : 0) * surface.canvasScale
        width: surface.selected ? surface.selected.w * surface.canvasScale : 0
        height: surface.selected ? surface.selected.h * surface.canvasScale : 0
        color: "transparent"; border.color: "#e0a54d"; border.width: 2
        Rectangle { width: 10; height: 10; x: parent.width - 5; y: parent.height - 5; color: "#e0a54d"; border.color: "#171717" }
    }
    MouseArea {
        id: pointer
        anchors.fill: parent
        hoverEnabled: true
        preventStealing: true
        acceptedButtons: Qt.LeftButton
        property string pressedId: ""
        property string pressedState: ""
        property string pressedObject: ""
        property bool editGesture: false
        property real pressX: 0
        property real pressY: 0
        property bool moved: false
        function logicalX(px) { return (px - surface.canvasX) / surface.canvasScale; }
        function logicalY(py) { return (py - surface.canvasY) / surface.canvasScale; }
        function inside(px, py) { return surface.doc && px >= 0 && py >= 0 && px <= surface.doc.width && py <= surface.doc.height; }
        function resizeAt(px, py) {
            return surface.editing && surface.selected && Math.abs(px - surface.canvasX - (surface.selected.x + surface.selected.w) * surface.canvasScale) <= 9
                && Math.abs(py - surface.canvasY - (surface.selected.y + surface.selected.h) * surface.canvasScale) <= 9;
        }
        function cancelPress() {
            var wasEditing = editGesture;
            editGesture = false; pressedId = ""; pressedState = ""; pressedObject = "";
            if (wasEditing) surface.editReleased(true);
            if (!inlineEditor || !inlineEditor.editing) surface.frozenBounds = null;
        }
        cursorShape: resizeAt(mouseX, mouseY) ? Qt.SizeFDiagCursor : surface.editing ? Qt.ArrowCursor
            : inside(logicalX(mouseX), logicalY(mouseY)) && Model.hit(surface.panelState, logicalX(mouseX), logicalY(mouseY), false) ? Qt.PointingHandCursor : Qt.ArrowCursor
        onPressed: function(mouse) {
            surface.finishText(true);
            if (surface.editing) surface.frozenBounds = surface.viewBounds;
            var lx = logicalX(mouse.x), ly = logicalY(mouse.y);
            var resizing = resizeAt(mouse.x, mouse.y);
            var object = resizing ? surface.selected : surface.editing || inside(lx, ly) ? Model.hit(surface.panelState, lx, ly, surface.editing) : null;
            pressedId = object ? object.id : "";
            pressedState = surface.stateId;
            pressedObject = object ? JSON.stringify(object) : "";
            pressX = mouse.x; pressY = mouse.y; moved = false;
            editGesture = surface.editing;
            if (editGesture) surface.editPressed(pressedId, lx, ly, resizing);
        }
        onPositionChanged: function(mouse) {
            if (!pressed || !editGesture) return;
            moved = moved || Math.abs(mouse.x - pressX) + Math.abs(mouse.y - pressY) >= 4;
            if (moved) surface.editMoved(logicalX(mouse.x), logicalY(mouse.y));
        }
        onReleased: function(mouse) {
            var id = pressedId, state = pressedState, snapshot = pressedObject, wasEditing = editGesture;
            editGesture = false; pressedId = ""; pressedState = ""; pressedObject = "";
            if (wasEditing) surface.editReleased(false);
            else if (!surface.editing && state === surface.stateId) {
                var lx = logicalX(mouse.x), ly = logicalY(mouse.y);
                var object = inside(lx, ly) ? Model.hit(surface.panelState, lx, ly, false) : null;
                if (object && object.id === id && JSON.stringify(object) === snapshot) surface.activated(object.id);
            }
            if (!inlineEditor.editing) surface.frozenBounds = null;
        }
        onDoubleClicked: function(mouse) {
            if (!surface.editing) return;
            var object = Model.hit(surface.panelState, logicalX(mouse.x), logicalY(mouse.y), true);
            if (!object || ["button", "hotspot", "label"].indexOf(object.type) < 0) return;
            cancelPress();
            surface.frozenBounds = surface.viewBounds;
            surface.inlineTarget = object.id;
            surface.textStarted(object.id);
            inlineEditor.begin(object.label || "");
        }
        onCanceled: cancelPress()
    }
    Item {
        x: surface.canvasX; y: surface.canvasY
        scale: surface.canvasScale; transformOrigin: Item.TopLeft
        S.SInlineTextEditor {
            id: inlineEditor
            x: surface.inlineObject ? surface.inlineObject.x : 0
            y: surface.inlineObject ? surface.inlineObject.y : 0
            width: surface.inlineObject ? surface.inlineObject.w : 0
            height: surface.inlineObject ? surface.inlineObject.h : 0
            padding: 8
            font.pixelSize: surface.inlineObject ? (surface.inlineObject.type === "hotspot" ? 20 : surface.inlineObject.fontSize) : 28
            color: surface.inlineObject ? surface.inlineObject.textColor : "white"
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            wrapMode: TextEdit.WordWrap
            onEdited: function(value) { surface.textEdited(surface.inlineTarget, value); }
            onFinished: function(value, accepted) {
                surface.textFinished(surface.inlineTarget, value, accepted);
                surface.inlineTarget = ""; surface.frozenBounds = null;
            }
        }
    }
}
