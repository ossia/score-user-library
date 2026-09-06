import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "Theme.js" as Theme

// label · slider · numeric readout — the workhorse row of the style inspectors.
//
// `moved` fires continuously while dragging (wire it to a live preview) and
// `committed` fires once on release (wire it to the undoable save), which is the
// split every editor here needs and previously open-coded.
RowLayout {
    id: row

    property string label: ""
    property real value: 0
    property real from: 0
    property real to: 1
    property real stepSize: 0.01
    property int decimals: 2
    property string suffix: ""
    property real defaultValue: from
    property string tip: ""
    property real labelWidth: Theme.labelW

    signal moved(real v)
    signal committed(real v)

    Layout.fillWidth: true
    spacing: Theme.gap

    SFieldLabel {
        id: lbl
        text: row.label
        tip: row.tip
        Layout.preferredWidth: row.labelWidth
    }
    SSlider {
        id: sld
        Layout.fillWidth: true
        from: row.from; to: row.to; stepSize: row.stepSize
        defaultValue: row.defaultValue
        value: row.value
        onMoved: row.moved(value)
        onPressedChanged: if (!pressed) row.committed(value)

        // Dragging assigns `value` imperatively, which breaks the declarative
        // binding above; mirror the owner's value back so the handle keeps
        // following external changes (undo, presets, a linked port).
        Connections {
            target: row
            function onValueChanged() { if (!sld.pressed) sld.value = row.value; }
        }
    }
    SValue {
        text: (row.decimals > 0 ? Number(sld.value).toFixed(row.decimals)
                                : String(Math.round(sld.value))) + row.suffix
    }
}
