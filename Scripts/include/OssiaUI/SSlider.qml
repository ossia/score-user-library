import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Slider with an explicit left-to-right fill, so the filled part always reads as
// "how much" regardless of style. Double click resets to `defaultValue`.
Slider {
    id: s

    property real defaultValue: from

    implicitHeight: Theme.rowHsm

    background: Rectangle {
        x: s.leftPadding
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: s.availableWidth
        height: 4
        radius: 2
        color: Theme.controlDown
        Rectangle {
            width: s.visualPosition * parent.width
            height: parent.height
            radius: 2
            color: s.enabled ? Theme.accent : "#6a5836"
        }
    }
    handle: Rectangle {
        x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: 12; height: 12; radius: 6
        color: s.pressed ? "#ffffff" : (s.enabled ? Theme.textStrong : Theme.textMuted)
        border.color: Theme.dark
        border.width: 1
    }
    TapHandler { onDoubleTapped: { s.value = s.defaultValue; s.moved(); } }
}
