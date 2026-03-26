# Dev server-specific environment

###########################
#          TOOLS          #
###########################
# --- Pixi: relocate everything ---
export PIXI_HOME="$XDG_DATA_HOME/pixi"
export PIXI_CACHE_DIR="$XDG_CACHE_HOME/pixi"
export PIXI_BIN_DIR="$HOME/.local/bin"

###########################
#          PATHS          #
###########################
export PATH="/usr/local/cuda/bin/:$PATH"     # nvcc binary
# # --- Ensure pixi binary is on PATH ---
# case ":$PATH:" in
#   *":$PIXI_HOME/bin:"*) ;;
#   *) export PATH="$PIXI_HOME/bin:$PATH" ;;
# esac


