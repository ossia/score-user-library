import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Toolbar / panel button.
//
// `lit` replaces checkable/checked on purpose: the active state is always driven
// by a binding to the owning model, so clicking twice cannot desynchronise the
// button from what it controls, and external changes (shortcuts, undo) stay in
// sync. `tint` overrides the resting fill for buttons that carry their own
// meaning (a destructive action, a locked show mode).
Button {
    id: btn

    property bool lit: false
    property string tip: ""
    property color tint: Theme.control
    property bool danger: false
    // Icon buttons are sized by the caller (an 18 px square, say); the normal
    // 9 px side padding would leave zero width for the glyph and elide it away.
    property bool compact: false

    implicitHeight: Theme.toolH
    leftPadding: compact ? 2 : 8
    rightPadding: compact ? 2 : 8
    topPadding: 1; bottomPadding: 1
    font.pixelSize: Theme.fontMd
    font.hintingPreference: Theme.hinting

    ToolTip.visible: hovered && tip.length > 0
    ToolTip.text: tip
    ToolTip.delay: 500

    contentItem: Text {
        text: btn.text
        font: btn.font
        color: !btn.enabled ? Theme.textMuted : (btn.lit ? Theme.textBright : "#e6ebe8")
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        implicitWidth: 20
        implicitHeight: Theme.toolH
        radius: Theme.radius
        color: btn.lit ? Theme.accentFill
                       : (btn.down ? Theme.controlDown
                                   : (btn.hovered ? Theme.controlHover
                                                  : (btn.danger ? Theme.danger : btn.tint)))
        border.width: 1
        border.color: btn.lit ? Theme.accent
                              : (btn.activeFocus ? Theme.accent : Theme.border)
    }
}
