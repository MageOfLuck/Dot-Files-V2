import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

MenuView {
    id: view
    implicitHeight: body.implicitHeight
    clip: true
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        RowLayout {
            MenuButton {
                text: ControlState.dnd ? "DND on" : "DND off"
                selected: ControlState.dnd
                onClicked: {
                    ControlState.dnd = !ControlState.dnd;
                    if (ControlState.dnd && ControlState.notificationHub)
                        ControlState.notificationHub.toastVisible = false;
                }
            }
            MenuButton {
                text: "Clear all"
                onClicked: if (ControlState.notificationHub)
                    ControlState.notificationHub.clear()
            }
        }
        Label {
            font.family: Settings.fontFamily
            visible: !ControlState.notificationHub || ControlState.notificationHub.notifications.values.length === 0
            text: "No notifications."
            color: Settings.muted
        }
        Repeater {
            model: ControlState.notificationHub ? ControlState.notificationHub.notifications.values.slice().reverse() : []
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                RowLayout {
                    Label {
                        font.family: Settings.fontFamily
                        text: modelData.appName
                        color: Settings.muted
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    MenuButton {
                        text: "×"
                        onClicked: modelData.dismiss()
                    }
                }
                Label {
                    font.family: Settings.fontFamily
                    text: modelData.summary
                    color: Settings.foreground
                    font.bold: true
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    Layout.fillWidth: true
                }
                Label {
                    font.family: Settings.fontFamily
                    text: modelData.body
                    color: Settings.foreground
                    wrapMode: Text.WordWrap
                    textFormat: Text.PlainText
                    Layout.fillWidth: true
                }
                Flow {
                    Layout.fillWidth: true
                    spacing: 6
                    Repeater {
                        model: modelData.actions
                        delegate: MenuButton {
                            required property var modelData
                            text: modelData.text
                            onClicked: modelData.invoke()
                        }
                    }
                }
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Settings.elevated
                    opacity: 0.4
                }
            }
        }
    }
}
