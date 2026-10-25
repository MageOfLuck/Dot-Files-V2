# Edge Control — Quickshell 0.3.2 / Hyprland

An auto-hidden top strip with native audio, Bluetooth and NetworkManager menus.
Your purple palette and green audio accent are retained. By default no desktop space is
reserved; a dashboard toggle can reserve a fixed bar-height gap. There are no bundled fonts.

## Install and launch

1. Extract the archive. From its extracted parent folder, run:

   ```sh
   bash edge-control/install.sh
   ```

   This copies the configuration into
   `${XDG_CONFIG_HOME:-~/.config}/quickshell/edge-control`. For an existing installation, use `bash edge-control/install.sh --update`
   from the newly extracted copy. This first backs up the installed folder.
   Without `--update` it refuses to overwrite an existing installation and does not edit Hyprland or stop services.

2. Stop Wayle (and any separate notification daemon such as mako, dunst or swaync)
   using your usual launch/service mechanism. Only one process can own the
   desktop notification service. Disable its autostart when switching permanently.

3. Run in a terminal first so any errors remain visible:

   ```sh
   env QT_QUICK_CONTROLS_STYLE=Fusion qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control"
   ```

4. Test a direct menu command in another terminal:

   ```sh
   qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle audio
   ```

5. Merge the desired entries from `hyprland-example.conf` into your own Hyprland
   configuration. Avoid keys you already use. If your Hyprland config uses Lua,
   use the same shell commands in your existing Lua keybinding format; the sample
   `.conf` is not a Lua config. Add the Quickshell launch command to autostart only
   after testing it manually. Do not launch a second copy while the first runs.

Run as your ordinary user inside the Hyprland session, not with sudo.

## Requirements

- Quickshell 0.3.2 with its Hyprland, Wayland, PipeWire, Bluetooth and Networking modules.
- A running PipeWire/WirePlumber session, NetworkManager, BlueZ and D-Bus.
- Python 3 for the read-only dashboard snapshot.
- A working session Polkit agent for network/system actions that require authorization.
- Optional: `blueman-manager` for Bluetooth pairing prompts and
  `nm-connection-editor` for advanced connection profiles.
- Optional: `hyprlock` for the dashboard Lock button; change the command if you use another locker.

Use the pairing/network tools you already have, or install those optional tools
through your normal package manager. Neither is needed for ordinary device
selection, volume control, saved Bluetooth connections or basic Wi-Fi controls.

## Behavior

- Hover within 8 pixels of the top edge for 80 ms to reveal the strip.
  Adjust `edgeHeight` and `revealDelay` in Settings.qml.
- The strip slides in/out over 270 ms. Adjust `animationDuration` if desired.
- When reservation is off, the strip hides after leaving it for 200 ms, unless
  a menu is open. Reservation on keeps the strip visible.
- Bar geometry is fixed; menus use a separate overlay and do not resize it.
- Menus stay open until Escape, the close button, clicking outside, or toggling
  the same menu again. Pinning and hover-dismissal of menus have been removed.
- The outside click is consumed rather than passed to applications underneath.
- Keybinds open menus on the focused Hyprland monitor.
- The normal strip is below fullscreen windows; menus are overlay windows.
- Notifications and output volume OSD use DP-2, with a first-screen fallback.
- Dropdowns, text fields and volume sliders use custom rounded styling.

## Menus and scope

| Feature | Implementation |
| --- | --- |
| Audio | Default output/input selection; device volume and mute; native application icons where supplied; separate volume/mute per playback or recording stream |
| Bluetooth | Adapter selection/power, device-name/address search, scanning, connected-first list, connect/disconnect, battery level when supplied, pair request |
| Network | Adapter selection, Wi-Fi toggle, scanning, connected/saved-first list, signal strength, name search, connect/disconnect, password entry for WPA/WPA2/WPA3 personal networks, confirmed Forget |
| Workspaces | Existing positive-numbered Hyprland workspaces belonging to that screen, per-monitor active indicator, workspace switching |
| Window title | Active Hyprland window title, truncated to fit |
| Media | MPRIS player selection, artwork, track/artist, previous/play/pause/next |
| Clock | Local clock and navigable Monday-first calendar |
| Notifications | Native notification daemon, session history capped at 100, action buttons, dismiss/clear, DND, DP-2 popups |
| Dashboard | Hostname, uptime, memory usage, CPU load averages; lock and confirmed session/power actions |
| OSD | PipeWire output volume/mute changes, including changes from existing hardware keybinds |

### Explicit limitations

- Application sliders represent audio streams, not a grouped application-wide
  master volume. An application with several streams can have several rows.
  Applications without an audio stream do not appear. Sliders are limited to 100%.
- Changing the default audio device follows WirePlumber routing policy. It does
  not implement per-application output routing or sound-card profile switching.
- Bluetooth pairing requests are sent through BlueZ. PIN/passkey confirmation
  requires an existing BlueZ agent; this configuration does not implement one.
  The pairing-manager shortcut is the fallback. Some pairings succeed directly;
  once paired, use Connect to connect the device. Errors from the Bluetooth
  backend may appear in Quickshell's terminal log rather than inline.
- Basic Wi-Fi password entry is native. Enterprise/802.1X, WEP and new hidden
  networks need the connection editor. Saved enterprise profiles may connect
  directly if their credentials/secret agent are available.
- Notification history and DND are session-only; quitting Quickshell clears them.
  Popups stack up to `notificationMaxVisible` (default 3), with hover-paused timeouts and separate open/dismiss controls.
