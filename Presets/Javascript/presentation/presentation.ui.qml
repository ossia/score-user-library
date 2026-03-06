import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "SlideRender.js" as SlideRender

Score.ScriptUI {
    id: root
    anchors.fill: parent

    property var slides: [SlideRender.defaultSlideState()]
    property int currentSlideIndex: 0
    property var slideState: slides[0]
    property int stateVersion: 0
    property int selectedObj: -1
    property int listDragIndex: -1
    property int listDropIndex: -1
    property int slideDragIndex: -1
    property int slideDropIndex: -1
    property real renderWidth: 0
    property real renderHeight: 0
    property int editingTextIdx: -1

    // Viewport drag state
    property bool isDragging: false
    property string dragType: ""  // "move", "resize-tl", "resize-tr", "resize-bl", "resize-br", "resize-t", "resize-b", "resize-l", "resize-r"
    property real dragStartMX: 0
    property real dragStartMY: 0
    property real dragOrigX: 0
    property real dragOrigY: 0
    property real dragOrigW: 0
    property real dragOrigH: 0

    // ---- State management ----

    function sendLive() {
        root.executionSend({
            type: "updateSlides",
            slides: root.slides,
            currentSlideIndex: root.currentSlideIndex
        });
    }
    function saveState(action) {
        root.beginUpdateState(action || "Edit slide");
        root.updateState("slideState", JSON.stringify({
            slides: root.slides,
            currentSlideIndex: root.currentSlideIndex
        }));
        root.endUpdateState();
    }
    function setObjProp(key, val) {
        var idx = root.selectedObj;
        if (idx < 0 || idx >= root.slideState.objects.length) return;
        root.slideState.objects[idx][key] = val;
        root.stateVersion++;
        sendLive();
    }
    function setObjPropAndSave(key, val, action) {
        setObjProp(key, val);
        saveState(action);
    }
    function setBgProp(key, val) {
        root.slideState[key] = val;
        root.stateVersion++;
        sendLive();
    }
    function setBgPropAndSave(key, val, action) {
        setBgProp(key, val);
        saveState(action);
    }

    function curObj() {
        var idx = root.selectedObj;
        if (idx < 0 || !root.slideState.objects || idx >= root.slideState.objects.length) return null;
        return root.slideState.objects[idx];
    }

    // ---- Slide operations ----

    function selectSlide(idx) {
        if (idx < 0 || idx >= root.slides.length) return;
        root.currentSlideIndex = idx;
        root.slideState = root.slides[idx];
        root.selectedObj = -1;
        root.editingTextIdx = -1;
        root.stateVersion++;
        sendLive();
    }

    function addSlide() {
        root.slides.push(SlideRender.defaultSlideState());
        root.currentSlideIndex = root.slides.length - 1;
        root.slideState = root.slides[root.currentSlideIndex];
        root.selectedObj = -1;
        root.editingTextIdx = -1;
        root.stateVersion++;
        sendLive();
        saveState("Add slide");
    }

    function duplicateSlide(idx) {
        if (idx < 0 || idx >= root.slides.length) return;
        var dup = SlideRender.cloneSlide(root.slides[idx]);
        root.slides.splice(idx + 1, 0, dup);
        root.currentSlideIndex = idx + 1;
        root.slideState = root.slides[root.currentSlideIndex];
        root.selectedObj = -1;
        root.editingTextIdx = -1;
        root.stateVersion++;
        sendLive();
        saveState("Duplicate slide");
    }

    function deleteSlide(idx) {
        if (root.slides.length <= 1) return;
        if (idx < 0 || idx >= root.slides.length) return;
        root.slides.splice(idx, 1);
        if (root.currentSlideIndex >= root.slides.length)
            root.currentSlideIndex = root.slides.length - 1;
        root.slideState = root.slides[root.currentSlideIndex];
        root.selectedObj = -1;
        root.editingTextIdx = -1;
        root.stateVersion++;
        sendLive();
        saveState("Delete slide");
    }

    function moveSlide(fromIdx, toIdx) {
        if (fromIdx === toIdx) return;
        if (fromIdx < 0 || fromIdx >= root.slides.length) return;
        if (toIdx < 0 || toIdx >= root.slides.length) return;
        var item = root.slides.splice(fromIdx, 1)[0];
        root.slides.splice(toIdx, 0, item);
        root.currentSlideIndex = toIdx;
        root.slideState = root.slides[toIdx];
        root.stateVersion++;
        sendLive();
        saveState("Reorder slides");
    }

    function loadMultiSlideState(s) {
        if (s.slides && Array.isArray(s.slides)) {
            root.slides = s.slides.map(function(sl) {
                return SlideRender.mergeState(SlideRender.defaultSlideState(), sl);
            });
            root.currentSlideIndex = Math.min(s.currentSlideIndex || 0, root.slides.length - 1);
        } else {
            root.slides = [SlideRender.mergeState(SlideRender.defaultSlideState(), s)];
            root.currentSlideIndex = 0;
        }
        root.slideState = root.slides[root.currentSlideIndex];
    }

    loadState: function(state) {
        if (state && state.slideState) {
            try {
                var s = typeof state.slideState === "string"
                    ? JSON.parse(state.slideState) : state.slideState;
                root.loadMultiSlideState(s);
            } catch(e) {
                root.slides = [SlideRender.defaultSlideState()];
                root.currentSlideIndex = 0;
                root.slideState = root.slides[0];
            }
        } else {
            root.slides = [SlideRender.defaultSlideState()];
            root.currentSlideIndex = 0;
            root.slideState = root.slides[0];
        }
        root.selectedObj = -1;
        root.editingTextIdx = -1;
        root.stateVersion++;
    }
    stateUpdated: function(k, v) {
        if (k === "slideState") {
            try {
                var s = typeof v === "string" ? JSON.parse(v) : v;
                root.loadMultiSlideState(s);
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

    // ---- Object actions ----

    function addObject(type) {
        var objs = root.slideState.objects;
        var obj = SlideRender.createObject(type, objs.length);
        objs.push(obj);
        root.selectedObj = objs.length - 1;
        root.stateVersion++;
        sendLive();
        saveState("Add " + type);
    }

    function deleteObject(idx) {
        var objs = root.slideState.objects;
        if (idx < 0 || idx >= objs.length) return;
        objs.splice(idx, 1);
        if (root.selectedObj >= objs.length) root.selectedObj = objs.length - 1;
        root.stateVersion++;
        sendLive();
        saveState("Delete object");
    }

    function moveObject(fromIdx, toIdx) {
        var objs = root.slideState.objects;
        if (fromIdx === toIdx || fromIdx < 0 || fromIdx >= objs.length || toIdx < 0 || toIdx >= objs.length) return;
        var item = objs.splice(fromIdx, 1)[0];
        objs.splice(toIdx, 0, item);
        root.selectedObj = toIdx;
        root.stateVersion++;
        sendLive();
        saveState("Reorder layers");
    }

    function duplicateObject(idx) {
        var objs = root.slideState.objects;
        if (idx < 0 || idx >= objs.length) return;
        var dup = JSON.parse(JSON.stringify(objs[idx]));
        dup.id = "obj-" + Date.now();
        dup.name = dup.name + " copy";
        dup.x += 0.02;
        dup.y += 0.02;
        objs.push(dup);
        root.selectedObj = objs.length - 1;
        root.stateVersion++;
        sendLive();
        saveState("Duplicate object");
    }

    // Hit-test: find topmost (highest index) visible object at normalized (nx, ny)
    function hitTestObject(nx, ny) {
        var objs = root.slideState.objects;
        if (!objs) return -1;
        for (var i = objs.length - 1; i >= 0; i--) {
            var o = objs[i];
            if (o.visible === false || o.locked) continue;
            if (nx >= o.x && nx <= o.x + o.w && ny >= o.y && ny <= o.y + o.h)
                return i;
        }
        return -1;
    }

    // ---- Inline components ----

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

    component ObjColorRow: RowLayout {
        property string label
        property string key
        spacing: 4
        Lbl { text: label }
        Rectangle {
            width: 18; height: 18
            color: { root.stateVersion; var o = root.curObj(); return o ? (o[key] || "#000") : "#000"; }
            border.color: "#666"; border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colorDialog.targetKey = key;
                    colorDialog.targetLabel = label;
                    colorDialog.isBg = false;
                    var o = root.curObj();
                    colorDialog.selectedColor = o ? o[key] : "#000000";
                    colorDialog.open();
                }
            }
        }
        TextField {
            Layout.fillWidth: true; Layout.preferredHeight: 22
            text: { root.stateVersion; var o = root.curObj(); return o ? (o[key] || "#000000") : "#000000"; }
            font.pixelSize: 10; color: "#eee"
            verticalAlignment: Text.AlignVCenter
            background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
            onEditingFinished: root.setObjPropAndSave(key, text, "Change " + label.toLowerCase())
        }
    }

    component BgColorRow: RowLayout {
        property string label
        property string key
        spacing: 4
        Lbl { text: label }
        Rectangle {
            width: 18; height: 18
            color: (root.stateVersion, root.slideState[key] || "#000")
            border.color: "#666"; border.width: 1
            MouseArea {
                anchors.fill: parent
                onClicked: {
                    colorDialog.targetKey = key;
                    colorDialog.targetLabel = label;
                    colorDialog.isBg = true;
                    colorDialog.selectedColor = parent.color;
                    colorDialog.open();
                }
            }
        }
        TextField {
            Layout.fillWidth: true; Layout.preferredHeight: 22
            text: (root.stateVersion, root.slideState[key] || "#000000")
            font.pixelSize: 10; color: "#eee"
            verticalAlignment: Text.AlignVCenter
            background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
            onEditingFinished: root.setBgPropAndSave(key, text, "Change " + label.toLowerCase())
        }
    }

    component ObjSliderRow: RowLayout {
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
            value: { root.stateVersion; var o = root.curObj(); return o && o[key] !== undefined ? o[key] : fallback; }
            onMoved: root.setObjProp(key, value)
            onPressedChanged: if (!pressed) root.saveState("Change " + label.toLowerCase())
        }
        Val {
            property real v: { root.stateVersion; var o = root.curObj(); return o && o[key] !== undefined ? o[key] : fallback; }
            text: (decimals > 0 ? v.toFixed(decimals) : Math.round(v)) + suffix
        }
    }

    ColorDialog {
        id: colorDialog
        property string targetKey: ""
        property string targetLabel: ""
        property bool isBg: false
        onAccepted: {
            if (isBg)
                root.setBgPropAndSave(targetKey, selectedColor.toString(), "Change " + targetLabel.toLowerCase());
            else
                root.setObjPropAndSave(targetKey, selectedColor.toString(), "Change " + targetLabel.toLowerCase());
        }
    }

    // ---- Main layout ----

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

    SplitView {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4

        // ======== Left panel: Object list ========
        ColumnLayout {
            SplitView.preferredWidth: 180
            SplitView.minimumWidth: 120
            SplitView.maximumWidth: 280
            SplitView.fillHeight: true
            spacing: 4

            // ---- Slide list section ----
            Hdr { id: hSlides; title: "Slides"; Layout.fillWidth: true; on: true }
            ColumnLayout {
                visible: hSlides.on
                Layout.fillWidth: true
                spacing: 2

                RowLayout {
                    Layout.fillWidth: true
                    Layout.margins: 4
                    spacing: 2
                    Button {
                        text: "+ Slide"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        onClicked: root.addSlide()
                    }
                    Button {
                        text: "Duplicate"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        onClicked: root.duplicateSlide(root.currentSlideIndex)
                    }
                    Button {
                        text: "Delete"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        enabled: root.slides.length > 1
                        onClicked: root.deleteSlide(root.currentSlideIndex)
                    }
                }

                ListView {
                    id: slideListView
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(root.slides.length * 28, 150)
                    Layout.minimumHeight: 28
                    clip: true
                    spacing: 1

                    model: {
                        root.stateVersion;
                        return root.slides ? root.slides.length : 1;
                    }

                    delegate: Rectangle {
                        id: slideDel
                        required property int index
                        width: slideListView.width
                        height: 26
                        radius: 3
                        color: {
                            if (root.slideDragIndex >= 0 && root.slideDropIndex === slideDel.index
                                && root.slideDragIndex !== slideDel.index)
                                return palette.mid;
                            return root.currentSlideIndex === slideDel.index
                                ? palette.highlight
                                : (slideDel.index % 2 ? palette.alternateBase : palette.base);
                        }
                        border.color: root.currentSlideIndex === slideDel.index
                            ? palette.light : "transparent"
                        border.width: 1

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 4
                            spacing: 4

                            Label {
                                text: "\u2261"
                                font.pixelSize: 14
                                color: palette.windowText
                                Layout.preferredWidth: 14
                                MouseArea {
                                    anchors.fill: parent
                                    anchors.margins: -4
                                    cursorShape: Qt.OpenHandCursor
                                    preventStealing: true
                                    onPressed: function(mouse) {
                                        root.slideDragIndex = slideDel.index;
                                        root.slideDropIndex = slideDel.index;
                                    }
                                    onPositionChanged: function(mouse) {
                                        if (root.slideDragIndex < 0) return;
                                        var y = mapToItem(slideListView, 0, mouse.y).y;
                                        var delegateH = slideDel.height + slideListView.spacing;
                                        var targetIdx = Math.floor((y + delegateH / 2) / delegateH);
                                        targetIdx = Math.max(0, Math.min(root.slides.length - 1, targetIdx));
                                        root.slideDropIndex = targetIdx;
                                    }
                                    onReleased: {
                                        if (root.slideDragIndex >= 0 && root.slideDropIndex >= 0
                                            && root.slideDragIndex !== root.slideDropIndex) {
                                            root.moveSlide(root.slideDragIndex, root.slideDropIndex);
                                        }
                                        root.slideDragIndex = -1;
                                        root.slideDropIndex = -1;
                                    }
                                }
                            }

                            Text {
                                text: "Slide " + (slideDel.index + 1)
                                font.pixelSize: 11
                                font.bold: root.currentSlideIndex === slideDel.index
                                color: palette.text
                                Layout.fillWidth: true
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            z: -1
                            onClicked: root.selectSlide(slideDel.index)
                        }
                    }
                }
            }

            Rectangle { Layout.fillWidth: true; height: 1; color: "#444" }

            // Slide format section
            Hdr { id: hFormat; title: "Format"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hFormat.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "Preset" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["fill", "16:9", "4:3", "1:1", "9:16", "custom"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["fill","16:9","4:3","1:1","9:16","custom"].indexOf(root.slideState.slideFormat || "fill")); }
                        onActivated: {
                            root.slideState.slideFormat = model[currentIndex];
                            root.stateVersion++;
                            root.sendLive();
                            root.saveState("Change slide format");
                        }
                    }
                }
                RowLayout {
                    visible: (root.stateVersion, root.slideState.slideFormat === "custom")
                    spacing: 4
                    Lbl { text: "Width" }
                    TextField {
                        Layout.fillWidth: true; Layout.preferredHeight: 22
                        text: (root.stateVersion, root.slideState.customWidth || 1920)
                        font.pixelSize: 10; color: "#eee"
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
                        validator: IntValidator { bottom: 1; top: 16384 }
                        onEditingFinished: {
                            root.slideState.customWidth = parseInt(text) || 1920;
                            root.stateVersion++;
                            root.sendLive();
                            root.saveState("Change custom width");
                        }
                    }
                }
                RowLayout {
                    visible: (root.stateVersion, root.slideState.slideFormat === "custom")
                    spacing: 4
                    Lbl { text: "Height" }
                    TextField {
                        Layout.fillWidth: true; Layout.preferredHeight: 22
                        text: (root.stateVersion, root.slideState.customHeight || 1080)
                        font.pixelSize: 10; color: "#eee"
                        verticalAlignment: Text.AlignVCenter
                        background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
                        validator: IntValidator { bottom: 1; top: 16384 }
                        onEditingFinished: {
                            root.slideState.customHeight = parseInt(text) || 1080;
                            root.stateVersion++;
                            root.sendLive();
                            root.saveState("Change custom height");
                        }
                    }
                }
            }

            // Add buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 2
                Button { text: "+ Rect"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("rect") }
                Button { text: "+ Ellipse"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("ellipse") }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 2
                Button { text: "+ Image"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("image") }
                Button { text: "+ Text"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("text") }
            }

            // Object list
            ListView {
                id: objListView
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 2

                model: {
                    root.stateVersion;
                    return root.slideState.objects ? root.slideState.objects.length : 0;
                }

                delegate: Rectangle {
                    id: listDel
                    required property int index
                    property int delIndex: index
                    width: objListView.width
                    height: delRow.implicitHeight + 8
                    radius: 4
                    color: {
                        if (root.listDragIndex >= 0 && root.listDropIndex === delIndex && root.listDragIndex !== delIndex)
                            return palette.mid;
                        return root.selectedObj === delIndex ? palette.highlight : (delIndex % 2 ? palette.alternateBase : palette.base);
                    }
                    border.color: root.selectedObj === delIndex ? palette.light : "transparent"
                    border.width: 1

                    property var od: {
                        root.stateVersion;
                        var objs = root.slideState.objects;
                        return (objs && delIndex < objs.length) ? objs[delIndex] : null;
                    }
                    opacity: (listDel.od && listDel.od.visible === false) ? 0.4 : 1.0

                    MouseArea {
                        anchors.fill: parent
                        onClicked: { root.forceActiveFocus(); root.selectedObj = listDel.delIndex; }
                    }

                    RowLayout {
                        id: delRow
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.margins: 4
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 4

                        // Drag handle
                        Label {
                            text: "\u2261"
                            font.pixelSize: 14
                            color: palette.windowText
                            Layout.preferredWidth: 14

                            MouseArea {
                                anchors.fill: parent
                                anchors.margins: -4
                                cursorShape: Qt.OpenHandCursor
                                preventStealing: true

                                onPressed: function(mouse) {
                                    root.listDragIndex = listDel.delIndex;
                                    root.listDropIndex = listDel.delIndex;
                                    root.selectedObj = listDel.delIndex;
                                }
                                onPositionChanged: function(mouse) {
                                    if (root.listDragIndex < 0) return;
                                    var y = mapToItem(objListView, 0, mouse.y).y;
                                    var delegateH = listDel.height + objListView.spacing;
                                    var targetIdx = Math.floor((y + delegateH / 2) / delegateH);
                                    targetIdx = Math.max(0, Math.min(root.slideState.objects.length - 1, targetIdx));
                                    root.listDropIndex = targetIdx;
                                }
                                onReleased: {
                                    if (root.listDragIndex >= 0 && root.listDropIndex >= 0 && root.listDragIndex !== root.listDropIndex) {
                                        root.moveObject(root.listDragIndex, root.listDropIndex);
                                    }
                                    root.listDragIndex = -1;
                                    root.listDropIndex = -1;
                                }
                            }
                        }

                        // Visibility toggle
                        Label {
                            text: (listDel.od && listDel.od.visible !== false) ? "\u{1f441}" : "\u25cb"
                            font.pixelSize: 11
                            color: palette.windowText
                            Layout.preferredWidth: 16
                            MouseArea {
                                anchors.fill: parent
                                onClicked: {
                                    var objs = root.slideState.objects;
                                    if (listDel.delIndex < objs.length) {
                                        objs[listDel.delIndex].visible = !(objs[listDel.delIndex].visible !== false);
                                        root.stateVersion++;
                                        root.sendLive();
                                        root.saveState("Toggle visibility");
                                    }
                                }
                            }
                        }

                        // Color swatch
                        Rectangle {
                            width: 10; height: 10; radius: 2
                            color: {
                                if (!listDel.od) return palette.mid;
                                if (listDel.od.type === "image") return "#6688cc";
                                if (listDel.od.type === "text") return "#cc8866";
                                return listDel.od.fillColor || "#ffffff";
                            }
                        }

                        // Editable name
                        TextInput {
                            text: listDel.od ? listDel.od.name : ""
                            font.bold: true
                            font.pixelSize: 11
                            color: palette.text
                            Layout.fillWidth: true
                            selectByMouse: true
                            function commitName() {
                                var objs = root.slideState.objects;
                                if (listDel.delIndex < objs.length && objs[listDel.delIndex].name !== text) {
                                    objs[listDel.delIndex].name = text;
                                    root.stateVersion++;
                                    root.saveState("Rename object");
                                    root.sendLive();
                                }
                            }
                            onEditingFinished: { commitName(); focus = false; }
                            onActiveFocusChanged: if (!activeFocus) commitName()
                        }

                        // Delete button
                        Button {
                            text: "\u2715"
                            flat: true
                            implicitWidth: 18; implicitHeight: 18
                            font.pixelSize: 12
                            onClicked: root.deleteObject(listDel.delIndex)
                        }
                    }
                }
            }

            // ---- Background section ----
            Hdr { id: hBg; title: "Background"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hBg.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "Type" }
                    ComboBox {
                        Layout.fillWidth: true
                        model: ["solid", "linearGradient", "radialGradient", "texture"]
                        currentIndex: { root.stateVersion; return Math.max(0, ["solid","linearGradient","radialGradient","texture"].indexOf(root.slideState.bgType)); }
                        onActivated: root.setBgPropAndSave("bgType", model[currentIndex], "Change bg type")
                    }
                }
                BgColorRow {
                    visible: (root.stateVersion, !root.slideState.bgType || root.slideState.bgType === "solid")
                    Layout.fillWidth: true; label: "Color"; key: "bgColor"
                }
                ColumnLayout {
                    visible: (root.stateVersion, root.slideState.bgType === "linearGradient" || root.slideState.bgType === "radialGradient")
                    Layout.fillWidth: true; spacing: 4
                    BgColorRow { Layout.fillWidth: true; label: "Start"; key: "bgGradStart" }
                    BgColorRow { Layout.fillWidth: true; label: "End"; key: "bgGradEnd" }
                    RowLayout {
                        visible: (root.stateVersion, root.slideState.bgType === "linearGradient")
                        spacing: 4
                        Lbl { text: "Angle" }
                        Slider {
                            Layout.fillWidth: true
                            from: 0; to: 360; stepSize: 1
                            value: (root.stateVersion, root.slideState.bgGradAngle || 90)
                            onMoved: root.setBgProp("bgGradAngle", value)
                            onPressedChanged: if (!pressed) root.saveState("Change bg angle")
                        }
                        Val { text: Math.round(root.stateVersion, root.slideState.bgGradAngle || 90) + "\u00b0" }
                    }
                }
                ColumnLayout {
                    visible: (root.stateVersion, root.slideState.bgType === "texture")
                    Layout.fillWidth: true; spacing: 4
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Source" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Image 1","Image 2","Image 3","Image 4","Image 5","Image 6","Image 7","Image 8"]
                            currentIndex: (root.stateVersion, root.slideState.bgTexSource || 0)
                            onActivated: root.setBgPropAndSave("bgTexSource", currentIndex, "Change bg source")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Fit" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["cover", "contain", "stretch", "tile"]
                            currentIndex: { root.stateVersion; return Math.max(0, ["cover","contain","stretch","tile"].indexOf(root.slideState.bgTexFit)); }
                            onActivated: root.setBgPropAndSave("bgTexFit", model[currentIndex], "Change bg fit")
                        }
                    }
                }
            }
        }

        // ======== Center panel: Visual canvas ========
        Item {
            id: viewport
            SplitView.fillWidth: true
            SplitView.fillHeight: true
            clip: true

            // Effective aspect ratio: always letterbox to match the output
            // For explicit formats, use the format ratio.
            // For "fill", use the actual output render dimensions so the
            // preview matches what the output produces.
            property real effectiveRatio: {
                root.stateVersion;
                var ratio = SlideRender.getFormatRatio(root.slideState);
                if (ratio > 0) return ratio;
                // "fill" mode: match output render aspect ratio
                if (root.renderWidth > 0 && root.renderHeight > 0)
                    return root.renderWidth / root.renderHeight;
                return 16 / 9; // sensible default before output size is known
            }

            property real canvasX: {
                var ratio = effectiveRatio;
                var viewRatio = width / Math.max(1, height);
                if (viewRatio > ratio) return (width - height * ratio) / 2;
                return 0;
            }
            property real canvasY: {
                var ratio = effectiveRatio;
                var viewRatio = width / Math.max(1, height);
                if (viewRatio <= ratio) return (height - width / ratio) / 2;
                return 0;
            }
            property real canvasW: {
                var ratio = effectiveRatio;
                var viewRatio = width / Math.max(1, height);
                if (viewRatio > ratio) return height * ratio;
                return width;
            }
            property real canvasH: {
                var ratio = effectiveRatio;
                var viewRatio = width / Math.max(1, height);
                if (viewRatio <= ratio) return width / ratio;
                return height;
            }

            Rectangle {
                anchors.fill: parent
                color: "#333"
            }

            // Active slide area background
            Rectangle {
                x: viewport.canvasX; y: viewport.canvasY
                width: viewport.canvasW; height: viewport.canvasH
                color: palette.base
            }

            // Background grid (within canvas area)
            Canvas {
                x: viewport.canvasX; y: viewport.canvasY
                width: viewport.canvasW; height: viewport.canvasH
                onPaint: {
                    var ctx = getContext("2d");
                    ctx.clearRect(0, 0, width, height);
                    ctx.strokeStyle = "rgba(255,255,255,0.08)";
                    ctx.lineWidth = 1;
                    var step = Math.max(width, height) / 10;
                    for (var gx = step; gx < width; gx += step) {
                        ctx.beginPath(); ctx.moveTo(gx, 0); ctx.lineTo(gx, height); ctx.stroke();
                    }
                    for (var gy = step; gy < height; gy += step) {
                        ctx.beginPath(); ctx.moveTo(0, gy); ctx.lineTo(width, gy); ctx.stroke();
                    }
                }
            }

            // Object overlay canvas — WYSIWYG rendering
            Canvas {
                id: slideOverlay
                x: viewport.canvasX
                y: viewport.canvasY
                width: viewport.canvasW
                height: viewport.canvasH

                property int ver: root.stateVersion
                onVerChanged: requestPaint()

                function loadFileImages() {
                    var objs = root.slideState.objects;
                    if (!objs) return;
                    for (var i = 0; i < objs.length; i++) {
                        var url = objs[i].imageFileUrl;
                        if (url && url.length > 0 && !isImageLoaded(url)) {
                            loadImage(url);
                        }
                    }
                }

                onImageLoaded: requestPaint()

                onPaint: {
                    loadFileImages();
                    var ctx = getContext("2d");
                    var w = width, h = height;

                    // Render actual slide content (pass null for inlets — not available in UI)
                    SlideRender.paintSlide(ctx, w, h, root.slideState, null, 1, root.editingTextIdx);

                    // Draw selection decorations on top
                    var objs = root.slideState.objects;
                    if (!objs) return;

                    if (root.selectedObj >= 0 && root.selectedObj < objs.length) {
                        var sel = objs[root.selectedObj];
                        var sx = sel.x * w, sy = sel.y * h;
                        var sw = sel.w * w, sh = sel.h * h;

                        ctx.strokeStyle = "#c58014";
                        ctx.lineWidth = 1;
                        ctx.setLineDash([4, 4]);
                        ctx.strokeRect(sx, sy, sw, sh);
                        ctx.setLineDash([]);
                    }
                }
            }

            // Main mouse area for click-to-select, drag-to-move, and double-click text editing
            MouseArea {
                anchors.fill: parent
                z: 1

                onPressed: function(mouse) {
                    root.forceActiveFocus();
                    if (root.editingTextIdx >= 0) {
                        root.editingTextIdx = -1;
                        root.stateVersion++;
                    }
                    var nx = (mouse.x - viewport.canvasX) / viewport.canvasW;
                    var ny = (mouse.y - viewport.canvasY) / viewport.canvasH;
                    var hitIdx = root.hitTestObject(nx, ny);
                    if (hitIdx >= 0) {
                        root.selectedObj = hitIdx;
                        var o = root.slideState.objects[hitIdx];
                        root.isDragging = true;
                        root.dragType = "move";
                        root.dragStartMX = nx;
                        root.dragStartMY = ny;
                        root.dragOrigX = o.x;
                        root.dragOrigY = o.y;
                        root.dragOrigW = o.w;
                        root.dragOrigH = o.h;
                        root.beginUpdateState("Move object");
                    } else {
                        root.selectedObj = -1;
                        root.stateVersion++;
                    }
                }

                onPositionChanged: function(mouse) {
                    if (!root.isDragging) return;
                    var nx = (mouse.x - viewport.canvasX) / viewport.canvasW;
                    var ny = (mouse.y - viewport.canvasY) / viewport.canvasH;
                    var dx = nx - root.dragStartMX;
                    var dy = ny - root.dragStartMY;
                    var o = root.slideState.objects[root.selectedObj];
                    if (!o) return;

                    if (root.dragType === "move") {
                        o.x = root.dragOrigX + dx;
                        o.y = root.dragOrigY + dy;
                    }
                    root.stateVersion++;
                    root.sendLive();
                }

                onReleased: {
                    if (!root.isDragging) return;
                    root.isDragging = false;
                    root.updateState("slideState", JSON.stringify({ slides: root.slides, currentSlideIndex: root.currentSlideIndex }));
                    root.endUpdateState();
                    root.dragType = "";
                }

                onDoubleClicked: function(mouse) {
                    var nx = (mouse.x - viewport.canvasX) / viewport.canvasW;
                    var ny = (mouse.y - viewport.canvasY) / viewport.canvasH;
                    var hitIdx = root.hitTestObject(nx, ny);
                    if (hitIdx >= 0 && root.slideState.objects[hitIdx].type === "text") {
                        root.selectedObj = hitIdx;
                        root.editingTextIdx = hitIdx;
                        root.stateVersion++;
                    }
                }
            }

            // DropArea for image file drag-and-drop
            DropArea {
                anchors.fill: parent
                z: 2
                keys: ["text/uri-list"]
                onDropped: function(drop) {
                    var validExts = [".png", ".jpg", ".jpeg", ".gif", ".bmp", ".svg", ".webp"];
                    var urls = drop.urls;
                    for (var i = 0; i < urls.length; i++) {
                        var url = urls[i].toString();
                        var lower = url.toLowerCase();
                        var isImage = false;
                        for (var e = 0; e < validExts.length; e++) {
                            if (lower.endsWith(validExts[e])) { isImage = true; break; }
                        }
                        if (isImage) {
                            var objs = root.slideState.objects;
                            var obj = SlideRender.createObject("image", objs.length);
                            obj.imageFileUrl = url;
                            obj.name = url.substring(url.lastIndexOf("/") + 1);
                            objs.push(obj);
                            root.selectedObj = objs.length - 1;
                        }
                    }
                    root.stateVersion++;
                    root.sendLive();
                    root.saveState("Import image");
                }
            }

            // Inline text editing overlay
            TextArea {
                id: inlineTextEdit
                visible: root.editingTextIdx >= 0
                z: 5

                property var editObj: {
                    root.stateVersion;
                    if (root.editingTextIdx < 0 || root.editingTextIdx >= root.slideState.objects.length) return null;
                    return root.slideState.objects[root.editingTextIdx];
                }

                x: editObj ? editObj.x * viewport.canvasW + viewport.canvasX : 0
                y: editObj ? editObj.y * viewport.canvasH + viewport.canvasY : 0
                width: editObj ? editObj.w * viewport.canvasW : 100
                height: editObj ? editObj.h * viewport.canvasH : 50

                text: editObj ? (editObj.text || "") : ""
                wrapMode: TextEdit.Wrap
                color: editObj ? (editObj.textColor || "#ffffff") : "#ffffff"
                font.family: editObj ? (editObj.fontFamily || "IBM Plex Sans") : "IBM Plex Sans"
                font.pixelSize: editObj ? (editObj.fontSize || 36) * viewport.canvasH / 1080 : 12
                font.bold: editObj ? editObj.fontWeight === "bold" : false
                font.italic: editObj ? editObj.fontStyle === "italic" : false
                horizontalAlignment: editObj ? (editObj.hAlign === "center" ? Text.AlignHCenter : (editObj.hAlign === "right" ? Text.AlignRight : Text.AlignLeft)) : Text.AlignHCenter
                verticalAlignment: editObj ? (editObj.vAlign === "center" ? Text.AlignVCenter : (editObj.vAlign === "bottom" ? Text.AlignBottom : Text.AlignTop)) : Text.AlignVCenter

                background: Rectangle {
                    color: "transparent"
                    border.color: "#c58014"
                    border.width: 2
                }

                onVisibleChanged: if (visible) forceActiveFocus()

                onTextChanged: {
                    if (root.editingTextIdx >= 0 && root.editingTextIdx < root.slideState.objects.length) {
                        var o = root.slideState.objects[root.editingTextIdx];
                        if (o && o.text !== text) {
                            o.text = text;
                            root.stateVersion++;
                            root.sendLive();
                        }
                    }
                }

                onActiveFocusChanged: {
                    if (!activeFocus && root.editingTextIdx >= 0) {
                        root.saveState("Edit text");
                        root.editingTextIdx = -1;
                        root.stateVersion++;
                    }
                }
            }

            // Resize handles for selected object (8 handles: 4 corners + 4 edges)
            // Uses fixed integer model so delegates survive stateVersion changes during drag
            Repeater {
                id: resizeHandles
                readonly property var handleDefs: [
                    { fx: 0,   fy: 0,   dt: "resize-tl", cur: Qt.SizeFDiagCursor },
                    { fx: 0.5, fy: 0,   dt: "resize-t",  cur: Qt.SizeVerCursor },
                    { fx: 1,   fy: 0,   dt: "resize-tr", cur: Qt.SizeBDiagCursor },
                    { fx: 0,   fy: 0.5, dt: "resize-l",  cur: Qt.SizeHorCursor },
                    { fx: 1,   fy: 0.5, dt: "resize-r",  cur: Qt.SizeHorCursor },
                    { fx: 0,   fy: 1,   dt: "resize-bl", cur: Qt.SizeBDiagCursor },
                    { fx: 0.5, fy: 1,   dt: "resize-b",  cur: Qt.SizeVerCursor },
                    { fx: 1,   fy: 1,   dt: "resize-br", cur: Qt.SizeFDiagCursor }
                ]

                model: {
                    root.stateVersion;
                    if (root.selectedObj < 0 || !root.slideState.objects || root.selectedObj >= root.slideState.objects.length) return 0;
                    var o = root.slideState.objects[root.selectedObj];
                    if (!o || o.locked) return 0;
                    return 8;
                }

                Rectangle {
                    id: resHandle
                    required property int index
                    property var hDef: resizeHandles.handleDefs[index]

                    x: { root.stateVersion;
                         var o = root.selectedObj >= 0 && root.selectedObj < root.slideState.objects.length ? root.slideState.objects[root.selectedObj] : null;
                         return o ? (o.x + o.w * hDef.fx) * viewport.canvasW + viewport.canvasX - 5 : -100; }
                    y: { root.stateVersion;
                         var o = root.selectedObj >= 0 && root.selectedObj < root.slideState.objects.length ? root.slideState.objects[root.selectedObj] : null;
                         return o ? (o.y + o.h * hDef.fy) * viewport.canvasH + viewport.canvasY - 5 : -100; }
                    width: 10; height: 10
                    color: "#c58014"
                    border.color: "#fff"
                    border.width: 1
                    z: 10
                    visible: { root.stateVersion;
                               return root.selectedObj >= 0 && root.selectedObj < root.slideState.objects.length
                                   && root.slideState.objects[root.selectedObj]
                                   && !root.slideState.objects[root.selectedObj].locked; }

                    MouseArea {
                        anchors.fill: parent
                        anchors.margins: -4
                        cursorShape: resHandle.hDef.cur
                        preventStealing: true

                        property real startMX; property real startMY
                        property real origX; property real origY
                        property real origW; property real origH
                        property bool active: false

                        onPressed: function(mouse) {
                            var o = root.selectedObj >= 0 && root.selectedObj < root.slideState.objects.length ? root.slideState.objects[root.selectedObj] : null;
                            if (!o) return;
                            active = true;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            startMX = (p.x - viewport.canvasX) / viewport.canvasW;
                            startMY = (p.y - viewport.canvasY) / viewport.canvasH;
                            origX = o.x; origY = o.y;
                            origW = o.w; origH = o.h;
                            root.isDragging = true;
                            root.dragType = resHandle.hDef.dt;
                            root.beginUpdateState("Resize object");
                        }

                        onPositionChanged: function(mouse) {
                            if (!active) return;
                            var o = root.selectedObj >= 0 && root.selectedObj < root.slideState.objects.length ? root.slideState.objects[root.selectedObj] : null;
                            if (!o) return;
                            var p = mapToItem(viewport, mouse.x, mouse.y);
                            var nx = (p.x - viewport.canvasX) / viewport.canvasW;
                            var ny = (p.y - viewport.canvasY) / viewport.canvasH;
                            var dx = nx - startMX;
                            var dy = ny - startMY;
                            var dt = resHandle.hDef.dt;
                            var minS = 0.01;

                            var newX = origX, newY = origY;
                            var newW = origW, newH = origH;

                            // Horizontal
                            if (dt === "resize-tl" || dt === "resize-l" || dt === "resize-bl") {
                                newX = origX + dx;
                                newW = origW - dx;
                                if (newW < minS) { newX += newW - minS; newW = minS; }
                            }
                            if (dt === "resize-tr" || dt === "resize-r" || dt === "resize-br") {
                                newW = origW + dx;
                                if (newW < minS) newW = minS;
                            }
                            // Vertical
                            if (dt === "resize-tl" || dt === "resize-t" || dt === "resize-tr") {
                                newY = origY + dy;
                                newH = origH - dy;
                                if (newH < minS) { newY += newH - minS; newH = minS; }
                            }
                            if (dt === "resize-bl" || dt === "resize-b" || dt === "resize-br") {
                                newH = origH + dy;
                                if (newH < minS) newH = minS;
                            }

                            o.x = newX; o.y = newY; o.w = newW; o.h = newH;
                            root.stateVersion++;
                            root.sendLive();
                        }

                        onReleased: {
                            if (!active) return;
                            active = false;
                            root.isDragging = false;
                            root.dragType = "";
                            root.updateState("slideState", JSON.stringify({ slides: root.slides, currentSlideIndex: root.currentSlideIndex }));
                            root.endUpdateState();
                        }
                    }
                }
            }
        }

        // ======== Right panel: Property editor ========
        ScrollView {
            id: propScroll
            SplitView.preferredWidth: 250
            SplitView.minimumWidth: 180
            SplitView.maximumWidth: 400
            SplitView.fillHeight: true
            contentWidth: availableWidth

            ColumnLayout {
                width: propScroll.availableWidth
                spacing: 0

                // No selection message
                Text {
                    visible: { root.stateVersion; return root.selectedObj < 0 || !root.slideState.objects || root.selectedObj >= root.slideState.objects.length; }
                    text: "Select an object to edit its properties"
                    color: "#888"; font.pixelSize: 12; font.italic: true
                    Layout.fillWidth: true; Layout.margins: 12
                    horizontalAlignment: Text.AlignHCenter
                }

                // ======== GEOMETRY ========
                Hdr {
                    id: hGeo; title: "Geometry"; Layout.fillWidth: true
                    visible: root.curObj() !== null
                }
                ColumnLayout {
                    visible: hGeo.on && hGeo.visible; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                    ObjSliderRow { label: "X"; key: "x"; lo: -0.5; hi: 1.5; step: 0.005; decimals: 3 }
                    ObjSliderRow { label: "Y"; key: "y"; lo: -0.5; hi: 1.5; step: 0.005; decimals: 3 }
                    ObjSliderRow { label: "Width"; key: "w"; lo: 0.01; hi: 2; step: 0.005; decimals: 3; fallback: 0.3 }
                    ObjSliderRow { label: "Height"; key: "h"; lo: 0.01; hi: 2; step: 0.005; decimals: 3; fallback: 0.2 }
                    ObjSliderRow { label: "Rotation"; key: "rotation"; lo: -360; hi: 360; step: 1; decimals: 0; suffix: "\u00b0" }
                    ObjSliderRow {
                        visible: { root.stateVersion; var o = root.curObj(); return o && o.type === "rect"; }
                        label: "Radius"; key: "cornerRadius"; lo: 0; hi: 200; step: 1; decimals: 0; suffix: "px"
                    }
                }

                // ======== FILL ========
                Hdr {
                    id: hFill; title: "Fill"; Layout.fillWidth: true
                    visible: root.curObj() !== null
                }
                ColumnLayout {
                    visible: hFill.on && hFill.visible; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                    RowLayout {
                        spacing: 4
                        CheckBox {
                            text: "Enabled"; font.pixelSize: 11
                            checked: { root.stateVersion; var o = root.curObj(); return o ? o.fillEnabled !== false : false; }
                            onToggled: root.setObjPropAndSave("fillEnabled", checked, "Toggle fill")
                        }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["solid", "linearGradient", "radialGradient"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["solid","linearGradient","radialGradient"].indexOf(o.fillType)) : 0; }
                            onActivated: root.setObjPropAndSave("fillType", model[currentIndex], "Change fill type")
                        }
                    }
                    ObjColorRow {
                        visible: { root.stateVersion; var o = root.curObj(); return o && (!o.fillType || o.fillType === "solid"); }
                        Layout.fillWidth: true; label: "Color"; key: "fillColor"
                    }
                    ColumnLayout {
                        visible: { root.stateVersion; var o = root.curObj(); return o && (o.fillType === "linearGradient" || o.fillType === "radialGradient"); }
                        Layout.fillWidth: true; spacing: 4
                        ObjColorRow { Layout.fillWidth: true; label: "Start"; key: "gradStartColor" }
                        ObjColorRow { Layout.fillWidth: true; label: "End"; key: "gradEndColor" }
                        ObjSliderRow {
                            visible: { root.stateVersion; var o = root.curObj(); return o && o.fillType === "linearGradient"; }
                            Layout.fillWidth: true; label: "Angle"; key: "gradAngle"
                            lo: 0; hi: 360; step: 1; decimals: 0; suffix: "\u00b0"
                        }
                    }
                }

                // ======== STROKE ========
                Hdr {
                    id: hStroke; title: "Stroke"; Layout.fillWidth: true
                    visible: root.curObj() !== null
                }
                ColumnLayout {
                    visible: hStroke.on && hStroke.visible; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                    CheckBox {
                        text: "Enabled"; font.pixelSize: 11
                        checked: { root.stateVersion; var o = root.curObj(); return o ? (o.strokeEnabled || false) : false; }
                        onToggled: root.setObjPropAndSave("strokeEnabled", checked, "Toggle stroke")
                    }
                    ObjColorRow { Layout.fillWidth: true; label: "Color"; key: "strokeColor" }
                    ObjSliderRow { label: "Width"; key: "strokeWidth"; lo: 0.5; hi: 50; step: 0.5; decimals: 1; fallback: 2 }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Style" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["solid", "dashed", "dotted"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["solid","dashed","dotted"].indexOf(o.strokeStyle)) : 0; }
                            onActivated: root.setObjPropAndSave("strokeStyle", model[currentIndex], "Change stroke style")
                        }
                    }
                }

                // ======== OPACITY ========
                Hdr {
                    id: hOpacity; title: "Opacity"; Layout.fillWidth: true
                    visible: root.curObj() !== null
                }
                ColumnLayout {
                    visible: hOpacity.on && hOpacity.visible; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                    ObjSliderRow { label: "Opacity"; key: "opacity"; lo: 0; hi: 1; step: 0.01; decimals: 2; fallback: 1 }
                }

                // ======== IMAGE (type === "image") ========
                Hdr {
                    id: hImg; title: "Image"; Layout.fillWidth: true
                    visible: { root.stateVersion; var o = root.curObj(); return o && o.type === "image"; }
                }
                ColumnLayout {
                    visible: hImg.on && hImg.visible; Layout.fillWidth: true; Layout.margins: 6; spacing: 4

                    // File-based image source
                    RowLayout {
                        spacing: 4
                        Lbl { text: "File" }
                        Text {
                            Layout.fillWidth: true
                            font.pixelSize: 10; color: "#ccc"
                            elide: Text.ElideMiddle
                            text: {
                                root.stateVersion;
                                var o = root.curObj();
                                if (o && o.imageFileUrl && o.imageFileUrl.length > 0) {
                                    var url = o.imageFileUrl;
                                    return url.substring(url.lastIndexOf("/") + 1);
                                }
                                return "From inlet";
                            }
                        }
                        Button {
                            text: "Browse..."
                            font.pixelSize: 10
                            implicitHeight: 22
                            onClicked: imageFileDialog.open()
                        }
                        Button {
                            text: "\u2715"
                            font.pixelSize: 10
                            implicitWidth: 22; implicitHeight: 22
                            visible: { root.stateVersion; var o = root.curObj(); return o && o.imageFileUrl && o.imageFileUrl.length > 0; }
                            onClicked: root.setObjPropAndSave("imageFileUrl", "", "Clear image file")
                        }
                    }

                    FileDialog {
                        id: imageFileDialog
                        title: "Select Image"
                        nameFilters: ["Image files (*.png *.jpg *.jpeg *.gif *.bmp *.svg *.webp)"]
                        onAccepted: root.setObjPropAndSave("imageFileUrl", selectedFile.toString(), "Set image file")
                    }

                    // Inlet-based image source
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Inlet" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["Image 1","Image 2","Image 3","Image 4","Image 5","Image 6","Image 7","Image 8"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? (o.imageSource || 0) : 0; }
                            onActivated: root.setObjPropAndSave("imageSource", currentIndex, "Change image source")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Fit" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["cover", "contain", "stretch", "tile"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["cover","contain","stretch","tile"].indexOf(o.imageFit)) : 0; }
                            onActivated: root.setObjPropAndSave("imageFit", model[currentIndex], "Change image fit")
                        }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 2 }
                    Lbl { text: "Crop"; font.bold: true }
                    ObjSliderRow { label: "Left"; key: "imageCropL"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    ObjSliderRow { label: "Right"; key: "imageCropR"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    ObjSliderRow { label: "Top"; key: "imageCropT"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    ObjSliderRow { label: "Bottom"; key: "imageCropB"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    Rectangle { Layout.fillWidth: true; height: 1; color: "#444"; Layout.topMargin: 2 }
                    ObjColorRow { Layout.fillWidth: true; label: "Border"; key: "imageBorderColor" }
                    ObjSliderRow { label: "Border W"; key: "imageBorderWidth"; lo: 0; hi: 20; step: 0.5; decimals: 1 }
                }

                // ======== TEXT (type === "text") ========
                Hdr {
                    id: hTxt; title: "Text"; Layout.fillWidth: true
                    visible: { root.stateVersion; var o = root.curObj(); return o && o.type === "text"; }
                }
                ColumnLayout {
                    visible: hTxt.on && hTxt.visible; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                    TextArea {
                        Layout.fillWidth: true; Layout.preferredHeight: 60
                        text: { root.stateVersion; var o = root.curObj(); return o ? (o.text || "") : ""; }
                        wrapMode: TextEdit.Wrap; font.pixelSize: 12; color: "#eee"
                        placeholderText: "Enter text..."
                        background: Rectangle { color: "#1e1e1e"; border.color: "#555"; radius: 2 }
                        onTextChanged: {
                            var o = root.curObj();
                            if (o && o.text !== text) { root.setObjProp("text", text); }
                        }
                        onFocusChanged: if (!focus) root.saveState("Edit text")
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Family" }
                        ComboBox {
                            Layout.fillWidth: true
                            editable: true
                            model: Qt.fontFamilies()
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? model.indexOf(o.fontFamily) : -1; }
                            onActivated: root.setObjPropAndSave("fontFamily", currentText, "Change font")
                            onAccepted: root.setObjPropAndSave("fontFamily", editText, "Change font")
                        }
                    }
                    ObjSliderRow { label: "Size"; key: "fontSize"; lo: 4; hi: 500; step: 1; decimals: 0; fallback: 36; suffix: "px" }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Weight" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["normal", "bold"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o && o.fontWeight === "bold" ? 1 : 0; }
                            onActivated: root.setObjPropAndSave("fontWeight", model[currentIndex], "Change weight")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Style" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["normal", "italic"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o && o.fontStyle === "italic" ? 1 : 0; }
                            onActivated: root.setObjPropAndSave("fontStyle", model[currentIndex], "Change style")
                        }
                    }
                    ObjColorRow { Layout.fillWidth: true; label: "Color"; key: "textColor" }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "H Align" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["left", "center", "right"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["left","center","right"].indexOf(o.hAlign)) : 1; }
                            onActivated: root.setObjPropAndSave("hAlign", model[currentIndex], "Change alignment")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "V Align" }
                        ComboBox {
                            Layout.fillWidth: true
                            model: ["top", "center", "bottom"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["top","center","bottom"].indexOf(o.vAlign)) : 1; }
                            onActivated: root.setObjPropAndSave("vAlign", model[currentIndex], "Change alignment")
                        }
                    }
                    CheckBox {
                        text: "Word Wrap"; font.pixelSize: 11
                        checked: { root.stateVersion; var o = root.curObj(); return o ? (o.wordWrap !== false) : true; }
                        onToggled: root.setObjPropAndSave("wordWrap", checked, "Toggle word wrap")
                    }
                    ObjSliderRow { label: "Line Sp."; key: "lineSpacing"; lo: 0.5; hi: 4; step: 0.05; decimals: 2; fallback: 1.3 }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: 20 }
            }
        }
    }
    }
}
