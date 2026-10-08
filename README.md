# omarchy-messages

iPhone texts (SMS + iMessage) on Omarchy / Arch Linux, over Bluetooth. No Mac relay. No cloud. No subscription.

This repo installs upstream [iphonebridge](https://github.com/gabrielmeir53/iphonebridge) (`v0.5.0`, GPL-2.0-or-later) plus a **Messages** launcher that opens straight to the Messages tab — the same setup this was built from.

## Requirements

- Omarchy / Arch / CachyOS, BlueZ 5.72+
- Python 3.10+
- iPhone iOS 16.5+
- Intel Bluetooth for per-app notifications (ANCS); SMS/iMessage works on any adapter

## Install

```bash
git clone https://github.com/<you>/omarchy-messages.git
cd omarchy-messages
./install.sh
```

Then pair and configure:

```bash
iphonebridge pair-setup
systemctl --user restart iphonebridge
```

On the iPhone: **Settings → Bluetooth → ⓘ next to your computer** → enable:

- Show Message Notifications (SMS/iMessage)
- Sync Contacts (names instead of numbers)
- Show System Notifications (per-app notifications)

Launch:

```bash
messages
# or
iphonebridge-ui --messages
```

## Usage

- `messages` — open Messages tab
- `iphonebridge sms-list -n 20` — recent messages
- `iphonebridge sms-send "<name-or-number>" "text"` — send SMS/iMessage
- `iphonebridge doctor` — health check
- `journalctl --user -u iphonebridge -f` — live daemon log

## What this repo does NOT contain

No names, no phone numbers, no Bluetooth MACs, no message history, no `local.env`. Pairing state stays on your machine under `~/.config/iphonebridge/` and is never committed (see `.gitignore`).

## Layout

```text
omarchy-messages/
├── install.sh            # one-shot Arch/Omarchy installer (idempotent)
├── assets/               # shipped verbatim: wrapper, .desktop, user service
├── docs/
│   └── TROUBLESHOOTING.md
├── README.md
├── LICENSE
└── .gitignore            # blocks local.env, history, contacts DBs
```

## Troubleshooting

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md).

## Credits / License

- Core bridge: [gabrielmeir53/iphonebridge](https://github.com/gabrielmeir53/iphonebridge), GPL-2.0-or-later
- Wrapper/installer in this repo: GPL-2.0-or-later (see [LICENSE](LICENSE))
