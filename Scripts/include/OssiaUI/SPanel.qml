import QtQuick
import "Theme.js" as Theme

// A framed panel: the standard container for a list, an inspector or a dock.
// `title` is optional; when set, a tight header row is reserved at the top and
// the panel's own content should anchor below `header`.
Rectangle {
    id: panel
    color: Theme.base
    border.color: Theme.divider
    border.width: 1
    radius: Theme.radius
}
