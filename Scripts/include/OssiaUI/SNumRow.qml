import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// label · numeric field with score's drag-to-edit behaviour.
//
// Bounded fields drag relative to their range; unbounded fields use spinbox
// acceleration. Ctrl gives fine control.
// Right-click to type, double-click to reset to `defaultValue`. Arrow keys and the
// wheel use `step` (one fifth with Ctrl). `live` previews a drag; `edited`
// commits its final value as one undoable change.
RowLayout {
    id: row

    property string label: ""
    property real value: 0
    property real step: 0.1
    property int decimals: 2
    property real from: -Infinity
    property real to: Infinity
    property string suffix: ""
    property string tip: ""
    property var defaultValue: undefined
    property real labelWidth: Theme.labelW

    signal edited(real v)
    signal live(real v)

    function bounded(v) { return Math.max(from, Math.min(to, v)); }
    function stepBy(direction, modifiers) {
        var increment = Math.max(Math.pow(10, -decimals), step * ((modifiers & Qt.ControlModifier) ? 0.2 : 1));
        var next = bounded(value + direction * increment);
        if (next !== value) edited(next);
    }

    Layout.fillWidth: true
    spacing: Theme.gap

    SFieldLabel { id: lbl; text: row.label; tip: row.tip; Layout.preferredWidth: row.labelWidth }

    STextField {
        id: tf
        Layout.fillWidth: true
        text: Theme.fmt(row.value, row.decimals)

        function rebind() {
            text = Qt.binding(function () { return Theme.fmt(row.value, row.decimals); });
        }
        Keys.onUpPressed: function (ev) { row.stepBy(1, ev.modifiers); }
        Keys.onDownPressed: function (ev) { row.stepBy(-1, ev.modifiers); }
        WheelHandler {
            onWheel: function (ev) {
                if (ev.angleDelta.y !== 0 && tf.activeFocus)
                    row.stepBy(ev.angleDelta.y > 0 ? 1 : -1, ev.modifiers);
                else
                    ev.accepted = false;
            }
        }

        SNumDrag {
            field: tf
            value: row.value
            decimals: row.decimals
            step: row.step
            from: row.from
            to: row.to
            onDragged: function (v) { tf.text = Theme.fmt(v, row.decimals); row.live(v); }
            onCommitted: function (v) { row.edited(row.bounded(v)); tf.rebind(); }
            onReset: {
                if (row.defaultValue !== undefined) { row.edited(row.bounded(row.defaultValue)); tf.rebind(); }
            }
        }
    }

    SLabel {
        text: row.suffix
        dim: true
        font.pixelSize: Theme.fontSm
        visible: row.suffix.length > 0
    }
}
