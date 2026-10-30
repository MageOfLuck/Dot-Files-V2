import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

PanelWindow {
    id: panel
    property bool revealed: false
    readonly property bool menuOpen: ControlState.menu !== "" && ControlState.monitor === screen.name
    readonly property bool showBar: !Settings.menusOnly && (ControlState.reserveSpace || revealed || menuOpen)
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Settings.barHeight
    mask: Region {
        width: panel.width
        height: Math.max(Settings.edgeHeight, bar.y + bar.height)
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "edge-control"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    // Geometry never changes when a menu opens. Only the input mask follows
    // the animated strip; the taller activation zone remains reachable.
    Connections {
        target: ControlState
        function onReserveSpaceChanged() {
            if (!ControlState.reserveSpace)
                panel.revealed = false;
        }
    }
    Timer {
        interval: Settings.revealDelay
        running: edgeHover.hovered && !panel.revealed && !panel.menuOpen
        onTriggered: {
            if (Settings.menusOnly)
                ControlState.open("audio", panel.screen.name, false);
            else
                panel.revealed = true;
        }
    }
    Timer {
        interval: Settings.hideDelay
        running: panel.revealed && !panel.menuOpen && !barHover.hovered && !edgeHover.hovered
        onTriggered: {
            if (panel.menuOpen)
                ControlState.close();
            panel.revealed = false;
        }
    }
    Item {
        width: parent.width
        height: Settings.edgeHeight
        HoverHandler {
            id: edgeHover
        }
    }
    Rectangle {
        id: bar
        width: parent.width
        height: Settings.barHeight
        y: panel.showBar ? 0 : -height
        Behavior on y {
            NumberAnimation {
                duration: Settings.animationDuration
                easing.type: Easing.OutCubic
            }
        }
        color: Qt.rgba(Settings.surface.r, Settings.surface.g, Settings.surface.b, 0.98)
        HoverHandler {
            id: barHover
        }
        RowLayout {
            id: leftGroup
            anchors {
                left: parent.left
                leftMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 6
            MenuButton {
                iconButton: true
                text: String.fromCodePoint(0xF0493) // nf-md-cog (monochrome System icon)
                hint: "System"
                selected: panel.menuOpen && ControlState.menu === "dashboard"
                onClicked: ControlState.toggle("dashboard", panel.screen.name, false)
            }
            RowLayout {
                spacing: 4
                Repeater {
                    model: Hyprland.workspaces
                    delegate: MenuButton {
                        required property var modelData
                        visible: modelData.id > 0 && !!modelData.monitor && modelData.monitor.name === panel.screen.name
                        workspaceButton: true
                        text: modelData.name
                        selected: modelData.active
                        // Activate through Quickshell's Hyprland IPC rather than
                        // launching a separate shell and hyprctl process.
                        onClicked: modelData.activate()
                        ToolTip.visible: hovered
                        ToolTip.delay: 600
                        ToolTip.text: "Switch to workspace " + modelData.name
                    }
                }
            }
            MenuButton {
                iconButton: true
                selected: panel.menuOpen && ControlState.menu === "media"
                text: String.fromCodePoint(0xF0387) // nf-md-music_note
                hint: Mpris.players.values.length ? (Mpris.players.values[0].trackTitle || "Media") : "Media"
                onClicked: ControlState.toggle("media", panel.screen.name, false)
            }
        }
        Text {
            font.family: Settings.fontFamily
            anchors.centerIn: parent
            width: Math.max(0, parent.width - 2 * Math.max(leftGroup.width + 24, rightGroup.width + 24))
            text: Hyprland.activeToplevel ? Hyprland.activeToplevel.title : "Desktop"
            color: Settings.foreground
            font.pixelSize: 13
            font.bold: true
            elide: Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
        }
        RowLayout {
            id: rightGroup
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }
            spacing: 6
            MenuButton {
                iconButton: true
                text: String.fromCodePoint(0xF00AF) // nf-md-bluetooth
                hint: "Bluetooth"
                selected: panel.menuOpen && ControlState.menu === "bluetooth"
                onClicked: ControlState.toggle("bluetooth", panel.screen.name, false)
            }
            MenuButton {
                iconButton: true
                audioAccent: true
                selected: panel.menuOpen && ControlState.menu === "audio"
                // Keep the speaker glyph separate from the normal-font volume
                // percentage, so the number is not rendered in a Nerd Font.
                text: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio && Pipewire.defaultAudioSink.audio.muted
                      ? String.fromCodePoint(0xF0581) // nf-md-volume_off
                      : String.fromCodePoint(0xF057E) // nf-md-volume_high
                valueText: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio && !Pipewire.defaultAudioSink.audio.muted
                           ? Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%" : ""
                hint: Pipewire.defaultAudioSink && Pipewire.defaultAudioSink.audio
                      ? (Pipewire.defaultAudioSink.audio.muted ? "Audio muted" : "Audio · " + Math.round(Pipewire.defaultAudioSink.audio.volume * 100) + "%")
                      : "Audio"
                onClicked: ControlState.toggle("audio", panel.screen.name, false)
            }
            MenuButton {
                iconButton: true
                text: String.fromCodePoint(0xF05A9) // nf-md-wifi
                hint: "Network"
                selected: panel.menuOpen && ControlState.menu === "network"
                onClicked: ControlState.toggle("network", panel.screen.name, false)
            }
            Rectangle {
                width: 1
                height: 20
                color: Settings.muted
                opacity: 0.5
            }
            MenuButton {
                iconButton: true
                text: ControlState.dnd ? String.fromCodePoint(0xF009B) : String.fromCodePoint(0xF009C) // nf-md-bell_off / nf-md-bell_outline
                hint: ControlState.dnd ? "Notifications · Do Not Disturb" : "Notifications"
                selected: panel.menuOpen && ControlState.menu === "notifications"
                onClicked: ControlState.toggle("notifications", panel.screen.name, false)
            }
            MenuButton {
                text: Qt.formatDateTime(clock.date, "dddd h:mm AP")
                selected: panel.menuOpen && ControlState.menu === "clock"
                onClicked: ControlState.toggle("clock", panel.screen.name, false)
            }
        }
        SystemClock {
            id: clock
            precision: SystemClock.Minutes
        }
    }
}