- The dashboard shows CPU load averages, not CPU utilization percentages.
- The default logout command is copied exactly from your Wayle configuration.
  Adjust it if your Hyprland dispatcher syntax changes.
- The strip currently uses readable text buttons; native icons are used for
  application audio rows when available.

## Customize

Edit `Settings.qml` in the installed folder. Quickshell hot reloads the config.

```qml
property bool menusOnly: true    // remove strip; top edge opens Audio directly
property string popupMonitor: "DP-2"
property int revealDelay: 180
property int hideDelay: 650
property string lockCommand: "hyprlock"
```

In menus-only mode, individual keybinds still open their respective panels.
To make access keybind-only, remove the reveal Timer from `ScreenPanel.qml`.

## Commands

```sh
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle audio
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle bluetooth
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle network
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle notifications
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle clock
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle dashboard
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control toggle media
qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control" ipc call control close
```

## Validation and first desktop check

All QML files passed Qt's QML parser/formatter. The seven menu views were rendered
with Qt Quick/Fusion using simulated service data, with no warnings. The original
strip/card layout was also rendered after replacing only compositor-specific
properties for the offscreen harness. The dashboard helper ran successfully.

The build environment has no Quickshell or Hyprland installation, so these are
syntax/layout checks, not a live 0.3.2 integration test. Test on your desktop:

1. Reveal the strip on each monitor; confirm tiled windows do not shift.
2. Play audio in two applications; change each slider and select output/input devices.
3. Scan Bluetooth devices and disconnect/reconnect a saved device.
4. Connect to a personal Wi-Fi network and exercise password retry if needed.
5. Send a test notification, use DND, and change volume to check the DP-2 OSD.
6. Open menus by keybind, dismiss with Escape/outside click, and test over fullscreen.

If startup fails, keep the exact terminal error from `qs -p "${XDG_CONFIG_HOME:-$HOME/.config}/quickshell/edge-control"`.

## API references

- https://quickshell.org/docs/v0.3.2/guide/introduction/
- https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/Pipewire/
- https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Pipewire/PwObjectTracker/
- https://quickshell.org/docs/v0.3.0/types/Quickshell.Bluetooth/BluetoothDevice/
- https://quickshell.org/docs/v0.3.0/types/Quickshell.Networking/WifiNetwork/
- https://quickshell.org/docs/v0.3.0/types/Quickshell.Services.Notifications/NotificationServer/
- https://quickshell.org/docs/v0.3.0/types/Quickshell.Io/IpcHandler/

The 0.3-series API references were checked during development. Patch-version
runtime behavior still needs verification on the target machine.

## Update: typography, monitor workspaces, reserved space

- Menus use Noto Sans instead of inheriting your desktop's Input Mono setting.
  Set `fontFamily` in Settings.qml to another installed sans-serif family if preferred.
- Each strip shows only existing workspaces whose Hyprland monitor name matches
  that strip's screen. Workspaces on other screens are excluded. Empty workspaces
  that do not yet exist in Hyprland are not invented from workspace rules.
- System dashboard → Reserve bar space toggles a fixed 42-pixel gap on all
  monitors. When enabled, the strip stays visible and the gap stays reserved.
  When disabled, the strip resumes auto-hide and windows regain the space. Opening a large menu never reserves additional space.
- The toggle is session-only. Set `reserveSpace: true` in Settings.qml for the
  startup default. Menus-only mode disables reservation.
- IPC alternative: `qs -p "$HOME/.config/quickshell/edge-control" ipc call control toggleReserve`.
- All components, including Alerts, are now explicitly registered in qmldir.
- Launch and keybind examples use direct paths to avoid named-config lookup failures.

The Qt Wayland text-input warnings shown during focus changes are not a failed
configuration load. This update does not suppress them; investigate further if
text entry or keyboard focus actually misbehaves.

## Animation/layout update

The old implementation resized the strip's window to screen height to host a
menu, which could look like a reload. ScreenPanel now remains bar-height, and
MenuPanel owns the menu overlay. Input masking follows the strip's animation.
Menus use stable bounded heights with scrolling so content cannot expand the
strip. Existing bold bar text has been retained.

The separate windows and compositor behavior still need a desktop test; the
menus and strip layout passed offscreen checks with simulated services.

## Menu and notification interaction update (2026-10-22)

See `CHANGES.md` for the details of this refinement. All menu content now uses
consistent section headings, inset cards, spacing, borders, typography and
centered dropdown chevrons. Tabs on the top bar highlight when their menu is open.

Notification popups **no longer disappear without taking an action when clicked**:
clicking a popup or notification-history card invokes the application's
`default` notification action, if it provides one. If no default action exists,
a popup click opens the notification menu so that you can explicitly choose
an action. Notifications without default actions cannot be forced to open an
application; this behavior depends on the sending app. Close/Dismiss buttons
remain separate. Simply hiding a toast does not delete notification history.
Notifications are retained for the session (up to 100) unless dismissed or
expired. Popups pause while hovered.

The media menu additionally includes a track seek slider and elapsed/total time
when the connected MPRIS player supports these capabilities.

This build passed structural checks and JavaScript mock tests for notification
behavior, but was not executed in a full Hyprland/Quickshell session in the build
environment. Test with your installed Quickshell 0.3.2, and revert to the backup
created by `install.sh --update` if there are compositor-specific issues.
