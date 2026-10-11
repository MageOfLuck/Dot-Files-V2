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
        function onVolumeChanged() {
            root.osdVisible = true;
            osdTimer.restart();
        }
        function onMutedChanged() {
            root.osdVisible = true;
            osdTimer.restart();
        }
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
        implicitWidth: Math.min(360, root.screen.width - 24)
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
                        required property var modelData
                        width: toastStack.width
                        height: toastText.implicitHeight + 28
                        color: Settings.surface
                        radius: 14
                        border.color: Settings.elevated
                        MouseArea { anchors.fill: parent; onClicked: root.hub.hidePopup(modelData.id) }
                        ColumnLayout {
                            id: toastText
                            anchors { left: parent.left; right: parent.right; top: parent.top; margins: 14 }
                            Label {
                                font.family: Settings.fontFamily
                                text: modelData.summary
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
                                text: modelData.body
                                textFormat: Text.PlainText
                                color: Settings.muted
                                wrapMode: Text.WordWrap
                                maximumLineCount: 4
                                elide: Text.ElideRight
                                Layout.fillWidth: true
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
        anchors {
            bottom: true
        }
        margins.bottom: 60
        implicitWidth: 270
        implicitHeight: 72
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "edge-control-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        mask: Region {} // display only; no input interception
        Rectangle {
            anchors.fill: parent
            color: Settings.surface
            radius: 14
            border.color: Settings.elevated
            ColumnLayout {
                anchors {
                    fill: parent
                    margins: 14
                }
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
