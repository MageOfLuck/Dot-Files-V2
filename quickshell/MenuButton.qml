import QtQuick
import QtQuick.Controls

Button {
    id: button
    property bool selected: false
    property bool audioAccent: false
    implicitHeight: 32
    padding: 8
    font.pixelSize: 13
    font.bold: true
    font.family: Settings.fontFamily
    contentItem: Text {
        text: button.text
        color: button.audioAccent ? "#000000" : Settings.foreground
        font: button.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        Behavior on color {
            ColorAnimation {
                duration: 120
            }
        }
        radius: 8
        color: button.audioAccent ? Settings.purple : (button.selected || button.hovered ? Settings.elevated : "#373043")
        opacity: button.enabled ? 1 : 0.45
        border.color: button.activeFocus ? Settings.foreground : "transparent"
    }
}
