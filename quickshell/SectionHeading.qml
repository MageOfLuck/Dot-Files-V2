import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

RowLayout {
    id: heading
    property string text: ""
    property string detail: ""
    Layout.fillWidth: true
    spacing: 10
    Label {
        text: heading.text.toUpperCase()
        font.family: Settings.fontFamily
        font.bold: true
        font.pixelSize: 11
        font.letterSpacing: 1
        color: Settings.muted
    }
    Label {
        visible: heading.detail.length > 0
        text: heading.detail
        font.family: Settings.fontFamily
        color: Settings.muted
        font.pixelSize: 11
    }
    Rectangle {
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignVCenter
        height: 1
        color: Settings.borderColor
    }
}
