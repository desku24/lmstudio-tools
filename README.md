# lmstudio-tools

> **[Deutsche Version / German version](README_de.md)**

Two small shell scripts that make working with [LM Studio](https://lmstudio.ai) on Linux a lot more convenient.

LM Studio is a fantastic app — actively developed, frequent updates, access to nearly every LLM on Hugging Face, MCP support, and great for both local inference and as an API backend. The only downside on Linux: there's no update workflow. You download the AppImage, make it executable, move it to the right place, clean up the old one — all manually.

LM Studio provides a static download URL. `lmstudio-tools` builds the entire workflow around it: download, make executable, set up a symlink, clean up old versions, and optionally automate via cron.

**The result:** `lmstudio-update` + `lmstudio-latest` — set it up once, and LM Studio on Linux updates itself just like on macOS or Windows.

![lmstudio-update --check](assets/check-demo.gif)

---

## Background

### Why this project?

The topic of easier update handling for LM Studio on Linux keeps coming up:

- [#376 — Add easier updates for LMStudio's AppImage](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/376)
- [#757 — GH repo/static URL to update AppImage automatically](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/757)
- [#89 — Make AppImage auto updatable](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/89)
- [#1381 — Include update info in the AppImage](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/1381)
- [Updating LM Studio — Linux Mint Forum](https://forums.linuxmint.com/viewtopic.php?t=463498)

Issues #89 and #1381 propose that LM Studio adopt the official AppImage update infrastructure (zsync URLs, .zsync files). That would allow GUI tools like Gear Lever or AppImageUpdate to handle updates automatically. It would be a clean solution — but it's not available yet.

`lmstudio-tools` takes a different approach: simple Bash scripts that run directly in the terminal with zero extra dependencies — no zsync, no AppImageUpdate, no libraries. Three commands is all it takes to get set up. Add a cron job, and everything runs on autopilot from there.

### How this project came about

Most of this project was built with AI assistance — the code is developed using Codex and Claude Code. I've been using Ollama and LM Studio for years and have tested dozens of LLMs locally. That knowledge was the foundation. AI accelerated the implementation enormously, but without understanding what these scripts need to do and how LM Studio behaves on Linux, nothing useful would have come out of it. I know what I need, the AI helps me build it.

### Adaptable to other apps

Only three things in the scripts are specific to LM Studio:

- **Download URL** — LM Studio's own release infrastructure
- **Filename pattern** — `LM-Studio-{version}-x64.AppImage`
- **Desktop metadata** — `Name=LM Studio`, `StartupWMClass=lmstudio`, `Icon=lmstudio`

Everything else — download logic, temp file handling, `--keep`, symlink, `.desktop`, cron, FUSE fallback, log redirection — is 100% generic. To adapt this for another AppImage-based app, you only need to change those three things.

---

## What's included?

| Script | Purpose |
|---|---|
| `lmstudio-update` | Downloads the latest LM Studio version, makes it executable, and cleans up old versions. Supports `--check` (just check for updates), `--symlink` (stable launch path), `--desktop` (app menu entry), `--keep N` (version history), and `--yes` (unattended mode, e.g. via cron). Detects whether LM Studio is currently running and warns accordingly. |
| `lmstudio-latest` | Always launches the newest installed AppImage — regardless of its filename. Automatically finds the most recent version by modification date, sets missing executable bits, and redirects output to a log file (`~/.cache/lmstudio-latest.log`) when launched from the app menu. Includes a FUSE fallback for systems without FUSE support. |
| `install.sh` | Installs both scripts to `~/.local/bin` and makes them executable. Use `--remove` to cleanly uninstall. |

---

## Quick start

```bash
# 1. Clone the repository
git clone https://github.com/desku24/lmstudio-tools.git
cd lmstudio-tools

# 2. Install
bash install.sh

# 3. Download LM Studio
lmstudio-update --symlink --desktop

# 4. Launch LM Studio
lmstudio-latest
```

After step 3, LM Studio shows up in your desktop environment's app menu like any native app — no folder hunting, no terminal required. `--symlink` keeps the launch command the same after every update; `--desktop` creates the menu entry.

**That's essentially all there is to it.** Set up a cron job (see [Automatic updates via cron](#automatic-updates-via-cron)) and you're done — from that point on, you just launch LM Studio from your app menu or sidebar and always get the latest version. No manual downloads, no terminal, no maintenance. The GIF above shows it in action — `--check` confirms the latest version is already installed, picked up automatically by the cron job overnight.

---

## lmstudio-update

### Usage

```bash
lmstudio-update [OPTIONS]
```

### Options

| Option | Description | Default |
|---|---|---|
| `--format appimage\|deb` | Download format | `appimage` |
| `--arch x64\|arm64` | CPU architecture | auto-detected |
| `--keep N` | Number of most recent files to keep | `1` |
| `--check` | Only check if an update is available | — |
| `--symlink` | Create stable symlink `~/Apps/lmstudio/lmstudio-latest` | — |
| `--desktop` | Create `.desktop` launcher in the app menu | — |
| `--no-sandbox` | Add `--no-sandbox` to the `.desktop` Exec line | — |
| `--yes` | No confirmation prompt, run immediately | — |
| `-h, --help` | Show help | — |

### Environment variables

| Variable | Description | Default |
|---|---|---|
| `LMSTUDIO_DIR` | Override the AppImage install directory | `~/Apps/lmstudio` |

### Examples

```bash
# Interactive update (asks for confirmation)
lmstudio-update

# Silent update without prompt
lmstudio-update --yes

# Update + create app menu launcher
lmstudio-update --yes --symlink --desktop

# Only check if a new version is available
lmstudio-update --check

# Keep the two most recent AppImages instead of just one
lmstudio-update --keep 2

# Download .deb (without installing)
lmstudio-update --format deb --yes

# Download ARM64 version
lmstudio-update --arch arm64 --yes
```

### Behavior when LM Studio is running

If LM Studio is currently running, `lmstudio-update` will detect it and warn you before downloading. In interactive mode you'll be asked to confirm. With `--yes` (e.g. via cron), the update proceeds with a warning — this is perfectly fine in practice, since the update only downloads the new file while the running instance keeps using the old one. The next time you launch LM Studio, it picks up the new version.

### Automatic updates via cron

**Recommendation: run manually first!**

Before setting up the cron job, run the script once in your terminal. That way you can immediately see if everything works:

```bash
lmstudio-update --yes --symlink
```

Once the manual run succeeds, you can switch to full automation. Use the **full path** to the script in your cron entry, since cron typically doesn't include `~/.local/bin` in its PATH:

```bash
# Open cron editor
crontab -e
```

Add the following line (example: daily at 8:00 PM):

```
0 20 * * * $HOME/.local/bin/lmstudio-update --yes --symlink >> $HOME/.local/share/lmstudio-update.log 2>&1
```

> **Tip:** Pick a time when your machine is reliably powered on. Most laptops don't run 24/7 — a cron job at 3 AM is useless if your laptop is asleep. Evenings after work or during your usual working hours tend to work best.

From there, everything runs on its own. The script only downloads when a new version is actually available — on all other days it exits immediately, using no unnecessary bandwidth or resources.

This works great in practice: the cron job on my machine picked up the update from 0.4.8 to 0.4.9 completely on its own — while LM Studio was running, without me even noticing. Next time I launched it, the new version was just there.

---

## lmstudio-latest

Always launches the newest AppImage in `~/Apps/lmstudio` — regardless of its filename.

```bash
lmstudio-latest
```

Any additional arguments are passed directly to LM Studio:

```bash
lmstudio-latest --no-sandbox
```

**What the script does in the background:**
- Automatically finds the newest AppImage by modification date
- Sets the executable bit if it's missing
- Redirects all output to `~/.cache/lmstudio-latest.log` when no terminal is present (launched from app menu) — useful for debugging
- Sets `APPIMAGE_EXTRACT_AND_RUN=1` as a fallback on systems without FUSE

### Note on --no-sandbox

LM Studio is based on Electron/Chromium. On some Linux systems (particularly those that restrict user namespaces), it may fail to start without the `--no-sandbox` flag. If LM Studio doesn't open:

```bash
lmstudio-latest --no-sandbox
```

If that fixes it, add the flag permanently to your app menu entry:

```bash
lmstudio-update --desktop --symlink --no-sandbox
```

For a locally trusted application this flag is generally safe. It is intentionally **not** set by default.

---

## Installation

### Automatic (recommended)

```bash
bash install.sh
```

Uninstall:

```bash
bash install.sh --remove
```

### Manual

```bash
cp lmstudio-update lmstudio-latest ~/.local/bin/
chmod +x ~/.local/bin/lmstudio-update ~/.local/bin/lmstudio-latest
```

### Check PATH

If the commands aren't found after installation, add `~/.local/bin` to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Directory structure

After first use, it looks like this:

```
~/
├── .local/
│   ├── bin/
│   │   ├── lmstudio-update       <- update script
│   │   └── lmstudio-latest       <- launcher script
│   └── share/
│       └── applications/
│           └── lmstudio.desktop  <- app menu entry (with --desktop)
└── Apps/
    └── lmstudio/
        ├── LM-Studio-0.x.x-x64.AppImage   <- downloaded AppImage
        └── lmstudio-latest -> ...          <- symlink (with --symlink)
```

LM Studio settings and chat history are stored separately and are not affected by updates:

```
~/.config/LM Studio/
~/.lmstudio/
```

---

## Requirements

- Linux (x64 or arm64)
- bash >= 4.0
- `curl` — for downloading
- `find`, `awk`, `sort` — pre-installed on all common distributions

---

## Tested on

- Ubuntu 22.04 / 24.04
- Linux Mint 21+

---

## Disclaimer

This is an **unofficial community project** and is **not affiliated with, endorsed by, or associated with LM Studio or LM Studio AI** in any way. "LM Studio" is a trademark of its respective owner.

This tool does not redistribute LM Studio. It downloads directly from the official public URLs provided by LM Studio (`lmstudio.ai`). No reverse engineering, modification, or circumvention of any kind is performed.

---

## License

MIT — free to use, modify, and redistribute.
