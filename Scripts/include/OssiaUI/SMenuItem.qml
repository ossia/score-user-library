import QtQuick
import QtQuick.Controls.impl
import QtQuick.Templates as T
import "Theme.js" as Theme

T.MenuItem {
    id: item

    readonly property color foreground: !enabled ? Theme.textMuted
                                                : (highlighted || down ? Theme.accentText : Theme.text)
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.max(Theme.rowHsm, implicitContentHeight + topPadding + bottomPadding)
    padding: 0
    leftPadding: Theme.gapLg
    rightPadding: Theme.gapLg
    spacing: Theme.gapLg
    font.pixelSize: Theme.fontSm
    font.hintingPreference: Theme.hinting
    icon.width: Theme.fontMd
    icon.height: Theme.fontMd
    hoverEnabled: true

    contentItem: IconLabel {
        readonly property real checkSpace: item.checkable ? item.indicator.width + item.spacing : 0
        readonly property real arrowSpace: item.subMenu ? item.arrow.width + item.spacing : 0
        leftPadding: item.mirrored ? arrowSpace : checkSpace
        rightPadding: item.mirrored ? checkSpace : arrowSpace
        spacing: item.spacing
        mirrored: item.mirrored
        display: item.display
        alignment: Qt.AlignLeft
        icon: item.icon
        defaultIconColor: item.foreground
        text: item.text
        font: item.font
        color: item.foreground
    }
    indicator: Text {
        x: item.mirrored ? item.width - width - item.rightPadding : item.leftPadding
        y: (item.height - height) / 2
        width: Theme.fontMd
        visible: item.checkable && item.checked
        text: "✓"
        font: item.font
        color: item.foreground
        horizontalAlignment: Text.AlignHCenter
    }
    arrow: Text {
        x: item.mirrored ? item.leftPadding : item.width - width - item.rightPadding
        y: (item.height - height) / 2
        width: Theme.fontMd
        visible: item.subMenu !== null
        text: item.mirrored ? "‹" : "›"
        font: item.font
        color: item.foreground
        horizontalAlignment: Text.AlignHCenter
    }
    background: Rectangle {
        color: item.enabled && (item.highlighted || item.down) ? Theme.accentFill : Theme.popup
    }
}
