# lmstudio-tools

> **[English version / Englische Version](README.md)**

Zwei kleine Shell-Skripte, die die Arbeit mit [LM Studio](https://lmstudio.ai) unter Linux deutlich komfortabler machen.

LM Studio ist eine fantastische App — aktiv entwickelt, regelmäßige Updates, Zugriff auf fast alle LLMs auf Hugging Face, unterstützt MCP und ist sowohl für lokale Inferenz als auch als API-Backend geeignet. Der einzige Haken unter Linux: Updates kommen ohne Workflow. AppImage herunterladen, ausführbar machen, an den richtigen Ort verschieben, die alte Version aufräumen — alles von Hand.

LM Studio bietet eine statische Download-URL. `lmstudio-tools` baut den kompletten Workflow darum: herunterladen, ausführbar machen, Symlink setzen, alte Versionen aufräumen, optional per Cron automatisieren.

**Das Ergebnis:** `lmstudio-update` + `lmstudio-latest` — einmal einrichten, und LM Studio unter Linux aktualisiert sich genauso automatisch wie unter macOS oder Windows.

![lmstudio-update --check](assets/check-demo.gif)

---

## Background

### Warum dieses Projekt?

Das Thema "einfacheres Update-Handling für LM Studio unter Linux" taucht immer wieder auf:

- [#376 — Add easier updates for LMStudio's AppImage](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/376)
- [#757 — GH repo/static URL to update AppImage automatically](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/757)
- [#89 — Make AppImage auto updatable](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/89)
- [#1381 — Include update info in the AppImage](https://github.com/lmstudio-ai/lmstudio-bug-tracker/issues/1381)
- [Updating LM Studio — Linux Mint Forum](https://forums.linuxmint.com/viewtopic.php?t=463498)

Die Issues #89 und #1381 schlagen vor, dass LM Studio die offizielle AppImage-Update-Infrastruktur nutzt (zsync-URLs, .zsync-Dateien). Damit könnten GUI-Tools wie Gear Lever oder AppImageUpdate Updates automatisch übernehmen. Das wäre eine saubere Lösung — ist aber aktuell nicht verfügbar.

`lmstudio-tools` löst das Problem auf einem anderen Weg: einfache Bash-Skripte, die direkt im Terminal laufen und keine zusätzlichen Abhängigkeiten brauchen — kein zsync, kein AppImageUpdate, keine Bibliotheken. Drei Befehle reichen für die komplette Einrichtung. Und mit einem Cron-Job läuft danach alles vollautomatisch.

### Wie dieses Projekt entstanden ist

Der größte Teil dieses Projekts wurde mit KI-Unterstützung gebaut — der Code entsteht mit Codex und Claude Code. Ich nutze Ollama und LM Studio seit Jahren und habe dutzende LLMs lokal getestet. Dieses Wissen war die Grundlage. Die KI hat die Umsetzung massiv beschleunigt, aber ohne ein Verständnis dafür, was die Skripte leisten sollen und wie sich LM Studio unter Linux verhält, wäre nichts Brauchbares entstanden. Ich weiß was ich brauche, die KI hilft mir es umzusetzen.

### Adaptable to other apps

Nur drei Dinge in den Skripten sind LM-Studio-spezifisch:

- **Download-URL** — LM Studios eigene Release-Infrastruktur
- **Dateinamens-Muster** — `LM-Studio-{version}-x64.AppImage`
- **Desktop-Metadaten** — `Name=LM Studio`, `StartupWMClass=lmstudio`, `Icon=lmstudio`

Alles andere — Download-Logik, Temp-File-Handling, `--keep`, Symlink, `.desktop`, Cron, FUSE-Fallback, Log-Umleitung — ist 100% generisch. Wer das für eine andere AppImage-basierte App anpassen will, muss nur diese drei Dinge ändern.

---

## What's included?

| Script | Zweck |
|---|---|
| `lmstudio-update` | Lädt die neueste LM-Studio-Version herunter, macht sie ausführbar und räumt alte Versionen auf. Unterstützt `--check` (nur prüfen), `--symlink` (stabiler Startpfad), `--desktop` (App-Menü-Eintrag), `--keep N` (Versionshistorie) und `--yes` (unbeaufsichtigt, z.B. via Cron). Erkennt ob LM Studio gerade läuft und warnt entsprechend. |
| `lmstudio-latest` | Startet immer das neueste installierte AppImage — egal wie die Datei heißt. Findet automatisch die aktuellste Version nach Änderungsdatum, setzt fehlende Executable-Bits und leitet Ausgaben bei Start über das App-Menü automatisch ins Log (`~/.cache/lmstudio-latest.log`). Enthält FUSE-Fallback für Systeme ohne FUSE-Support. |
| `install.sh` | Installiert beide Skripte nach `~/.local/bin` und macht sie ausführbar. Mit `--remove` wieder sauber deinstallieren. |

---

## Quick start

```bash
# 1. Repository klonen
git clone https://github.com/desku24/lmstudio-tools.git
cd lmstudio-tools

# 2. Installieren
bash install.sh

# 3. LM Studio herunterladen
lmstudio-update --symlink --desktop

# 4. LM Studio starten
lmstudio-latest
```

Nach Schritt 3 erscheint LM Studio im App-Menü deiner Desktop-Umgebung wie jede native App — kein Ordner-Suchen, kein Terminal nötig. `--symlink` sorgt dafür, dass der Startbefehl nach jedem Update gleich bleibt; `--desktop` erstellt den Menüeintrag.

**Das war's im Grunde.** Richte einen Cron-Job ein (siehe [Automatische Updates per Cron](#automatische-updates-per-cron)) und ab dann startest du LM Studio einfach über das App-Menü oder die Seitenleiste — immer die neueste Version, ohne manuellen Download, ohne Terminal, ohne Aufwand. Das GIF oben zeigt es in Aktion — `--check` bestätigt, dass die neueste Version bereits installiert ist, automatisch vom Cron-Job über Nacht geholt.

---

## lmstudio-update

### Usage

```bash
lmstudio-update [OPTIONS]
```

### Options

| Option | Beschreibung | Standard |
|---|---|---|
| `--format appimage\|deb` | Download-Format | `appimage` |
| `--arch x64\|arm64` | CPU-Architektur | automatisch erkannt |
| `--keep N` | Anzahl der neuesten Dateien, die behalten werden | `1` |
| `--check` | Nur prüfen, ob ein Update verfügbar ist | — |
| `--symlink` | Stabilen Symlink `~/Apps/lmstudio/lmstudio-latest` erstellen | — |
| `--desktop` | `.desktop`-Launcher im App-Menü erstellen | — |
| `--no-sandbox` | `--no-sandbox` in die `.desktop` Exec-Zeile einfügen | — |
| `--yes` | Keine Bestätigungsabfrage, sofort ausführen | — |
| `-h, --help` | Hilfe anzeigen | — |

### Environment variables

| Variable | Beschreibung | Standard |
|---|---|---|
| `LMSTUDIO_DIR` | AppImage-Installationsverzeichnis überschreiben | `~/Apps/lmstudio` |

### Examples

```bash
# Interaktives Update (fragt nach Bestätigung)
lmstudio-update

# Stilles Update ohne Rückfrage
lmstudio-update --yes

# Update + App-Menü-Launcher erstellen
lmstudio-update --yes --symlink --desktop

# Nur prüfen, ob eine neue Version verfügbar ist
lmstudio-update --check

# Die zwei neuesten AppImages behalten statt nur eins
lmstudio-update --keep 2

# .deb herunterladen (ohne Installation)
lmstudio-update --format deb --yes

# ARM64-Version herunterladen
lmstudio-update --arch arm64 --yes
```

### Verhalten wenn LM Studio läuft

Wenn LM Studio gerade läuft, erkennt `lmstudio-update` das und warnt vor dem Download. Im interaktiven Modus wirst du gefragt, ob du fortfahren willst. Mit `--yes` (z.B. via Cron) läuft das Update mit einer Warnung weiter — das ist in der Praxis unproblematisch, da das Update nur die neue Datei herunterlädt und die alte erst beim nächsten Start ersetzt wird. Die laufende Instanz ist davon nicht betroffen.

### Automatische Updates per Cron

**Empfehlung: zuerst manuell ausführen!**

Bevor du den Cron-Job einrichtest, führe das Skript einmal direkt im Terminal aus. So siehst du sofort, ob alles funktioniert:

```bash
lmstudio-update --yes --symlink
```

Sobald der manuelle Lauf erfolgreich war, kannst du auf volle Automatisierung umstellen. Verwende den **vollständigen Pfad** zum Skript, da Cron `~/.local/bin` normalerweise nicht im PATH hat:

```bash
# Cron-Editor öffnen
crontab -e
```

Folgende Zeile hinzufügen (Beispiel: täglich um 20:00 Uhr):

```
0 20 * * * $HOME/.local/bin/lmstudio-update --yes --symlink >> $HOME/.local/share/lmstudio-update.log 2>&1
```

> **Tipp:** Wähle eine Uhrzeit, zu der dein Rechner sicher eingeschaltet ist. Die meisten Notebooks laufen nicht 24/7 — ein Cron-Job um 3:00 Uhr nachts bringt nichts, wenn der Laptop im Standby ist. Abends nach Feierabend oder während der üblichen Arbeitszeit funktioniert in der Regel am besten.

Von da an läuft alles automatisch. Das Skript lädt nur herunter, wenn tatsächlich eine neue Version verfügbar ist — an allen anderen Tagen beendet es sich sofort, ohne unnötige Bandbreite oder Ressourcen zu verbrauchen.

In der Praxis funktioniert das hervorragend: Der Cron-Job auf meinem Rechner hat das Update von 0.4.8 auf 0.4.9 vollautomatisch heruntergeladen — während LM Studio lief und ohne dass ich es bemerkt habe. Beim nächsten Start war die neue Version einfach da.

---

## lmstudio-latest

Startet immer das neueste AppImage in `~/Apps/lmstudio` — egal wie die Datei heißt.

```bash
lmstudio-latest
```

Zusätzliche Argumente werden direkt an LM Studio weitergereicht:

```bash
lmstudio-latest --no-sandbox
```

**Was das Skript im Hintergrund macht:**
- Findet automatisch das neueste AppImage nach Änderungsdatum
- Setzt das Executable-Bit, falls es fehlt
- Leitet alle Ausgaben nach `~/.cache/lmstudio-latest.log` um, wenn kein Terminal vorhanden ist (Start über App-Menü) — nützlich für Debugging
- Setzt `APPIMAGE_EXTRACT_AND_RUN=1` als Fallback auf Systemen ohne FUSE

### Hinweis zu --no-sandbox

LM Studio basiert auf Electron/Chromium. Auf manchen Linux-Systemen (besonders solchen, die User-Namespaces einschränken) startet es ohne `--no-sandbox` nicht. Falls LM Studio sich nicht öffnet:

```bash
lmstudio-latest --no-sandbox
```

Wenn das hilft, kannst du das Flag permanent in den Menüeintrag aufnehmen:

```bash
lmstudio-update --desktop --symlink --no-sandbox
```

Für eine lokal vertrauenswürdige Anwendung ist dieses Flag generell unbedenklich. Es wird absichtlich **nicht** standardmäßig gesetzt.

---

## Installation

### Automatisch (empfohlen)

```bash
bash install.sh
```

Deinstallation:

```bash
bash install.sh --remove
```

### Manuell

```bash
cp lmstudio-update lmstudio-latest ~/.local/bin/
chmod +x ~/.local/bin/lmstudio-update ~/.local/bin/lmstudio-latest
```

### PATH prüfen

Falls die Befehle nach der Installation nicht gefunden werden, muss `~/.local/bin` zum PATH hinzugefügt werden:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

---

## Directory structure

Nach der ersten Nutzung sieht es so aus:

```
~/
├── .local/
│   ├── bin/
│   │   ├── lmstudio-update       <- Update-Skript
│   │   └── lmstudio-latest       <- Launcher-Skript
│   └── share/
│       └── applications/
│           └── lmstudio.desktop  <- App-Menü-Eintrag (mit --desktop)
└── Apps/
    └── lmstudio/
        ├── LM-Studio-0.x.x-x64.AppImage   <- heruntergeladenes AppImage
        └── lmstudio-latest -> ...          <- Symlink (mit --symlink)
```

LM-Studio-Einstellungen und Chat-Verlauf werden separat gespeichert und sind von Updates nicht betroffen:

```
~/.config/LM Studio/
~/.lmstudio/
```

---

## Requirements

- Linux (x64 oder arm64)
- bash >= 4.0
- `curl` — für den Download
- `find`, `awk`, `sort` — auf allen gängigen Distributionen vorinstalliert

---

## Tested on

- Ubuntu 22.04 / 24.04
- Linux Mint 21+

---

## Disclaimer

Dies ist ein **inoffizielles Community-Projekt** und steht in **keiner Verbindung zu LM Studio oder LM Studio AI** — weder unterstützt, noch beauftragt, noch genehmigt. "LM Studio" ist eine Marke des jeweiligen Inhabers.

Dieses Tool verteilt LM Studio nicht weiter. Es lädt direkt von den offiziellen öffentlichen URLs herunter, die LM Studio bereitstellt (`lmstudio.ai`). Es findet kein Reverse Engineering, keine Modifikation und keine Umgehung jeglicher Art statt.

---

## License

MIT — frei nutzbar, veränderbar und weiterverteilbar.
