import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Themed single-line field at the standard dense row height.
TextField {
    id: tf
    implicitHeight: Theme.rowH
    font.pixelSize: Theme.fontMd
    leftPadding: Theme.gapLg; rightPadding: Theme.gapLg
    topPadding: 2; bottomPadding: 2
    color: enabled ? Theme.text : Theme.textMuted
    placeholderTextColor: Theme.textMuted
    selectByMouse: true
    selectionColor: Theme.accentFill
    selectedTextColor: Theme.accentText
    background: Rectangle {
        implicitWidth: 60
        implicitHeight: Theme.rowH
        radius: Theme.radius
        color: tf.enabled ? Theme.control : Theme.base
        border.width: 1
        border.color: tf.activeFocus ? Theme.accent
                                     : (tf.hovered ? Theme.controlDown : Theme.border)
    }
}
