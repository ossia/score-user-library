import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "SlideRender.js" as SlideRender
import OssiaUI as S

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
    property var editingTextObject: null
    property var editingTextSlide: null
    property string editingTextOriginal: ""
    property var editingTextEditor: null
    readonly property int editingTextIdx: {
        root.stateVersion;
        return editingTextEditor === inlineTextEdit && editingTextSlide === slideState && editingTextObject
                ? slideState.objects.indexOf(editingTextObject) : -1;
    }
    property var clipboard: null

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
        finishTextEditing(true);
        setObjProp(key, val);
        saveState(action);
    }
    function setBgProp(key, val) {
        root.slideState[key] = val;
        root.stateVersion++;
        sendLive();
    }
    function setBgPropAndSave(key, val, action) {
        finishTextEditing(true);
        setBgProp(key, val);
        saveState(action);
    }

    function curObj() {
        var idx = root.selectedObj;
        if (idx < 0 || !root.slideState.objects || idx >= root.slideState.objects.length) return null;
        return root.slideState.objects[idx];
    }

    function finishTextEditing(accept) {
        if (editingTextEditor) editingTextEditor.finish(accept);
    }

    function beginTextEditing(idx, editor) {
        finishTextEditing(true);
        var obj = root.slideState.objects[idx];
        if (!obj || obj.type !== "text") return;
        root.editingTextSlide = root.slideState;
        root.editingTextObject = obj;
        root.editingTextOriginal = obj.text || "";
        root.editingTextEditor = editor || inlineTextEdit;
        root.editingTextEditor.begin(root.editingTextOriginal);
        root.stateVersion++;
    }

    onSelectedObjChanged: {
        if (editingTextObject && curObj() !== editingTextObject)
            finishTextEditing(true);
    }

    function chooseColor(key, label, background) {
        finishTextEditing(true);
        var slide = root.slideState;
        var target = background ? slide : root.curObj();
        if (!target) return;
        Util.openColorDialog("Change " + label.toLowerCase(), target[key] || "#000000", function(color) {
            if (!root || !color || root.slides.indexOf(slide) < 0
                    || (!background && slide.objects.indexOf(target) < 0)) return;
            target[key] = color;
            root.stateVersion++;
            root.sendLive();
            root.saveState("Change " + label.toLowerCase());
        });
    }

    function replaceImage(slide, obj, path) {
        if (!path || !obj || obj.type !== "image" || root.slides.indexOf(slide) < 0
                || slide.objects.indexOf(obj) < 0) return;
        finishTextEditing(true);
        obj.imageFileUrl = Score.Editor.relativizeFilePath(path);
        root.stateVersion++;
        root.sendLive();
        root.saveState("Set image file");
    }

    function chooseImage() {
        var slide = root.slideState;
        var obj = root.curObj();
        Util.openFileDialog("Select image",
                            "Image files (*.png *.jpg *.jpeg *.gif *.bmp *.svg *.svgz *.webp)",
                            "", function(path) {
            if (root && path) root.replaceImage(slide, obj, path);
        });
    }

    // ---- Slide operations ----

    function selectSlide(idx) {
        if (idx < 0 || idx >= root.slides.length) return;
        finishTextEditing(true);
        root.currentSlideIndex = idx;
        root.slideState = root.slides[idx];
        root.selectedObj = -1;
        root.stateVersion++;
        sendLive();
        // Sync the backend's Slide IntSlider (1-based)
        Score.Editor.setValue(root.inlet("Slide"), idx + 1);
    }

    function addSlide() {
        finishTextEditing(true);
        root.slides.push(SlideRender.defaultSlideState());
        root.currentSlideIndex = root.slides.length - 1;
        root.slideState = root.slides[root.currentSlideIndex];
        root.selectedObj = -1;
        root.stateVersion++;
        sendLive();
        saveState("Add slide");
    }

    function duplicateSlide(idx) {
        if (idx < 0 || idx >= root.slides.length) return;
        finishTextEditing(true);
        var dup = SlideRender.cloneSlide(root.slides[idx]);
        root.slides.splice(idx + 1, 0, dup);
        root.currentSlideIndex = idx + 1;
        root.slideState = root.slides[root.currentSlideIndex];
        root.selectedObj = -1;
        root.stateVersion++;
        sendLive();
        saveState("Duplicate slide");
    }

    function deleteSlide(idx) {
        if (root.slides.length <= 1) return;
        if (idx < 0 || idx >= root.slides.length) return;
        finishTextEditing(true);
        root.slides.splice(idx, 1);
        if (idx < root.currentSlideIndex)
            root.currentSlideIndex--;
        else if (root.currentSlideIndex >= root.slides.length)
            root.currentSlideIndex = root.slides.length - 1;
        root.slideState = root.slides[root.currentSlideIndex];
        root.selectedObj = -1;
        root.stateVersion++;
        sendLive();
        saveState("Delete slide");
    }

    function moveSlide(fromIdx, toIdx) {
        if (fromIdx === toIdx) return;
        if (fromIdx < 0 || fromIdx >= root.slides.length) return;
        if (toIdx < 0 || toIdx >= root.slides.length) return;
        finishTextEditing(true);
        var selectedSlide = root.slideState;
        var item = root.slides.splice(fromIdx, 1)[0];
        root.slides.splice(toIdx, 0, item);
        root.currentSlideIndex = root.slides.indexOf(selectedSlide);
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
        finishTextEditing(false);
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
        root.stateVersion++;
    }
    stateUpdated: function(k, v) {
        if (k === "slideState") {
            finishTextEditing(false);
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
        finishTextEditing(true);
        var objs = root.slideState.objects;
        var obj = SlideRender.createObject(type, objs.length);
        objs.push(obj);
        root.selectedObj = objs.length - 1;
        root.stateVersion++;
        sendLive();
        saveState("Add " + type);
    }

    function deleteObject(idx) {
        finishTextEditing(true);
        var objs = root.slideState.objects;
        if (idx < 0 || idx >= objs.length) return;
        objs.splice(idx, 1);
        if (idx < root.selectedObj) root.selectedObj--;
        else if (root.selectedObj >= objs.length) root.selectedObj = objs.length - 1;
        root.stateVersion++;
        sendLive();
        saveState("Delete object");
    }

    function moveObject(fromIdx, toIdx) {
        finishTextEditing(true);
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
        finishTextEditing(true);
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
    // Thin wrappers over the shared OssiaUI kit: they keep the names and the
    // property APIs this file already uses, so the look changes in one place
    // while every call site below stays as it was.

    component Hdr: S.SFoldout {
        id: hdr
        property alias on: hdr.expanded
    }

    component Lbl: S.SFieldLabel {
        Layout.preferredWidth: S.Theme.labelWsm
    }

    component Val: S.SValue {}

    component SlideTextEditor: S.SInlineTextEditor {
        padding: 6
        onEdited: function(value) {
            var obj = root.editingTextObject;
            if (obj && obj.text !== value) {
                obj.text = value;
                root.stateVersion++;
                root.sendLive();
            }
        }
        onFinished: function(value, accepted) {
            var changed = value !== root.editingTextOriginal;
            root.editingTextObject = null;
            root.editingTextSlide = null;
            root.editingTextEditor = null;
            root.stateVersion++;
            if (accepted && changed) root.saveState("Edit text");
        }
    }

    component ObjColorRow: RowLayout {
        property string label
        property string key
        Layout.fillWidth: true
        spacing: S.Theme.gap
        Lbl { text: parent.label }
        Rectangle {
            implicitWidth: 20; implicitHeight: S.Theme.rowH - 3
            radius: S.Theme.radiusSm
            color: { root.stateVersion; var o = root.curObj(); return o ? (o[parent.key] || "#000") : "#000"; }
            border.width: 1
            border.color: swHov.hovered ? S.Theme.accent : S.Theme.border
            HoverHandler { id: swHov; cursorShape: Qt.PointingHandCursor }
            TapHandler {
                onTapped: root.chooseColor(parent.parent.key, parent.parent.label, false)
            }
        }
        S.STextField {
            Layout.fillWidth: true
            font.pixelSize: S.Theme.fontSm
            font.family: "monospace"
            text: { root.stateVersion; var o = root.curObj(); return o ? (o[parent.key] || "#000000") : "#000000"; }
            onEditingFinished: root.setObjPropAndSave(parent.key, text, "Change " + parent.label.toLowerCase())
        }
    }

    component BgColorRow: RowLayout {
        property string label
        property string key
        Layout.fillWidth: true
        spacing: S.Theme.gap
        Lbl { text: parent.label }
        Rectangle {
            implicitWidth: 20; implicitHeight: S.Theme.rowH - 3
            radius: S.Theme.radiusSm
            color: (root.stateVersion, root.slideState[parent.key] || "#000")
            border.width: 1
            border.color: bgHov.hovered ? S.Theme.accent : S.Theme.border
            HoverHandler { id: bgHov; cursorShape: Qt.PointingHandCursor }
            TapHandler {
                onTapped: root.chooseColor(parent.parent.key, parent.parent.label, true)
            }
        }
        S.STextField {
            Layout.fillWidth: true
            font.pixelSize: S.Theme.fontSm
            font.family: "monospace"
            text: (root.stateVersion, root.slideState[parent.key] || "#000000")
            onEditingFinished: root.setBgPropAndSave(parent.key, text, "Change " + parent.label.toLowerCase())
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
        Layout.fillWidth: true
        spacing: S.Theme.gap
        Lbl { text: parent.label }
        S.SSlider {
            id: sld
            Layout.fillWidth: true
            from: parent.lo; to: parent.hi; stepSize: parent.step
            defaultValue: parent.fallback
            value: { root.stateVersion; var o = root.curObj(); return o && o[sld.parent.key] !== undefined ? o[sld.parent.key] : sld.parent.fallback; }
            onMoved: root.setObjProp(sld.parent.key, value)
            onPressedChanged: if (!pressed) root.saveState("Change " + sld.parent.label.toLowerCase())
        }
        Val {
            text: (parent.decimals > 0 ? Number(sld.value).toFixed(parent.decimals) : String(Math.round(sld.value))) + parent.suffix
        }
    }


    // ---- Main layout ----

    S.ThemedPage {
        anchors.fill: parent

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: S.Theme.gap
        spacing: S.Theme.gap

    SplitView {
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: S.Theme.gap

        // ======== Left panel: Object list ========
        S.SPanel {
            SplitView.preferredWidth: 190
            SplitView.minimumWidth: 130
            SplitView.maximumWidth: 300
            SplitView.fillHeight: true

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: S.Theme.pad
            spacing: S.Theme.gap

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
                    S.SButton {
                        text: "+ Slide"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        onClicked: root.addSlide()
                    }
                    S.SButton {
                        text: "Duplicate"
                        font.pixelSize: 10
                        Layout.fillWidth: true
                        onClicked: root.duplicateSlide(root.currentSlideIndex)
                    }
                    S.SButton {
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
                    Layout.preferredHeight: Math.min(root.slides.length * (S.Theme.listRowH + 1), 150)
                    Layout.minimumHeight: S.Theme.listRowH
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
                        height: S.Theme.listRowH
                        radius: S.Theme.radiusSm
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

                            S.SLayerDragHandle {
                                view: slideListView
                                index: slideDel.index
                                Layout.preferredWidth: 14
                                onStarted: {
                                    root.finishTextEditing(true);
                                    root.forceActiveFocus();
                                    root.slideDragIndex = index;
                                    root.slideDropIndex = index;
                                }
                                onTargetIndexChanged: if (dragging) root.slideDropIndex = targetIndex
                                onMoved: function(from, to) { root.moveSlide(from, to); }
                                onFinished: {
                                    root.slideDragIndex = -1;
                                    root.slideDropIndex = -1;
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

            Rectangle { Layout.fillWidth: true; height: 1; color: S.Theme.border }

            // Slide format section
            Hdr { id: hFormat; title: "Format"; Layout.fillWidth: true; on: false }
            ColumnLayout {
                visible: hFormat.on; Layout.fillWidth: true; Layout.margins: 6; spacing: 4
                RowLayout {
                    spacing: 4
                    Lbl { text: "Preset" }
                    S.SCombo {
                        Layout.fillWidth: true
                        readonly property var options: ["fill", "16:9", "4:3", "1:1", "9:16", "custom"]
                        model: ["Match output", "16:9", "4:3", "1:1", "9:16", "Custom"]
                        currentIndex: { root.stateVersion; return Math.max(0, options.indexOf(root.slideState.slideFormat || "fill")); }
                        onActivated: {
                            root.slideState.slideFormat = options[currentIndex];
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
                    S.STextField {
                        Layout.fillWidth: true
                        text: (root.stateVersion, root.slideState.customWidth || 1920)
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
                    S.STextField {
                        Layout.fillWidth: true
                        text: (root.stateVersion, root.slideState.customHeight || 1080)
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
                S.SButton { text: "+ Rect"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("rect") }
                S.SButton { text: "+ Ellipse"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("ellipse") }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 2
                S.SButton { text: "+ Image"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("image") }
                S.SButton { text: "+ Text"; font.pixelSize: 10; Layout.fillWidth: true; onClicked: root.addObject("text") }
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
                    height: S.Theme.listRowH
                    radius: S.Theme.radiusSm
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
                        S.SLayerDragHandle {
                            view: objListView
                            index: listDel.delIndex
                            Layout.preferredWidth: 14
                            onStarted: {
                                root.finishTextEditing(true);
                                root.forceActiveFocus();
                                root.listDragIndex = index;
                                root.listDropIndex = index;
                                root.selectedObj = index;
                            }
                            onTargetIndexChanged: if (dragging) root.listDropIndex = targetIndex
                            onMoved: function(from, to) { root.moveObject(from, to); }
                            onFinished: {
                                root.listDragIndex = -1;
                                root.listDropIndex = -1;
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
                        S.SButton {
                            text: "\u2715"
                            compact: true
                            implicitWidth: 18; implicitHeight: 18
                            font.pixelSize: 11
                            tip: "Delete"
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
                    S.SCombo {
                        Layout.fillWidth: true
                        readonly property var options: ["solid", "linearGradient", "radialGradient", "texture"]
                        model: ["Solid", "Linear gradient", "Radial gradient", "Texture"]
                        currentIndex: { root.stateVersion; return Math.max(0, options.indexOf(root.slideState.bgType)); }
                        onActivated: root.setBgPropAndSave("bgType", options[currentIndex], "Change bg type")
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
                        S.SSlider {
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
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["Image 1","Image 2","Image 3","Image 4","Image 5","Image 6","Image 7","Image 8"]
                            currentIndex: (root.stateVersion, root.slideState.bgTexSource || 0)
                            onActivated: root.setBgPropAndSave("bgTexSource", currentIndex, "Change bg source")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Fit" }
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["cover", "contain", "stretch", "tile"]
                            currentIndex: { root.stateVersion; return Math.max(0, ["cover","contain","stretch","tile"].indexOf(root.slideState.bgTexFit)); }
                            onActivated: root.setBgPropAndSave("bgTexFit", model[currentIndex], "Change bg fit")
                        }
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
            SplitView.minimumWidth: 240
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
                color: S.Theme.dark
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
                        if (url && url.length > 0) {
                            var resolved = SlideRender.localFileUrl(Score.Editor.locateFilePath(url));
                            objs[i]._resolvedUrl = resolved;
                            if (!isImageLoaded(resolved)) loadImage(resolved);
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

                function finishMove(accept) {
                    if (!root.isDragging || root.dragType !== "move") return;
                    root.isDragging = false;
                    root.dragType = "";
                    var obj = root.curObj();
                    if (!obj || (obj.x === root.dragOrigX && obj.y === root.dragOrigY)) return;
                    if (accept) {
                        root.saveState("Move object");
                    } else {
                        obj.x = root.dragOrigX;
                        obj.y = root.dragOrigY;
                        root.stateVersion++;
                        root.sendLive();
                    }
                }

                onPressed: function(mouse) {
                    root.forceActiveFocus();
                    root.finishTextEditing(true);
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

                onReleased: finishMove(true)
                onCanceled: finishMove(false)

                onDoubleClicked: function(mouse) {
                    finishMove(false);
                    var nx = (mouse.x - viewport.canvasX) / viewport.canvasW;
                    var ny = (mouse.y - viewport.canvasY) / viewport.canvasH;
                    var hitIdx = root.hitTestObject(nx, ny);
                    if (hitIdx >= 0 && root.slideState.objects[hitIdx].type === "text") {
                        root.selectedObj = hitIdx;
                        root.beginTextEditing(hitIdx);
                    }
                }
            }

            S.SImageDropArea {
                anchors.fill: parent
                z: 2
                onFilesDropped: function(paths, x, y) {
                    root.finishTextEditing(true);
                    var objs = root.slideState.objects;
                    for (var i = 0; i < paths.length; i++) {
                        var path = paths[i];
                        var obj = SlideRender.createObject("image", objs.length);
                        obj.imageFileUrl = Score.Editor.relativizeFilePath(path);
                        obj.name = path.substring(path.lastIndexOf("/") + 1);
                        // Normalized dimensions account for the slide's aspect ratio.
                        var sz = Util.imageSize(path);
                        if (sz.width > 0 && sz.height > 0) {
                            var imgAspect = sz.width / sz.height;
                            obj.h = (obj.w / imgAspect) * viewport.effectiveRatio;
                        }
                        objs.push(obj);
                        root.selectedObj = objs.length - 1;
                    }
                    root.stateVersion++;
                    root.sendLive();
                    root.saveState("Import image");
                }
            }

            // Inline text editing overlay
            SlideTextEditor {
                id: inlineTextEdit
                z: 5

                property var editObj: { root.stateVersion; return root.editingTextObject; }

                x: editObj ? editObj.x * viewport.canvasW + viewport.canvasX : 0
                y: editObj ? editObj.y * viewport.canvasH + viewport.canvasY : 0
                width: editObj ? editObj.w * viewport.canvasW : 100
                height: editObj ? editObj.h * viewport.canvasH : 50

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
                            root.finishTextEditing(true);
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
        S.SPanel {
            SplitView.preferredWidth: 270
            SplitView.minimumWidth: 200
            SplitView.maximumWidth: 420
            SplitView.fillHeight: true

        ScrollView {
            id: propScroll
            anchors.fill: parent
            anchors.margins: S.Theme.pad
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            contentWidth: availableWidth

            ColumnLayout {
                width: propScroll.availableWidth
                spacing: 0


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
                        S.SCheck {
                            text: "Enabled"; font.pixelSize: 11
                            checked: { root.stateVersion; var o = root.curObj(); return o ? o.fillEnabled !== false : false; }
                            onToggled: root.setObjPropAndSave("fillEnabled", checked, "Toggle fill")
                        }
                        S.SCombo {
                            Layout.fillWidth: true
                            readonly property var options: ["solid", "linearGradient", "radialGradient"]
                            model: ["Solid", "Linear gradient", "Radial gradient"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, options.indexOf(o.fillType)) : 0; }
                            onActivated: root.setObjPropAndSave("fillType", options[currentIndex], "Change fill type")
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
                    S.SCheck {
                        text: "Enabled"; font.pixelSize: 11
                        checked: { root.stateVersion; var o = root.curObj(); return o ? (o.strokeEnabled || false) : false; }
                        onToggled: root.setObjPropAndSave("strokeEnabled", checked, "Toggle stroke")
                    }
                    ObjColorRow { Layout.fillWidth: true; label: "Color"; key: "strokeColor" }
                    ObjSliderRow { label: "Width"; key: "strokeWidth"; lo: 0.5; hi: 50; step: 0.5; decimals: 1; fallback: 2 }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Style" }
                        S.SCombo {
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
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: imageFileRow.implicitHeight
                        S.SImageDropArea {
                            anchors.fill: parent
                            onFilesDropped: function(paths, x, y) {
                                root.replaceImage(root.slideState, root.curObj(), paths[0]);
                            }
                        }
                        RowLayout {
                            id: imageFileRow
                            anchors.fill: parent
                        spacing: 4
                        Lbl { text: "File" }
                        Text {
                            Layout.fillWidth: true
                            font.pixelSize: S.Theme.fontSm; color: S.Theme.text
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
                        S.SButton {
                            text: "Browse..."
                            font.pixelSize: 10
                            implicitHeight: 22
                            onClicked: root.chooseImage()
                        }
                        S.SButton {
                            text: "\u2715"
                            compact: true
                            font.pixelSize: 10
                            implicitWidth: 22; implicitHeight: 22
                            visible: { root.stateVersion; var o = root.curObj(); return o && o.imageFileUrl && o.imageFileUrl.length > 0; }
                            onClicked: root.setObjPropAndSave("imageFileUrl", "", "Clear image file")
                        }
                    }
                    }


                    // Inlet-based image source
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Inlet" }
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["Image 1","Image 2","Image 3","Image 4","Image 5","Image 6","Image 7","Image 8"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? (o.imageSource || 0) : 0; }
                            onActivated: root.setObjPropAndSave("imageSource", currentIndex, "Change image source")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Fit" }
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["cover", "contain", "stretch", "tile"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["cover","contain","stretch","tile"].indexOf(o.imageFit)) : 0; }
                            onActivated: root.setObjPropAndSave("imageFit", model[currentIndex], "Change image fit")
                        }
                    }
                    Rectangle { Layout.fillWidth: true; height: 1; color: S.Theme.border; Layout.topMargin: 2 }
                    Lbl { text: "Crop"; font.bold: true }
                    ObjSliderRow { label: "Left"; key: "imageCropL"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    ObjSliderRow { label: "Right"; key: "imageCropR"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    ObjSliderRow { label: "Top"; key: "imageCropT"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    ObjSliderRow { label: "Bottom"; key: "imageCropB"; lo: 0; hi: 0.5; step: 0.01; decimals: 2 }
                    Rectangle { Layout.fillWidth: true; height: 1; color: S.Theme.border; Layout.topMargin: 2 }
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
                    Item {
                        Layout.fillWidth: true; Layout.preferredHeight: 60
                        clip: true
                        Text {
                            anchors.fill: parent
                            anchors.margins: 6
                            visible: !propertyTextEdit.editing
                            text: {
                                root.stateVersion;
                                var o = root.curObj();
                                return o && o.text ? o.text : "Enter text";
                            }
                            wrapMode: Text.Wrap
                            font.pixelSize: 12
                            color: "#eee"
                        }
                        MouseArea {
                            anchors.fill: parent
                            visible: !propertyTextEdit.editing
                            cursorShape: Qt.IBeamCursor
                            onClicked: root.beginTextEditing(root.selectedObj, propertyTextEdit)
                        }
                        SlideTextEditor {
                            id: propertyTextEdit
                            anchors.fill: parent
                            wrapMode: TextEdit.Wrap
                            font.pixelSize: 12
                            color: "#eee"
                            placeholderText: "Enter text"
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Family" }
                        S.SCombo {
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
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["normal", "bold"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o && o.fontWeight === "bold" ? 1 : 0; }
                            onActivated: root.setObjPropAndSave("fontWeight", model[currentIndex], "Change weight")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "Style" }
                        S.SCombo {
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
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["left", "center", "right"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["left","center","right"].indexOf(o.hAlign)) : 1; }
                            onActivated: root.setObjPropAndSave("hAlign", model[currentIndex], "Change alignment")
                        }
                    }
                    RowLayout {
                        spacing: 4
                        Lbl { text: "V Align" }
                        S.SCombo {
                            Layout.fillWidth: true
                            model: ["top", "center", "bottom"]
                            currentIndex: { root.stateVersion; var o = root.curObj(); return o ? Math.max(0, ["top","center","bottom"].indexOf(o.vAlign)) : 1; }
                            onActivated: root.setObjPropAndSave("vAlign", model[currentIndex], "Change alignment")
                        }
                    }
                    S.SCheck {
                        text: "Word Wrap"; font.pixelSize: 11
                        checked: { root.stateVersion; var o = root.curObj(); return o ? (o.wordWrap !== false) : true; }
                        onToggled: root.setObjPropAndSave("wordWrap", checked, "Toggle word wrap")
                    }
                    ObjSliderRow { label: "Line Sp."; key: "lineSpacing"; lo: 0.5; hi: 4; step: 0.05; decimals: 2; fallback: 1.3 }
                }

                Item { Layout.fillHeight: true; Layout.minimumHeight: S.Theme.pad }
            }
        }
        }
    }

    S.SStatusBar {
        visible: detail.length > 0
        detail: root.renderWidth > 0
                ? (Math.round(root.renderWidth) + "×" + Math.round(root.renderHeight))
                : ""
    }
    }
    }

    // Keyboard shortcuts
    Keys.onPressed: function(event) {
        // Let either text editor handle its own editing shortcuts.
        if (root.editingTextObject) return;

        var ctrl = event.modifiers & Qt.ControlModifier;
        var shift = event.modifiers & Qt.ShiftModifier;

        // Undo: Ctrl+Z
        if (ctrl && !shift && event.key === Qt.Key_Z) {
            Score.Editor.undo();
            event.accepted = true;
        }
        // Redo: Ctrl+Shift+Z or Ctrl+Y
        else if ((ctrl && shift && event.key === Qt.Key_Z) || (ctrl && event.key === Qt.Key_Y)) {
            Score.Editor.redo();
            event.accepted = true;
        }
        // Delete: Del/Backspace
        else if ((event.key === Qt.Key_Delete || event.key === Qt.Key_Backspace) && root.selectedObj >= 0) {
            root.deleteObject(root.selectedObj);
            event.accepted = true;
        }
        // Duplicate: Ctrl+D
        else if (ctrl && event.key === Qt.Key_D && root.selectedObj >= 0) {
            root.duplicateObject(root.selectedObj);
            event.accepted = true;
        }
        // Copy: Ctrl+C
        else if (ctrl && event.key === Qt.Key_C && root.selectedObj >= 0) {
            var obj = root.curObj();
            if (obj) root.clipboard = JSON.parse(JSON.stringify(obj));
            event.accepted = true;
        }
        // Paste: Ctrl+V
        else if (ctrl && event.key === Qt.Key_V && root.clipboard) {
            var dup = JSON.parse(JSON.stringify(root.clipboard));
            dup.id = "obj-" + Date.now();
            dup.x += 0.02;
            dup.y += 0.02;
            root.slideState.objects.push(dup);
            root.selectedObj = root.slideState.objects.length - 1;
            root.stateVersion++;
            sendLive();
            saveState("Paste object");
            event.accepted = true;
        }
    }
}
