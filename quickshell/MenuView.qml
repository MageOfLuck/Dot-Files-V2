import QtQuick
import QtQuick.Controls

ScrollView {
    id: view

    // Scroll larger lists faster so that a long device/notification list is
    // not dramatically slower to navigate than a short menu. Mouse wheel only;
    // Qt retains precise native touchpad scrolling.
    property real wheelStepPixels: 60
    property bool wheelDebug: false
    property real wheelContentFraction: 0.10
    property real wheelMaximumPixels: 300

    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        interactive: true
        implicitWidth: 7
        contentItem: Rectangle {
            implicitWidth: 6
            radius: width / 2
            color: Settings.muted
            opacity: 0.75
        }
    }

    WheelHandler {
        parent: view.contentItem
        target: null
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        orientation: Qt.Vertical
        blocking: true
        onWheel: event => {
            if (view.wheelDebug) console.log("Wheel event received:", event.angleDelta.y, "pixelDelta:", event.pixelDelta.y);
            const flickable = view.contentItem;
            if (!flickable || flickable.contentY === undefined) {
                event.accepted = false;
                return;
            }
            const overflow = Math.max(0, flickable.contentHeight - flickable.height);
            if (overflow <= 0) {
                event.accepted = true;
                return;
            }
            // At least 155px per notch, rising with the *scrollable distance*
            // up to 380px. Avoid scaling mouse movement down on longer menus.
            const step = Math.max(view.wheelStepPixels,
                                  Math.min(view.wheelMaximumPixels,
                                           overflow * view.wheelContentFraction));

            const ticks = event.angleDelta.y / 120;
            if (!ticks) {
                event.accepted = false;
                return;
            }
            const direction = event.inverted ? -1 : 1;
            flickable.contentY = Math.max(0, Math.min(overflow,
                                       flickable.contentY - ticks * direction * step));
            event.accepted = true;
        }
    }

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
