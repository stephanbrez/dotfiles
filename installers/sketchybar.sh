#!/bin/bash
# sketchybar.sh - Install SketchyBar status bar (macOS only)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/common.sh"

install_sketchybar() {
    if command -v sketchybar &>/dev/null; then
        log_message "INFO" "sketchybar already installed, skipping"
        return 0
    fi
    _echo "installing SketchyBar"
    if [[ "$pkgmgr" == "brew" ]]; then
        if should_run; then
            $ASME brew tap FelixKratz/formulae
            $ASME brew trust FelixKratz/formulae 2>/dev/null || true
            $ASME brew install sketchybar
            $ASME brew install switchaudio-osx
            log_message "SUCCESS" "SketchyBar installed via Homebrew (FelixKratz/formulae)"
        else
            dry_print "Would run: brew tap FelixKratz/formulae"
            dry_print "Would run: brew trust FelixKratz/formulae"
            dry_print "Would run: brew install sketchybar"
            dry_print "Would run: brew install switchaudio-osx"
        fi
    else
        log_message "WARNING" "SketchyBar is macOS-only, skipping for $DISTRO_ID" "true"
        return 1
    fi
}

# ─── Standalone mode ───
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    parse_installer_args "$@"
    init_installer_env
    install_sketchybar
    log_message "SUCCESS" "SketchyBar installation complete" "true"
fi
