import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell.Networking

MenuView {
    id: view
    implicitHeight: body.implicitHeight
    clip: true
    readonly property var adapters: Networking.devices.values.filter(d => d.type === DeviceType.Wifi)
    property var device: adapters.length ? adapters[0] : null
    property var pending: null
    property string error: ""
    property var forgetTarget: null
    readonly property var networks: device ? device.networks.values.slice().sort((a, b) => Number(b.connected) - Number(a.connected) || Number(b.known) - Number(a.known) || b.signalStrength - a.signalStrength) : []
    readonly property var filteredNetworks: networks.filter(n => (n.name || "").toLowerCase().indexOf(filter.text.trim().toLowerCase()) >= 0)
    function connectNetwork(n) {
        pending = n;
        error = "";
        n.connect();
    }
    function personal(n) {
        return n && [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].indexOf(n.security) >= 0;
    }
    Component.onCompleted: if (device) device.scannerEnabled = true
    Component.onDestruction: if (device) device.scannerEnabled = false
    Connections {
        target: view.pending
        function onConnectionFailed(reason) {
            view.error = reason === ConnectionFailReason.NoSecrets && view.personal(view.pending) ? "Enter or correct the Wi-Fi password below." : "Connection failed: " + ConnectionFailReason.toString(reason);
        }
        function onConnectedChanged() {
            if (view.pending && view.pending.connected) {
                view.pending = null;
                view.error = "";
            }
        }
    }
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        SectionHeading { text: "Wi-Fi adapter" }
        MenuCard {
            RowLayout {
                Layout.fillWidth: true
                MenuButton {
                    text: Networking.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
                    selected: Networking.wifiEnabled
                    onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
                }
                Item { Layout.fillWidth: true }
                MenuButton {
                    text: view.device && view.device.scannerEnabled ? "Stop scan" : "Scan"
                    enabled: !!view.device && Networking.wifiEnabled
                    onClicked: view.device.scannerEnabled = !view.device.scannerEnabled
                }
            }
            SleekComboBox {
                Layout.fillWidth: true
                model: view.adapters
                textRole: "name"
                currentIndex: view.adapters.indexOf(view.device)
                onActivated: index => {
                    if (index < 0 || index >= view.adapters.length) return;
                    if (view.device) view.device.scannerEnabled = false;
                    view.pending = null;
                    view.error = "";
                    view.device = view.adapters[index];
                    view.device.scannerEnabled = true;
                }
            }
        }
        Label {
            font.family: Settings.fontFamily
            visible: !Networking.wifiHardwareEnabled
            text: "Wi-Fi is blocked by hardware/rfkill."
            color: Settings.muted
        }
        SectionHeading { text: "Networks"; detail: view.filteredNetworks.length + " found" }
        SleekTextField {
            id: filter
            Layout.fillWidth: true
            placeholderText: "Search networks"
        }
        Label {
            font.family: Settings.fontFamily
            Layout.fillWidth: true
            visible: !view.device || view.filteredNetworks.length === 0
            text: !view.device ? "No Wi-Fi adapter detected." : filter.text ? "No matching networks." : "No networks found. Select Scan to refresh."
            color: Settings.muted
            wrapMode: Text.WordWrap
        }
        Repeater {
            model: view.filteredNetworks
            delegate: MenuCard {
                id: networkCard
                required property var modelData
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 8
                    RowLayout {
                        Layout.fillWidth: true
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 4
                            Label {
                                font.family: Settings.fontFamily
                                text: networkCard.modelData.name || "Hidden network"
                                font.bold: true
                                Layout.fillWidth: true
                                color: Settings.foreground
                                elide: Text.ElideRight
                            }
                            Label {
                                font.family: Settings.fontFamily
                                color: Settings.muted
                                font.pixelSize: 11
                                text: (networkCard.modelData.connected ? "Connected · " : networkCard.modelData.known ? "Saved · " : "") + Math.round(networkCard.modelData.signalStrength * 100) + "% signal · " + WifiSecurityType.toString(networkCard.modelData.security)
                            }
                        }
                        MenuButton {
                            text: networkCard.modelData.stateChanging ? "Working…" : networkCard.modelData.connected ? "Disconnect" : "Connect"
                            enabled: Networking.wifiEnabled && !networkCard.modelData.stateChanging
                            onClicked: {
                                if (networkCard.modelData.connected) networkCard.modelData.disconnect();
                                else view.connectNetwork(networkCard.modelData);
                            }
                        }
                    }
                    RowLayout {
                        visible: networkCard.modelData.known
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        MenuButton {
                            text: "Forget saved network"
                            compact: true
                            onClicked: view.forgetTarget = networkCard.modelData
                        }
                    }
                }
            }
        }
        MenuCard {
            visible: view.error !== "" || (!!view.pending && view.personal(view.pending) && !view.pending.connected)
            Label {
                font.family: Settings.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: view.error
                visible: text !== ""
                color: Settings.foreground
            }
            ColumnLayout {
                visible: !!view.pending && view.personal(view.pending) && !view.pending.connected
                Layout.fillWidth: true
                Label {
                    font.family: Settings.fontFamily
                    text: "Password for " + (view.pending ? view.pending.name : "")
                    color: Settings.foreground
                }
                SleekTextField {
                    id: password
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholderText: "Wi-Fi password"
                    onAccepted: if (submit.enabled) submit.clicked()
                }
                MenuButton {
                    id: submit
                    text: "Connect with password"
                    enabled: password.text.length > 0
                    onClicked: {
                        if (view.pending) {
                            view.error = "";
                            view.pending.connectWithPsk(password.text);
                            password.clear();
                        }
                    }
                }
            }
        }
        MenuCard {
            visible: !!view.forgetTarget
            RowLayout {
                Layout.fillWidth: true
                Label {
                    font.family: Settings.fontFamily
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: Settings.foreground
                    text: "Forget “" + (view.forgetTarget ? view.forgetTarget.name : "") + "”?"
                }
                MenuButton {
                    text: "Yes"
                    onClicked: {
                        if (view.forgetTarget) view.forgetTarget.forget();
                        view.forgetTarget = null;
                    }
                }
                MenuButton {
                    text: "Cancel"
                    onClicked: view.forgetTarget = null
                }
            }
        }
        SectionHeading { text: "Advanced" }
        MenuCard {
            Label {
                font.family: Settings.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Settings.muted
                font.pixelSize: 11
                text: "Enterprise/802.1X and hidden networks use the connection editor."
            }
            MenuButton {
                text: "Connection editor"
                onClicked: ControlState.run(Settings.networkEditor)
            }
        }
    }
}
