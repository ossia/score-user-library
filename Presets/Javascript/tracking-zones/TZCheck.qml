import QtQuick
import QtQuick.Controls

// Compact CheckBox: 13 px indicator, text vertically centred.
CheckBox {
    id: cb
    implicitHeight: 20
    font.pixelSize: 10
    padding: 0; spacing: 4
    indicator: Rectangle {
        implicitWidth: 13; implicitHeight: 13
        x: cb.leftPadding
        anchors.verticalCenter: parent.verticalCenter
        radius: 2
        color: cb.checked ? "#62400a" : "#1d1c1a"
        border.color: cb.checked ? "#c58014" : (cb.hovered ? "#7c7670" : "#3a3835"); border.width: 1
        Text { anchors.centerIn: parent; visible: cb.checked; text: "✓"; font.pixelSize: 9; font.bold: true; color: "#f0f0f0" }
    }
    contentItem: Text {
        leftPadding: cb.indicator.width + cb.spacing
        text: cb.text
        font: cb.font
        color: cb.enabled ? "#c0c0c0" : "#7c7670"
        verticalAlignment: Text.AlignVCenter
    }
}
