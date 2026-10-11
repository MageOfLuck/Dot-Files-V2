import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

PanelWindow {
    id: panel
    readonly property bool menuOpen: ControlState.menu !== "" && ControlState.monitor === screen.name
    readonly property int topGap: Settings.menusOnly ? 0 : Settings.barHeight
    visible: menuOpen
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
    WlrLayershell.keyboardFocus: menuOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
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
                audio: 560,
                bluetooth: 480,
                network: 560,
                notifications: 560,
                clock: 490,
                dashboard: 340,
                media: 440
            })
        height: Math.max(100, Math.min(panel.height - y - 12, menuHeights[ControlState.menu] || 480))
        x: ["dashboard", "media"].indexOf(ControlState.menu) >= 0 ? 12 : panel.width - width - 12
        y: panel.topGap + 8
        radius: 16
        color: Qt.rgba(Settings.surface.r, Settings.surface.g, Settings.surface.b, 0.98)
        border.color: Settings.elevated
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
            focus: panel.menuOpen
            Keys.onEscapePressed: ControlState.close()
            RowLayout {
                Layout.fillWidth: true
                Label {
                    font.family: Settings.fontFamily
                    text: ControlState.menu.charAt(0).toUpperCase() + ControlState.menu.slice(1)
                    color: Settings.foreground
                    font.pixelSize: 20
                    font.bold: true
                    Layout.fillWidth: true
                }
                MenuButton {
                    text: "×"
                    onClicked: ControlState.close()
                }
            }
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: panel.menuOpen
                source: ControlState.menu === "audio" ? "AudioMenu.qml" : ControlState.menu === "bluetooth" ? "BluetoothMenu.qml" : ControlState.menu === "network" ? "NetworkMenu.qml" : ControlState.menu === "notifications" ? "NotificationMenu.qml" : "ExtrasMenu.qml"
            }
        }
    }
}
