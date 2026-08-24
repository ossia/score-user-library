import Score as Score
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Model.js" as Model

// Top toolbar: tools, creation menu, view options, set selector, show-mode lock, import/export.
Item {
    id: bar
    property var owner
    implicitHeight: flow.implicitHeight

    // "lit" replaces checkable/checked: the active state is always driven by a binding to the owner,
    // so clicking twice cannot deselect a mode and external changes (shortcuts) stay in sync.
    component ToolBtn: Button {
        property string toolName: ""
        property string tip: ""
        property bool lit: toolName.length > 0 && bar.owner.tool === toolName
        implicitHeight: 26
        leftPadding: 9; rightPadding: 9; topPadding: 2; bottomPadding: 2
        font.pixelSize: 11
        onClicked: if (toolName.length) bar.owner.tool = toolName
        ToolTip.visible: hovered && tip.length > 0; ToolTip.text: tip; ToolTip.delay: 500
        property color tint: "#1d1c1a"
        contentItem: Text { text: parent.text; font: parent.font; color: parent.lit ? "#f4f7f5" : "#e6ebe8"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { implicitWidth: 20; implicitHeight: 26; radius: 3; color: parent.lit ? "#62400a" : (parent.down ? "#3a3835" : (parent.hovered ? "#2c2a27" : parent.tint)); border.color: parent.lit ? "#c58014" : "#3a3835"; border.width: 1 }
    }

    Flow {
        id: flow
        width: parent.width
        spacing: 3

        ToolBtn { text: "Select"; toolName: "select"; tip: "Select / move (1). Drag handles to resize, Shift-click to multi-select." }
        ToolBtn { text: "Rect"; toolName: "rect"; tip: "Draw a rectangle (2)" }
        ToolBtn { text: "Circle"; toolName: "circle"; tip: "Draw a circle (3)" }
        ToolBtn { text: "Polygon"; toolName: "polygon"; tip: "Click to add vertices, double-click or right-click to close (4)" }
        ToolBtn { text: "Line"; toolName: "line"; tip: "Directional tripwire: drag from A to B (5). Crossing to the left of A→B counts as 'in'." }
        ToolBtn { text: "Path"; toolName: "path"; tip: "Polyline path with progress 0..1 (6)" }
        ToolBtn { text: "Box"; toolName: "box"; tip: "3D box: drag footprint, set depth in the inspector" }
        ToolBtn { text: "Sphere"; toolName: "sphere"; tip: "3D sphere" }
        ToolBtn { text: "Cyl"; toolName: "cylinder"; tip: "3D cylinder" }
        ToolBtn { text: "Dummies"; toolName: "sim"; tip: "Simulation: click to add a dummy entity, drag to move, right-click to remove (7)" }

        Rectangle { width: 1; height: 26; color: palette.mid }

        ToolBtn {
            text: "Generate ▾"; tip: "Templates and generators"
            onClicked: genMenu.open()
            Menu {
                id: genMenu
                MenuItem { text: "Grid 3×2 (6 m × 4 m)"; onTriggered: bar.owner.addZones(Model.gridZones(0, 0, 6, 4, 3, 2, bar.owner.doc.zones.length), "Add grid") }
                MenuItem { text: "Grid 4×4 (8 m × 8 m)"; onTriggered: bar.owner.addZones(Model.gridZones(0, 0, 8, 8, 4, 4, bar.owner.doc.zones.length), "Add grid") }
                MenuItem { text: "Radial sectors ×6 (r 1-3 m)"; onTriggered: bar.owner.addZones(Model.sectorZones(0, 0, 1, 3, 6, bar.owner.doc.zones.length), "Add sectors") }
                MenuItem { text: "Radial sectors ×8 (r 0-4 m)"; onTriggered: bar.owner.addZones(Model.sectorZones(0, 0, 0, 4, 8, bar.owner.doc.zones.length), "Add sectors") }
                MenuItem { text: "Pie ×4 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 4, bar.owner.doc.zones.length), "Add pie") }
                MenuItem { text: "Pie ×6 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 6, bar.owner.doc.zones.length), "Add pie") }
                MenuItem { text: "Pie ×8 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 8, bar.owner.doc.zones.length), "Add pie") }
                MenuItem { text: "Pie ×12 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 12, bar.owner.doc.zones.length), "Add pie") }
                MenuItem { text: "Pie ×16 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 16, bar.owner.doc.zones.length), "Add pie") }
                MenuSeparator {}
                MenuItem { text: "Template: door tripwire + approach"; onTriggered: bar.owner.addZones(Model.template("door"), "Add template") }
                MenuItem { text: "Template: stage up/mid/down"; onTriggered: bar.owner.addZones(Model.template("stage"), "Add template") }
                MenuItem { text: "Template: audience funnel rings"; onTriggered: bar.owner.addZones(Model.template("funnel"), "Add template") }
                MenuSeparator {}
                MenuItem { text: "Camera: 3×3 segmentation"; onTriggered: bar.owner.addZones(Model.template("camera-grid"), "Add template") }
                MenuItem { text: "Camera: quadrants"; onTriggered: bar.owner.addZones(Model.template("camera-quadrants"), "Add template") }
                MenuItem { text: "Camera: 8 vertical strips (fader bank)"; onTriggered: bar.owner.addZones(Model.template("camera-columns"), "Add template") }
                MenuItem { text: "Camera: 5 horizontal bands"; onTriggered: bar.owner.addZones(Model.template("camera-rows"), "Add template") }
                MenuItem { text: "Camera: piano keyboard, 1 octave"; onTriggered: bar.owner.addZones(Model.template("piano"), "Add template") }
                MenuItem { text: "Camera: piano keyboard, 2 octaves"; onTriggered: bar.owner.addZones(Model.template("piano2"), "Add template") }
                MenuItem { text: "Camera: XY pad + corner triggers"; onTriggered: bar.owner.addZones(Model.template("xy-pad"), "Add template") }
                MenuItem { text: "Camera: swipe tripwires"; onTriggered: bar.owner.addZones(Model.template("swipe"), "Add template") }
                MenuItem { text: "3D: near / mid / far depth layers"; onTriggered: bar.owner.addZones(Model.template("depth-layers"), "Add template") }
            }
        }

        Rectangle { width: 1; height: 26; color: palette.mid }

        ToolBtn { text: "2D"; lit: bar.owner.viewMode === "2d"; onClicked: bar.owner.viewMode = "2d"; tip: "Top view (Tab cycles)" }
        ToolBtn { text: "3D"; lit: bar.owner.viewMode === "3d"; onClicked: bar.owner.viewMode = "3d" }
        ToolBtn { text: "Split"; lit: bar.owner.viewMode === "split"; onClicked: bar.owner.viewMode = "split" }
        ToolBtn { text: "Fit"; tip: "Fit all zones in view (F)"; onClicked: bar.owner.fitView() }

        Rectangle { width: 1; height: 26; color: palette.mid }

        ToolBtn { text: "Snap"; lit: bar.owner.snapping; onClicked: bar.owner.snapping = !bar.owner.snapping; tip: "Snap to grid (G)" }
        SpinBox {
            id: gridSpin; from: 1; to: 500; stepSize: 1; value: Math.round(bar.owner.gridStep * 100); editable: true
            implicitWidth: 96; implicitHeight: 26; font.pixelSize: 11
            leftPadding: 20; rightPadding: 20
            textFromValue: function (v) { return (v / 100).toFixed(2) + " m"; }
            valueFromText: function (t) { return Math.round(parseFloat(t) * 100); }
            onValueModified: bar.owner.gridStep = value / 100
            ToolTip.visible: hovered; ToolTip.text: "Grid step"
            contentItem: TextInput {
                text: gridSpin.textFromValue(gridSpin.value, gridSpin.locale)
                font: gridSpin.font; color: "#d0d0d0"
                horizontalAlignment: Qt.AlignHCenter; verticalAlignment: Qt.AlignVCenter
                readOnly: !gridSpin.editable; validator: gridSpin.validator; selectByMouse: true
            }
            up.indicator: Rectangle {
                x: gridSpin.width - width; height: gridSpin.height; width: 18; radius: 3
                color: gridSpin.up.pressed ? "#3a3835" : "#1d1c1a"; border.color: "#3a3835"
                Text { anchors.centerIn: parent; text: "+"; font.pixelSize: 12; color: "#c0c0c0" }
            }
            down.indicator: Rectangle {
                x: 0; height: gridSpin.height; width: 18; radius: 3
                color: gridSpin.down.pressed ? "#3a3835" : "#1d1c1a"; border.color: "#3a3835"
                Text { anchors.centerIn: parent; text: "−"; font.pixelSize: 12; color: "#c0c0c0" }
            }
            background: Rectangle { radius: 3; color: "#1d1c1a"; border.color: "#3a3835" }
        }
        ToolBtn { text: "Trails"; lit: bar.owner.showTrails; onClicked: bar.owner.showTrails = !bar.owner.showTrails }
        ToolBtn { text: "Labels"; lit: bar.owner.showLabels; onClicked: bar.owner.showLabels = !bar.owner.showLabels }
        ToolBtn { text: "Speed"; lit: bar.owner.showVelocity; onClicked: bar.owner.showVelocity = !bar.owner.showVelocity; tip: "Draw velocity lines on entities" }
        ToolBtn { text: "Keypoints"; lit: bar.owner.showKeypoints; onClicked: bar.owner.showKeypoints = !bar.owner.showKeypoints; tip: "Draw skeleton keypoints (costs bandwidth with many entities)" }
        ToolBtn { text: "Heat"; lit: bar.owner.showHeat; onClicked: bar.owner.showHeat = !bar.owner.showHeat; tip: "Show heatmap (enable it in Settings)" }
        ToolBtn { text: "Floor plan…"; tip: "Load a floor plan image (PNG, JPG, SVG...) as a scaled backdrop in the 2D and 3D views. Position, size, opacity and rotation are in Settings."; onClicked: planDlg.open() }

        Item { width: 12; height: 1 }

        Label { text: "Set:"; font.pixelSize: 11; color: palette.windowText; height: 26; verticalAlignment: Text.AlignVCenter }
        TZCombo {
            id: setBox
            implicitWidth: 120; implicitHeight: 26; font.pixelSize: 11
            model: { bar.owner.docVersion; return ["(all)"].concat(bar.owner.zoneSetsList()); }
            currentIndex: { var s = bar.owner.doc.settings.activeSet || ""; var i = model.indexOf(s); return i < 0 ? 0 : i; }
            onActivated: function (i) { bar.owner.setSettings("activeSet", i === 0 ? "" : model[i], "Active set"); }
            ToolTip.visible: hovered; ToolTip.text: "Active zone set (zones without a set are always active). Can also be driven by the 'Active Set' port."
        }

        ToolBtn {
            text: bar.owner.showMode ? "🔒 Show mode" : "Edit mode"; lit: bar.owner.showMode
            onClicked: bar.owner.showMode = !bar.owner.showMode
            tip: "Show mode locks all editing so a running show cannot be altered by accident"
            tint: bar.owner.showMode ? "#7a1e1e" : "#1d1c1a"
        }
        ToolBtn {
            text: "⋯"; tip: "Import / export"
            onClicked: moreMenu.open()
            Menu {
                id: moreMenu
                MenuItem { text: "Export zones to JSON file…"; onTriggered: exportDlg.open() }
                MenuItem { text: "Import zones from JSON file…"; onTriggered: importDlg.open() }
                MenuSeparator {}
                MenuItem { text: "Select all"; onTriggered: bar.owner.selection = bar.owner.doc.zones.map(function (z) { return z.id; }) }
                MenuItem { text: "Delete selected"; onTriggered: bar.owner.deleteSelected() }
                MenuItem { text: "Duplicate selected (Ctrl+D)"; onTriggered: bar.owner.duplicateSelected() }
                MenuSeparator {}
                MenuItem { text: "Reset all counters"; onTriggered: bar.owner.executionSend({ type: "resetCounters" }) }
                MenuItem { text: "Clear tracked entities"; onTriggered: bar.owner.executionSend({ type: "clearEntities" }) }
                MenuItem { text: "Undo (Ctrl+Z)"; onTriggered: Score.Editor.undo() }
                MenuItem { text: "Redo (Ctrl+Shift+Z)"; onTriggered: Score.Editor.redo() }
            }
        }
    }
    FileDialog { id: planDlg; fileMode: FileDialog.OpenFile; nameFilters: ["Images (*.png *.jpg *.jpeg *.bmp *.svg *.webp *.gif)"]; onAccepted: { var p = Util.urlToLocalFile(selectedFile); var sz = Util.imageSize(p); var w = bar.owner.doc.settings.backdrop.w || 10; bar.owner.doc.settings.backdrop.path = p; if (sz && sz.width > 0) bar.owner.doc.settings.backdrop.h = w * sz.height / sz.width; bar.owner.commit("Load floor plan"); bar.owner.selection = []; bar.owner.statusText = "Floor plan loaded: set its real width/height in Settings › Floor plan backdrop"; } }
    FileDialog { id: exportDlg; fileMode: FileDialog.SaveFile; nameFilters: ["JSON (*.json)"]; defaultSuffix: "json"; onAccepted: { Util.writeFile(Util.urlToLocalFile(selectedFile), bar.owner.exportDoc()); bar.owner.statusText = "Exported to " + Util.urlToLocalFile(selectedFile); } }
    FileDialog { id: importDlg; fileMode: FileDialog.OpenFile; nameFilters: ["JSON (*.json)"]; onAccepted: bar.owner.importDoc(bar.owner.readTextFile(Util.urlToLocalFile(selectedFile))) }
}
