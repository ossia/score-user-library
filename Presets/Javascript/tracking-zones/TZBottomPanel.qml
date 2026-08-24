import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: bottom
    property var owner
    color: palette.base
    border.color: palette.mid
    radius: 3
    clip: true

    // drag the top edge to resize the panel
    MouseArea {
        anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right
        height: 5; z: 10
        visible: bottom.owner.bottomVisible
        cursorShape: Qt.SplitVCursor
        preventStealing: true
        property real pressY: 0
        onPressed: function (m) { pressY = m.y; }
        onPositionChanged: function (m) { if (pressed) bottom.owner.bottomHeight = Math.max(120, Math.min(520, bottom.owner.bottomHeight + (pressY - m.y))); }
    }

    component Tab: TabButton {
        font.pixelSize: 11; implicitHeight: 24; width: implicitWidth + 18
        contentItem: Text { text: parent.text; font: parent.font; color: parent.checked ? "#f0f0f0" : "#a39d96"; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        background: Rectangle { implicitHeight: 24; color: parent.checked ? "#2c2a27" : (parent.hovered ? "#242220" : "transparent"); radius: 3; Rectangle { anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: 2; color: parent.parent.checked ? "#c58014" : "transparent" } }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 3
        spacing: 2
        RowLayout {
            Layout.fillWidth: true
            TabBar {
                id: tabs
                currentIndex: bottom.owner.bottomTab
                onCurrentIndexChanged: { bottom.owner.bottomTab = currentIndex; if (!bottom.owner.bottomVisible) bottom.owner.bottomVisible = true; }
                implicitHeight: 24
                background: Rectangle { color: "transparent" }
                Tab { text: "Sources & calibration" }
                Tab { text: "Simulator & recorder" }
                Tab { text: "Event monitor" }
                Tab { text: "Source monitor" }
            }
            Item { Layout.fillWidth: true }
            Button { text: bottom.owner.bottomVisible ? "▾" : "▴"; implicitWidth: 24; implicitHeight: 22; onClicked: bottom.owner.bottomVisible = !bottom.owner.bottomVisible }
        }
        StackLayout {
            Layout.fillWidth: true; Layout.fillHeight: true
            visible: bottom.owner.bottomVisible
            currentIndex: tabs.currentIndex
            TZSourcesPanel { owner: bottom.owner }
            TZSimPanel { owner: bottom.owner }
            TZMonitorPanel { owner: bottom.owner }
            TZSourceMonitor { owner: bottom.owner }
        }
    }
}
