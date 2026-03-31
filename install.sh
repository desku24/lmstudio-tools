#!/usr/bin/env bash
# =============================================================================
# install.sh — Installs lmstudio-tools (lmstudio-update + lmstudio-latest)
# =============================================================================
#
# USAGE
#   bash install.sh          # Interactive installation
#   bash install.sh --yes    # Install without prompts
#   bash install.sh --remove # Uninstall tools
#
# WHAT THIS SCRIPT DOES
#   1. Creates ~/.local/bin if it doesn't exist
#   2. Copies lmstudio-update and lmstudio-latest there
#   3. Sets the executable bit on both scripts
#   4. Checks whether ~/.local/bin is in PATH and shows a hint if not
#
# =============================================================================

set -euo pipefail

readonly INSTALL_DIR="${HOME}/.local/bin"
readonly SCRIPTS=("lmstudio-update" "lmstudio-latest")
readonly LOG="[install]"

# Colors (disabled when no terminal is present)
if [[ -t 1 ]]; then
  GREEN="\033[0;32m"
  YELLOW="\033[0;33m"
  RED="\033[0;31m"
  BOLD="\033[1m"
  RESET="\033[0m"
else
  GREEN="" YELLOW="" RED="" BOLD="" RESET=""
fi

log()   { echo -e "${LOG} $*"; }
ok()    { echo -e "${GREEN}✔${RESET} $*"; }
info()  { echo -e "${YELLOW}→${RESET} $*"; }
error() { echo -e "${RED}✘ ERROR:${RESET} $*" >&2; }

# -----------------------------------------------------------------------------
# Arguments
# -----------------------------------------------------------------------------
SKIP_PROMPT=0
UNINSTALL=0

for arg in "$@"; do
  case "$arg" in
    --yes)    SKIP_PROMPT=1 ;;
    --remove) UNINSTALL=1 ;;
    -h|--help)
      echo "Usage: bash install.sh [--yes] [--remove]"
      exit 0
      ;;
    *)
      error "Unknown parameter: $arg"
      exit 1
      ;;
  esac
done

# -----------------------------------------------------------------------------
# Uninstall
# -----------------------------------------------------------------------------
if [[ "$UNINSTALL" -eq 1 ]]; then
  echo
  echo -e "${BOLD}Uninstalling lmstudio-tools${RESET}"
  echo

  removed=0
  for script in "${SCRIPTS[@]}"; do
    target="${INSTALL_DIR}/${script}"
    if [[ -f "$target" ]]; then
      rm -f "$target"
      ok "Removed: $target"
      removed=$((removed + 1))
    else
      info "Not found (skipped): $target"
    fi
  done

  echo
  if [[ "$removed" -gt 0 ]]; then
    ok "Uninstall complete."
  else
    info "Nothing to remove."
  fi
  exit 0
fi

# -----------------------------------------------------------------------------
# Check that the script files exist in the current directory
# -----------------------------------------------------------------------------
echo
echo -e "${BOLD}Installing lmstudio-tools${RESET}"
echo

missing=0
for script in "${SCRIPTS[@]}"; do
  if [[ ! -f "./${script}" ]]; then
    error "Script not found: ./${script}"
    missing=$((missing + 1))
  fi
done

if [[ "$missing" -gt 0 ]]; then
  echo
  error "Please run install.sh from the lmstudio-tools directory."
  exit 1
fi

# -----------------------------------------------------------------------------
# Show installation plan
# -----------------------------------------------------------------------------
echo "  Install to : $INSTALL_DIR"
for script in "${SCRIPTS[@]}"; do
  echo "  Script     : $script"
done
echo

# -----------------------------------------------------------------------------
# Confirmation prompt
# -----------------------------------------------------------------------------
if [[ "$SKIP_PROMPT" -ne 1 ]]; then
  read -r -p "Start installation? [y/N] " answer
  case "$answer" in
    y|Y|yes|YES) ;;
    *) log "Aborted."; exit 0 ;;
  esac
  echo
fi

# -----------------------------------------------------------------------------
# Install
# -----------------------------------------------------------------------------
mkdir -p "$INSTALL_DIR"

for script in "${SCRIPTS[@]}"; do
  target="${INSTALL_DIR}/${script}"
  cp "./${script}" "$target"
  chmod +x "$target"
  ok "Installed: $target"
done

# -----------------------------------------------------------------------------
# PATH check: verify whether ~/.local/bin is already in PATH
# -----------------------------------------------------------------------------
echo
if echo "$PATH" | tr ':' '\n' | grep -qx "$INSTALL_DIR"; then
  ok "~/.local/bin is already in your PATH — you're all set!"
else
  echo -e "${YELLOW}Note:${RESET} ~/.local/bin is not in your PATH yet."
  echo
  echo "Add this line to your ~/.bashrc (or ~/.zshrc):"
  echo
  echo -e "  ${BOLD}export PATH=\"\$HOME/.local/bin:\$PATH\"${RESET}"
  echo
  echo "Then reload it with:"
  echo
  echo -e "  ${BOLD}source ~/.bashrc${RESET}"
fi

# -----------------------------------------------------------------------------
# Done
# -----------------------------------------------------------------------------
echo
ok "Installation complete!"
echo
echo "Next steps:"
echo "  1. Download LM Studio:  lmstudio-update --symlink --desktop"
echo "  2. Launch LM Studio:    lmstudio-latest"
echo
