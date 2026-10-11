import QtQuick
import QtQuick.Controls

TextField {
    id: control
    font.family: Settings.fontFamily
    color: Settings.foreground
    placeholderTextColor: Settings.muted
    selectionColor: Settings.elevated
    selectedTextColor: Settings.foreground
    implicitHeight: 38
    leftPadding: 12
    rightPadding: 12
    background: Rectangle {
        radius: 10
        color: "#30293e"
        border.color: control.activeFocus ? Settings.elevated : "#4a405c"
        Behavior on border.color {
            ColorAnimation {
                duration: 120
            }
        }
    }
}
