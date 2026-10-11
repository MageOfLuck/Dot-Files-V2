import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Bluetooth

MenuView {
    id: view
    implicitHeight: body.implicitHeight
    clip: true
    property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter ? adapter.devices.values.slice().sort((a, b) => Number(b.connected) - Number(a.connected) || Number(b.paired) - Number(a.paired) || a.name.localeCompare(b.name)) : []
    Component.onDestruction: if (adapter)
        adapter.discovering = false
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 10
        SleekComboBox {
            Layout.fillWidth: true
            model: Bluetooth.adapters.values
            textRole: "name"
            currentIndex: Bluetooth.adapters.values.indexOf(view.adapter)
            onActivated: index => {
                if (view.adapter)
                    view.adapter.discovering = false;
                view.adapter = Bluetooth.adapters.values[index];
            }
        }
        RowLayout {
            MenuButton {
                text: view.adapter && view.adapter.enabled ? "Bluetooth on" : "Bluetooth off"
                enabled: !!view.adapter
                onClicked: view.adapter.enabled = !view.adapter.enabled
            }
            MenuButton {
                text: view.adapter && view.adapter.discovering ? "Stop scan" : "Scan"
                enabled: !!view.adapter && view.adapter.enabled
                onClicked: view.adapter.discovering = !view.adapter.discovering
            }
        }
        SleekTextField {
            id: filter
            Layout.fillWidth: true
            placeholderText: "Search devices"
        }
        Label {
            font.family: Settings.fontFamily
            visible: !view.adapter
            text: "No Bluetooth adapter detected."
            color: Settings.foreground
        }
        Repeater {
            model: view.devices
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                visible: (modelData.name + " " + modelData.address).toLowerCase().indexOf(filter.text.toLowerCase()) >= 0
                RowLayout {
                    Label {
                        font.family: Settings.fontFamily
                        text: modelData.name || modelData.address
                        color: Settings.foreground
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }
                    MenuButton {
                        text: modelData.connected ? "Disconnect" : (modelData.paired ? "Connect" : "Pair")
                        enabled: !!view.adapter && view.adapter.enabled && !modelData.pairing
                        onClicked: {
                            if (modelData.connected)
                                modelData.disconnect();
                            else if (modelData.paired)
                                modelData.connect();
                            else
                                modelData.pair();
                        }
                    }
                }
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.muted
                    font.pixelSize: 11
                    text: (modelData.connected ? "Connected" : modelData.pairing ? "Pairing…" : modelData.paired ? "Saved" : "Nearby") + (modelData.batteryAvailable ? " · " + Math.round(modelData.battery * 100) + "% battery" : "")
                }
            }
        }
        Label {
            font.family: Settings.fontFamily
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Settings.muted
            text: "Pairing that requires a PIN or confirmation needs a BlueZ agent. Use the pairing manager below if no agent is running."
        }
        MenuButton {
            text: "Open pairing manager"
            onClicked: ControlState.run(Settings.bluetoothManager)
        }
    }
}
