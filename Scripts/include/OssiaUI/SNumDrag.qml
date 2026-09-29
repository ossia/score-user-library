import QtQuick
import QtQuick.Window
import QtQuick.Controls

// Bounded fields scrub a fraction of their range, like score's sliders;
// unbounded fields retain spinbox acceleration. Ctrl scales motion to one fifth.
// Right-click edits text; left double-click resets without opening the editor.
//
// Qt's popup lifecycle owns editor focus and outside-click dismissal. The
// underlying display stays read-only, including after focus is restored to it.
MouseArea {
    id: d

    required property Item field      // the TextField underneath
    property real value: 0
    property int decimals: 6
    property real from: -Infinity
    property real to: Infinity
    property real step: decimals === 0 ? 1 : 0.1

    signal dragged(real v)            // live, while dragging
    signal committed(real v)          // on release, if a drag actually happened
    signal reset()                    // double click

    anchors.fill: field
    enabled: !editorPopup.visible
    acceptedButtons: Qt.LeftButton | Qt.RightButton
    cursorShape: Qt.SizeVerCursor
    preventStealing: true
    hoverEnabled: false

    property real lastY: 0
    property real delta: 0
    property real dragHeight: 1
    property real startV: 0
    property bool moved: false

    Binding { target: d.field; property: "readOnly"; value: true }

    Popup {
        id: editorPopup
        parent: d.field
        width: d.field.width
        height: d.field.height
        padding: 0
        background: null
        popupType: Popup.Item
        focus: true
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape
        // Native score panels are outside the QML overlay's pointer region.
        onActiveFocusChanged: if (opened && !activeFocus) close()
        property bool cancelled: false
        onAboutToShow: cancelled = false
        onAboutToHide: {
            var input = editorLoader.item;
            if (!cancelled && input && input.acceptableInput && input.text !== input.initialText) {
                var v = Number.fromLocaleString(Qt.locale("en_US"), input.text);
                if (isFinite(v) && v !== d.value)
                    d.committed(Math.max(d.from, Math.min(d.to, v)));
            }
        }
        contentItem: Loader {
            id: editorLoader
            active: editorPopup.visible
            focus: true
            onLoaded: {
                item.text = Number(d.value).toFixed(item.editDecimals);
                item.initialText = item.text;
                item.editText = item.text;
                item.selectAll();
            }
            sourceComponent: STextField {
                id: input
                focus: true
                font: d.field.font
                property int editDecimals: d.decimals === 0 ? 0 : Math.max(6, d.decimals)
                // Opening and dismissing must not round the stored value.
                property string initialText: ""
                property string editText: ""
                validator: DoubleValidator {
                    bottom: d.from; top: d.to; decimals: input.editDecimals
                    notation: DoubleValidator.StandardNotation
                    locale: "en_US"
                }
                onTextEdited: {
                    // Allow incomplete prefixes, but not typing past a bound.
                    var v = Number(text);
                    if (text.length && isFinite(v)
                        && ((text[0] !== "-" && v > d.to) || (text[0] === "-" && v < d.from)))
                        text = editText;
                    else
                        editText = text;
                }
                function stepBy(direction, modifiers) {
                    var v = acceptableInput ? Number.fromLocaleString(Qt.locale("en_US"), text) : d.value;
                    var increment = Math.max(Math.pow(10, -d.decimals), d.step * ((modifiers & Qt.ControlModifier) ? 0.2 : 1));
                    v = Math.max(d.from, Math.min(d.to, v + direction * increment));
                    if (v !== d.value) d.committed(v);
                    text = v.toFixed(editDecimals);
                    initialText = text;
                    editText = text;
                }
                onAccepted: editorPopup.close()
                Keys.onShortcutOverride: function(event) {
                    if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Escape)
                        event.accepted = true;
                }
                Keys.onEscapePressed: {
                    editorPopup.cancelled = true;
                    editorPopup.close();
                }
                Keys.onUpPressed: function(ev) { stepBy(1, ev.modifiers); }
                Keys.onDownPressed: function(ev) { stepBy(-1, ev.modifiers); }
                WheelHandler {
                    onWheel: function(ev) {
                        if (ev.angleDelta.y !== 0)
                            input.stepBy(ev.angleDelta.y > 0 ? 1 : -1, ev.modifiers);
                    }
                }
            }
        }
    }

    function current(m) {
        delta += (m.y - lastY) * ((m.modifiers & Qt.ControlModifier) ? 0.2 : 1);
        lastY = m.y;
        var span = to - from;
        if (span === 0) return from;
        var ranged = isFinite(span);
        // Match InfiniteScroller::move for a range, move_free's accelerated
        // spinbox mapping otherwise. Small ranges must not move in raw units.
        var change = -(ranged ? span : (1 + Math.abs(delta))) * delta / dragHeight;
        var v = startV + Number(change.toFixed(decimals));
        var bounded = Math.max(from, Math.min(to, v));
        if (bounded !== v) {
            // Hold the accumulator at the bound, as score does, so reversing
            // direction responds immediately after an overshoot.
            var k = (startV - bounded) * dragHeight;
            delta = ranged ? k / span
                : (k >= 0 ? 1 : -1) * (Math.sqrt(1 + 4 * Math.abs(k)) - 1) / 2;
        }
        return bounded;
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
            editorPopup.open();
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
