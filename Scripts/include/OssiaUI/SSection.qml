import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// A collapsible group, styled as a Unity-style foldout rather than a filled bar:
// a disclosure triangle and a bold title sitting on the panel ground, with a
// hairline rule underneath. A column of a dozen of these stays quiet, and the
// eye reads the titles instead of a ladder of grey blocks.
//
//   SSection {
//       title: "Font"
//       SSliderRow { ... }
//       SComboRow { ... }
//   }
//
// Children are placed in the body automatically, so callers never repeat the
// `visible: header.on` / `Layout.margins` boilerplate.
ColumnLayout {
    id: sec

    property string title: ""
    property bool expanded: true
    property string tip: ""
    default property alias content: body.data

    Layout.fillWidth: true
    spacing: 0

    SFoldout {
        id: header
        Layout.fillWidth: true
        title: sec.title
        tip: sec.tip
        expanded: sec.expanded
        onExpandedChanged: sec.expanded = expanded
    }

    ColumnLayout {
        id: body
        visible: sec.expanded
        Layout.fillWidth: true
        Layout.leftMargin: Theme.gapLg
        Layout.rightMargin: Theme.gapSm
        Layout.topMargin: Theme.gap
        Layout.bottomMargin: Theme.gap
        spacing: Theme.gap
    }
}
