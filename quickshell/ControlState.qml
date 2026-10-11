pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

QtObject {
    id: root
    property string menu: ""
    property string monitor: ""
    property bool dnd: false
    property bool reserveSpace: Settings.reserveSpace
    property var notificationHub: null
    property var panels: ["audio", "bluetooth", "network", "notifications", "clock", "dashboard", "media"]
    function open(name, screenName, pin) {
        if (panels.indexOf(name) < 0)
            return;
        monitor = screenName || (Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "");
        if (!monitor && Quickshell.screens.length)
            monitor = Quickshell.screens[0].name;
        menu = name;
    }
    function toggle(name, screenName, pin) {
        const target = screenName || (Hyprland.focusedMonitor ? Hyprland.focusedMonitor.name : "");
        if (menu === name && monitor === target)
            close();
        else
            open(name, target, pin);
    }
    function close() {
        menu = "";
    }
    function run(command) {
        Quickshell.execDetached(["sh", "-c", command]);
    }
}
