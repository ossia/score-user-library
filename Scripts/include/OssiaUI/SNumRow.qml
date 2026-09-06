import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// label · numeric field with score's drag-to-edit behaviour.
//
// Press and drag the field to scrub the value, click to type, double click to
// reset to `defaultValue`, arrow keys and the wheel step by `step`. `live` fires
// continuously while scrubbing so the viewport can follow; `edited` fires once
// the value is settled and is the one to make undoable.
RowLayout {
    id: row

    property string label: ""
    property real value: 0
    property real step: 0.1
    property int decimals: 2
    property string suffix: ""
    property string tip: ""
    property var defaultValue: undefined
    property real labelWidth: Theme.labelW

    signal edited(real v)
    signal live(real v)

    Layout.fillWidth: true
    spacing: Theme.gap

    SFieldLabel { id: lbl; text: row.label; tip: row.tip; Layout.preferredWidth: row.labelWidth }

    STextField {
        id: tf
        Layout.fillWidth: true
        text: Theme.fmt(row.value, row.decimals)
        validator: DoubleValidator { notation: DoubleValidator.StandardNotation }

        function rebind() {
            text = Qt.binding(function () { return Theme.fmt(row.value, row.decimals); });
        }
        onEditingFinished: {
            var nv = parseFloat(text);
            if (!isNaN(nv) && Math.abs(nv - row.value) > 1e-9)
                row.edited(nv);
            rebind();
        }
        Keys.onUpPressed: row.edited(row.value + row.step)
        Keys.onDownPressed: row.edited(row.value - row.step)
        WheelHandler {
            onWheel: function (ev) {
                if (tf.activeFocus)
                    row.edited(row.value + (ev.angleDelta.y > 0 ? 1 : -1) * row.step);
            }
        }

        SNumDrag {
            field: tf
            value: row.value
            step: row.step
            onDragged: function (v) { tf.text = Theme.fmt(v, row.decimals); row.live(v); }
            onCommitted: function (v) { row.edited(v); tf.rebind(); }
            onReset: {
                if (row.defaultValue !== undefined) { row.edited(row.defaultValue); tf.rebind(); }
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
