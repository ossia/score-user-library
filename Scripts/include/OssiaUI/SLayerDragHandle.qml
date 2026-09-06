import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

Item {
    id: handle
    property var view
    property int index: -1
    readonly property bool dragging: _dragging
    readonly property int targetIndex: _targetIndex
    property bool _dragging: false
    property int _sourceIndex: -1
    property int _targetIndex: -1
    property real _pressY: 0
    property real _pointerY: 0

    signal started()
    signal moved(int from, int to)
    signal finished()

    implicitWidth: 16
    implicitHeight: Theme.listRowH

    function updateTarget() {
        if (!view || _sourceIndex < 0 || !view.count) return;
        var y = Math.max(0, Math.min(view.height - 1, _pointerY));
        var contentY = view.contentY + y;
        var x = view.contentX + Math.min(view.width / 2, 10);
        var target = view.indexAt(x, contentY);
        // A pointer over a spacing gap belongs to the next visible row.
        if (target < 0) target = view.indexAt(x, contentY + view.spacing + 1);
        if (target < 0) target = view.indexAt(x, contentY - view.spacing - 1);
        if (target >= 0) _targetIndex = target;
    }

    function endDrag(accept) {
        if (_sourceIndex < 0) return;
        var from = _sourceIndex, to = _targetIndex;
        var move = accept && _dragging && from !== to && to >= 0;
        _dragging = false;
        _sourceIndex = -1;
        _targetIndex = -1;
        if (move) moved(from, to);
        finished();
    }

    Text {
        anchors.centerIn: parent
        text: "\u2261"
        color: handle.enabled ? Theme.text : Theme.textMuted
        font.pixelSize: Theme.fontMd
        font.hintingPreference: Theme.hinting
    }
    MouseArea {
        id: pointer
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton
        preventStealing: true
        cursorShape: handle.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
        onPressed: function(mouse) {
            if (!handle.view || handle.index < 0) { mouse.accepted = false; return; }
            handle.view.cancelFlick();
            handle.view.currentIndex = handle.index;
            handle._sourceIndex = handle.index;
            handle._targetIndex = handle.index;
            handle._pointerY = mapToItem(handle.view, mouse.x, mouse.y).y;
            handle._pressY = handle._pointerY;
            handle.started();
        }
        onPositionChanged: function(mouse) {
            if (!pressed || handle._sourceIndex < 0) return;
            handle._pointerY = mapToItem(handle.view, mouse.x, mouse.y).y;
            if (!handle._dragging && Math.abs(handle._pointerY - handle._pressY) >= Qt.styleHints.startDragDistance)
                handle._dragging = true;
            if (handle._dragging) handle.updateTarget();
        }
        onReleased: handle.endDrag(true)
        onCanceled: handle.endDrag(false)
    }
    Timer {
        interval: 30
        repeat: true
        running: handle.dragging
        onTriggered: {
            var view = handle.view;
            if (!view) { handle.endDrag(false); return; }
            var edge = Math.min(24, view.height / 4);
            var direction = handle._pointerY < edge ? -1 : handle._pointerY > view.height - edge ? 1 : 0;
            if (!direction) return;
            var minimum = view.originY;
            var maximum = minimum + Math.max(0, view.contentHeight - view.height);
            var next = Math.max(minimum, Math.min(maximum, view.contentY + direction * 8));
            if (next !== view.contentY) {
                view.contentY = next;
                handle.updateTarget();
            }
        }
    }
    onEnabledChanged: if (!enabled) endDrag(false)
}
