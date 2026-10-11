import QtQuick
import Quickshell
import Quickshell.Wayland

// A separate input-transparent surface reserves a fixed bar height. The menu
// overlay can grow to screen height without changing the reserved space.
PanelWindow {
    visible: ControlState.reserveSpace && !Settings.menusOnly
    anchors {
        top: true
        left: true
        right: true
    }
    implicitHeight: Settings.barHeight
    exclusiveZone: Settings.barHeight
    exclusionMode: ExclusionMode.Normal
    color: "transparent"
    mask: Region {}
    WlrLayershell.namespace: "edge-control-reservation"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
}
