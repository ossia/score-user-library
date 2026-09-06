import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// A checkbox on its own row, aligned with the label column above it.
RowLayout {
    id: row

    property string label: ""
    property bool value: false
    property string tip: ""

    signal edited(bool v)

    Layout.fillWidth: true
    spacing: Theme.gap

    SCheck {
        id: check
        text: row.label
        checked: row.value
        font.pixelSize: Theme.fontMd
        onToggled: row.edited(checked)
        ToolTip.visible: row.tip.length > 0 && hovered
        ToolTip.text: row.tip
        ToolTip.delay: 500

        // Toggling assigns `checked` imperatively and breaks the binding above;
        // mirror the owner's value back so undo and external edits still show.
        Connections {
            target: row
            function onValueChanged() { check.checked = row.value; }
        }
    }
}
