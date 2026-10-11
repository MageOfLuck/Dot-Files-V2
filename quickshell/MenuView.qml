import QtQuick.Controls

ScrollView {
    font.family: Settings.fontFamily
    palette {
        window: Settings.surface
        windowText: Settings.foreground
        base: "#373043"
        alternateBase: Settings.surface
        text: Settings.foreground
        button: "#373043"
        buttonText: Settings.foreground
        highlight: Settings.elevated
        highlightedText: Settings.foreground
        placeholderText: Settings.muted
    }
}
