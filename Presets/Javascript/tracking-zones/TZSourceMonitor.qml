import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "UiUtil.js" as U

// Source monitor: one row per inlet showing what arrives and what the ingest made of it.
// Data comes from the execution snapshot (already rate-limited to the UI rate).
Item {
    id: panel
    property var owner
    property var rows: { owner.snapshot; return owner.snapshot && owner.snapshot.sourceInfo ? owner.snapshot.sourceInfo : [null, null, null, null]; }
    property var health: { owner.snapshot; return owner.snapshot && owner.snapshot.sources ? owner.snapshot.sources : ({}); }
    property int selectedRow: 0

    // fixed column widths so every row lines up with the header whatever the text
    component Cell: Label { property real w: 60; font.pixelSize: 10; color: palette.text; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter; Layout.fillHeight: true; Layout.preferredWidth: w; Layout.minimumWidth: w; Layout.maximumWidth: w }
    component Head: Label { property real w: 60; font.pixelSize: 10; font.bold: true; color: palette.placeholderText; verticalAlignment: Text.AlignVCenter; Layout.preferredWidth: w; Layout.minimumWidth: w; Layout.maximumWidth: w }

    ColumnLayout {
        anchors.fill: parent
        spacing: 3
        RowLayout {
            Layout.fillWidth: true
            TZCheck { text: "Source monitor"; font.bold: true; font.pixelSize: 11; checked: owner.sourceMonitorEnabled; onToggled: owner.sourceMonitorEnabled = checked; ToolTip.visible: hovered; ToolTip.text: "Off: the execution skips payload classification and raw previews (saves CPU on the audio thread)." }
            Label {
                Layout.fillWidth: true; wrapMode: Text.WordWrap; font.pixelSize: 10; color: palette.placeholderText
                text: !owner.sourceMonitorEnabled ? "Disabled." : (owner.liveData ? "Live. Click a row to see the last raw payload received on that inlet." : "Transport stopped: nothing arrives on the inlets until score plays.")
            }
        }
        // table
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 22 * 6 + 2
            color: palette.base; border.color: palette.mid; radius: 3
            ColumnLayout {
                anchors.fill: parent; anchors.margins: 1
                spacing: 0
                RowLayout {
                    Layout.fillWidth: true; Layout.preferredHeight: 22; spacing: 8
                    Head { text: "Inlet"; w: 110; Layout.leftMargin: 6 }
                    Head { text: "Status"; w: 90 }
                    Head { text: "Msgs/tick"; w: 60 }
                    Head { text: "Payload"; w: 230 }
                    Head { text: "Parsed"; w: 50 }
                    Head { text: "In engine"; w: 60 }
                    Head { text: "Dropped (NaN)"; w: 80 }
                    Label { text: "Entities (id @ x,y,z after calibration)"; font.pixelSize: 10; font.bold: true; color: palette.placeholderText; verticalAlignment: Text.AlignVCenter; Layout.fillWidth: true }
                }
                Repeater {
                    model: 5
                    delegate: Item {
                        id: rowItem
                        required property int index
                        property bool isSim: index === 4
                        property var r: isSim ? null : panel.rows[index]
                        property var h: panel.health[String(index)] || null
                        property bool alive: h && owner.liveData && owner.snapshot && (owner.snapshot.t - h.lastT) < 1.0
                        property string name: isSim ? "Simulation" : ((owner.doc.sources[index] && owner.doc.sources[index].name) || ("Source " + (index + 1)))
                        Layout.fillWidth: true; Layout.preferredHeight: 22
                        Rectangle { anchors.fill: parent; color: panel.selectedRow === rowItem.index ? "#2c2a27" : (rowItem.index % 2 ? palette.alternateBase : "transparent") }
                        MouseArea { anchors.fill: parent; onClicked: panel.selectedRow = rowItem.index }
                        RowLayout {
                            anchors.fill: parent; spacing: 8
                            Cell { text: rowItem.name + (rowItem.isSim ? "" : " (inlet " + (rowItem.index + 1) + ")"); w: 110; Layout.leftMargin: 6; font.bold: true }
                            RowLayout {
                                Layout.preferredWidth: 90; Layout.minimumWidth: 90; Layout.maximumWidth: 90; spacing: 4
                                Rectangle { width: 8; height: 8; radius: 4; color: rowItem.alive ? "#c58014" : ((rowItem.r && rowItem.r.enabled === false) ? "#7a1e1e" : "#555") }
                                Label { text: rowItem.r && rowItem.r.enabled === false ? "disabled" : (rowItem.alive ? (U.fmt(rowItem.h.fps, 0) + " Hz") : "no data"); font.pixelSize: 10; color: palette.placeholderText; Layout.fillWidth: true; elide: Text.ElideRight }
                            }
                            Cell { text: rowItem.isSim ? "-" : (rowItem.r ? String(rowItem.r.msgs) : "-"); w: 60 }
                            Cell { text: rowItem.isSim ? ((owner.snapshot && owner.snapshot.simCount ? owner.snapshot.simCount : 0) + " virtual entities") : (rowItem.r ? rowItem.r.kind : "-"); w: 230 }
                            Cell { text: rowItem.isSim ? "-" : (rowItem.r ? String(rowItem.r.parsed) : "-"); w: 50 }
                            Cell { text: rowItem.h ? String(rowItem.h.n) : "0"; w: 60 }
                            Cell { text: rowItem.isSim ? "-" : (rowItem.r ? String(rowItem.r.nan) : "-"); w: 80; color: rowItem.r && rowItem.r.nan > 0 ? "#e0a54d" : palette.text }
                            Label { text: rowItem.isSim ? "" : (rowItem.r && rowItem.r.ids ? rowItem.r.ids.split("\n").join("   ") : ""); font.pixelSize: 10; color: palette.placeholderText; elide: Text.ElideRight; verticalAlignment: Text.AlignVCenter; Layout.fillWidth: true; Layout.fillHeight: true }
                        }
                    }
                }
            }
        }
        // raw payload of the selected inlet
        RowLayout {
            Layout.fillWidth: true
            Head { text: "Last raw payload on " + (panel.selectedRow === 4 ? "Simulation" : "inlet " + (panel.selectedRow + 1)) }
            Item { Layout.fillWidth: true }
            Label { font.pixelSize: 10; color: palette.placeholderText; text: "Payload kinds: single point, flat floats, list of vectors / lists / maps, one entity map, map of entities, map of sources (see README)" }
        }
        ScrollView {
            Layout.fillWidth: true; Layout.fillHeight: true; clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
            TextArea {
                readOnly: true; font.family: "monospace"; font.pixelSize: 10; wrapMode: TextEdit.WrapAnywhere; color: palette.text
                background: Rectangle { color: palette.base; border.color: palette.mid; radius: 3 }
                text: panel.selectedRow === 4 ? "(virtual entities come from the Simulator pane)" : ((panel.rows[panel.selectedRow] && panel.rows[panel.selectedRow].preview) || "(nothing received)")
            }
        }
    }
}
