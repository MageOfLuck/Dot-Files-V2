import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire

Scope {
    id: root
    required property var screen
    required property var hub
    readonly property bool target: screen.name === (Quickshell.screens.find(s => s.name === Settings.popupMonitor) || Quickshell.screens[0]).name
    property bool osdVisible: false
    readonly property var sink: Pipewire.defaultAudioSink
    Connections {
        target: root.sink ? root.sink.audio : null
        function onVolumeChanged() { root.osdVisible = true; osdTimer.restart(); }
        function onMutedChanged() { root.osdVisible = true; osdTimer.restart(); }
    }
    Timer {
        id: osdTimer
        interval: 1500
        onTriggered: root.osdVisible = false
    }
    PanelWindow {
        screen: root.screen
        visible: root.target && root.hub.popups.length > 0 && !ControlState.dnd
        anchors { top: true; right: true }
        margins { top: Settings.barHeight + 12; right: 12 }
        implicitWidth: Math.min(390, root.screen.width - 24)
        implicitHeight: Math.min(toastStack.implicitHeight, root.screen.height - Settings.barHeight - 24)
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "edge-control-notification"
        WlrLayershell.layer: WlrLayer.Overlay
        ScrollView {
            id: scroll
            anchors.fill: parent
            clip: true
            Column {
                id: toastStack
                width: scroll.availableWidth
                spacing: 8
                Repeater {
                    model: root.hub.popups
                    delegate: Rectangle {
                        id: toast
                        required property var modelData
                        width: toastStack.width
                        implicitHeight: contents.implicitHeight + 26
                        height: implicitHeight
                        color: Settings.sectionSurface
                        radius: 12
                        border.color: hover.hovered ? Settings.purple : Settings.borderColor
                        Behavior on border.color { ColorAnimation { duration: 120 } }
                        HoverHandler {
                            id: hover
                            onHoveredChanged: root.hub.pausePopup(toast.modelData.id, hovered)
                        }
                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: root.hub.activate(toast.modelData.id, root.screen.name)
                        }
                        ColumnLayout {
                            id: contents
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 13 }
                            spacing: 6
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8
                                Label {
                                    font.family: Settings.fontFamily
                                    text: toast.modelData.appName
                                    color: Settings.muted
                                    font.pixelSize: 11
                                    font.bold: true
                                    elide: Text.ElideRight
                                    Layout.fillWidth: true
                                }
                                // Dismiss is independent from activating the notification.
                                MenuButton {
                                    text: "×"
                                    compact: true
                                    onClicked: root.hub.dismiss(toast.modelData.id)
                                }
                            }
                            Label {
                                font.family: Settings.fontFamily
                                text: toast.modelData.summary
                                textFormat: Text.PlainText
                                color: Settings.foreground
                                font.bold: true
                                wrapMode: Text.WordWrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Label {
                                font.family: Settings.fontFamily
                                visible: text.length > 0
                                text: toast.modelData.body
                                textFormat: Text.PlainText
                                color: Settings.muted
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                Layout.fillWidth: true
                            }
                            Label {
                                font.family: Settings.fontFamily
                                text: toast.modelData.hasDefault ? "Click to open" : "Click to view details"
                                font.pixelSize: 10
                                color: Settings.muted
                            }
                        }
                    }
                }
            }
        }
    }
    PanelWindow {
        screen: root.screen
        visible: root.target && root.osdVisible && ControlState.menu !== "audio"
        anchors { bottom: true }
        margins.bottom: 60
        implicitWidth: 270
        implicitHeight: 72
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "edge-control-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        mask: Region {}
        Rectangle {
            anchors.fill: parent
            color: Settings.sectionSurface
            radius: 12
            border.color: Settings.borderColor
            ColumnLayout {
                anchors { fill: parent; margins: 14 }
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.foreground
                    text: root.sink && root.sink.audio ? (root.sink.audio.muted ? "Muted" : "Volume " + Math.round(root.sink.audio.volume * 100) + "%") : "No output"
                }
                ProgressBar {
                    Layout.fillWidth: true
                    value: root.sink && root.sink.audio ? root.sink.audio.volume : 0
                    palette.highlight: Settings.purple
                }
            }
        }
    }
}
