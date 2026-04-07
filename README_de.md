# lmstudio-tools

> **[English version](README.md)**

Kleine Shell-Skripte für einen einfacheren **LM-Studio-AppImage-Workflow unter Linux**.

![lmstudio-update --check](assets/check-demo.gif)

`lmstudio-tools` hilft dabei, LM Studio schneller und sauberer zu nutzen:
- neue Version herunterladen
- ausführbar machen
- alte Versionen aufräumen
- optional Symlink erstellen
- optional `.desktop`-Eintrag anlegen
- optional Updates per Cron automatisieren

## Warum dieses Projekt?

Einfacheres Update-Handling für das LM-Studio-AppImage unter Linux wird von Nutzern schon länger gewünscht.  
Solange es dafür keine offizielle, integrierte Lösung gibt, übernimmt `lmstudio-tools` den praktischen Teil: herunterladen, aufräumen und optional Symlink sowie Desktop-Eintrag anlegen.

## Enthaltene Skripte

| Skript | Zweck |
|---|---|
| `lmstudio-update` | Lädt die neueste LM-Studio-AppImage-Version herunter und räumt alte Versionen auf. |
| `lmstudio-latest` | Startet immer das neueste installierte AppImage. |
| `install.sh` | Installiert die Skripte nach `~/.local/bin`. |

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
lmstudio-update [OPTIONEN]
```

### Wichtige Optionen

| Option | Beschreibung |
|---|---|
| `--check` | Nur prüfen, ob ein Update verfügbar ist |
| `--keep N` | Anzahl der Versionen, die behalten werden |
| `--symlink` | Symlink `~/Apps/lmstudio/lmstudio-latest` erstellen |
| `--desktop` | `.desktop`-Launcher erstellen |
| `--no-sandbox` | `--no-sandbox` in den Launcher einfügen |
| `--yes` | Ohne Rückfrage ausführen |

### Beispiele

```bash
lmstudio-update --check
lmstudio-update --yes
lmstudio-update --yes --symlink --desktop
lmstudio-update --keep 2
```

## Automatische Updates per Cron

Wer Updates automatisieren möchte, kann `lmstudio-update` per Cron regelmäßig ausführen lassen.

Beispiel: täglich um 20:00 Uhr

```cron
0 20 * * * $HOME/.local/bin/lmstudio-update --yes --symlink >> $HOME/.local/share/lmstudio-update.log 2>&1
```

Hinweis: Der Cron-Job läuft nur, wenn das System zu diesem Zeitpunkt eingeschaltet ist.

## lmstudio-latest

```bash
lmstudio-latest
```

Zusätzliche Argumente werden direkt an LM Studio weitergereicht:

```bash
lmstudio-latest --no-sandbox
```

## Installation

### Automatisch

```bash
bash install.sh
```

### Entfernen

```bash
bash install.sh --remove
```

## PATH prüfen

Falls die Befehle nach der Installation nicht gefunden werden, muss `~/.local/bin` zum PATH hinzugefügt werden:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Voraussetzungen

- Linux (x86_64)
- bash >= 4.0
- `curl`
- `find`, `awk`, `sort`
- `libfuse2t64` (für AppImages — installieren mit `sudo apt install libfuse2t64`)

## Getestet auf

- Ubuntu 22.04 / 24.04
- Linux Mint 21+

## Hinweis

Dies ist ein **inoffizielles Community-Projekt** und steht in keiner Verbindung zu **LM Studio** oder **LM Studio AI**.

Das Tool lädt direkt von den offiziellen öffentlichen URLs von `lmstudio.ai`.  
Es findet **keine kryptografische Verifikation** des Downloads statt.

## Lizenz

MIT
