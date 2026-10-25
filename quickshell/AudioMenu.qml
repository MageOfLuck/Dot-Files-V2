import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Services.Pipewire

MenuView {
    id: view
    implicitHeight: body.implicitHeight
    clip: true
    readonly property var outputs: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && n.isSink)
    readonly property var inputs: Pipewire.nodes.values.filter(n => n.audio && !n.isStream && !n.isSink)
    readonly property var streams: Pipewire.nodes.values.filter(n => n.audio && n.isStream)
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        SectionHeading { text: "Output" }
        MenuCard {
            SleekComboBox {
                Layout.fillWidth: true
                model: view.outputs
                textRole: "description"
                currentIndex: view.outputs.indexOf(Pipewire.defaultAudioSink)
                displayText: Pipewire.defaultAudioSink ? Pipewire.defaultAudioSink.description || Pipewire.defaultAudioSink.name : "No output device"
                onActivated: index => { if (index >= 0 && index < view.outputs.length) Pipewire.preferredDefaultAudioSink = view.outputs[index]; }
            }
            AudioRow { node: Pipewire.defaultAudioSink; device: true }
        }
        SectionHeading { text: "Input" }
        MenuCard {
            SleekComboBox {
                Layout.fillWidth: true
                model: view.inputs
                textRole: "description"
                currentIndex: view.inputs.indexOf(Pipewire.defaultAudioSource)
                displayText: Pipewire.defaultAudioSource ? Pipewire.defaultAudioSource.description || Pipewire.defaultAudioSource.name : "No input device"
                onActivated: index => { if (index >= 0 && index < view.inputs.length) Pipewire.preferredDefaultAudioSource = view.inputs[index]; }
            }
            AudioRow { node: Pipewire.defaultAudioSource; device: true }
        }
        SectionHeading { text: "Applications"; detail: view.streams.length + " streams" }
        Label {
            font.family: Settings.fontFamily
            visible: view.streams.length === 0
            text: "No application audio streams."
            color: Settings.muted
        }
        Repeater {
            model: view.streams
            delegate: MenuCard {
                required property var modelData
                AudioRow { node: modelData }
            }
        }
        Label {
            font.family: Settings.fontFamily
            text: "Default device changes follow WirePlumber routing policy."
            color: Settings.muted
            font.pixelSize: 11
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }
    }
}
