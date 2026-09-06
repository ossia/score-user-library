import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "UiUtil.js" as U
import OssiaUI as S

// Left panel: the list of zones with quick toggles, drag reorder and occupancy badges.
Rectangle {
    id: panel
    property var owner
    color: palette.base
    border.color: palette.mid
    radius: 3
    property string filter: ""
    property int dragIndex: -1
    property int dropIndex: -1

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Label { text: "Zones"; font.bold: true; font.pixelSize: 12; color: palette.windowText }
            Label { font.pixelSize: 11; color: palette.placeholderText; text: { panel.owner.docVersion; return "(" + panel.owner.doc.zones.length + ")"; } }
            Item { Layout.fillWidth: true }
            Button {
                text: "+"; implicitWidth: 26; implicitHeight: 24; font.pixelSize: 12
                onClicked: addMenu.open()
                ToolTip.visible: hovered; ToolTip.text: "Add a zone at the view centre"
                Menu {
                    id: addMenu
                    MenuItem { text: "Rectangle"; onTriggered: panel.owner.addZone("rect", 0, 0) }
                    MenuItem { text: "Circle"; onTriggered: panel.owner.addZone("circle", 0, 0) }
                    MenuItem { text: "Polygon"; onTriggered: panel.owner.addZone("polygon", 0, 0) }
                    MenuItem { text: "Line (tripwire)"; onTriggered: panel.owner.addZone("line", 0, 0) }
                    MenuItem { text: "Path"; onTriggered: panel.owner.addZone("path", 0, 0) }
                    MenuSeparator {}
                    MenuItem { text: "Box"; onTriggered: panel.owner.addZone("box", 0, 0) }
                    MenuItem { text: "Sphere"; onTriggered: panel.owner.addZone("sphere", 0, 0) }
                    MenuItem { text: "Cylinder"; onTriggered: panel.owner.addZone("cylinder", 0, 0) }
                    MenuItem { text: "Prism (extruded polygon)"; onTriggered: panel.owner.addZone("prism", 0, 0) }
                }
            }
        }
        TextField {
            Layout.fillWidth: true; placeholderText: "filter by name / set / group"; font.pixelSize: 11; implicitHeight: 24
            onTextChanged: panel.filter = text.toLowerCase()
        }
        ListView {
            id: list
            Layout.fillWidth: true; Layout.fillHeight: true
            clip: true
            spacing: 1
            model: { panel.owner.docVersion; return panel.owner.doc.zones.length; }
            ScrollBar.vertical: ScrollBar {}
            delegate: Rectangle {
                id: row
                required property int index
                property var zn: { panel.owner.docVersion; return index < panel.owner.doc.zones.length ? panel.owner.doc.zones[index] : null; }
                property var st: { var zs = panel.owner.zoneStates; return zn && zs ? (zs[zn.id] || null) : null; }
                property bool matches: !zn ? false : (panel.filter.length === 0 || zn.name.toLowerCase().indexOf(panel.filter) >= 0 || (zn.set && zn.set.toLowerCase().indexOf(panel.filter) >= 0) || (zn.group && zn.group.toLowerCase().indexOf(panel.filter) >= 0))
                width: list.width
                height: matches ? 26 : 0
                visible: matches
                color: zn && panel.owner.isSelected(zn.id) ? palette.highlight : (index % 2 ? palette.alternateBase : palette.base)
                opacity: zn && zn.visible === false ? 0.45 : 1
                Rectangle { visible: panel.dropIndex === row.index && panel.dragIndex >= 0 && panel.dragIndex !== row.index; anchors.left: parent.left; anchors.right: parent.right; height: 2; color: palette.light; y: panel.dragIndex < row.index ? parent.height - 2 : 0 }
                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.LeftButton | Qt.RightButton
                    onPressed: function (m) { panel.owner.forceActiveFocus(); if (!row.zn) return; if (m.button === Qt.RightButton) { panel.owner.select(row.zn.id, false); rowMenu.popup(); return; } panel.owner.select(row.zn.id, (m.modifiers & Qt.ShiftModifier) !== 0 || (m.modifiers & Qt.ControlModifier) !== 0); panel.dragIndex = row.index; panel.dropIndex = row.index; }
                    onPositionChanged: function (m) { if (panel.dragIndex < 0) return; var p = mapToItem(list, m.x, m.y); var it = list.itemAt(p.x, p.y + list.contentY); if (it) panel.dropIndex = it.index; }
                    onReleased: { if (panel.dragIndex >= 0 && panel.dropIndex >= 0 && panel.dragIndex !== panel.dropIndex) panel.owner.reorderZone(panel.dragIndex, panel.dropIndex); panel.dragIndex = -1; panel.dropIndex = -1; }
                    onDoubleClicked: { nameEdit.visible = true; nameEdit.forceActiveFocus(); nameEdit.selectAll(); }
                }
                RowLayout {
                    anchors.fill: parent; anchors.leftMargin: 4; anchors.rightMargin: 4; spacing: 4
                    Rectangle {
                        width: 10; height: 10; radius: 2; color: row.zn ? row.zn.color : "#888"
                        border.color: row.st && row.st.occupied ? "#ffffff" : "transparent"; border.width: 1
                        MouseArea { anchors.fill: parent; onClicked: { panel.owner.select(row.zn.id, false); colorMenu.popup(); } }
                        Menu {
                            id: colorMenu
                            Repeater { model: S.Theme.swatches
                                MenuItem { required property string modelData; contentItem: Row { spacing: 6; Rectangle { width: 12; height: 12; color: modelData; anchors.verticalCenter: parent.verticalCenter } Label { text: modelData; font.pixelSize: 11 } } onTriggered: panel.owner.setSelectedProp("color", modelData, "Zone colour") }
                            }
                        }
                    }
                    Label {
                        Layout.fillWidth: true; text: row.zn ? row.zn.name + (row.zn.set ? "  ·" + row.zn.set : "") : ""; font.pixelSize: 11; elide: Text.ElideRight
                        color: row.zn && row.zn.enabled === false ? palette.placeholderText : palette.text
                        visible: !nameEdit.visible
                    }
                    TextField {
                        id: nameEdit; visible: false; Layout.fillWidth: true; implicitHeight: 22; font.pixelSize: 11
                        text: row.zn ? row.zn.name : ""
                        onAccepted: { panel.owner.setZoneProp(row.zn.id, "name", text, "Rename zone"); visible = false; }
                        onActiveFocusChanged: if (!activeFocus) visible = false
                        Keys.onEscapePressed: visible = false
                    }
                    Label {
                        visible: row.st && (row.st.count > 0 || row.st.crossings_in > 0 || row.st.crossings_out > 0)
                        text: row.st ? (row.zn && row.zn.shape.type === "line" ? (row.st.crossings_in + "/" + row.st.crossings_out) : String(row.st.count)) : ""
                        font.pixelSize: 10; font.bold: true; color: "#0b0d0c"
                        padding: 2; leftPadding: 5; rightPadding: 5
                        background: Rectangle { radius: 7; color: row.st && row.st.occupied ? (row.zn ? row.zn.color : S.Theme.ok) : S.Theme.textDim }
                    }
                    // eye
                    Label { text: row.zn && row.zn.visible === false ? "◌" : "◉"; font.pixelSize: 12; color: palette.windowText; MouseArea { anchors.fill: parent; onClicked: panel.owner.setZoneProp(row.zn.id, "visible", row.zn.visible === false, "Toggle visibility") } ToolTip.visible: false }
                    // lock
                    Label { text: row.zn && row.zn.locked ? "🔒" : "🔓"; font.pixelSize: 10; opacity: row.zn && row.zn.locked ? 1 : 0.35; MouseArea { anchors.fill: parent; onClicked: panel.owner.setZoneProp(row.zn.id, "locked", !row.zn.locked, "Toggle lock") } }
                    // enabled
                    CheckBox { checked: row.zn ? row.zn.enabled !== false : true; implicitWidth: 18; implicitHeight: 18; padding: 0; onToggled: panel.owner.setZoneProp(row.zn.id, "enabled", checked, "Toggle enabled") }
                }
                Menu {
                    id: rowMenu
                    MenuItem { text: "Rename"; onTriggered: { nameEdit.visible = true; nameEdit.forceActiveFocus(); } }
                    MenuItem { text: "Duplicate"; onTriggered: panel.owner.duplicateSelected() }
                    MenuItem { text: "Delete"; onTriggered: panel.owner.deleteSelected() }
                    MenuSeparator {}
                    MenuItem { text: "Move up"; onTriggered: panel.owner.reorderZone(row.index, Math.max(0, row.index - 1)) }
                    MenuItem { text: "Move down"; onTriggered: panel.owner.reorderZone(row.index, Math.min(panel.owner.doc.zones.length - 1, row.index + 1)) }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Button { text: "Dup"; implicitHeight: 22; font.pixelSize: 10; enabled: panel.owner.selection.length > 0; onClicked: panel.owner.duplicateSelected(); Layout.fillWidth: true }
            Button { text: "Delete"; implicitHeight: 22; font.pixelSize: 10; enabled: panel.owner.selection.length > 0; onClicked: panel.owner.deleteSelected(); Layout.fillWidth: true }
        }
    }
}
