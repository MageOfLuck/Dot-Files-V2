import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris

MenuView {
    id: view
    clip: true
    implicitHeight: body.implicitHeight
    property var selectedPlayer: null
    readonly property var player: selectedPlayer && Mpris.players.values.indexOf(selectedPlayer) >= 0 ? selectedPlayer : (Mpris.players.values.length ? Mpris.players.values[0] : null)
    property date month: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    property var stats: ({})
    property string confirmAction: ""
    function timeString(s) {
        const seconds = Math.max(0, Math.floor(s || 0));
        return Math.floor(seconds / 60) + ":" + String(seconds % 60).padStart(2, "0");
    }
    SystemClock {
        id: now
        precision: SystemClock.Seconds
    }
    Process {
        id: statsProcess
        command: ["python3", Quickshell.shellDir + "/system-info.py"]
        stdout: StdioCollector {
            onStreamFinished: {
                try { view.stats = JSON.parse(text); }
                catch (e) { console.warn("system-info:", e); }
            }
        }
    }
    Component.onCompleted: if (ControlState.menu === "dashboard") statsProcess.running = true
    Timer {
        interval: 3000
        repeat: true
        running: ControlState.menu === "dashboard"
        onTriggered: if (!statsProcess.running) statsProcess.running = true
    }
    Timer {
        interval: 1000
        repeat: true
        running: ControlState.menu === "media" && !!view.player && view.player.isPlaying && view.player.positionSupported
        onTriggered: if (view.player) view.player.positionChanged()
    }
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        ColumnLayout {
            visible: ControlState.menu === "dashboard"
            Layout.fillWidth: true
            spacing: 12
            SectionHeading { text: "Bar settings" }
            MenuCard {
                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        font.family: Settings.fontFamily
                        text: "Reserve space for the bar"
                        color: Settings.foreground
                        Layout.fillWidth: true
                        wrapMode: Text.WordWrap
                    }
                    MenuButton {
                        text: ControlState.reserveSpace ? "On" : "Off"
                        selected: ControlState.reserveSpace
                        onClicked: ControlState.reserveSpace = !ControlState.reserveSpace
                    }
                }
            }
            SectionHeading { text: "System information" }
            MenuCard {
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.foreground
                    text: view.stats.host || "System"
                    font.pixelSize: 19
                    font.bold: true
                }
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.muted
                    text: "Uptime · " + (view.stats.uptime || "…")
                }
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.muted
                    text: "Memory · " + (view.stats.memory || "…")
                    wrapMode: Text.WordWrap
                    Layout.fillWidth: true
                }
                Label {
                    font.family: Settings.fontFamily
                    color: Settings.muted
                    text: "Load averages · " + (view.stats.load || "…")
                }
            }
            SectionHeading { text: "Session & power" }
            MenuCard {
                Flow {
                    Layout.fillWidth: true
                    spacing: 7
                    MenuButton {
                        text: "Lock"
                        onClicked: { ControlState.run(Settings.lockCommand); ControlState.close(); }
                    }
                    MenuButton { text: "Suspend"; onClicked: view.confirmAction = "suspend" }
                    MenuButton { text: "Log out"; onClicked: view.confirmAction = "logout" }
                    MenuButton { text: "Reboot"; onClicked: view.confirmAction = "reboot" }
                    MenuButton { text: "Power off"; onClicked: view.confirmAction = "poweroff" }
                }
                RowLayout {
                    visible: view.confirmAction !== ""
                    Layout.fillWidth: true
                    Label {
                        font.family: Settings.fontFamily
                        color: Settings.foreground
                        text: "Confirm " + view.confirmAction + "?"
                        Layout.fillWidth: true
                    }
                    MenuButton {
                        text: "Yes"
                        onClicked: {
                            ControlState.run(view.confirmAction === "logout" ? Settings.logoutCommand : "systemctl " + view.confirmAction);
                            ControlState.close();
                        }
                    }
                    MenuButton { text: "Cancel"; onClicked: view.confirmAction = "" }
                }
            }
        }
        ColumnLayout {
            visible: ControlState.menu === "media"
            Layout.fillWidth: true
            spacing: 12
            SectionHeading { text: "Player" }
            SleekComboBox {
                Layout.fillWidth: true
                model: Mpris.players.values
                textRole: "identity"
                currentIndex: Mpris.players.values.indexOf(view.player)
                displayText: view.player ? view.player.identity : "No media player"
                onActivated: index => { if (index >= 0 && index < Mpris.players.values.length) view.selectedPlayer = Mpris.players.values[index]; }
            }
            MenuCard {
                Image {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: 176
                    Layout.preferredHeight: 176
                    visible: !!view.player && view.player.trackArtUrl !== ""
                    source: view.player ? view.player.trackArtUrl : ""
                    fillMode: Image.PreserveAspectFit
                }
                Label {
                    font.family: Settings.fontFamily
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: Settings.foreground
                    font.bold: true
                    font.pixelSize: 17
                    text: view.player ? view.player.trackTitle || "Unknown track" : "No media player"
                }
                Label {
                    font.family: Settings.fontFamily
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    color: Settings.muted
                    text: view.player ? view.player.trackArtist : ""
                    visible: text.length > 0
                }
                SleekSlider {
                    Layout.fillWidth: true
                    visible: !!view.player && view.player.positionSupported && view.player.lengthSupported && view.player.length > 0
                    enabled: !!view.player && view.player.canSeek
                    from: 0
                    to: view.player && view.player.length > 0 ? view.player.length : 1
                    value: view.player ? view.player.position : 0
                    onMoved: if (view.player && view.player.canSeek) view.player.position = value
                }
                RowLayout {
                    visible: !!view.player && view.player.positionSupported && view.player.lengthSupported && view.player.length > 0
                    Layout.fillWidth: true
                    Label {
                        font.family: Settings.fontFamily
                        text: view.timeString(view.player ? view.player.position : 0)
                        color: Settings.muted
                        font.pixelSize: 11
                    }
                    Item { Layout.fillWidth: true }
                    Label {
                        font.family: Settings.fontFamily
                        text: view.timeString(view.player ? view.player.length : 0)
                        color: Settings.muted
                        font.pixelSize: 11
                    }
                }
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 9
                    MenuButton {
                        text: "Previous"
                        enabled: !!view.player && view.player.canGoPrevious
                        onClicked: view.player.previous()
                    }
                    MenuButton {
                        text: view.player && view.player.isPlaying ? "Pause" : "Play"
                        selected: !!view.player && view.player.isPlaying
                        enabled: !!view.player && view.player.canTogglePlaying
                        onClicked: view.player.togglePlaying()
                    }
                    MenuButton {
                        text: "Next"
                        enabled: !!view.player && view.player.canGoNext
                        onClicked: view.player.next()
                    }
                }
            }
        }
        ColumnLayout {
            visible: ControlState.menu === "clock"
            Layout.fillWidth: true
            spacing: 12
            MenuCard {
                Label {
                    font.family: Settings.fontFamily
                    text: Qt.formatDateTime(now.date, "h:mm:ss AP")
                    color: Settings.foreground
                    font.pixelSize: 34
                    font.bold: true
                    Layout.alignment: Qt.AlignHCenter
                }
                Label {
                    font.family: Settings.fontFamily
                    text: Qt.formatDateTime(now.date, "dddd, MMMM d, yyyy")
                    color: Settings.muted
                    Layout.alignment: Qt.AlignHCenter
                }
            }
            SectionHeading { text: "Calendar" }
            MenuCard {
                RowLayout {
                    Layout.fillWidth: true
                    MenuButton {
                        text: "‹"
                        compact: true
                        onClicked: view.month = new Date(view.month.getFullYear(), view.month.getMonth() - 1, 1)
                    }
                    Label {
                        font.family: Settings.fontFamily
                        text: Qt.formatDateTime(view.month, "MMMM yyyy")
                        color: Settings.foreground
                        font.bold: true
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    MenuButton {
                        text: "›"
                        compact: true
                        onClicked: view.month = new Date(view.month.getFullYear(), view.month.getMonth() + 1, 1)
                    }
                }
                GridLayout {
                    columns: 7
                    columnSpacing: 1
                    rowSpacing: 4
                    Layout.fillWidth: true
                    Repeater {
                        model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]
                        delegate: Label {
                            font.family: Settings.fontFamily
                            required property string modelData
                            text: modelData
                            color: Settings.muted
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }
                    }
                    Repeater {
                        model: 42
                        delegate: Rectangle {
                            required property int index
                            property date day: new Date(view.month.getFullYear(), view.month.getMonth(), 1 - (view.month.getDay() + 6) % 7 + index)
                            property bool today: Qt.formatDateTime(day, "yyyy-MM-dd") === Qt.formatDateTime(now.date, "yyyy-MM-dd")
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 8
                            color: today ? Settings.elevated : "transparent"
                            Label {
                                font.family: Settings.fontFamily
                                anchors.centerIn: parent
                                text: parent.day.getDate()
                                color: parent.day.getMonth() === view.month.getMonth() ? Settings.foreground : Settings.muted
                                opacity: parent.day.getMonth() === view.month.getMonth() ? 1 : 0.4
                            }
                        }
                    }
                }
                MenuButton {
                    text: "Today"
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: view.month = new Date(now.date.getFullYear(), now.date.getMonth(), 1)
                }
            }
        }
    }
}
