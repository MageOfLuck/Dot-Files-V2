import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: hub
    property alias notifications: server.trackedNotifications
    property var popups: []
    // Optional Settings properties preserve compatibility with your edited config.
    readonly property int maxVisible: typeof Settings.notificationMaxVisible === "undefined" ? 3 : Math.max(0, Settings.notificationMaxVisible)
    readonly property int duration: typeof Settings.notificationDuration === "undefined" ? 5000 : Math.max(0, Settings.notificationDuration)
    property bool toastVisible: false // compatibility with NotificationMenu's DND action
    onToastVisibleChanged: if (!toastVisible && popups.length) popups = []
    function hidePopup(id) {
        popups = popups.filter(p => p.id !== id);
        toastVisible = popups.length > 0;
    }
    function showPopup(n) {
        if (!maxVisible) return;
        const next = popups.filter(p => p.id !== n.id);
        next.push({ id: n.id, summary: n.summary, body: n.body,
                    expires: duration > 0 ? Date.now() + duration : 0 });
        popups = next.slice(-maxVisible);
        toastVisible = popups.length > 0;
    }
    onMaxVisibleChanged: {
        popups = maxVisible ? popups.slice(-maxVisible) : [];
        toastVisible = popups.length > 0;
    }
    Connections {
        target: ControlState
        function onDndChanged() { if (ControlState.dnd) { hub.popups = []; hub.toastVisible = false; } }
    }
    function clear() {
        popups = [];
        toastVisible = false;
        server.trackedNotifications.values.slice().forEach(n => n.dismiss());
    }
    function dismiss(id) {
        const n = server.trackedNotifications.values.find(n => n.id === id);
        if (n)
            n.dismiss();
    }
    Component.onCompleted: ControlState.notificationHub = hub
    NotificationServer {
        id: server
        actionsSupported: true
        persistenceSupported: true
        bodyMarkupSupported: false
        onNotification: n => {
            n.tracked = true;
            // Bound history prevents unlimited growth; history lasts this session.
            const entries = server.trackedNotifications.values;
            if (entries.length > 100)
                entries[0].dismiss();
            if (!ControlState.dnd && !n.lastGeneration) hub.showPopup(n);
        }
    }
    Timer {
        interval: 100
        repeat: true
        running: hub.popups.length > 0 && hub.popups.some(p => p.expires > 0)
        onTriggered: {
            const now = Date.now();
            hub.popups = hub.popups.filter(p => p.expires === 0 || p.expires > now);
            hub.toastVisible = hub.popups.length > 0;
        }
    }
    // Transient notifications must not stay in history indefinitely.
    Instantiator {
        model: server.trackedNotifications
        delegate: QtObject {
            required property var modelData
            property Timer expiry: Timer {
                interval: Math.max(1000, modelData.expireTimeout > 0 ? modelData.expireTimeout * 1000 : 5000)
                running: modelData.transient
                onTriggered: modelData.expire()
            }
        }
    }
}
