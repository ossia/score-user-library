import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs
import "Theme.js" as Theme

// label · swatch · hex field. Clicking the swatch opens the platform colour
// picker; the field accepts a typed "#rrggbb" (or "#aarrggbb").
RowLayout {
    id: row

    property string label: ""
    property string value: "#000000"
    property string tip: ""
    property real labelWidth: Theme.labelW

    signal edited(string v)

    Layout.fillWidth: true
    spacing: Theme.gap

    SFieldLabel { id: lbl; text: row.label; tip: row.tip; Layout.preferredWidth: row.labelWidth }

    Rectangle {
        implicitWidth: 20; implicitHeight: 18
        radius: Theme.radiusSm
        color: row.value || "#000000"
        border.width: 1
        border.color: swatchHover.hovered ? Theme.accent : Theme.border
        HoverHandler { id: swatchHover; cursorShape: Qt.PointingHandCursor }
        TapHandler {
            onTapped: { dlg.selectedColor = row.value || "#000000"; dlg.open(); }
        }
    }

    STextField {
        Layout.fillWidth: true
        font.pixelSize: Theme.fontSm
        font.family: "monospace"
        text: row.value || "#000000"
        onEditingFinished: if (text !== row.value) row.edited(text)
    }

    ColorDialog {
        id: dlg
        onAccepted: row.edited(selectedColor.toString())
    }
}
