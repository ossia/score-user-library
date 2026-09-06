import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// The right-aligned numeric readout that trails a slider.
Label {
    Layout.preferredWidth: 34
    font.pixelSize: Theme.fontSm
    font.hintingPreference: Theme.hinting
    font.family: "monospace"
    color: Theme.textDim
    horizontalAlignment: Text.AlignRight
    verticalAlignment: Text.AlignVCenter
}
