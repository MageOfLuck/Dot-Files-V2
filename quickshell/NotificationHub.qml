import QtQuick
import QtQml.Models
import Quickshell
import Quickshell.Services.Notifications

Scope {
    id: hub
    property alias notifications: server.trackedNotifications
    property var popups: []
    readonly property int maxVisible: Math.max(0, Settings.notificationMaxVisible)
    readonly property int duration: Math.max(0, Settings.notificationDuration)
    readonly property int historyLimit: Math.max(1, Settings.notificationHistoryLimit)

    // Toast state is separate from notification history. Hiding a toast should
    // never dismiss an actionable notification from the notification server.
    function hidePopup(id) {
        popups = popups.filter(p => p.id !== id);
    }
    function showPopup(n) {
        if (maxVisible === 0 || ControlState.dnd) return;
        const next = popups.filter(p => p.id !== n.id);
        next.push({
            id: n.id,
            summary: n.summary || "Notification",
            body: n.body || "",
            appName: n.appName || "Application",
            expires: duration > 0 ? Date.now() + duration : 0,
            remaining: duration,
            hasDefault: !!findAction(n, "default"),
            paused: false
        });
        popups = next.slice(-maxVisible);
    }
    function pausePopup(id, pause) {
        // Mutate the toast timer only; replacing the Repeater's array here would
        // recreate its delegates and repeatedly cancel the hover state.
        const p = popups.find(p => p.id === id);
        if (!p || p.paused === pause || duration === 0) return;
        if (pause) {
            p.remaining = Math.max(0, p.expires - Date.now());
            p.paused = true;
        } else {
            p.expires = Date.now() + p.remaining;
            p.paused = false;
        }
    }
    function findNotification(id) {
        return server.trackedNotifications.values.find(n => n.id === id) || null;
    }
    function findAction(n, identifier) {
        if (!n) return null;
        for (let i = 0; i < n.actions.length; i++) {
            if (n.actions[i].identifier === identifier) return n.actions[i];
        }
        return null;
    }
    function hasDefaultAction(id) {
        return !!findAction(findNotification(id), "default");
    }
    function invokeAction(id, identifier) {
        const n = findNotification(id);
        if (!n) {
            hidePopup(id);
            return;
        }
        const action = findAction(n, identifier);
        if (action) {
            hidePopup(id);
            action.invoke();
        }
    }
    // Same activation path for the on-screen toast and the history card.
    // Notifications without a default action open the notification center,
    // rather than disappearing or guessing which action is intended.
    function activate(id, monitorName) {
        const n = findNotification(id);
        if (!n) {
            hidePopup(id);
            return;
        }
        const defaultAction = findAction(n, "default");
        hidePopup(id);
        if (defaultAction) {
            defaultAction.invoke();
        } else {
            ControlState.open("notifications", monitorName || Settings.popupMonitor, false);
        }
    }
    function dismiss(id) {
        const n = findNotification(id);
        hidePopup(id);
        if (n) n.dismiss();
    }
    function clear() {
        popups = [];
        server.trackedNotifications.values.slice().forEach(n => n.dismiss());
    }
    onMaxVisibleChanged: popups = maxVisible > 0 ? popups.slice(-maxVisible) : []
    Connections {
        target: ControlState
        function onDndChanged() { if (ControlState.dnd) hub.popups = []; }
    }
    Component.onCompleted: ControlState.notificationHub = hub
    Component.onDestruction: if (ControlState.notificationHub === hub) ControlState.notificationHub = null

    NotificationServer {
        id: server
        actionsSupported: true
        persistenceSupported: true
        bodyMarkupSupported: false
        onNotification: n => {
            n.tracked = true;
            // Transient messages can appear as toasts but should not persist.
            if (!n.lastGeneration) hub.showPopup(n);
            const entries = server.trackedNotifications.values;
            if (entries.length > hub.historyLimit)
                entries.slice(0, entries.length - hub.historyLimit).forEach(old => old.dismiss());
        }
    }
    Timer {
        interval: 200
        repeat: true
        running: hub.popups.some(p => p.expires > 0)
        onTriggered: {
            const now = Date.now();
            if (hub.popups.some(p => !p.paused && p.expires > 0 && p.expires <= now))
                hub.popups = hub.popups.filter(p => p.paused || p.expires === 0 || p.expires > now);
        }
    }
    Instantiator {
        model: server.trackedNotifications
        delegate: QtObject {
            required property var modelData
            readonly property int notificationId: modelData.id
            // Remove stale toast references when apps close their own messages.
            property Connections closeConnection: Connections {
                target: modelData
                function onClosed(reason) { hub.hidePopup(notificationId); }
            }
            property Timer expiry: Timer {
                interval: Math.max(1000, modelData.expireTimeout > 0 ? modelData.expireTimeout * 1000 : 5000)
                running: modelData.transient
                onTriggered: modelData.expire()
            }
        }
    }
}
