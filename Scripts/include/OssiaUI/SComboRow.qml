import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// label · combo. `options` are the stored values; `labels` (optional) are what
// the user reads, so persisted state never has to carry display strings.
RowLayout {
    id: row

    property string label: ""
    property var options: []
    property var labels: []
    property string value: ""
    property string tip: ""
    property real labelWidth: Theme.labelW

    signal edited(string v)

    Layout.fillWidth: true
    spacing: Theme.gap

    SFieldLabel { id: lbl; text: row.label; tip: row.tip; Layout.preferredWidth: row.labelWidth }
    SCombo {
        id: combo
        Layout.fillWidth: true
        model: row.labels.length ? row.labels : row.options
        currentIndex: Math.max(0, row.options.indexOf(row.value))
        onActivated: function (i) { row.edited(row.options[i]); }

        // Activating the combo assigns currentIndex imperatively and breaks the
        // binding above; re-assert it so the shown item keeps tracking the owner.
        Connections {
            target: row
            function onValueChanged() {
                combo.currentIndex = Math.max(0, row.options.indexOf(row.value));
            }
        }
    }
}
