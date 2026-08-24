import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Model.js" as Model
import "UiUtil.js" as U

// Output pane: which event types are emitted at all, and the configuration of the
// simple per-event outlets (Enter / Leave / Dwell / Cross / Occupancy) and the Location outlet.
Item {
    id: panel
    property var owner
    property int v: owner.docVersion
    function sv(path, def) { v; var r = U.deepGet(owner.doc.settings, path); return r === undefined || r === null ? def : r; }
    function set(path, value, label) { owner.setSettings(path, value, label || "Output settings"); }

    component ColTitle: Label { font.bold: true; font.pixelSize: 11; color: palette.light }
    component Hint: Label { font.pixelSize: 10; color: palette.placeholderText; wrapMode: Text.WordWrap; Layout.fillWidth: true }
    component OutletRow: RowLayout {
        property string name: ""
        property string key: ""
        property var formats: ["zone", "id", "pair", "map", "full"]
        property var formatLabels: ["Zone name", "Entity id", "[zone, id]", "Map (zone, id, ...)", "Full event"]
        Layout.fillWidth: true; spacing: 6
        TZCheck {
            text: parent.name; Layout.preferredWidth: 90
            checked: panel.sv("outputs." + parent.key + ".enabled", true)
            onToggled: panel.set("outputs." + parent.key + ".enabled", checked, "Event outlets")
        }
        TZCombo {
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
            Hint { text: "Unchecked types are sent nowhere: not on the Events outlet, not on the simple outlets, not in the monitors. Zones can also opt out per type in their Outputs section." }
            GridLayout {
                columns: 2; columnSpacing: 10; rowSpacing: 0
                Repeater {
                    model: Model.EVENT_TYPES
                    TZCheck {
                        required property var modelData
                        text: modelData.label
                        checked: panel.sv("events." + modelData.key, true)
                        onToggled: panel.set("events." + modelData.key, checked, "Event types")
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
            Hint { text: "Each outlet sends one message per event of its type, in the chosen format." }
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
            Hint { text: "Reports for each tracked entity the zone it is currently in. With overlapping zones, 'topmost' is the last one in the list order." }
            RowLayout {
                Layout.fillWidth: true; spacing: 6
                TZCheck {
                    text: "Enabled"; Layout.preferredWidth: 90
                    checked: panel.sv("outputs.location.enabled", true)
                    onToggled: panel.set("outputs.location.enabled", checked, "Location outlet")
                }
                TZCombo {
                    Layout.preferredWidth: 170; Layout.maximumWidth: 170
                    enabled: panel.sv("outputs.location.enabled", true)
                    property var formats: ["map", "list", "zone"]
                    model: ["Map {id: zone}", "List [[id, zone], ...]", "Single zone string"]
                    currentIndex: Math.max(0, formats.indexOf(panel.sv("outputs.location.format", "map")))
                    onActivated: function (i) { panel.set("outputs.location.format", formats[i], "Location format"); }
                }
            }
            TZCheck {
                text: "All zones per entity (list instead of the topmost zone)"
                checked: panel.sv("outputs.location.all", false)
                onToggled: panel.set("outputs.location.all", checked, "Location outlet")
            }
            TZCheck {
                text: "Only send when something changed"
                checked: panel.sv("outputs.location.onChange", true)
                onToggled: panel.set("outputs.location.onChange", checked, "Location outlet")
            }
            TZCheck {
                text: "Include entities that are in no zone"
                checked: panel.sv("outputs.location.includeOutside", false)
                onToggled: panel.set("outputs.location.includeOutside", checked, "Location outlet")
            }
            Hint { text: "'Single zone string' is meant for the one-performer case: it sends the first entity's zone name, or an empty string when it is nowhere." }
            Item { Layout.fillHeight: true }
        }
    }
}
