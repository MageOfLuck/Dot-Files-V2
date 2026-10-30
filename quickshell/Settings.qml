pragma Singleton
import QtQuick

QtObject {
    property color surface: "#241f31"
    property color elevated: "#575fbf"
    property color purple: '#7668c5'
    property color foreground: "#f0edf8"
    property color muted: "#b8b2c8"
    property color sectionSurface: "#302a3d"
    property color hoverSurface: "#423853"
    property color borderColor: "#4c435d"
    property bool menusOnly: false
    property bool reserveSpace: false
    property string fontFamily: "Noto Sans"
    // Install a Nerd Font symbols font, or set this to an installed Nerd Font family.
    property string iconFontFamily: "Symbols Nerd Font Mono"
    property int barIconSize: 19
    property int edgeHeight: 8
    property int animationDuration: 270
    property int revealDelay: 80
    property int hideDelay: 200
    property int barHeight: 42
    property string popupMonitor: "DP-2"
    property int menuWidth: 430
    property string logoutCommand: "command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"
    property string lockCommand: "hyprlock"
    property string bluetoothManager: "blueman-manager"
    property string networkEditor: "nm-connection-editor"
    property int notificationMaxVisible: 3
    property int notificationDuration: 5000
    property int notificationHistoryLimit: 100
}
