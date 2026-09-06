import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

TextArea {
    id: editor
    readonly property bool editing: _editing
    property bool _editing: false
    property bool _updating: false
    property bool _finishing: false
    property string _original: ""

    signal edited(string value)
    signal finished(string value, bool accepted)

    visible: editing
    selectByMouse: true
    textFormat: TextEdit.PlainText
    wrapMode: TextEdit.Wrap
    color: Theme.text
    font.pixelSize: Theme.fontMd
    selectionColor: Theme.accentFill
    selectedTextColor: Theme.accentText
    padding: 0
    background: Rectangle {
        color: "transparent"
        border.color: Theme.accent
        border.width: 2
    }

    function begin(initialText) {
        if (_editing) finish(true);
        _updating = true;
        _original = initialText;
        text = initialText;
        _updating = false;
        _editing = true;
        forceActiveFocus(Qt.MouseFocusReason);
        selectAll();
    }

    function finish(accept) {
        if (!_editing || _finishing) return;
        _finishing = true;
        if (!accept && text !== _original) {
            _updating = true;
            text = _original;
            _updating = false;
            edited(text);
        }
        var value = text;
        _editing = false;
        focus = false;
        _finishing = false;
        finished(value, accept);
    }

    onTextChanged: if (_editing && !_updating) edited(text)
    onActiveFocusChanged: if (!activeFocus && _editing) finish(true)
    onVisibleChanged: if (!visible && _editing) finish(true)
    Keys.onPressed: function(event) {
        if (event.key === Qt.Key_Escape) {
            finish(false);
            event.accepted = true;
        } else if ((event.key === Qt.Key_Return || event.key === Qt.Key_Enter)
                   && (event.modifiers & Qt.ControlModifier)) {
            finish(true);
            event.accepted = true;
        }
    }
}
