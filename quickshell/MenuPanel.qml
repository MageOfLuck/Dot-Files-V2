import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: panel
    // Use the immutable name supplied by shell.qml. Looking up the window's
    // screen while its visibility changes may cause a binding loop on Wayland.
    property string assignedScreenName: ""
    readonly property bool isShown: ControlState.menu !== "" && ControlState.monitor === assignedScreenName
    readonly property int topGap: Settings.menusOnly ? 0 : Settings.barHeight
    visible: panel.isShown
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "edge-control-menu"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: panel.isShown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    // Leave the strip's input region available for switching menus.
    mask: Region {
        x: 0
        y: panel.topGap
        width: panel.width
        height: panel.height - panel.topGap
    }
    MouseArea {
        anchors.fill: parent
        onClicked: ControlState.close()
    }
    Rectangle {
        id: card
        width: Math.min(Settings.menuWidth, panel.width - 24)
        readonly property var menuHeights: ({
                audio: 610,
                bluetooth: 490,
                network: 620,
                notifications: 620,
                clock: 530,
                dashboard: 490,
                media: 530
            })
        // Extend menus downward, but always stop above the monitor's bottom edge.
        height: Math.max(80, Math.min(panel.height - y - 12, menuHeights[ControlState.menu] || 520))
        x: ["dashboard", "media"].indexOf(ControlState.menu) >= 0 ? 12 : panel.width - width - 12
        y: panel.topGap + 8
        radius: 16
        color: Qt.rgba(Settings.surface.r, Settings.surface.g, Settings.surface.b, 0.98)
        border.color: Settings.borderColor
        MouseArea {
            anchors.fill: parent
            onClicked: {}
        }
        ColumnLayout {
            anchors {
                fill: parent
                margins: 16
            }
            spacing: 12
            focus: panel.isShown
            Keys.onEscapePressed: ControlState.close()
            RowLayout {
                Layout.fillWidth: true
                Label {
                    font.family: Settings.fontFamily
                    text: ControlState.menu.charAt(0).toUpperCase() + ControlState.menu.slice(1)
                    color: Settings.foreground
                    font.pixelSize: 19
                    font.bold: true
                    Layout.fillWidth: true
                }
                MenuButton {
                    text: "×"
                    compact: true
                    onClicked: ControlState.close()
                }
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 1
                color: Settings.borderColor
            }
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: panel.isShown
                source: ControlState.menu === "audio" ? "AudioMenu.qml" : ControlState.menu === "bluetooth" ? "BluetoothMenu.qml" : ControlState.menu === "network" ? "NetworkMenu.qml" : ControlState.menu === "notifications" ? "NotificationMenu.qml" : "ExtrasMenu.qml"
            }
        }
    }
}
