import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// label · text field, committed on editingFinished.
RowLayout {
    id: row

    property string label: ""
    property string value: ""
    property string placeholder: ""
    property string tip: ""
    property real labelWidth: Theme.labelW

    signal edited(string v)

    Layout.fillWidth: true
    spacing: Theme.gap

    SFieldLabel { id: lbl; text: row.label; tip: row.tip; Layout.preferredWidth: row.labelWidth }
    STextField {
        Layout.fillWidth: true
        text: row.value
        placeholderText: row.placeholder
        onEditingFinished: if (text !== row.value) row.edited(text)
    }
}
