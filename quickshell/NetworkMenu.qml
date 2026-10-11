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
    function connectNetwork(n) {
        pending = n;
        error = "";
        n.connect();
    }
    function personal(n) {
        return n && [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].indexOf(n.security) >= 0;
    }
    Component.onCompleted: if (device)
        device.scannerEnabled = true
    Component.onDestruction: if (device)
        device.scannerEnabled = false
    Connections {
        target: view.pending
        function onConnectionFailed(reason) {
            view.error = reason === ConnectionFailReason.NoSecrets && view.personal(view.pending) ? "Enter or correct the Wi-Fi password below." : "Connection failed: " + ConnectionFailReason.toString(reason);
        }
    }
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 10
        RowLayout {
            MenuButton {
                text: Networking.wifiEnabled ? "Wi-Fi on" : "Wi-Fi off"
                onClicked: Networking.wifiEnabled = !Networking.wifiEnabled
            }
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
                if (view.device)
                    view.device.scannerEnabled = false;
                view.pending = null;
                view.device = view.adapters[index];
                view.device.scannerEnabled = true;
            }
        }
        SleekTextField {
            id: filter
            Layout.fillWidth: true
            placeholderText: "Search networks"
        }
        Label {
            font.family: Settings.fontFamily
            visible: !view.device
            text: "No Wi-Fi adapter detected."
            color: Settings.foreground
        }
        Label {
            font.family: Settings.fontFamily
            visible: !Networking.wifiHardwareEnabled
            text: "Wi-Fi is blocked by hardware/rfkill."
            color: Settings.muted
        }
        Repeater {
            model: view.networks
            delegate: ColumnLayout {
                required property var modelData
                Layout.fillWidth: true
                visible: modelData.name.toLowerCase().indexOf(filter.text.toLowerCase()) >= 0
                RowLayout {
                    Label {
                        font.family: Settings.fontFamily
                        text: modelData.name || "Hidden network"
                        Layout.fillWidth: true
                        color: Settings.foreground
                        elide: Text.ElideRight
                    }
                    MenuButton {
                        text: modelData.stateChanging ? "Working…" : modelData.connected ? "Disconnect" : "Connect"
                        enabled: Networking.wifiEnabled && !modelData.stateChanging
                        onClicked: {
                            if (modelData.connected)
                                modelData.disconnect();
                            else
                                view.connectNetwork(modelData);
                        }
                    }
                    MenuButton {
                        text: "Forget"
                        visible: modelData.known
                        onClicked: {
                            view.forgetTarget = modelData;
                        }
                    }
                }
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.muted
                    font.pixelSize: 11
                    text: (modelData.connected ? "Connected · " : modelData.known ? "Saved · " : "") + Math.round(modelData.signalStrength * 100) + "% · " + WifiSecurityType.toString(modelData.security)
                }
            }
        }
        Label {
            font.family: Settings.fontFamily
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            text: view.error
            visible: text !== ""
            color: Settings.purple
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
                onAccepted: submit.clicked()
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
        RowLayout {
            visible: !!view.forgetTarget
            Label {
                font.family: Settings.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Settings.foreground
                text: "Forget " + (view.forgetTarget ? view.forgetTarget.name : "") + "?"
            }
            MenuButton {
                text: "Yes"
                onClicked: {
                    view.forgetTarget.forget();
                    view.forgetTarget = null;
                }
            }
            MenuButton {
                text: "Cancel"
                onClicked: view.forgetTarget = null
            }
        }
        Label {
            font.family: Settings.fontFamily
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            color: Settings.muted
            font.pixelSize: 11
            text: "Enterprise/802.1X and hidden-network setup use the connection editor; saved profiles can connect here."
        }
        MenuButton {
            text: "Connection editor"
            onClicked: ControlState.run(Settings.networkEditor)
        }
    }
}
