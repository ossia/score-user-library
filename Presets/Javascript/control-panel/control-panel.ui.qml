import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import OssiaUI as S
import "PanelModel.js" as Model

Score.ScriptUI {
    id: root
    anchors.fill: parent
    implicitWidth: 1200
    implicitHeight: 800
    property var doc: Model.defaultDoc()
    property int revision: 0
    property string selectedState: doc.initial
    property string selectedObject: ""
    property string runtimeState: ""
    property bool runtimeCanBack: false
    property bool testing: false
    property string previewState: ""
    property var previewHistory: []
    property var textEdit: null
    property string status: ""
    property var currentState: { revision; return Model.stateById(doc, selectedState); }
    property var currentObject: { revision; return Model.objectById(currentState, selectedObject); }
    property var stateNames: { revision; return doc.states.map(function(s) { return s.name; }); }
    property var targetNames: ["No transition", "Back"].concat(stateNames)
    property var drag: null

    function sendLive() { root.executionSend({ type: "doc", doc: JSON.stringify(doc) }); }
    function changed(label) {
        revision++;
        doc = Model.clone(doc);
        root.beginUpdateState(label);
        root.updateState("panelDoc", JSON.stringify(doc));
        root.endUpdateState();
        sendLive();
    }
    function restore(value) {
        try {
            var replacement = Model.parse(value);
            if (JSON.stringify(doc) !== JSON.stringify(replacement)) {
                panelView.finishText(false);
                if (drag) endDrag(true);
                doc = replacement; revision++;
            }
            if (!Model.stateById(doc, selectedState)) selectedState = doc.initial;
            if (!Model.objectById(currentState, selectedObject)) selectedObject = "";
            if (!Model.stateById(doc, previewState)) previewState = selectedState;
            previewHistory = previewHistory.filter(function(id) { return !!Model.stateById(doc, id); });
            sendLive();
            status = "";
        } catch (e) { status = "Document could not be loaded: " + e; }
    }
    loadState: function(state) {
        restore(state && state.panelDoc ? state.panelDoc : Model.defaultDoc());
        root.executionSend({ type: "status" });
    }
    stateUpdated: function(key, value) { if (key === "panelDoc") restore(value); }
    executionEvent: function(message) {
        if (!message) return;
        if (message.type === "runtime") { runtimeState = message.state; runtimeCanBack = message.canBack; }
        else if (message.type === "action") status = "Activated " + message.event.zone + (message.event.action ? " · " + message.event.action : "") + " → " + stateName(message.event.target);
        else if (message.type === "error") status = message.message;
    }
    function stateName(id) { revision; var s = Model.stateById(doc, id); return s ? s.name : "Not running"; }
    function stateIndex(id) { return doc.states.findIndex(function(s) { return s.id === id; }); }
    function selectState(id) { panelView.finishText(true); if (drag) endDrag(true); selectedState = id; selectedObject = ""; testing = false; }
    function selectObject(id) { panelView.finishText(true); selectedObject = id; testing = false; }
    function previewCommand(command) {
        var result = Model.transition(doc, previewState, previewHistory, command);
        previewState = result.state; previewHistory = result.history;
        if (result.event) status = "Preview: " + result.event.zone + (result.event.action ? " · " + result.event.action : "") + " → " + stateName(result.event.target);
        if (result.error) status = result.error;
    }
    function togglePreview() {
        panelView.finishText(true);
        if (drag) endDrag(true);
        if (testing) testing = false;
        else { previewState = selectedState; previewHistory = []; testing = true; status = ""; }
    }
    function beginText(id) {
        if (drag) endDrag(true);
        selectedObject = id;
        if (currentObject) textEdit = { state: selectedState, id: id, original: currentObject.label };
    }
    function editText(id, value) {
        if (!textEdit || textEdit.id !== id) return;
        var o = Model.objectById(Model.stateById(doc, textEdit.state), id);
        if (o) { o.label = value; revision++; }
    }
    function finishText(id, value, accepted) {
        if (!textEdit || textEdit.id !== id) return;
        var edit = textEdit; textEdit = null;
        var o = Model.objectById(Model.stateById(doc, edit.state), id);
        if (!o) return;
        o.label = accepted ? value : edit.original;
        revision++;
        if (accepted && value !== edit.original) changed("Edit panel text");
    }
    function addState() {
        panelView.finishText(true);
        var s = Model.makeState(doc, "State " + (doc.states.length + 1));
        doc.states.push(s); selectState(s.id); changed("Add panel state");
    }
    function duplicateState() {
        panelView.finishText(true);
        if (!currentState) return;
        var sourceId = currentState.id, s = Model.clone(currentState);
        s.id = Model.newId(doc, "s"); s.name += " copy";
        s.objects.forEach(function(o) { o.id = Model.newId(doc, "o"); if (o.target === sourceId) o.target = s.id; });
        doc.states.push(s); selectState(s.id); changed("Duplicate panel state");
    }
    function deleteState() {
        panelView.finishText(true);
        if (doc.states.length < 2) return;
        var id = selectedState, index = stateIndex(id);
        doc.states.splice(index, 1);
        doc.states.forEach(function(s) { s.objects.forEach(function(o) { if (o.target === id) o.target = ""; }); });
        if (doc.initial === id) doc.initial = doc.states[0].id;
        selectState(doc.states[Math.min(index, doc.states.length - 1)].id);
        changed("Delete panel state");
    }
    function setState(key, value) {
        panelView.finishText(true);
        if (!currentState || currentState[key] === value) return;
        if (key === "name") { value = value.trim(); if (!value) return; }
        currentState[key] = value; changed("Edit panel state");
    }
    function setObject(key, value) {
        panelView.finishText(true);
        if (["x", "y", "w", "h", "fontSize", "radius", "borderWidth", "opacity"].indexOf(key) >= 0 && !isFinite(value)) return;
        if (!currentObject || currentObject[key] === value) return;
        if (key === "fontSize") value = Math.max(6, Math.min(500, value));
        if (key === "radius" || key === "borderWidth") value = Math.max(0, Math.min(200, value));
        if (key === "opacity") value = Math.max(0, Math.min(1, value));
        currentObject[key] = value;
        Model.constrain(doc, currentObject);
        changed("Edit panel object");
    }
    function resizeCanvas(key, value) {
        panelView.finishText(true);
        if (!isFinite(value)) return;
        value = Math.round(Math.max(64, Math.min(8192, value)));
        if (doc[key] === value) return;
        doc[key] = value;
        changed("Resize panel canvas");
    }
    function addObject(type) {
        panelView.finishText(true);
        if (!currentState) return;
        testing = false;
        var o = Model.makeObject(doc, type);
        o.x = (doc.width - o.w) / 2; o.y = (doc.height - o.h) / 2;
        Model.constrain(doc, o);
        currentState.objects.push(o); selectedObject = o.id;
        changed("Add " + type);
        if (type === "image") browseAsset(false);
    }
    function removeObject() {
        panelView.finishText(true);
        if (!currentObject) return;
        currentState.objects = currentState.objects.filter(function(o) { return o.id !== selectedObject; });
        selectedObject = ""; changed("Delete panel object");
    }
    function reorderObjects(from, to) {
        panelView.finishText(true);
        if (!currentState || from === to) return;
        var objects = currentState.objects, count = objects.length;
        if (from < 0 || to < 0 || from >= count || to >= count) return;
        var o = objects.splice(count - from - 1, 1)[0];
        objects.splice(count - to - 1, 0, o);
        changed("Reorder panel object");
    }
    function reorderStates(from, to) {
        panelView.finishText(true);
        if (from === to || from < 0 || to < 0 || from >= doc.states.length || to >= doc.states.length) return;
        var s = doc.states.splice(from, 1)[0]; doc.states.splice(to, 0, s);
        changed("Reorder panel state");
    }
    function moveOrder(delta) {
        if (!currentObject) return;
        var index = currentState.objects.findIndex(function(o) { return o.id === selectedObject; });
        var visible = currentState.objects.length - index - 1;
        reorderObjects(visible, visible - delta);
    }
    function targetIndex() {
        revision;
        if (!currentObject || !currentObject.target) return 0;
        if (currentObject.target === "@back") return 1;
        return stateIndex(currentObject.target) + 2;
    }
    function beginDrag(id, x, y, resize) {
        panelView.finishText(true);
        selectedObject = id;
        if (!currentObject) return;
        drag = { x: x, y: y, resize: resize, original: Model.clone(currentObject), before: JSON.stringify(doc) };
        root.beginUpdateState(resize ? "Resize panel object" : "Move panel object");
    }
    function moveDrag(x, y) {
        if (!isFinite(x) || !isFinite(y)) return;
        if (!drag || !currentObject) return;
        var o = currentObject, original = drag.original;
        if (drag.resize) {
            o.w = Math.max(8, Math.round(original.w + x - drag.x));
            o.h = Math.max(8, Math.round(original.h + y - drag.y));
        } else {
            o.x = Math.round(original.x + x - drag.x); o.y = Math.round(original.y + y - drag.y);
            Model.constrain(doc, o);
        }
        doc = Model.clone(doc); revision++; sendLive();
    }
    function endDrag(canceled) {
        if (!drag) return;
        var gesture = drag; drag = null;
        if (canceled) { doc = Model.parse(gesture.before); revision++; }
        else if (JSON.stringify(doc) !== gesture.before) root.updateState("panelDoc", JSON.stringify(doc));
        root.endUpdateState(); sendLive();
    }
    function browseAsset(background) {
        panelView.finishText(true);
        var stateId = selectedState, objectId = selectedObject;
        Util.openFileDialog("Choose image or SVG",
                            "Images (*.svg *.svgz *.png *.jpg *.jpeg *.webp *.bmp *.gif);;All files (*)",
                            "", function(path) {
            if (!root || !path) return;
            panelView.finishText(true);
            var s = Model.stateById(root.doc, stateId);
            var o = background ? s : Model.objectById(s, objectId);
            if (!o) return;
            o.image = Score.Editor.relativizeFilePath(path);
            root.changed("Import panel image");
        });
    }
    function assignImage(background, path) {
        if (!path) return;
        panelView.finishText(true);
        var object = background ? currentState : currentObject;
        if (!object) return;
        var relative = Score.Editor.relativizeFilePath(path);
        if (object.image === relative) return;
        object.image = relative; changed("Import panel image");
    }
    function importImages(paths, x, y) {
        panelView.finishText(true);
        if (!currentState || !paths.length || !isFinite(x) || !isFinite(y)) return;
        var batch = { state: selectedState, x: x, y: y, paths: paths, sizes: new Array(paths.length), remaining: paths.length };
        for (var i = 0; i < paths.length; ++i)
            imageProbe.createObject(root, { batch: batch, slot: i, source: panelView.assetUrl(paths[i]) });
    }
    function imageLoaded(batch, slot, imageWidth, imageHeight) {
        batch.sizes[slot] = imageWidth > 0 && imageHeight > 0 ? { w: imageWidth, h: imageHeight } : null;
        if (--batch.remaining) return;
        panelView.finishText(true);
        if (drag) endDrag(true);
        var state = Model.stateById(doc, batch.state);
        if (!state) return;
        var added = 0, failed = 0;
        for (var i = 0; i < batch.paths.length; ++i) {
            var size = batch.sizes[i];
            if (!size) { failed++; continue; }
            var o = Model.makeObject(doc, "image");
            o.image = Score.Editor.relativizeFilePath(batch.paths[i]);
            o.label = batch.paths[i].replace(/\\/g, "/").split("/").pop();
            var scale = Math.min(1, 320 / size.w, 220 / size.h);
            o.w = Math.max(8, size.w * scale); o.h = Math.max(8, size.h * scale);
            o.x = Math.round(batch.x + added * 24); o.y = Math.round(batch.y + added * 24);
            state.objects.push(o); added++;
            if (selectedState === batch.state) selectedObject = o.id;
        }
        if (added) changed("Drop panel images");
        status = failed ? failed + " image(s) could not be loaded" : "";
    }
    Component {
        id: imageProbe
        Image {
            id: probeImage
            property var batch
            property int slot
            property bool completed: false
            visible: false; asynchronous: true
            function complete() {
                if (completed || !batch || (status !== Image.Ready && status !== Image.Error)) return;
                completed = true;
                root.imageLoaded(batch, slot, status === Image.Ready ? sourceSize.width : 0, status === Image.Ready ? sourceSize.height : 0);
                Qt.callLater(function() { probeImage.destroy(); });
            }
            onStatusChanged: complete()
            Component.onCompleted: complete()
        }
    }

    S.ThemedPage {
        anchors.fill: parent
        ColumnLayout {
            anchors.fill: parent; anchors.margins: 6; spacing: 6
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                S.SLabel { text: "Control panel"; font.bold: true }
                S.SVSeparator {}
                S.SButton { text: "Button"; enabled: !root.testing; onClicked: root.addObject("button") }
                S.SButton { text: "Hotspot"; enabled: !root.testing; onClicked: root.addObject("hotspot") }
                S.SButton { text: "Label"; enabled: !root.testing; onClicked: root.addObject("label") }
                S.SButton { text: "Image / SVG"; enabled: !root.testing; onClicked: root.addObject("image") }
                Item { Layout.fillWidth: true }
                S.SButton {
                    text: root.testing ? "Edit" : "Preview selected"
                    tip: root.testing ? "Return to editing." : "Preview locally, even while stopped. No runtime actions are emitted."
                    onClicked: root.togglePreview()
                }
                S.SButton { text: "Back"; enabled: root.testing && root.previewHistory.length > 0; onClicked: root.previewCommand({ command: "back" }) }
                S.SButton { text: "Reset"; enabled: root.testing; onClicked: root.previewCommand({ command: "reset" }) }
            }
            RowLayout {
                Layout.fillWidth: true; Layout.fillHeight: true; spacing: 6
                Rectangle {
                    Layout.preferredWidth: 210; Layout.fillHeight: true; color: S.Theme.base; border.color: S.Theme.border
                    ColumnLayout {
                        anchors.fill: parent; anchors.margins: S.Theme.pad; spacing: S.Theme.gap
                        S.SLabel { text: "States"; font.bold: true }
                        RowLayout {
                            S.SButton { text: "Add"; onClicked: root.addState() }
                            S.SButton { text: "Copy"; onClicked: root.duplicateState() }
                            S.SButton { text: "Delete"; enabled: root.doc.states.length > 1; onClicked: root.deleteState() }
                        }
                        ListView {
                            id: stateList
                            Layout.fillWidth: true; Layout.preferredHeight: Math.min(root.doc.states.length * (S.Theme.listRowH + S.Theme.gapSm), 150); clip: true
                            spacing: S.Theme.gapSm
                            model: root.doc.states.length
                            ScrollBar.vertical: ScrollBar {}
                            delegate: Rectangle {
                                id: stateRow
                                required property int index
                                property var entry: { root.revision; return root.doc.states[index]; }
                                width: ListView.view.width; height: S.Theme.listRowH; radius: S.Theme.radiusSm
                                color: entry && entry.id === root.selectedState ? S.Theme.accentFill : index % 2 ? S.Theme.altBase : S.Theme.base
                                Text {
                                    anchors.fill: parent; anchors.leftMargin: S.Theme.pad + stateDrag.width + S.Theme.gap; anchors.rightMargin: S.Theme.pad
                                    text: entry ? (entry.id === root.doc.initial ? "• " : "") + entry.name : ""
                                    color: S.Theme.text; font.pixelSize: S.Theme.fontSm; font.hintingPreference: S.Theme.hinting; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                                }
                                MouseArea { anchors.fill: parent; onClicked: if (parent.entry) root.selectState(parent.entry.id) }
                                S.SLayerDragHandle {
                                    id: stateDrag
                                    anchors.left: parent.left; anchors.leftMargin: S.Theme.pad; anchors.verticalCenter: parent.verticalCenter
                                    view: stateList; index: stateRow.index
                                    onStarted: if (stateRow.entry) root.selectState(stateRow.entry.id)
                                    onMoved: function(from, to) { root.reorderStates(from, to); }
                                }
                            }
                        }
                        S.SLabel { text: "Initial state"; dim: true }
                        S.SCombo {
                            Layout.fillWidth: true; model: root.stateNames
                            currentIndex: { root.revision; return root.stateIndex(root.doc.initial); }
                            onActivated: function(index) { root.doc.initial = root.doc.states[index].id; root.changed("Set initial panel state"); }
                        }
                        S.SSeparator {}
                        S.SLabel { text: "Objects (front first)"; font.bold: true }
                        ListView {
                            id: objectList
                            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                            spacing: S.Theme.gapSm
                            model: root.currentState ? root.currentState.objects.length : 0
                            ScrollBar.vertical: ScrollBar {}
                            delegate: Rectangle {
                                id: objectRow
                                required property int index
                                property var entry: { root.revision; return root.currentState ? root.currentState.objects[root.currentState.objects.length - index - 1] : null; }
                                width: ListView.view.width; height: S.Theme.listRowH; radius: S.Theme.radiusSm
                                color: entry && entry.id === root.selectedObject ? S.Theme.accentFill : index % 2 ? S.Theme.altBase : S.Theme.base
                                Text {
                                    anchors.fill: parent; anchors.leftMargin: S.Theme.pad + objectDrag.width + S.Theme.gap; anchors.rightMargin: S.Theme.pad
                                    text: entry ? entry.label + " (" + entry.type + ")" : ""
                                    color: S.Theme.text; font.pixelSize: S.Theme.fontSm; font.hintingPreference: S.Theme.hinting; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter
                                }
                                MouseArea { anchors.fill: parent; onClicked: root.selectObject(parent.entry ? parent.entry.id : "") }
                                S.SLayerDragHandle {
                                    id: objectDrag
                                    anchors.left: parent.left; anchors.leftMargin: S.Theme.pad; anchors.verticalCenter: parent.verticalCenter
                                    view: objectList; index: objectRow.index
                                    onStarted: if (objectRow.entry) root.selectObject(objectRow.entry.id)
                                    onMoved: function(from, to) { root.reorderObjects(from, to); }
                                }
                            }
                        }
                        RowLayout {
                            S.SButton { text: "Raise"; enabled: !!root.currentObject; onClicked: root.moveOrder(1) }
                            S.SButton { text: "Lower"; enabled: !!root.currentObject; onClicked: root.moveOrder(-1) }
                            S.SButton { text: "Delete"; enabled: !!root.currentObject; onClicked: root.removeObject() }
                        }
                    }
                }
                ColumnLayout {
                    Layout.fillWidth: true; Layout.fillHeight: true; spacing: 6
                    RowLayout {
                        Layout.fillWidth: true
                        S.SLabel { text: root.testing ? "Preview: " + root.stateName(root.previewState) : "Edit: " + root.stateName(root.selectedState); font.bold: true }
                        Item { Layout.fillWidth: true }
                        S.SLabel { text: root.doc.width + " × " + root.doc.height; dim: true }
                    }
                    PanelSurface {
                        id: panelView
                        Layout.fillWidth: true; Layout.fillHeight: true
                        doc: root.doc; revision: root.revision
                        stateId: root.testing ? root.previewState : root.selectedState
                        editing: !root.testing; selectedId: root.selectedObject
                        onActivated: function(objectId) { root.previewCommand({ activate: objectId }); }
                        onEditPressed: function(objectId, logicalX, logicalY, resize) { root.beginDrag(objectId, logicalX, logicalY, resize); }
                        onEditMoved: function(logicalX, logicalY) { root.moveDrag(logicalX, logicalY); }
                        onEditReleased: function(canceled) { root.endDrag(canceled); }
                        onTextStarted: function(objectId) { root.beginText(objectId); }
                        onTextEdited: function(objectId, value) { root.editText(objectId, value); }
                        onTextFinished: function(objectId, value, accepted) { root.finishText(objectId, value, accepted); }
                        S.SImageDropArea {
                            anchors.fill: parent; enabled: !root.testing
                            onFilesDropped: function(paths, x, y) {
                                root.importImages(paths, (x - panelView.canvasX) / panelView.canvasScale, (y - panelView.canvasY) / panelView.canvasScale);
                            }
                        }
                    }
                }
                Rectangle {
                    Layout.preferredWidth: 280; Layout.fillHeight: true; color: S.Theme.base; border.color: S.Theme.border
                    ScrollView {
                        anchors.fill: parent; anchors.margins: 8; clip: true
                        contentWidth: availableWidth
                        ColumnLayout {
                            width: parent.width; spacing: 7
                            S.SLabel { text: "Canvas"; font.bold: true }
                            S.SNumRow { label: "Width"; value: root.doc.width; decimals: 0; step: 10; onEdited: function(v) { root.resizeCanvas("width", v); } }
                            S.SNumRow { label: "Height"; value: root.doc.height; decimals: 0; step: 10; onEdited: function(v) { root.resizeCanvas("height", v); } }
                            S.SSeparator {}
                            S.SLabel { text: "State"; font.bold: true }
                            S.STextRow { label: "Name"; value: root.currentState ? root.currentState.name : ""; onEdited: function(v) { root.setState("name", v); } }
                            S.SLabel { text: root.currentState ? "ID  " + root.currentState.id : ""; dim: true }
                            S.SColorRow { label: "Background"; value: root.currentState ? root.currentState.color : "#17232b"; onEdited: function(v) { root.setState("color", v); } }
                            RowLayout {
                                S.SButton {
                                    text: "Background image / SVG"; onClicked: root.browseAsset(true)
                                    S.SImageDropArea { anchors.fill: parent; onFilesDropped: function(paths) { root.assignImage(true, paths[0]); } }
                                }
                                S.SButton { text: "Clear"; enabled: !!root.currentState && !!root.currentState.image; onClicked: root.setState("image", "") }
                            }
                            S.SLabel { Layout.fillWidth: true; text: root.currentState && root.currentState.image ? root.currentState.image : "No background image"; dim: true; wrapMode: Text.WrapAnywhere }
                            S.SCombo {
                                Layout.fillWidth: true; model: ["Fit background", "Crop background"]
                                currentIndex: root.currentState && root.currentState.fit === "crop" ? 1 : 0
                                onActivated: function(index) { root.setState("fit", index ? "crop" : "fit"); }
                            }
                            S.SSeparator {}
                            S.SLabel { text: root.currentObject ? "Object: " + root.currentObject.type : "No object selected"; font.bold: true }
                            ColumnLayout {
                                Layout.fillWidth: true; visible: !!root.currentObject; spacing: 7
                                S.SLabel { text: root.currentObject ? "ID  " + root.currentObject.id : ""; dim: true }
                                S.STextRow { label: "Label"; value: root.currentObject ? root.currentObject.label : ""; onEdited: function(v) { root.setObject("label", v); } }
                                S.SNumRow { label: "X"; value: root.currentObject ? root.currentObject.x : 0; decimals: 0; step: 1; onEdited: function(v) { root.setObject("x", v); } }
                                S.SNumRow { label: "Y"; value: root.currentObject ? root.currentObject.y : 0; decimals: 0; step: 1; onEdited: function(v) { root.setObject("y", v); } }
                                S.SNumRow { label: "Width"; value: root.currentObject ? root.currentObject.w : 0; decimals: 0; step: 1; onEdited: function(v) { root.setObject("w", v); } }
                                S.SNumRow { label: "Height"; value: root.currentObject ? root.currentObject.h : 0; decimals: 0; step: 1; onEdited: function(v) { root.setObject("h", v); } }
                                S.SSeparator {}
                                S.SLabel { text: "On activation"; font.bold: true }
                                S.SCombo {
                                    Layout.fillWidth: true; model: root.targetNames; currentIndex: root.targetIndex()
                                    onActivated: function(index) { root.setObject("target", index === 0 ? "" : index === 1 ? "@back" : root.doc.states[index - 2].id); }
                                }
                                S.STextRow {
                                    label: "Action"; value: root.currentObject ? root.currentObject.action : ""; placeholder: "Optional event name"; onEdited: function(v) { root.setObject("action", v); }
                                    ToolTip.visible: actionHover.hovered
                                    ToolTip.text: "Action emits {state, zone, action, target} on activation."
                                    HoverHandler { id: actionHover }
                                }
                                S.SSeparator {}
                                ColumnLayout {
                                    Layout.fillWidth: true; visible: !!root.currentObject && root.currentObject.type === "image"
                                    S.SButton {
                                        text: "Choose image / SVG"; onClicked: root.browseAsset(false)
                                        S.SImageDropArea { anchors.fill: parent; onFilesDropped: function(paths) { root.assignImage(false, paths[0]); } }
                                    }
                                    S.SLabel { Layout.fillWidth: true; text: root.currentObject ? root.currentObject.image : ""; wrapMode: Text.WrapAnywhere; dim: true }
                                    S.SCombo {
                                        Layout.fillWidth: true; model: ["Fit image", "Crop image"]
                                        currentIndex: root.currentObject && root.currentObject.fit === "crop" ? 1 : 0
                                        onActivated: function(index) { root.setObject("fit", index ? "crop" : "fit"); }
                                    }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; visible: !!root.currentObject && (root.currentObject.type === "button" || root.currentObject.type === "label")
                                    S.SColorRow { label: "Text"; value: root.currentObject ? root.currentObject.textColor : "#ffffff"; onEdited: function(v) { root.setObject("textColor", v); } }
                                    S.SNumRow { label: "Text size"; value: root.currentObject ? root.currentObject.fontSize : 28; decimals: 0; step: 1; onEdited: function(v) { root.setObject("fontSize", v); } }
                                }
                                ColumnLayout {
                                    Layout.fillWidth: true; visible: !!root.currentObject && root.currentObject.type === "button"
                                    S.SColorRow { label: "Fill"; value: root.currentObject ? root.currentObject.fill : "#c58014"; onEdited: function(v) { root.setObject("fill", v); } }
                                    S.SColorRow { label: "Border"; value: root.currentObject ? root.currentObject.borderColor : "#e0a54d"; onEdited: function(v) { root.setObject("borderColor", v); } }
                                    S.SNumRow { label: "Border width"; value: root.currentObject ? root.currentObject.borderWidth : 1; decimals: 0; step: 1; onEdited: function(v) { root.setObject("borderWidth", v); } }
                                    S.SNumRow { label: "Radius"; value: root.currentObject ? root.currentObject.radius : 8; decimals: 0; step: 1; onEdited: function(v) { root.setObject("radius", v); } }
                                }
                                S.SNumRow { label: "Opacity"; visible: !!root.currentObject && root.currentObject.type !== "hotspot"; value: root.currentObject ? root.currentObject.opacity : 1; decimals: 2; step: 0.05; onEdited: function(v) { root.setObject("opacity", v); } }
                            }
                        }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                S.SLabel { Layout.fillWidth: true; text: root.status; elide: Text.ElideRight }
                S.SLabel { text: "Running panel: " + root.stateName(root.runtimeState); dim: true }
            }
        }
    }
}
