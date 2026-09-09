import QtQuick
import QtQuick.Window

// score-style accelerated vertical scrubbing. Ctrl scales each motion delta to
// one fifth, including when pressed or released during a drag. Right-click
// opens text editing; left double-click emits reset without opening the editor.
//
// Text editing is explicit: native window focus restoration must not turn a
// subsequent drag or double-click into a text-selection gesture.
MouseArea {
    id: d

    required property Item field      // the TextField underneath
    property real value: 0
    property int decimals: 6

    signal dragged(real v)            // live, while dragging
    signal committed(real v)          // on release, if a drag actually happened
    signal reset()                    // double click

    anchors.fill: field
    enabled: !editing
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.SizeVerCursor
    preventStealing: true
    hoverEnabled: false

    property real lastY: 0
    property real delta: 0
    property real dragHeight: 1
    property real startV: 0
    property bool moved: false
    property bool editing: false

    Binding { target: d.field; property: "readOnly"; value: !d.editing }

    Connections {
        target: d.field
        function onAccepted() { d.editing = false; d.field.focus = false; }
        function onEditingFinished() { d.editing = false; }
        function onActiveFocusChanged() {
            if (!d.field.activeFocus)
                Qt.callLater(function() { if (!d.field.activeFocus) d.editing = false; });
        }
    }

    function current(m) {
        delta += (m.y - lastY) * ((m.modifiers & Qt.ControlModifier) ? 0.2 : 1);
        lastY = m.y;
        // Same acceleration as DefaultGraphicsSpinboxImpl, in value units.
        var change = -(1 + Math.abs(delta)) * delta / dragHeight;
        return startV + Number(change.toFixed(decimals));
    }

    onPressed: function (m) {
        if (m.button !== Qt.LeftButton) return;
        lastY = m.y; delta = 0; startV = value; moved = false;
        dragHeight = Math.max(1, Screen.desktopAvailableHeight);
    }
    onPositionChanged: function (m) {
        if (!(pressedButtons & Qt.LeftButton)) return;
        if (m.y === lastY) return;
        moved = true; dragged(current(m));
    }
    onReleased: function (m) {
        if (m.button === Qt.RightButton) {
            field.focus = false;
            editing = true;
            field.forceActiveFocus();
            field.selectAll();
        } else if (moved) {
            committed(current(m));
            moved = false;
        }
    }
    onDoubleClicked: function (m) {
        if (m.button === Qt.LeftButton) { moved = false; reset(); }
    }
    onCanceled: moved = false
}
