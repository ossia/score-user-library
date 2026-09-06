import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// The header half of a collapsible group: a disclosure triangle and a bold
// title on the panel ground, closed off by a hairline. Use SSection when the
// body can be a child of the group; use this directly when the body has to stay
// a sibling (an existing layout you do not want to reparent).
Item {
    id: fold

    property string title: ""
    property bool expanded: true
    property string tip: ""
    // optional trailing content (a count, a small button) laid out at the right
    default property alias trailing: rightSlot.data

    Layout.fillWidth: true
    Layout.topMargin: Theme.gap
    implicitHeight: Theme.rowH
    implicitWidth: 100

    Rectangle {
        anchors.fill: parent
        color: hover.hovered ? Theme.controlHover : "transparent"
        radius: Theme.radius
    }

    Text {
        id: tri
        anchors { left: parent.left; leftMargin: Theme.gap; verticalCenter: parent.verticalCenter }
        width: 11
        text: fold.expanded ? "▾" : "▸"
        font.pixelSize: Theme.fontSm
        font.hintingPreference: Theme.hinting
        color: Theme.textDim
    }
    Text {
        anchors {
            left: tri.right; leftMargin: Theme.gap
            right: rightSlot.left; rightMargin: Theme.gap
            verticalCenter: parent.verticalCenter
        }
        text: fold.title
        color: fold.expanded ? Theme.textStrong : Theme.textDim
        font.pixelSize: Theme.fontMd
        font.hintingPreference: Theme.hinting
        font.bold: true
        elide: Text.ElideRight
    }

    Row {
        id: rightSlot
        anchors { right: parent.right; rightMargin: Theme.gap; verticalCenter: parent.verticalCenter }
        spacing: Theme.gap
    }

    Rectangle {
        anchors { left: parent.left; right: parent.right; bottom: parent.bottom }
        height: 1
        color: Theme.border
    }

    HoverHandler { id: hover }
    TapHandler { onTapped: fold.expanded = !fold.expanded }

    ToolTip.visible: fold.tip.length > 0 && hover.hovered
    ToolTip.text: fold.tip
    ToolTip.delay: 600
}
