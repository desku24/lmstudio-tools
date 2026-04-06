# lmstudio-tools

Small shell scripts for a simpler **LM Studio AppImage workflow on Linux**.

`lmstudio-tools` helps make LM Studio easier to manage:
- download new versions
- make them executable
- clean up older versions
- optionally create a symlink
- optionally create a `.desktop` launcher
- optionally automate updates via cron

## Why this project?

Easier update handling for the LM Studio AppImage on Linux has been requested by users for quite some time.  
As long as there is no official integrated solution for that, `lmstudio-tools` handles the practical part: downloading, cleanup, and optionally creating a symlink and desktop launcher.

## Included scripts

| Script | Purpose |
|---|---|
| `lmstudio-update` | Downloads the latest LM Studio AppImage version and cleans up older versions. |
| `lmstudio-latest` | Launches the newest installed AppImage. |
| `install.sh` | Installs the scripts into `~/.local/bin`. |

## Quick Start

```bash
git clone https://github.com/desku24/lmstudio-tools.git
cd lmstudio-tools
bash install.sh
lmstudio-update --symlink --desktop
lmstudio-latest
```

## lmstudio-update

```bash
lmstudio-update [OPTIONS]
```

### Main options

| Option | Description |
|---|---|
| `--check` | Only check whether an update is available |
| `--keep N` | Number of versions to keep |
| `--symlink` | Create symlink `~/Apps/lmstudio/lmstudio-latest` |
| `--desktop` | Create a `.desktop` launcher |
| `--no-sandbox` | Add `--no-sandbox` to the launcher |
| `--yes` | Run without confirmation |

### Examples

```bash
lmstudio-update --check
lmstudio-update --yes
lmstudio-update --yes --symlink --desktop
lmstudio-update --keep 2
```

## Automatic updates via cron

If you want to automate updates, you can run `lmstudio-update` regularly through cron.

Example: every day at 20:00

```cron
0 20 * * * $HOME/.local/bin/lmstudio-update --yes --symlink >> $HOME/.local/share/lmstudio-update.log 2>&1
```

Note: the cron job only runs if the system is powered on at that time.

## lmstudio-latest

```bash
lmstudio-latest
```

Additional arguments are passed directly to LM Studio:

```bash
lmstudio-latest --no-sandbox
```

## Installation

### Automatic

```bash
bash install.sh
```

### Remove

```bash
bash install.sh --remove
```

## Check PATH

If the commands are not found after installation, `~/.local/bin` may need to be added to your PATH:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Requirements

- Linux
- bash >= 4.0
- `curl`
- `find`, `awk`, `sort`

## Tested on

- Ubuntu 22.04 / 24.04
- Linux Mint 21+

## Note

This is an **unofficial community project** and is not affiliated with **LM Studio** or **LM Studio AI**.

The tool downloads directly from the official public URLs at `lmstudio.ai`.  
There is **no cryptographic verification** of downloads.

## License

MIT
