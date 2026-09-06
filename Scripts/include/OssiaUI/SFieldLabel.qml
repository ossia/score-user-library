import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// The left-hand label column of an inspector row. Fixed width so that every
// field in a panel lines up, elided rather than wrapped.
Label {
    property string tip: ""
    Layout.preferredWidth: Theme.labelW
    font.pixelSize: Theme.fontMd
    font.hintingPreference: Theme.hinting
    color: enabled ? "#c0c0c0" : Theme.textMuted
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
    ToolTip.visible: tip.length > 0 && hh.hovered
    ToolTip.text: tip
    ToolTip.delay: 500
    HoverHandler { id: hh }
}
