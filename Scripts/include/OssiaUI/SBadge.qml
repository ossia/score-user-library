import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Small count / state pill, e.g. the occupancy badge on a list row.
Label {
    id: badge
    property color tint: Theme.textDim
    font.pixelSize: Theme.fontSm
    font.hintingPreference: Theme.hinting
    font.bold: true
    color: "#0b0d0c"
    padding: 2; leftPadding: 5; rightPadding: 5
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    background: Rectangle { radius: height / 2; color: badge.tint }
}
