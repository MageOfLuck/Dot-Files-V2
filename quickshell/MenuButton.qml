import QtQuick
import QtQuick.Controls

Button {
    id: button
    property bool selected: false
    property bool audioAccent: false
    property bool compact: false
    // Dedicated workspace sizing; other menu buttons keep their original dimensions.
    property bool workspaceButton: false
    implicitHeight: workspaceButton ? 32 : (compact ? 28 : 34)
    implicitWidth: workspaceButton ? Math.max(30, label.implicitWidth + 14)
                                  : Math.max(compact ? 28 : 54, label.implicitWidth + (compact ? 14 : 22))
    leftPadding: workspaceButton ? 7 : (compact ? 6 : 11)
    rightPadding: workspaceButton ? 7 : (compact ? 6 : 11)
    topPadding: workspaceButton ? 4 : 5
    bottomPadding: workspaceButton ? 4 : 5
    font.pixelSize: workspaceButton ? 12 : 13
    font.bold: true
    font.family: Settings.fontFamily
    contentItem: Text {
        id: label
        text: button.text
        color: button.audioAccent ? "#161222" : Settings.foreground
        font: button.font
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
    background: Rectangle {
        radius: 9
        color: button.audioAccent ? Settings.purple : (button.selected ? Settings.elevated : button.hovered ? Settings.hoverSurface : Settings.sectionSurface)
        opacity: button.enabled ? 1 : 0.45
        border.color: button.activeFocus ? Settings.foreground : (button.audioAccent || button.selected ? "transparent" : Settings.borderColor)
        Behavior on color { ColorAnimation { duration: 120 } }
    }
}