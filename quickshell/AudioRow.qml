import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Pipewire

ColumnLayout {
    id: row
    required property var node
    property bool device: false
    readonly property bool ready: node && node.ready && node.audio
    Layout.fillWidth: true
    spacing: 4
    PwObjectTracker {
        objects: [row.node]
    }
    RowLayout {
        Layout.fillWidth: true
        Image {
            visible: !row.device
            Layout.preferredWidth: 24
            Layout.preferredHeight: 24
            source: row.ready ? Quickshell.iconPath(row.node.properties["application.icon-name"] || "audio-x-generic", true) : ""
            fillMode: Image.PreserveAspectFit
        }
        Label {
            font.family: Settings.fontFamily
            Layout.fillWidth: true
            color: Settings.foreground
            text: !row.node ? "No device" : (row.ready && !row.device ? row.node.properties["application.name"] || row.node.description || row.node.name : row.node.description || row.node.name)
            elide: Text.ElideRight
        }
        Label {
            font.family: Settings.fontFamily
            color: Settings.muted
            text: row.ready ? Math.round(row.node.audio.volume * 100) + "%" : "—"
        }
        MenuButton {
            text: row.ready && row.node.audio.muted ? "Unmute" : "Mute"
            enabled: !!row.ready
            onClicked: row.node.audio.muted = !row.node.audio.muted
        }
    }
    SleekSlider {
        Layout.fillWidth: true
        from: 0
        to: 1
        stepSize: 0.01
        enabled: !!row.ready
        value: row.ready ? row.node.audio.volume : 0
        onMoved: if (row.ready)
            row.node.audio.volume = value
        palette.highlight: Settings.purple
    }
}
