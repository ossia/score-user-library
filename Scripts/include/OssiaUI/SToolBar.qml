import QtQuick
import QtQuick.Layouts
import "Theme.js" as Theme

// Top toolbar strip: a wrapping row of SButton / SVSeparator / other controls,
// so a narrow window reflows instead of clipping.
Item {
    id: bar
    default property alias content: flow.data

    implicitHeight: flow.implicitHeight
    Layout.fillWidth: true

    Flow {
        id: flow
        width: parent.width
        spacing: Theme.gapSm + 1
    }
}
