import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Bluetooth

MenuView {
    id: view
    implicitHeight: body.implicitHeight
    clip: true
    property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: adapter ? adapter.devices.values.slice().sort((a, b) => Number(b.connected) - Number(a.connected) || Number(b.paired) - Number(a.paired) || (a.name || "").localeCompare(b.name || "")) : []
    readonly property var filteredDevices: devices.filter(d => ((d.name || "") + " " + (d.address || "")).toLowerCase().indexOf(filter.text.trim().toLowerCase()) >= 0)
    onAdapterChanged: if (adapter && !adapter.enabled && adapter.discovering) adapter.discovering = false
    Component.onDestruction: if (adapter) adapter.discovering = false
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        SectionHeading { text: "Adapter" }
        MenuCard {
            SleekComboBox {
                Layout.fillWidth: true
                model: Bluetooth.adapters.values
                textRole: "name"
                currentIndex: Bluetooth.adapters.values.indexOf(view.adapter)
                onActivated: index => {
                    if (index < 0 || index >= Bluetooth.adapters.values.length) return;
                    if (view.adapter) view.adapter.discovering = false;
                    view.adapter = Bluetooth.adapters.values[index];
                }
            }
            RowLayout {
                Layout.fillWidth: true
                MenuButton {
                    text: view.adapter && view.adapter.enabled ? "Bluetooth on" : "Bluetooth off"
                    selected: !!view.adapter && view.adapter.enabled
                    enabled: !!view.adapter
                    onClicked: view.adapter.enabled = !view.adapter.enabled
                }
                Item { Layout.fillWidth: true }
                MenuButton {
                    text: view.adapter && view.adapter.discovering ? "Stop scan" : "Scan"
                    enabled: !!view.adapter && view.adapter.enabled
                    onClicked: view.adapter.discovering = !view.adapter.discovering
                }
            }
        }
        SectionHeading { text: "Devices"; detail: view.filteredDevices.length + " shown" }
        SleekTextField {
            id: filter
            Layout.fillWidth: true
            placeholderText: "Search name or address"
        }
        Label {
            font.family: Settings.fontFamily
            Layout.fillWidth: true
            visible: !view.adapter || view.filteredDevices.length === 0
            text: !view.adapter ? "No Bluetooth adapter detected." : filter.text ? "No matching devices." : "No devices found. Select Scan to discover nearby devices."
            color: Settings.muted
            wrapMode: Text.WordWrap
        }
        Repeater {
            model: view.filteredDevices
            delegate: MenuCard {
                id: deviceCard
                required property var modelData
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 4
                        Label {
                            font.family: Settings.fontFamily
                            text: deviceCard.modelData.name || deviceCard.modelData.address || "Unknown device"
                            font.bold: true
                            color: Settings.foreground
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                        }
                        Label {
                            font.family: Settings.fontFamily
                            color: Settings.muted
                            font.pixelSize: 11
                            text: (deviceCard.modelData.connected ? "Connected" : deviceCard.modelData.pairing ? "Pairing…" : deviceCard.modelData.paired ? "Saved" : "Nearby") + (deviceCard.modelData.batteryAvailable ? " · " + Math.round(deviceCard.modelData.battery * 100) + "% battery" : "")
                        }
                    }
                    MenuButton {
                        text: deviceCard.modelData.connected ? "Disconnect" : (deviceCard.modelData.paired ? "Connect" : "Pair")
                        enabled: !!view.adapter && view.adapter.enabled && !deviceCard.modelData.pairing
                        onClicked: {
                            if (deviceCard.modelData.connected) deviceCard.modelData.disconnect();
                            else if (deviceCard.modelData.paired) deviceCard.modelData.connect();
                            else deviceCard.modelData.pair();
                        }
                    }
                }
            }
        }
        SectionHeading { text: "Pairing tools" }
        MenuCard {
            Label {
                font.family: Settings.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Settings.muted
                font.pixelSize: 11
                text: "Devices needing a PIN or confirmation require a BlueZ agent. Open the pairing manager if pairing stalls."
            }
            MenuButton {
                text: "Open pairing manager"
                onClicked: ControlState.run(Settings.bluetoothManager)
            }
        }
    }
}
