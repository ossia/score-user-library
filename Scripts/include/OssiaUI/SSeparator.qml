import QtQuick
import QtQuick.Layouts
import "Theme.js" as Theme

// Horizontal hairline between groups of controls inside a panel.
Rectangle {
    Layout.fillWidth: true
    Layout.topMargin: Theme.gap
    Layout.bottomMargin: Theme.gapSm
    implicitHeight: 1
    height: 1
    color: Theme.border
}
