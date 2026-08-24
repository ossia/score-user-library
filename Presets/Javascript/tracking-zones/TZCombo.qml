import QtQuick
import QtQuick.Controls

// ComboBox sized for dense panels: text vertically centred, a drop arrow that is not clipped.
ComboBox {
    id: cb
    implicitHeight: 22
    font.pixelSize: 10
    leftPadding: 6; rightPadding: 18; topPadding: 0; bottomPadding: 0
    contentItem: Text {
        text: cb.displayText
        font: cb.font
        color: cb.enabled ? "#d0d0d0" : "#7c7670"
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    indicator: Text {
        x: cb.width - width - 5
        anchors.verticalCenter: parent.verticalCenter
        text: "▾"
        font.pixelSize: 10
        color: "#a39d96"
    }
    background: Rectangle {
        implicitWidth: 60; implicitHeight: 22
        radius: 3
        color: cb.down ? "#3a3835" : (cb.hovered ? "#2c2a27" : "#1d1c1a")
        border.color: cb.activeFocus ? "#c58014" : "#3a3835"; border.width: 1
    }
    popup: Popup {
        y: cb.height
        width: cb.width            // never wider than the control, so it stays inside its panel
        height: Math.min(cb.count * 20 + 2, 300)
        padding: 1
        contentItem: ListView {
            clip: true
            model: cb.popup.visible ? cb.delegateModel : null
            currentIndex: cb.highlightedIndex
            ScrollBar.vertical: ScrollBar {}
        }
        background: Rectangle { color: "#141312"; border.color: "#62400a"; radius: 3 }
    }
    delegate: ItemDelegate {
        id: dlg
        required property var model
        required property int index
        property string label: { var v = cb.textRole ? model[cb.textRole] : model.modelData; return v === undefined ? String(model.display === undefined ? "" : model.display) : String(v); }
        width: cb.popup.width - 2
        height: 20
        padding: 0; leftPadding: 2; rightPadding: 2
        contentItem: Text { text: dlg.label; font.pixelSize: 10; color: dlg.highlighted ? "#ffffff" : "#e8e8e8"; verticalAlignment: Text.AlignVCenter; elide: Text.ElideRight; leftPadding: 4 }
        background: Rectangle { color: dlg.highlighted ? "#62400a" : (dlg.index === cb.currentIndex ? "#2c2a27" : "#141312") }
        highlighted: cb.highlightedIndex === index
    }
}
