import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// The one-line footer every editor ends with: a status message on the left, an
// optional monospaced metric on the right.
RowLayout {
    id: bar

    property string text: ""
    property string hint: ""      // shown when `text` is empty
    property string detail: ""    // right-hand metric

    Layout.fillWidth: true
    spacing: Theme.gapLg

    SLabel {
        Layout.fillWidth: true
        text: bar.text.length ? bar.text : bar.hint
        color: bar.text.length ? Theme.textDim : Theme.textMuted
        elide: Text.ElideRight
    }
    SLabel {
        visible: bar.detail.length > 0
        text: bar.detail
        font.pixelSize: Theme.fontSm
        font.family: "monospace"
        color: Theme.textMuted
    }
}
