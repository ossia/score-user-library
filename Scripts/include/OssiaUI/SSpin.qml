import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// SpinBox with the −/+ steppers flanking a centred value, at toolbar height.
SpinBox {
    id: sb

    implicitHeight: Theme.toolH
    font.pixelSize: Theme.fontMd
    font.hintingPreference: Theme.hinting
    leftPadding: 20; rightPadding: 20
    editable: true

    contentItem: TextInput {
        text: sb.textFromValue(sb.value, sb.locale)
        font: sb.font
        color: sb.enabled ? Theme.text : Theme.textMuted
        horizontalAlignment: Qt.AlignHCenter
        verticalAlignment: Qt.AlignVCenter
        readOnly: !sb.editable
        validator: sb.validator
        selectByMouse: true
        selectionColor: Theme.accentFill
        selectedTextColor: Theme.accentText
    }
    up.indicator: Rectangle {
        x: sb.width - width
        height: sb.height; width: 18
        radius: Theme.radius
        color: sb.up.pressed ? Theme.controlDown : (sb.up.hovered ? Theme.controlHover : Theme.control)
        border.color: Theme.border
        Text { anchors.centerIn: parent; text: "+"; font.pixelSize: Theme.fontLg; color: "#c0c0c0" }
    }
    down.indicator: Rectangle {
        x: 0
        height: sb.height; width: 18
        radius: Theme.radius
        color: sb.down.pressed ? Theme.controlDown : (sb.down.hovered ? Theme.controlHover : Theme.control)
        border.color: Theme.border
        Text { anchors.centerIn: parent; text: "−"; font.pixelSize: Theme.fontLg; color: "#c0c0c0" }
    }
    background: Rectangle {
        implicitWidth: 96
        radius: Theme.radius
        color: Theme.control
        border.width: 1
        border.color: sb.activeFocus ? Theme.accent : Theme.border
    }
}
