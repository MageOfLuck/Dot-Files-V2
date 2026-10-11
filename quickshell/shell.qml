import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Pipewire

ShellRoot {
    IpcHandler {
        target: "control"
        function toggle(menu: string): void {
            ControlState.toggle(menu, "", true);
        }
        function open(menu: string): void {
            ControlState.open(menu, "", true);
        }
        function close(): void {
            ControlState.close();
        }
        function toggleReserve(): void {
            ControlState.reserveSpace = !ControlState.reserveSpace;
        }
    }
    // Keep the default devices tracked for the strip and OSD.
    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink, Pipewire.defaultAudioSource]
    }
    Variants {
        model: Quickshell.screens
        delegate: Scope {
            required property var modelData
            ScreenPanel {
                screen: modelData
            }
            MenuPanel {
                screen: modelData
            }
            SpaceReservation {
                screen: modelData
            }
        }
    }
    NotificationHub {
        id: notifications
    }
    Variants {
        model: Quickshell.screens
        delegate: Alerts {
            required property var modelData
            screen: modelData
            hub: notifications
        }
    }
}
