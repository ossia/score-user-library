import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// A non-collapsing group heading inside a panel: accent-coloured, with the
// breathing room above that separates it from the previous group.
Label {
    Layout.fillWidth: true
    Layout.topMargin: Theme.gapLg
    font.bold: true
    font.pixelSize: Theme.fontMd
    color: Theme.accent
}
