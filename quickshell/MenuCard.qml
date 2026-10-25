import QtQuick
import QtQuick.Layouts

Rectangle {
    id: card
    default property alias content: contentLayout.data
    property int inset: 12
    Layout.fillWidth: true
    implicitHeight: contentLayout.implicitHeight + inset * 2
    color: Settings.sectionSurface
    radius: 11
    border.color: Settings.borderColor
    ColumnLayout {
        id: contentLayout
        anchors { left: parent.left; right: parent.right; top: parent.top; margins: card.inset }
        spacing: 8
    }
}
