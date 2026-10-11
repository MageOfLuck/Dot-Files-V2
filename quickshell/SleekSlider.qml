import QtQuick
import QtQuick.Controls

Slider {
    id: control
    implicitHeight: 28
    background: Rectangle {
        x: control.leftPadding
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.availableWidth
        height: 5
        radius: 3
        color: "#494054"
        Rectangle {
            width: control.visualPosition * parent.width
            height: parent.height
            radius: 3
            color: Settings.purple
        }
    }
    handle: Rectangle {
        x: control.leftPadding + control.visualPosition * (control.availableWidth - width)
        y: control.topPadding + control.availableHeight / 2 - height / 2
        width: control.pressed ? 18 : 14
        height: width
        radius: width / 2
        color: control.pressed ? Settings.purple : Settings.foreground
        Behavior on width {
            NumberAnimation {
                duration: 100
            }
        }
    }
}
