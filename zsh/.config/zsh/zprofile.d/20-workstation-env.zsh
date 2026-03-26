# Workstation-specific environment
# Path

###########################
#          TOOLS          #
###########################
# --- Pixi: relocate everything ---
export PIXI_HOME="$XDG_DATA_HOME/pixi"
export PIXI_CACHE_DIR="$XDG_CACHE_HOME/pixi"

###########################
#         PLUGINS         #
###########################

# ======== 1Password ======== #
export SSH_AUTH_SOCK=~/.1password/agent.sock

