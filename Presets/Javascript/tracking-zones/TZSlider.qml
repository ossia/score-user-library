import QtQuick
import QtQuick.Controls

// Slider with an explicit left-to-right fill so the filled part always reads correctly.
// Double click resets to defaultValue.
Slider {
    id: s
    property real defaultValue: from
    implicitHeight: 20
    background: Rectangle {
        x: s.leftPadding; y: s.topPadding + s.availableHeight / 2 - height / 2
        width: s.availableWidth; height: 4; radius: 2
        color: "#3a3835"
        Rectangle { width: s.visualPosition * parent.width; height: parent.height; radius: 2; color: s.enabled ? "#c58014" : "#6a5836" }
    }
    handle: Rectangle {
        x: s.leftPadding + s.visualPosition * (s.availableWidth - width)
        y: s.topPadding + s.availableHeight / 2 - height / 2
        width: 12; height: 12; radius: 6
        color: s.pressed ? "#ffffff" : "#f0f0f0"
        border.color: "#0c0c0b"; border.width: 1
    }
    TapHandler { onDoubleTapped: { s.value = s.defaultValue; s.moved(); } }
}
