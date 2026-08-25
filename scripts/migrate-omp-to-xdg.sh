#!/usr/bin/env bash
# migrate-omp-to-xdg.sh — relocate ~/.omp to XDG-compliant locations
#
# Prerequisites:
#   1. PI_CONFIG_DIR and XDG_*_HOME are set in zprofile.d/00-base-env.zsh
#   2. `omp config init-xdg` has been run (creates empty XDG omp dirs)
#   3. NO omp process is running (agent.db corruption risk)
#
# Run: bash scripts/migrate-omp-to-xdg.sh
# After verifying, remove the backup: rm -rf ~/.omp
set -euo pipefail

# ── safety checks ──────────────────────────────────────────────

if pgrep -x omp >/dev/null 2>&1 || pgrep -f 'bin/omp' >/dev/null 2>&1; then
  echo "ERROR: omp is still running. Exit all omp sessions first." >&2
  pgrep -af 'omp' >&2 || true
  exit 1
fi

SRC="$HOME/.omp"
if [[ ! -d "$SRC" ]]; then
  echo "ERROR: $SRC does not exist — nothing to migrate." >&2
  exit 1
fi

# Use the same values the shell profile will export
: "${XDG_CONFIG_HOME:=$HOME/.config}"
: "${XDG_DATA_HOME:=$HOME/.local/share}"
: "${XDG_STATE_HOME:=$HOME/.local/state}"
: "${XDG_CACHE_HOME:=$HOME/.cache}"
: "${PI_CONFIG_DIR:=.config/omp}"

CONFIG_ROOT="$HOME/$PI_CONFIG_DIR"     # ~/.config/omp
AGENT_DIR="$CONFIG_ROOT/agent"          # ~/.config/omp/agent
DATA_DIR="$XDG_DATA_HOME/omp"           # ~/.local/share/omp
STATE_DIR="$XDG_STATE_HOME/omp"         # ~/.local/state/omp
CACHE_DIR="$XDG_CACHE_HOME/omp"         # ~/.cache/omp

echo "Source:  $SRC"
echo "Config:  $AGENT_DIR"
echo "Data:    $DATA_DIR"
echo "State:   $STATE_DIR"
echo "Cache:   $CACHE_DIR"
echo

# ── create target dirs ─────────────────────────────────────────

mkdir -p "$CONFIG_ROOT" "$AGENT_DIR" "$DATA_DIR" "$STATE_DIR" "$CACHE_DIR"

# ── helpers ────────────────────────────────────────────────────

moved=0
skipped=0

# move_item <src_path> <dest_dir> [dest_name]
# Moves a file or dir into dest_dir. If dest_name is omitted, keeps basename.
move_item() {
  local src="$1" dest_dir="$2" dest_name="${3:-}"
  local base
  base="$(basename "$src")"
  local dest="$dest_dir/${dest_name:-$base}"

  if [[ ! -e "$src" ]]; then
    ((skipped++)) || true
    return 0
  fi

  if [[ -e "$dest" ]]; then
    # For cache/ merge: if both exist, merge contents
    if [[ -d "$src" && -d "$dest" ]]; then
      cp -a "$src"/. "$dest"/ 2>/dev/null || true
      rm -rf "$src"
      ((moved++)) || true
      echo "  merged  $base → $dest"
      return 0
    fi
    echo "  SKIP    $base (dest exists: $dest)" >&2
    ((skipped++)) || true
    return 0
  fi

  mv "$src" "$dest"
  ((moved++)) || true
  echo "  moved   $base → $dest"
}

# move_glob <pattern> <dest_dir>
move_glob() {
  local pattern="$1" dest_dir="$2"
  shopt -s nullglob dotglob
  local items=($pattern)
  shopt -u nullglob dotglob
  for item in "${items[@]}"; do
    move_item "$item" "$dest_dir"
  done
}

# ── 1. Config root files (no XDG category) → ~/.config/omp/ ───

echo "== config root =="
move_item "$SRC/install-id" "$CONFIG_ROOT"

# ── 2. Agent dir — config (no XDG) → ~/.config/omp/agent/ ─────

echo "== agent config =="
move_glob "$SRC/agent/config.yml"       "$AGENT_DIR"
move_glob "$SRC/agent/config.yaml"      "$AGENT_DIR"
move_glob "$SRC/agent/models.yml"       "$AGENT_DIR"
move_glob "$SRC/agent/models.yaml"      "$AGENT_DIR"
move_glob "$SRC/agent/mcp.json"         "$AGENT_DIR"
move_glob "$SRC/agent/.mcp.json"        "$AGENT_DIR"
move_glob "$SRC/agent/ssh.json"         "$AGENT_DIR"
move_glob "$SRC/agent/.ssh.json"        "$AGENT_DIR"
move_glob "$SRC/agent/SYSTEM.md"        "$AGENT_DIR"
move_glob "$SRC/agent/RULES.md"         "$AGENT_DIR"
move_glob "$SRC/agent/AGENTS.md"        "$AGENT_DIR"
move_glob "$SRC/agent/TITLE_SYSTEM.md"  "$AGENT_DIR"
move_glob "$SRC/agent/APPEND_SYSTEM.md" "$AGENT_DIR"
move_glob "$SRC/agent/PERSONALITY.md"   "$AGENT_DIR"
move_glob "$SRC/agent/keybindings.*"    "$AGENT_DIR"
move_glob "$SRC/agent/.env"             "$AGENT_DIR"
move_item  "$SRC/agent/themes"          "$AGENT_DIR"
move_item  "$SRC/agent/commands"        "$AGENT_DIR"
move_item  "$SRC/agent/prompts"         "$AGENT_DIR"
move_item  "$SRC/agent/tools"           "$AGENT_DIR"
move_item  "$SRC/agent/modules"         "$AGENT_DIR"

