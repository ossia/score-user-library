import QtQuick
import QtQuick.Controls
import "Theme.js" as Theme

// ComboBox sized for dense panels: text vertically centred, a drop arrow that is
// not clipped, and a popup that is never wider than the control so it cannot
// spill outside a narrow inspector.
ComboBox {
    id: cb

    implicitHeight: Theme.rowH
    font.pixelSize: Theme.fontMd
    font.hintingPreference: Theme.hinting
    leftPadding: Theme.gapLg; rightPadding: 18
    topPadding: 0; bottomPadding: 0

    // A TextInput rather than a Text: ComboBox drives this item directly when
    // `editable` is set, so an editable combo (font pickers, free-form presets)
    // keeps working instead of silently becoming read-only.
    contentItem: TextInput {
        text: cb.editable ? cb.editText : cb.displayText
        font: cb.font
        color: cb.enabled ? Theme.text : Theme.textMuted
        verticalAlignment: TextInput.AlignVCenter
        // Read-only TextInput still consumes clicks; let the combo handle them.
        enabled: cb.editable
        readOnly: !cb.editable
        selectByMouse: cb.editable
        selectionColor: Theme.accentFill
        selectedTextColor: Theme.accentText
        clip: true
    }
    indicator: Text {
        x: cb.width - width - 5
        anchors.verticalCenter: parent.verticalCenter
        text: "▾"
        font.pixelSize: Theme.fontSm
        font.hintingPreference: Theme.hinting
        color: cb.enabled ? Theme.textDim : Theme.textMuted
    }
    background: Rectangle {
        implicitWidth: 60
        implicitHeight: Theme.rowH
        radius: Theme.radius
        color: cb.down ? Theme.controlDown : (cb.hovered ? Theme.controlHover : Theme.control)
        border.width: 1
        border.color: cb.activeFocus ? Theme.accent : Theme.border
    }
    popup: Popup {
        y: cb.height
        width: cb.width
        height: Math.min(cb.count * Theme.rowHsm + 2, 300)
        padding: 1
        contentItem: ListView {
            clip: true
            model: cb.popup.visible ? cb.delegateModel : null
            currentIndex: cb.highlightedIndex
            ScrollBar.vertical: ScrollBar {}
        }
        background: Rectangle {
            color: Theme.popup
            border.color: Theme.accentFill
            radius: Theme.radius
        }
    }
    delegate: ItemDelegate {
        id: dlg
        required property var model
        required property int index
        property string label: {
            var v = cb.textRole ? model[cb.textRole] : model.modelData;
            return v === undefined ? String(model.display === undefined ? "" : model.display) : String(v);
        }
        width: cb.popup.width - 2
        height: Theme.rowHsm
        padding: 0; leftPadding: 2; rightPadding: 2
        highlighted: cb.highlightedIndex === index
        contentItem: Text {
            text: dlg.label
            font.pixelSize: Theme.fontSm
            font.hintingPreference: Theme.hinting
            color: dlg.highlighted ? "#ffffff" : "#e8e8e8"
            verticalAlignment: Text.AlignVCenter
            elide: Text.ElideRight
            leftPadding: Theme.gap
        }
        background: Rectangle {
            color: dlg.highlighted ? Theme.accentFill
                                   : (dlg.index === cb.currentIndex ? Theme.controlHover : Theme.popup)
        }
    }
}
