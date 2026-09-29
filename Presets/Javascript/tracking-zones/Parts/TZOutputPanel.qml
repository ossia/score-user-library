import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Model.js" as Model
import "../UiUtil.js" as U
import OssiaUI as S

// Output pane: which event types are emitted at all, and the configuration of the
// simple per-event outlets (Enter / Leave / Dwell / Cross / Occupancy) and the Location outlet.
Item {
    id: panel
    property var owner
    property int v: owner.docVersion
    function sv(path, def) { v; var r = U.deepGet(owner.doc.settings, path); return r === undefined || r === null ? def : r; }
    function set(path, value, label) { owner.setSettings(path, value, label || "Output settings"); }

    component ColTitle: Label { font.bold: true; font.pixelSize: 11; color: palette.light }
    component OutletRow: RowLayout {
        property string name: ""
        property string key: ""
        property var formats: ["zone", "id", "pair", "map", "full"]
        property var formatLabels: ["Zone name", "Entity id", "[zone, id]", "Map (zone, id, ...)", "Full event"]
        Layout.fillWidth: true; spacing: 6
        S.SCheck {
            text: parent.name; Layout.preferredWidth: 90
            checked: panel.sv("outputs." + parent.key + ".enabled", true)
            onToggled: panel.set("outputs." + parent.key + ".enabled", checked, "Event outlets")
            ToolTip.visible: hovered
            ToolTip.text: "Send one message per event of this type, in the chosen format."
        }
        S.SCombo {
            Layout.preferredWidth: 170; Layout.maximumWidth: 170
            enabled: panel.sv("outputs." + parent.key + ".enabled", true)
            model: parent.formatLabels
            currentIndex: Math.max(0, parent.formats.indexOf(panel.sv("outputs." + parent.key + ".format", "map")))
            onActivated: function (i) { panel.set("outputs." + parent.key + ".format", parent.formats[i], "Outlet format"); }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 4
        spacing: 16

        // ---- master event-type switches ----
        ColumnLayout {
            Layout.fillHeight: true; Layout.preferredWidth: 230; spacing: 2
            ColTitle { text: "Event types" }
            GridLayout {
                columns: 2; columnSpacing: 10; rowSpacing: 0
                Repeater {
                    model: Model.EVENT_TYPES
                    S.SCheck {
                        required property var modelData
                        text: modelData.label
                        checked: panel.sv("events." + modelData.key, true)
                        onToggled: panel.set("events." + modelData.key, checked, "Event types")
                        ToolTip.visible: hovered
                        ToolTip.text: "Unchecked event types are not sent or logged. Each zone can also disable event types under Outputs."
                    }
                }
            }
            Item { Layout.fillHeight: true }
        }

        Rectangle { width: 1; Layout.fillHeight: true; color: palette.mid }

        // ---- simple per-event outlets ----
        ColumnLayout {
            Layout.fillHeight: true; Layout.preferredWidth: 300; spacing: 2
            ColTitle { text: "Event outlets" }
            OutletRow { name: "Enter"; key: "enter" }
            OutletRow { name: "Leave"; key: "exit" }
            OutletRow { name: "Dwell"; key: "dwell" }
            OutletRow { name: "Cross"; key: "cross" }
            OutletRow { name: "Occupancy"; key: "occupancy"; formats: ["pair", "map", "full"]; formatLabels: ["[zone, 0/1]", "Map (zone, occupied, count)", "Full event"] }
            Item { Layout.fillHeight: true }
        }

        Rectangle { width: 1; Layout.fillHeight: true; color: palette.mid }

        // ---- location outlet ----
        ColumnLayout {
            Layout.fillHeight: true; Layout.fillWidth: true; spacing: 2
            ColTitle { text: "Location outlet" }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                S.SCheck {
                    text: "Enabled"; Layout.preferredWidth: 90
                    checked: panel.sv("outputs.location.enabled", true)
                    onToggled: panel.set("outputs.location.enabled", checked, "Location outlet")
                    ToolTip.visible: hovered
                    ToolTip.text: "Report each entity's current zone."
                }
                S.SCombo {
                    Layout.preferredWidth: 170; Layout.maximumWidth: 170
                    enabled: panel.sv("outputs.location.enabled", true)
                    property var formats: ["map", "list", "zone"]
                    model: ["Map {id: zone}", "List [[id, zone], ...]", "First entity's zone"]
                    currentIndex: Math.max(0, formats.indexOf(panel.sv("outputs.location.format", "map")))
                    onActivated: function (i) { panel.set("outputs.location.format", formats[i], "Location format"); }
                    ToolTip.visible: hovered
                    ToolTip.text: "'First entity's zone' sends the first included entity's zone name. With All zones per entity, it sends a list. If no entity is included, it sends an empty string or list."
                }
            }
            S.SCheck {
                text: "All zones per entity"
                checked: panel.sv("outputs.location.all", false)
                onToggled: panel.set("outputs.location.all", checked, "Location outlet")
                ToolTip.visible: hovered
                ToolTip.text: "Send a list instead of the topmost zone. Where zones overlap, the last zone in the list is topmost."
            }
            S.SCheck {
                text: "Only send when the location output changes"
                checked: panel.sv("outputs.location.onChange", true)
                onToggled: panel.set("outputs.location.onChange", checked, "Location outlet")
            }
            S.SCheck {
                text: "Include entities that are in no zone"
                checked: panel.sv("outputs.location.includeOutside", false)
                onToggled: panel.set("outputs.location.includeOutside", checked, "Location outlet")
            }
            Item { Layout.fillHeight: true }
        }
    }
}
