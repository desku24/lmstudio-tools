# lmstudio-tools 🚀

Two small shell scripts that make working with [LM Studio](https://lmstudio.ai) on Linux a lot more convenient.

LM Studio is a fantastic app — actively developed, regular updates, great for both local inference and as an API backend. The only catch on Linux: updates don't come with a workflow. Download the AppImage, make it executable, move it to the right place, clean up the old one — all done by hand.

LM Studio provides a static download URL for this. `lmstudio-tools` builds the complete workflow around it: download, make executable, set symlink, clean up old versions, optionally automate via cron.

**The result:** `lmstudio-update` + `lmstudio-latest` — LM Studio on Linux, as convenient as on macOS or Windows.

---

## Background

This project was born out of a simple goal: update LM Studio automatically, without clicks, and always have the latest version ready. The community has been asking for this — see [#376](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/376) and [#757](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/757) in the LM Studio bug tracker.

Most of this project was built using AI (vibecoding with Claude). This shows two things: first, that anyone can build useful tools like this — you don't need to be a seasoned developer. And second, that AI tools, when used the right way, are powerful and effective enough to produce production-ready software.

### Adaptable to other apps

Only three things in the scripts are LM Studio-specific:

- **Download URL** — LM Studio's own release infrastructure
- **Filename pattern** — `LM-Studio-{version}-x64.AppImage`
- **Desktop metadata** — `Name=LM Studio`, `StartupWMClass=lmstudio`, `Icon=lmstudio`

Everything else — download logic, temp file handling, `--keep`, symlink, `.desktop`, cron, FUSE fallback, log redirection — is 100% generic. If you want to adapt this for another AppImage-based app, you only need to change those three things. That said, this project focuses on LM Studio.

---

## What's included?

| Script | Purpose |
|---|---|
| `lmstudio-update` | Downloads the latest LM Studio version, makes it executable, and cleans up old versions |
| `lmstudio-latest` | Always launches the newest installed AppImage — regardless of its filename |
| `install.sh` | Installs both scripts to `~/.local/bin` |

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

After step 3, LM Studio appears in your desktop environment's app menu like any native app — no folder hunting, no terminal required. `--symlink` ensures the launch command stays the same after every update; `--desktop` creates the menu entry.

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

If LM Studio is currently running, `lmstudio-update` will detect it and warn you before downloading. In interactive mode you will be asked to confirm. With `--yes`, the update proceeds with a warning.

### Automatic updates via cron

**Recommendation: run manually first!**

Before setting up the cron job, run the script once directly in your terminal. This way you can see immediately whether everything works and fix any issues on the spot:

```bash
lmstudio-update --yes --symlink
```

Once the manual run succeeds, you can switch to full automation. Use the **full path** to the script in your cron entry, as cron typically does not include `~/.local/bin` in its PATH:

```bash
# Open cron editor
crontab -e
```

Add the following line (runs daily at 09:00):

```
0 9 * * * $HOME/.local/bin/lmstudio-update --yes --symlink >> $HOME/.local/share/lmstudio-update.log 2>&1
```

From here on, everything runs automatically. The script only downloads when a new version is actually available — on all other days it exits immediately, using no unnecessary bandwidth or resources.

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

LM Studio is based on Electron/Chromium. On some Linux systems (particularly those that restrict user namespaces), it may fail to start without the `--no-sandbox` flag. If LM Studio does not open, try:

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

If the commands are not found after installation, `~/.local/bin` needs to be added to your PATH:

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
│   │   ├── lmstudio-update       ← update script
│   │   └── lmstudio-latest       ← launcher script
│   └── share/
│       └── applications/
│           └── lmstudio.desktop  ← app menu entry (with --desktop)
└── Apps/
    └── lmstudio/
        ├── LM-Studio-0.x.x-x64.AppImage   ← downloaded AppImage
        └── lmstudio-latest -> ...          ← symlink (with --symlink)
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
- Debian 12
- Fedora 39+

---

## Disclaimer

This is an **unofficial community project** and is **not affiliated with, endorsed by, or associated with LM Studio or LM Studio AI** in any way. "LM Studio" is a trademark of its respective owner.

This tool does not redistribute LM Studio. It downloads directly from the official public URLs provided by LM Studio (`lmstudio.ai`). No reverse engineering, modification, or circumvention of any kind is performed.

If the LM Studio team has any concerns about this project, please [open an issue](https://github.com/desku24/lmstudio-tools/issues) — I'm happy to make adjustments.

---

## License

MIT — free to use, modify, and redistribute.
