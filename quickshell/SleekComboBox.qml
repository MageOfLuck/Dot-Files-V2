import QtQuick
import QtQuick.Controls

ComboBox {
    id: control
    font.family: Settings.fontFamily
    implicitHeight: 38
    leftPadding: 12
    rightPadding: 32
    contentItem: Text {
        text: control.displayText
        color: Settings.foreground
        font: control.font
        elide: Text.ElideRight
        verticalAlignment: Text.AlignVCenter
    }
    indicator: Text {
        x: control.width - width - 12
        y: (control.height - height) / 2
        text: "⌄"
        color: Settings.muted
        font.pixelSize: 18
    }
    background: Rectangle {
        radius: 10
        color: "#30293e"
        border.color: control.activeFocus || control.hovered ? Settings.elevated : "#4a405c"
        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }
    }
    delegate: ItemDelegate {
        required property int index
        width: control.width
        implicitHeight: 38
        highlighted: control.highlightedIndex === index
        contentItem: Text {
            text: control.textAt(index)
            color: Settings.foreground
            font: control.font
            elide: Text.ElideRight
            verticalAlignment: Text.AlignVCenter
        }
        background: Rectangle {
            radius: 8
            color: parent.highlighted ? Settings.elevated : "transparent"
        }
    }
    popup: Popup {
        y: control.height + 6
        width: control.width
        padding: 6
        implicitHeight: Math.min(list.contentHeight + 12, 280)
        contentItem: ListView {
            id: list
            clip: true
            model: control.popup.visible ? control.delegateModel : null
            currentIndex: control.highlightedIndex
            ScrollIndicator.vertical: ScrollIndicator {}
        }
        background: Rectangle {
            color: Settings.surface
            border.color: Settings.elevated
            radius: 12
        }
    }
}
