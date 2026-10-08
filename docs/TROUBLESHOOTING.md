# Troubleshooting

## Messages stopped arriving

```bash
systemctl --user restart iphonebridge
journalctl --user -u iphonebridge -f
```

If iOS toggles vanished: forget + re-pair the iPhone, re-run `iphonebridge pair-setup`, restart the daemon.

## `Forbidden` errors in the log

An iPhone toggle is off. Check **Settings → Bluetooth → ⓘ**:

- Show Message Notifications
- Sync Contacts
- Show System Notifications

## ANCS (per-app) notifications never arrive

- Needs Intel Bluetooth; Realtek/USB dongles cannot do the BLE bond.
- One-time: `iphonebridge ancs-enable`, then forget + re-pair. Instructions print in the terminal.

## Calls don't connect / no audio

```bash
iphonebridge hfp-enable
sudo systemctl restart ofono
# reconnect iPhone, then:
systemctl --user restart iphonebridge
```

oFono must start *after* WirePlumber or HFP registration fails.

## Verification codes aren't auto-copied

`wl-clipboard` is installed by `install.sh` (Wayland). On X11 install `xclip`.

## `iphonebridge: command not found`

Re-run `./install.sh`, then ensure `~/.local/bin` is on PATH:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

## Start over (pairing only, keeps app)

```bash
systemctl --user stop iphonebridge
rm ~/.config/iphonebridge/local.env
iphonebridge pair-setup
systemctl --user restart iphonebridge
```
