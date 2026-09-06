import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Compact CheckBox: 13 px indicator, text vertically centred, no stray padding
// so it drops into a dense row without pushing it taller.
CheckBox {
    id: cb

    implicitHeight: Theme.rowHsm
    font.pixelSize: Theme.fontSm
    padding: 0
    spacing: Theme.gap

    indicator: Rectangle {
        implicitWidth: 13; implicitHeight: 13
        x: cb.leftPadding
        anchors.verticalCenter: parent.verticalCenter
        radius: Theme.radiusSm
        color: cb.checked ? Theme.accentFill : Theme.control
        border.width: 1
        border.color: cb.checked ? Theme.accent
                                 : (cb.hovered ? Theme.textMuted : Theme.border)
        Text {
            anchors.centerIn: parent
            visible: cb.checked
            text: "✓"
            font.pixelSize: 9
            font.bold: true
            color: Theme.textStrong
        }
    }
    contentItem: Text {
        leftPadding: cb.indicator.width + cb.spacing
        text: cb.text
        font: cb.font
        color: cb.enabled ? "#c0c0c0" : Theme.textMuted
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