# ── 3. Agent dir — data → ~/.local/share/omp/ ─────────────────

echo "== agent data =="
move_glob "$SRC/agent/agent.db*"     "$DATA_DIR"
move_glob "$SRC/agent/history.db*"   "$DATA_DIR"
move_glob "$SRC/agent/models.db*"    "$DATA_DIR"
move_item  "$SRC/agent/sessions"     "$DATA_DIR"
move_item  "$SRC/agent/blobs"        "$DATA_DIR"

# ── 4. Agent dir — state → ~/.local/state/omp/ ────────────────

echo "== agent state =="
move_item "$SRC/agent/last-changelog-version" "$STATE_DIR"
move_item "$SRC/agent/memories"               "$STATE_DIR"
move_item "$SRC/agent/terminal-sessions"      "$STATE_DIR"
move_item "$SRC/agent/python-gateway"         "$STATE_DIR"
move_glob "$SRC/agent/omp-crash.log"          "$STATE_DIR"
move_glob "$SRC/agent/omp-debug.log"          "$STATE_DIR"
move_glob "$SRC/agent/secret-placeholder.key" "$STATE_DIR"

# ── 5. Agent dir — cache → ~/.cache/omp/ (flattened) ──────────
# agent/cache/ → ~/.cache/omp/cache/  (the "agent/" prefix is dropped)

echo "== agent cache =="
if [[ -d "$SRC/agent/cache" ]]; then
  mkdir -p "$CACHE_DIR/cache"
  move_item "$SRC/agent/cache" "$CACHE_DIR/cache" "cache"
  # move_item merges dirs when dest exists; but we created dest above,
  # so it merged. Clean up the nested cache/cache if it happened.
  if [[ -d "$CACHE_DIR/cache/cache" ]]; then
    cp -a "$CACHE_DIR/cache/cache"/. "$CACHE_DIR/cache"/ 2>/dev/null || true
    rm -rf "$CACHE_DIR/cache/cache"
  fi
fi

# ── 6. Config root — data → ~/.local/share/omp/ ───────────────

echo "== root data =="
move_item "$SRC/plugins"          "$DATA_DIR"
move_glob "$SRC/marketplaces.json" "$DATA_DIR"
move_item "$SRC/remote"           "$DATA_DIR"
move_item "$SRC/remote-host"      "$DATA_DIR"
move_item "$SRC/python-env"       "$DATA_DIR"
move_item "$SRC/browser-relay"    "$DATA_DIR"
move_glob "$SRC/autoqa.db*"       "$DATA_DIR"
move_glob "$SRC/stats.db*"        "$DATA_DIR"

# ── 7. Config root — state → ~/.local/state/omp/ ──────────────

echo "== root state =="
move_item "$SRC/logs"         "$STATE_DIR"
move_item "$SRC/run"          "$STATE_DIR"
move_item "$SRC/autoresearch" "$STATE_DIR"
move_item "$SRC/security"     "$STATE_DIR"
move_item "$SRC/reports"      "$STATE_DIR"

# ── 8. Config root — cache → ~/.cache/omp/ ────────────────────

echo "== root cache =="
move_glob  "$SRC/gpu_cache.json" "$CACHE_DIR"
move_item   "$SRC/puppeteer"      "$CACHE_DIR"
move_item   "$SRC/natives"        "$CACHE_DIR"
move_item   "$SRC/webcache"       "$CACHE_DIR"
# Root-level cache/ dir (github-cache.db, fastembed, etc.)
if [[ -d "$SRC/cache" ]]; then
  mkdir -p "$CACHE_DIR/cache"
  cp -a "$SRC/cache"/. "$CACHE_DIR/cache"/ 2>/dev/null || true
  rm -rf "$SRC/cache"
  ((moved++)) || true
  echo "  merged  cache → $CACHE_DIR/cache"
fi

# ── 9. .env at config root → ~/.config/omp/ ───────────────────

echo "== root env =="
move_glob "$SRC/.env" "$CONFIG_ROOT"

# ── report ─────────────────────────────────────────────────────

echo
echo "Moved: $moved  Skipped: $skipped"

# Show anything left behind
remaining=$(find "$SRC" -mindepth 1 2>/dev/null || true)
if [[ -n "$remaining" ]]; then
  echo
  echo "WARNING: items remain in $SRC:"
  echo "$remaining"
else
  echo
  echo "$SRC is empty — safe to remove: rm -rf $SRC"
fi

# ── verify ─────────────────────────────────────────────────────

echo
echo "== verification =="
echo "  config.yml:   $([[ -f "$AGENT_DIR/config.yml" ]] && echo 'OK' || echo 'MISSING')"
echo "  agent.db:     $([[ -f "$DATA_DIR/agent.db" ]] && echo 'OK' || echo 'MISSING')"
echo "  install-id:   $([[ -f "$CONFIG_ROOT/install-id" ]] && echo 'OK' || echo 'MISSING')"
echo "  models.yml:   $([[ -f "$AGENT_DIR/models.yml" ]] && echo 'OK' || echo 'MISSING')"
echo "  sessions/:    $([[ -d "$DATA_DIR/sessions" ]] && echo 'OK' || echo 'MISSING')"
echo
echo "Next: restart your shell (source the updated profile), then run:"
echo "  omp config path   # should show $AGENT_DIR"
echo "  omp config list   # should show your settings"
echo "If everything works: rm -rf $SRC"
