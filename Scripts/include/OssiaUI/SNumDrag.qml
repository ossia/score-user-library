import QtQuick

// Drag-to-change overlay for a numeric text field, like score's own spinboxes:
// press and drag horizontally (or vertically) to change the value by `step`
// every `pxPerStep` pixels; a plain click focuses the field for typing (after
// the double-click interval has passed); a double click emits reset().
//
// While the field has focus the overlay disables itself so text selection and
// caret placement work normally.
MouseArea {
    id: d

    required property Item field      // the TextField underneath
    property real value: 0
    property real step: 0.1
    property real pxPerStep: 4

    signal dragged(real v)            // live, while dragging
    signal committed(real v)          // on release, if a drag actually happened
    signal reset()                    // double click

    anchors.fill: field
    enabled: !field.activeFocus
    cursorShape: Qt.SizeHorCursor
    preventStealing: true
    hoverEnabled: false

    property real pressX: 0
    property real pressY: 0
    property real startV: 0
    property bool moved: false

    Timer {
        id: focusTimer
        interval: 220; repeat: false
        onTriggered: { d.field.forceActiveFocus(); if (d.field.selectAll) d.field.selectAll(); }
    }

    function current(m) {
        var dx = (m.x - pressX) - (m.y - pressY);
        var n = Math.round(dx / pxPerStep);
        var v = startV + n * step;
        var dec = Math.max(0, Math.min(6, Math.ceil(-Math.log(step) / Math.LN10)));
        return Number(v.toFixed(dec));
    }

    onPressed: function (m) { pressX = m.x; pressY = m.y; startV = value; moved = false; }
    onPositionChanged: function (m) {
        if (!pressed) return;
        if (!moved && Math.abs((m.x - pressX) - (m.y - pressY)) < 4) return;
        moved = true; focusTimer.stop(); dragged(current(m));
    }
    onReleased: function (m) {
        if (moved) committed(current(m));
        else focusTimer.restart();
    }
    onDoubleClicked: function (m) { focusTimer.stop(); moved = false; reset(); }
    onCanceled: moved = false
}
