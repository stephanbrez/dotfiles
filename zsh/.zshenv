# ███████╗███████╗██╗  ██╗███████╗███╗   ██╗██╗   ██╗
# ╚══███╔╝██╔════╝██║  ██║██╔════╝████╗  ██║██║   ██║
#   ███╔╝ ███████╗███████║█████╗  ██╔██╗ ██║██║   ██║
#  ███╔╝  ╚════██║██╔══██║██╔══╝  ██║╚██╗██║╚██╗ ██╔╝
# ███████╗███████║██║  ██║███████╗██║ ╚████║ ╚████╔╝
# ╚══════╝╚══════╝╚═╝  ╚═╝╚══════╝╚═╝  ╚═══╝  ╚═══╝
#
# ZSHENV - Unconditional bootstrap entry point
#
# Read by EVERY zsh invocation - login, interactive, non-interactive, scripts,
# `zsh -c` - before .zprofile and .zshrc, and always resolvable with no prior
# state. It is the only startup file zsh reads from $HOME when $ZDOTDIR is unset.
#
# WHY THIS FILE EXISTS
#   zsh resolves its startup files from $ZDOTDIR when that variable is already
#   present in the environment, and from $HOME otherwise. Exporting ZDOTDIR from
#   ~/.zprofile was circular: a login shell that *inherited* ZDOTDIR looked for
#   "$ZDOTDIR/.zprofile", found nothing (the dispatcher lived at ~/.zprofile),
#   and silently skipped the whole environment tree - BUN_INSTALL, CARGO_HOME,
#   PATH additions included. Sourcing from here breaks that cycle, because this
#   file cannot be shadowed by a stale variable.
#
# KEEP THIS FILE MINIMAL
#   It runs for non-interactive shells too, so no PATH surgery, no plugins, no
#   interactive-only settings. Session environment belongs in zprofile.d/,
#   interactive configuration in zshrc.d/.
#
# ======== ======== #

# Point zsh at the repo-managed config directory. Every subsequent startup file
# (.zprofile, .zshrc, .zlogin) is then resolved from here.
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"

# When ZDOTDIR is inherited, zsh reads "$ZDOTDIR/.zshenv" instead of this file.
# Source it if present so both entry points behave identically. The sentinel
# prevents recursion if the two paths are ever symlinked to each other.
if [[ -r "$ZDOTDIR/.zshenv" && -z "${_ZSHENV_BOOTSTRAPPED:-}" ]]; then
	typeset -g _ZSHENV_BOOTSTRAPPED=1
	source "$ZDOTDIR/.zshenv"
fi
