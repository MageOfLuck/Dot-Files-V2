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
    property var player: Mpris.players.values.length ? Mpris.players.values[0] : null
    property date month: new Date(new Date().getFullYear(), new Date().getMonth(), 1)
    property var stats: ({})
    property string confirmAction: ""
    SystemClock {
        id: now
        precision: SystemClock.Seconds
    }
    Process {
        id: statsProcess
        command: ["python3", Quickshell.shellDir + "/system-info.py"]
        running: ControlState.menu === "dashboard"
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    view.stats = JSON.parse(text);
                } catch (e) {
                    console.warn("system-info:", e);
                }
            }
        }
    }
    Timer {
        interval: 3000
        repeat: true
        running: ControlState.menu === "dashboard"
        onTriggered: if (!statsProcess.running)
            statsProcess.running = true
    }
    ColumnLayout {
        id: body
        width: view.availableWidth
        spacing: 12
        ColumnLayout {
            visible: ControlState.menu === "dashboard"
            Layout.fillWidth: true
            MenuButton {
                text: ControlState.reserveSpace ? "Reserve bar space: On" : "Reserve bar space: Off"
                selected: ControlState.reserveSpace
                onClicked: ControlState.reserveSpace = !ControlState.reserveSpace
            }
            Label {
                font.family: Settings.fontFamily
                color: Settings.foreground
                text: view.stats.host || "System"
                font.pixelSize: 24
            }
            Label {
                font.family: Settings.fontFamily
                color: Settings.muted
                text: "Uptime: " + (view.stats.uptime || "…")
            }
            Label {
                font.family: Settings.fontFamily
                color: Settings.muted
                text: "Memory: " + (view.stats.memory || "…")
            }
            Label {
                font.family: Settings.fontFamily
                color: Settings.muted
                text: "CPU load averages: " + (view.stats.load || "…")
            }
            Flow {
                Layout.fillWidth: true
                spacing: 6
                MenuButton {
                    text: "Lock"
                    onClicked: {
                        ControlState.run(Settings.lockCommand);
                        ControlState.close();
                    }
                }
                MenuButton {
                    text: "Suspend"
                    onClicked: view.confirmAction = "suspend"
                }
                MenuButton {
                    text: "Log out"
                    onClicked: view.confirmAction = "logout"
                }
                MenuButton {
                    text: "Reboot"
                    onClicked: view.confirmAction = "reboot"
                }
                MenuButton {
                    text: "Power off"
                    onClicked: view.confirmAction = "poweroff"
                }
            }
            RowLayout {
                visible: view.confirmAction !== ""
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
                MenuButton {
                    text: "Cancel"
                    onClicked: view.confirmAction = ""
                }
            }
        }
        ColumnLayout {
            visible: ControlState.menu === "media"
            Layout.fillWidth: true
            SleekComboBox {
                Layout.fillWidth: true
                model: Mpris.players.values
                textRole: "identity"
                currentIndex: Mpris.players.values.indexOf(view.player)
                onActivated: index => view.player = Mpris.players.values[index]
            }
            Image {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: 180
                Layout.preferredHeight: 180
                visible: !!view.player && view.player.trackArtUrl !== ""
                source: view.player ? view.player.trackArtUrl : ""
                fillMode: Image.PreserveAspectFit
            }
            Label {
                font.family: Settings.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Settings.foreground
                font.pixelSize: 18
                text: view.player ? view.player.trackTitle || "Unknown track" : "No media player"
            }
            Label {
                font.family: Settings.fontFamily
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                color: Settings.muted
                text: view.player ? view.player.trackArtist : ""
            }
            RowLayout {
                MenuButton {
                    text: "Previous"
                    enabled: !!view.player && view.player.canGoPrevious
                    onClicked: view.player.previous()
                }
                MenuButton {
                    text: view.player && view.player.isPlaying ? "Pause" : "Play"
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
        ColumnLayout {
            visible: ControlState.menu === "clock"
            Layout.fillWidth: true
            Label {
                font.family: Settings.fontFamily
                text: Qt.formatDateTime(now.date, "h:mm:ss AP")
                color: Settings.foreground
                font.pixelSize: 36
                Layout.alignment: Qt.AlignHCenter
            }
            Label {
                font.family: Settings.fontFamily
                text: Qt.formatDateTime(now.date, "dddd, MMMM d, yyyy")
                color: Settings.muted
                Layout.alignment: Qt.AlignHCenter
            }
            RowLayout {
                MenuButton {
                    text: "‹"
                    onClicked: view.month = new Date(view.month.getFullYear(), view.month.getMonth() - 1, 1)
                }
                Label {
                    font.family: Settings.fontFamily
                    text: Qt.formatDateTime(view.month, "MMMM yyyy")
                    color: Settings.foreground
                    Layout.fillWidth: true
                    horizontalAlignment: Text.AlignHCenter
                }
                MenuButton {
                    text: "›"
                    onClicked: view.month = new Date(view.month.getFullYear(), view.month.getMonth() + 1, 1)
                }
            }
            GridLayout {
                columns: 7
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
                onClicked: view.month = new Date(now.date.getFullYear(), now.date.getMonth(), 1)
            }
        }
    }
}
