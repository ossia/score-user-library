import QtQuick
import QtQuick.Templates as T
import "Theme.js" as Theme

T.MenuSeparator {
    implicitWidth: leftPadding + rightPadding
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    padding: Theme.gap
    leftPadding: Theme.gapLg
    rightPadding: Theme.gapLg
    contentItem: Rectangle {
        implicitHeight: 1
        color: Theme.divider
    }
}
