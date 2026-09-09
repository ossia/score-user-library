import QtQuick
import QtQuick.Window

// score-style accelerated vertical scrubbing. Ctrl scales each motion delta to
// one fifth, including when pressed or released during a drag. A plain click
// focuses the field for typing; a double click emits reset().
//
// While the field has focus the overlay disables itself so text selection and
// caret placement work normally.
MouseArea {
    id: d

    required property Item field      // the TextField underneath
    property real value: 0
    property int decimals: 6

    signal dragged(real v)            // live, while dragging
    signal committed(real v)          // on release, if a drag actually happened
    signal reset()                    // double click

    anchors.fill: field
    enabled: !field.activeFocus
    cursorShape: Qt.SizeVerCursor
    preventStealing: true
    hoverEnabled: false

    property real lastY: 0
    property real delta: 0
    property real dragHeight: 1
    property real startV: 0
    property bool moved: false

    Timer {
        id: focusTimer
        interval: 220; repeat: false
        onTriggered: { d.field.forceActiveFocus(); if (d.field.selectAll) d.field.selectAll(); }
    }

    function current(m) {
        delta += (m.y - lastY) * ((m.modifiers & Qt.ControlModifier) ? 0.2 : 1);
        lastY = m.y;
        // Same acceleration as DefaultGraphicsSpinboxImpl, in value units.
        var change = -(1 + Math.abs(delta)) * delta / dragHeight;
        return startV + Number(change.toFixed(decimals));
    }

    onPressed: function (m) {
        lastY = m.y; delta = 0; startV = value; moved = false;
        dragHeight = Math.max(1, Screen.desktopAvailableHeight);
    }
    onPositionChanged: function (m) {
        if (!pressed) return;
        if (m.y === lastY) return;
        moved = true; focusTimer.stop(); dragged(current(m));
    }
    onReleased: function (m) {
        if (moved) committed(current(m));
        else focusTimer.restart();
    }
    onDoubleClicked: function (m) { focusTimer.stop(); moved = false; reset(); }
    onCanceled: moved = false
}
