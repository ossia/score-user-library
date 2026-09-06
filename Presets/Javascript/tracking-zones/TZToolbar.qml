import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Model.js" as Model
import OssiaUI as S

// Top toolbar: tools, creation menu, view options, set selector, show-mode lock, import/export.
Item {
    id: bar
    property var owner
    implicitHeight: flow.implicitHeight

    // Tool buttons come from the shared kit; the only local part is binding
    // `lit` to the owner's current tool, so clicking twice cannot deselect a
    // mode and external changes (shortcuts) stay in sync.
    component ToolBtn: S.SButton {
        property string toolName: ""
        lit: toolName.length > 0 && bar.owner.tool === toolName
        enabled: !bar.owner.showMode || toolName === "" || toolName === "select" || toolName === "sim"
        onClicked: if (toolName.length) bar.owner.tool = toolName
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

        S.SVSeparator {}

        ToolBtn {
            text: "Generate ▾"; tip: "Templates and generators"
            enabled: !bar.owner.showMode
            onClicked: genMenu.open()
            S.SMenu {
                id: genMenu
                y: parent.height
                S.SMenuItem { text: "Grid 3×2 (6 m × 4 m)"; onTriggered: bar.owner.addZones(Model.gridZones(0, 0, 6, 4, 3, 2, bar.owner.doc.zones.length), "Add grid") }
                S.SMenuItem { text: "Grid 4×4 (8 m × 8 m)"; onTriggered: bar.owner.addZones(Model.gridZones(0, 0, 8, 8, 4, 4, bar.owner.doc.zones.length), "Add grid") }
                S.SMenuItem { text: "Radial sectors ×6 (r 1-3 m)"; onTriggered: bar.owner.addZones(Model.sectorZones(0, 0, 1, 3, 6, bar.owner.doc.zones.length), "Add sectors") }
                S.SMenuItem { text: "Radial sectors ×8 (r 0-4 m)"; onTriggered: bar.owner.addZones(Model.sectorZones(0, 0, 0, 4, 8, bar.owner.doc.zones.length), "Add sectors") }
                S.SMenuItem { text: "Pie ×4 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 4, bar.owner.doc.zones.length), "Add pie") }
                S.SMenuItem { text: "Pie ×6 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 6, bar.owner.doc.zones.length), "Add pie") }
                S.SMenuItem { text: "Pie ×8 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 8, bar.owner.doc.zones.length), "Add pie") }
                S.SMenuItem { text: "Pie ×12 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 12, bar.owner.doc.zones.length), "Add pie") }
                S.SMenuItem { text: "Pie ×16 (r 2 m)"; onTriggered: bar.owner.addZones(Model.pieZones(0, 0, 2, 16, bar.owner.doc.zones.length), "Add pie") }
                S.SMenuSeparator {}
                S.SMenuItem { text: "Template: door tripwire + approach"; onTriggered: bar.owner.addZones(Model.template("door"), "Add template") }
                S.SMenuItem { text: "Template: stage up/mid/down"; onTriggered: bar.owner.addZones(Model.template("stage"), "Add template") }
                S.SMenuItem { text: "Template: audience funnel rings"; onTriggered: bar.owner.addZones(Model.template("funnel"), "Add template") }
                S.SMenuSeparator {}
                S.SMenuItem { text: "Camera: 3×3 segmentation"; onTriggered: bar.owner.addZones(Model.template("camera-grid"), "Add template") }
                S.SMenuItem { text: "Camera: quadrants"; onTriggered: bar.owner.addZones(Model.template("camera-quadrants"), "Add template") }
                S.SMenuItem { text: "Camera: 8 vertical strips (fader bank)"; onTriggered: bar.owner.addZones(Model.template("camera-columns"), "Add template") }
                S.SMenuItem { text: "Camera: 5 horizontal bands"; onTriggered: bar.owner.addZones(Model.template("camera-rows"), "Add template") }
                S.SMenuItem { text: "Camera: piano keyboard, 1 octave"; onTriggered: bar.owner.addZones(Model.template("piano"), "Add template") }
                S.SMenuItem { text: "Camera: piano keyboard, 2 octaves"; onTriggered: bar.owner.addZones(Model.template("piano2"), "Add template") }
                S.SMenuItem { text: "Camera: XY pad + corner triggers"; onTriggered: bar.owner.addZones(Model.template("xy-pad"), "Add template") }
                S.SMenuItem { text: "Camera: swipe tripwires"; onTriggered: bar.owner.addZones(Model.template("swipe"), "Add template") }
                S.SMenuItem { text: "3D: near / mid / far depth layers"; onTriggered: bar.owner.addZones(Model.template("depth-layers"), "Add template") }
            }
        }

        S.SVSeparator {}

        ToolBtn { text: "2D"; lit: bar.owner.viewMode === "2d"; onClicked: bar.owner.viewMode = "2d"; tip: "Top view (Tab cycles)" }
        ToolBtn { text: "3D"; lit: bar.owner.viewMode === "3d"; onClicked: bar.owner.viewMode = "3d"; tip: "3D view (Tab cycles). Drag empty space to orbit, right-drag to pan, wheel to zoom." }
        ToolBtn { text: "Split"; lit: bar.owner.viewMode === "split"; onClicked: bar.owner.viewMode = "split"; tip: "2D and 3D views (Tab cycles). In 3D, drag empty space to orbit, right-drag to pan, wheel to zoom." }
        ToolBtn { text: "Fit"; tip: "Fit all zones in view (F)"; onClicked: bar.owner.fitView() }

        S.SVSeparator {}

        ToolBtn { text: "Snap"; lit: bar.owner.snapping; onClicked: bar.owner.snapping = !bar.owner.snapping; tip: "Snap to grid (G)" }
        S.SSpin {
            id: gridSpin
            from: 1; to: 500; stepSize: 1
            value: Math.round(bar.owner.gridStep * 100)
            implicitWidth: 92
            textFromValue: function (v) { return (v / 100).toFixed(2) + " m"; }
            valueFromText: function (t) { return Math.round(parseFloat(t) * 100); }
            onValueModified: bar.owner.gridStep = value / 100
            ToolTip.visible: hovered; ToolTip.text: "Grid step"
        }
        ToolBtn { text: "Trails"; lit: bar.owner.showTrails; onClicked: bar.owner.showTrails = !bar.owner.showTrails }
        ToolBtn { text: "Labels"; lit: bar.owner.showLabels; onClicked: bar.owner.showLabels = !bar.owner.showLabels }
        ToolBtn { text: "Speed"; lit: bar.owner.showVelocity; onClicked: bar.owner.showVelocity = !bar.owner.showVelocity; tip: "Draw velocity lines on entities" }
        ToolBtn { text: "Keypoints"; lit: bar.owner.showKeypoints; onClicked: bar.owner.showKeypoints = !bar.owner.showKeypoints; tip: "Draw skeleton keypoints (costs bandwidth with many entities)" }
        ToolBtn { text: "Heat"; lit: bar.owner.showHeat; onClicked: bar.owner.showHeat = !bar.owner.showHeat; tip: "Show heatmap (enable it in Settings)" }
        ToolBtn { text: "Floor plan…"; enabled: !bar.owner.showMode; tip: "Load a floor plan image for the 2D and 3D views. Set its real width and height in Settings under Floor plan backdrop."; onClicked: bar.owner.chooseFloorPlan() }

        Item { width: 12; height: 1 }

        Label { text: "Set:"; font.pixelSize: 11; color: palette.windowText; height: 26; verticalAlignment: Text.AlignVCenter }
        S.SCombo {
            id: setBox
            implicitWidth: 120; implicitHeight: 26; font.pixelSize: 11
            model: { bar.owner.docVersion; return ["(all)"].concat(bar.owner.zoneSetsList()); }
            currentIndex: { var s = bar.owner.doc.settings.activeSet || ""; var i = model.indexOf(s); return i < 0 ? 0 : i; }
            onActivated: function (i) { bar.owner.setSettings("activeSet", i === 0 ? "" : model[i], "Active set"); }
            ToolTip.visible: hovered; ToolTip.text: "Active zone set (zones without a set are always active). Can also be driven by the 'Active Set' port."
        }

        ToolBtn {
            text: bar.owner.showMode ? "Editing locked" : "Editing unlocked"; lit: bar.owner.showMode
            onClicked: bar.owner.showMode = !bar.owner.showMode
            tip: "Lock editing to prevent accidental changes during a show"
            tint: bar.owner.showMode ? S.Theme.danger : S.Theme.control
        }
        ToolBtn {
            text: "⋯"; tip: "More actions"
            onClicked: moreMenu.open()
            S.SMenu {
                id: moreMenu
                y: parent.height
                S.SMenuItem { text: "Export zones to JSON file…"; onTriggered: Util.saveFileDialog("Export zones", "JSON (*.json)", "", "zones.json", function(path) { if (bar && path) { Util.writeFile(path, bar.owner.exportDoc()); bar.owner.statusText = "Exported to " + path; } }) }
                S.SMenuItem { text: "Import zones from JSON file…"; enabled: !bar.owner.showMode; onTriggered: Util.openFileDialog("Import zones", "JSON (*.json)", "", function(path) { if (bar && path && !bar.owner.showMode) bar.owner.importDoc(bar.owner.readTextFile(path)); }) }
                S.SMenuSeparator {}
                S.SMenuItem { text: "Select all"; onTriggered: bar.owner.selection = bar.owner.doc.zones.map(function (z) { return z.id; }) }
                S.SMenuItem { text: "Delete selected"; enabled: !bar.owner.showMode; onTriggered: bar.owner.deleteSelected() }
                S.SMenuItem { text: "Duplicate selected (Ctrl+D)"; enabled: !bar.owner.showMode; onTriggered: bar.owner.duplicateSelected() }
                S.SMenuSeparator {}
                S.SMenuItem { text: "Reset all counters"; onTriggered: bar.owner.executionSend({ type: "resetCounters" }) }
                S.SMenuItem { text: "Clear tracked entities"; onTriggered: bar.owner.executionSend({ type: "clearEntities" }) }
                S.SMenuItem { text: "Undo (Ctrl+Z)"; onTriggered: bar.owner.uiAction({ action: "undo" }) }
                S.SMenuItem { text: "Redo (Ctrl+Shift+Z)"; onTriggered: bar.owner.uiAction({ action: "redo" }) }
            }
        }
    }
}
