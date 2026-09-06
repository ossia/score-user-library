import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// Default body label. `dim` greys it out for secondary information.
Label {
    property bool dim: false
    font.pixelSize: Theme.fontMd
    color: dim ? Theme.textMuted : Theme.text
    elide: Text.ElideRight
    verticalAlignment: Text.AlignVCenter
}
