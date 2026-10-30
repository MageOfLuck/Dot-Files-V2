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
    readonly property real outputVolume: root.sink && root.sink.audio ? root.sink.audio.volume : 0
    readonly property bool outputMuted: root.sink && root.sink.audio ? root.sink.audio.muted : false
    readonly property int volumePercent: Math.round(root.outputVolume * 100)
    readonly property string volumeIcon: String.fromCodePoint(
        root.outputMuted || root.volumePercent === 0 ? 0xF0581 : // nf-md-volume_off
        root.volumePercent < 34 ? 0xF057F :                   // nf-md-volume_low
        root.volumePercent < 67 ? 0xF0580 : 0xF057E)          // nf-md-volume_medium/high
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
    // Compact, non-interactive output-volume OSD. This is shown whenever
    // the default PipeWire sink changes volume or mute state (keyboard knob,
    // media keys, or other mixers) without affecting the main Audio menu.
    PanelWindow {
        screen: root.screen
        visible: root.target && root.osdVisible && ControlState.menu !== "audio"
        anchors { bottom: true }
        margins.bottom: 60
        implicitWidth: 296
        implicitHeight: 96
        color: "transparent"
        exclusionMode: ExclusionMode.Ignore
        WlrLayershell.namespace: "edge-control-osd"
        WlrLayershell.layer: WlrLayer.Overlay
        // The OSD never captures clicks or wheel events from applications.
        mask: Region {}

        Rectangle {
            anchors.fill: parent
            radius: 15
            color: Settings.surface
            border.width: 1
            border.color: Settings.borderColor

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 13
                spacing: 9

                // A fixed-size icon tile prevents different speaker glyphs from
                // shifting the label or the percentage as the volume changes.
                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 45

                    Rectangle {
                        id: volumeIconTile
                        width: 45
                        height: 45
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        radius: 11
                        color: Settings.sectionSurface
                        border.width: 1
                        border.color: Settings.borderColor

                        Text {
                            // Use the entire fixed tile for alignment rather than
                            // centering the variable-width implicit glyph bounds.
                            anchors.fill: parent
                            text: root.volumeIcon
                            font.family: Settings.iconFontFamily
                            font.pixelSize: 24
                            font.bold: false
                            color: root.outputMuted ? Settings.muted : Settings.foreground
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }
                    }

                    Column {
                        anchors.left: volumeIconTile.right
                        anchors.leftMargin: 11
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2

                        Text {
                            text: "AUDIO"
                            font.family: Settings.fontFamily
                            font.pixelSize: 10
                            font.bold: true
                            font.letterSpacing: 0.7
                            color: Settings.muted
                        }
                        Text {
                            text: !root.sink || !root.sink.audio ? "No output" : root.outputMuted ? "Muted" : "Volume"
                            font.family: Settings.fontFamily
                            font.pixelSize: 14
                            font.bold: true
                            color: Settings.foreground
                        }
                    }

                    // Anchoring this to the right edge keeps 5%, 95% and 100%
                    // at the same right boundary instead of moving with text width.
                    Text {
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        text: root.sink && root.sink.audio ? root.volumePercent + "%" : "—"
                        font.family: Settings.fontFamily
                        font.pixelSize: 22
                        font.bold: true
                        color: root.outputMuted ? Settings.muted : Settings.foreground
                        horizontalAlignment: Text.AlignRight
                    }
                }

                // Custom progress track, with no platform-native padding.
                Rectangle {
                    id: volumeTrack
                    Layout.fillWidth: true
                    Layout.preferredHeight: 7
                    radius: 3.5
                    color: Settings.hoverSurface
                    clip: true

                    Rectangle {
                        height: parent.height
                        width: parent.width * Math.min(1, Math.max(0, root.outputVolume))
                        radius: parent.radius
                        color: root.outputMuted ? Settings.muted : Settings.purple
                        opacity: root.outputMuted ? 0.5 : 1
                        Behavior on width {
                            NumberAnimation {
                                duration: 110
                                easing.type: Easing.OutCubic
                            }
                        }
                    }
                }
            }
        }
    }
}
