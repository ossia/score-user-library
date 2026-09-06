import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "UiUtil.js" as U
import OssiaUI as S

// Monitor: event log + per-zone counters table.
Item {
    id: panel
    property var owner

    RowLayout {
        anchors.fill: parent
        spacing: 6
        // ---- event log ----
        ColumnLayout {
            Layout.fillHeight: true; Layout.preferredWidth: 420; spacing: 2
            RowLayout {
                S.SCheck { text: "Events"; font.bold: true; font.pixelSize: 11; checked: owner.eventMonitorEnabled; onToggled: owner.eventMonitorEnabled = checked; ToolTip.visible: hovered; ToolTip.text: "Turn off to stop collecting this log. The Events outlet is unaffected." }
                Label { font.pixelSize: 10; color: palette.placeholderText; text: "(" + owner.eventLog.count + " of max " + ((owner.doc.settings.monitor && owner.doc.settings.monitor.maxEvents) || 400) + ")" }
                Label { visible: owner.droppedEvents > 0; font.pixelSize: 10; color: "#e0a54d"; text: owner.droppedEvents + " not listed"; ToolTip.visible: dh.hovered; ToolTip.text: "Rate limit reached. Set the row limit in Settings under Event log limits. The Events outlet is unaffected."; HoverHandler { id: dh } }
                Item { Layout.fillWidth: true }
                CheckBox { id: autoScroll; text: "Follow"; checked: true; font.pixelSize: 10; implicitHeight: 18 }
                Button { text: "Clear"; implicitHeight: 20; font.pixelSize: 10; onClicked: { owner.eventLog.clear(); owner.eventLogVersion++; } }
            }
            ListView {
                id: evList
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                model: owner.eventLog
                onCountChanged: if (autoScroll.checked) positionViewAtEnd()
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property int index
                    required property real t
                    required property string type
                    required property string zone
                    required property string eid
                    required property string detail
                    width: evList.width; height: 16
                    color: index % 2 ? palette.alternateBase : "transparent"
                    RowLayout {
                        anchors.fill: parent; spacing: 6
                        Label { text: U.fmtTime(t); font.pixelSize: 10; color: palette.placeholderText; Layout.preferredWidth: 44 }
                        Label {
                            text: type; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 60
                            color: type === "enter" || type === "occupied" || type === "first_in" ? S.Theme.accent : (type === "exit" || type === "empty" || type === "last_out" ? "#e0a54d" : (type === "cross" ? "#7ad3ff" : palette.text))
                        }
                        Label { text: zone; font.pixelSize: 10; Layout.preferredWidth: 100; elide: Text.ElideRight; color: palette.text }
                        Label { text: eid !== "" ? ("id " + eid) : ""; font.pixelSize: 10; Layout.preferredWidth: 60; elide: Text.ElideRight; color: palette.text }
                        Label { Layout.fillWidth: true; font.pixelSize: 10; color: palette.placeholderText; elide: Text.ElideRight; text: detail }
                    }
                }
            }
        }
        // ---- zone table ----
        ColumnLayout {
            Layout.fillHeight: true; Layout.fillWidth: true; spacing: 2
            RowLayout {
                Label { text: "Zone counters"; font.bold: true; font.pixelSize: 11; color: palette.windowText }
                Item { Layout.fillWidth: true }
                Button { text: "Export CSV"; implicitHeight: 20; font.pixelSize: 10; onClicked: Util.saveFileDialog("Export counters", "CSV (*.csv)", "", "counters.csv", function(path) { if (panel && path) { Util.writeFile(path, panel.zonesCsv()); panel.owner.statusText = "Exported counters to " + path; } }); ToolTip.visible: hovered; ToolTip.text: "Save the current per-zone counters as CSV" }
                Button { text: "Reset all"; implicitHeight: 20; font.pixelSize: 10; onClicked: owner.executionSend({ type: "resetCounters" }) }
                Button { text: "Clear entities"; implicitHeight: 20; font.pixelSize: 10; onClicked: owner.executionSend({ type: "clearEntities" }) }
            }
            Rectangle {
                Layout.fillWidth: true; height: 16; color: palette.mid
                RowLayout { anchors.fill: parent; anchors.leftMargin: 4; spacing: 4
                    Label { text: "Zone"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 110 }
                    Label { text: "Count"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 40 }
                    Label { text: "State"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 60 }
                    Label { text: "In/Out"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 50 }
                    Label { text: "Visits"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 40 }
                    Label { text: "Unique"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 44 }
                    Label { text: "Dwell"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 44 }
                    Label { text: "Idle"; font.pixelSize: 10; font.bold: true; Layout.preferredWidth: 44 }
                    Label { text: "Ids"; font.pixelSize: 10; font.bold: true; Layout.fillWidth: true }
                }
            }
            ListView {
                id: zList
                Layout.fillWidth: true; Layout.fillHeight: true; clip: true
                model: { owner.docVersion; return owner.doc.zones.length; }
                ScrollBar.vertical: ScrollBar {}
                delegate: Rectangle {
                    required property int index
                    property var zn: { owner.docVersion; return owner.doc.zones[index]; }
                    property var st: { var zs = owner.zoneStates; return zn && zs ? (zs[zn.id] || null) : null; }
                    width: zList.width; height: 16
                    color: zn && owner.isSelected(zn.id) ? palette.highlight : (index % 2 ? palette.alternateBase : "transparent")
                    MouseArea { anchors.fill: parent; onClicked: owner.select(zn.id, false) }
                    RowLayout { anchors.fill: parent; anchors.leftMargin: 4; spacing: 4
                        Label { text: zn ? zn.name : ""; font.pixelSize: 10; Layout.preferredWidth: 110; elide: Text.ElideRight; color: palette.text }
                        Label { text: st ? st.count : "-"; font.pixelSize: 10; Layout.preferredWidth: 40; color: palette.text }
                        Label { text: st ? (st.active === false ? "disabled" : (st.occupied ? "occupied" : "empty")) : "-"; font.pixelSize: 10; Layout.preferredWidth: 60; color: st && st.occupied ? S.Theme.accent : palette.placeholderText }
                        Label { text: st ? st.crossings_in + "/" + st.crossings_out : "-"; font.pixelSize: 10; Layout.preferredWidth: 50; color: palette.text }
                        Label { text: st ? st.visits : "-"; font.pixelSize: 10; Layout.preferredWidth: 40; color: palette.text }
                        Label { text: st ? st.unique : "-"; font.pixelSize: 10; Layout.preferredWidth: 44; color: palette.text }
                        Label { text: st ? U.fmtTime(st.dwell_now || 0) : "-"; font.pixelSize: 10; Layout.preferredWidth: 44; color: palette.text }
                        Label { text: st ? U.fmtTime(st.idle || 0) : "-"; font.pixelSize: 10; Layout.preferredWidth: 44; color: palette.text }
                        Label { text: st ? (st.ids || []).join(", ") : ""; font.pixelSize: 10; Layout.fillWidth: true; elide: Text.ElideRight; color: palette.placeholderText }
                    }
                }
            }
        }
    }
    function zonesCsv() {
        var rows = ["zone,type,count,occupied,crossings_in,crossings_out,visits,unique,dwell_now_s,dwell_max_s,idle_s,ids"];
        var s = owner.snapshot; var byId = {}; if (s) for (var i = 0; i < s.zones.length; i++) byId[s.zones[i].id] = s.zones[i];
        for (var j = 0; j < owner.doc.zones.length; j++) { var z = owner.doc.zones[j]; var st = byId[z.id] || {}; rows.push([JSON.stringify(z.name), z.shape.type, st.count || 0, st.occupied ? 1 : 0, st.crossings_in || 0, st.crossings_out || 0, st.visits || 0, st.unique || 0, (st.dwell_now || 0).toFixed(2), (st.dwell_max || 0).toFixed(2), (st.idle || 0).toFixed(2), JSON.stringify((st.ids || []).join(" "))].join(",")); }
        return rows.join("\n") + "\n";
    }
}
