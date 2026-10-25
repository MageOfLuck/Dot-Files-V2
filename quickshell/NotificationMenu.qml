import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

MenuView {
    id: view
    implicitHeight: body.implicitHeight
    clip: true
    readonly property var hub: ControlState.notificationHub
    readonly property var entries: hub ? hub.notifications.values.slice().reverse() : []

    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        RowLayout {
            Layout.fillWidth: true
            MenuButton {
                text: ControlState.dnd ? "Do not disturb · On" : "Do not disturb · Off"
                selected: ControlState.dnd
                onClicked: ControlState.dnd = !ControlState.dnd
            }
            Item { Layout.fillWidth: true }
            MenuButton {
                text: "Clear all"
                enabled: view.entries.length > 0
                onClicked: if (view.hub) view.hub.clear()
            }
        }
        SectionHeading { text: "Recent"; detail: view.entries.length + " total" }
        Label {
            Layout.fillWidth: true
            visible: view.entries.length === 0
            horizontalAlignment: Text.AlignHCenter
            text: "You're all caught up."
            color: Settings.muted
            font.family: Settings.fontFamily
            topPadding: 22
            bottomPadding: 22
        }
        Repeater {
            model: view.entries
            delegate: MenuCard {
                id: itemCard
                required property var modelData
                readonly property bool hasDefault: !!view.hub && view.hub.hasDefaultAction(modelData.id)
                MouseArea {
                    // Only the information area activates, never the buttons.
                    Layout.fillWidth: true
                    implicitHeight: content.implicitHeight
                    cursorShape: Qt.PointingHandCursor
                    onClicked: view.hub.activate(itemCard.modelData.id, ControlState.monitor)
                    ColumnLayout {
                        id: content
                        width: parent.width
                        spacing: 6
                        RowLayout {
                            Layout.fillWidth: true
                            Label {
                                text: itemCard.modelData.appName || "Application"
                                font.family: Settings.fontFamily
                                color: Settings.muted
                                font.bold: true
                                font.pixelSize: 11
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Label {
                                text: itemCard.hasDefault ? "Open ↗" : "Details"
                                font.family: Settings.fontFamily
                                color: Settings.muted
                                font.pixelSize: 10
                            }
                        }
                        Label {
                            Layout.fillWidth: true
                            text: itemCard.modelData.summary
                            textFormat: Text.PlainText
                            color: Settings.foreground
                            font.family: Settings.fontFamily
                            font.bold: true
                            wrapMode: Text.WordWrap
                        }
                        Label {
                            Layout.fillWidth: true
                            visible: text.length > 0
                            text: itemCard.modelData.body
                            textFormat: Text.PlainText
                            color: Settings.muted
                            font.family: Settings.fontFamily
                            wrapMode: Text.WordWrap
                        }
                    }
                }
                Flow {
                    Layout.fillWidth: true
                    visible: itemCard.modelData.actions.length > 0
                    spacing: 6
                    Repeater {
                        model: itemCard.modelData.actions
                        delegate: MenuButton {
                            required property var modelData
                            text: modelData.text || "Open"
                            onClicked: view.hub.invokeAction(itemCard.modelData.id, modelData.identifier)
                        }
                    }
                }
                RowLayout {
                    Layout.fillWidth: true
                    Item { Layout.fillWidth: true }
                    MenuButton {
                        text: "Dismiss"
                        compact: true
                        onClicked: view.hub.dismiss(itemCard.modelData.id)
                    }
                }
            }
        }
    }
}
