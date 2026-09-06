import QtQuick
import QtQuick.Controls.Basic as Basic
import QtQuick.Templates as T
import "Theme.js" as Theme

T.Menu {
    id: menu

    // Item popups keep the same compact skin under native platform styles.
    popupType: T.Popup.Item
    padding: 1
    margins: Theme.gap
    overlap: 1
    implicitWidth: implicitContentWidth + leftPadding + rightPadding
    implicitHeight: Math.min(implicitContentHeight + topPadding + bottomPadding, 300)

    delegate: SMenuItem {}

    contentItem: ListView {
        implicitWidth: {
            var widest = Theme.rowH;
            for (var i = 0; i < menu.count; ++i) {
                var item = menu.itemAt(i);
                if (item)
                    widest = Math.max(widest, item.implicitWidth);
            }
            return widest;
        }
        implicitHeight: contentHeight
        model: menu.contentModel
        currentIndex: menu.currentIndex
        clip: true
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        highlightMoveDuration: 0
        highlightResizeDuration: 0

        Basic.ScrollBar.vertical: Basic.ScrollBar {
            id: scrollBar
            padding: 0
            implicitWidth: Theme.pad
            contentItem: Rectangle {
                implicitWidth: Theme.pad
                implicitHeight: Theme.rowHsm
                radius: Theme.radius
                color: scrollBar.pressed ? Theme.accent : Theme.textMuted
                opacity: scrollBar.size < 1 ? 1 : 0
            }
            background: null
        }
    }
    background: Rectangle {
        color: Theme.popup
        border.color: Theme.accentFill
        radius: Theme.radius
    }
}
