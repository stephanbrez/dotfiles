#!/bin/bash
#
# worktree.sh - Git Worktree Management with Coding Agent Integration
#
# A powerful tool for managing Git worktrees with integrated support for coding agents.
# This script helps you create isolated development environments and seamlessly integrate
# with coding assistants like Claude, CodeX, Vibe, and OpenCode.
#
# USAGE:
#   worktree newtree [-a|--agent <agent>] <branch-name>
#     Creates a new worktree and branch, then launches the specified coding agent
#     Supported agents: claude, codex, vibe, opencode (default: claude)
#
#   worktree mergetree <branch-name>
#     Merges the specified branch into main, cleans up worktree, and pushes changes
#
# EXAMPLES:
#   worktree newtree my-feature          # Uses claude (default)
#   worktree newtree -a vibe my-feature  # Uses vibe agent
#   worktree newtree --agent opencode my-feature  # Uses opencode agent
#   worktree mergetree my-feature        # Merge and cleanup
#
# FEATURES:
#   - Automatic worktree creation and management
#   - Multi-agent support with validation
#   - Interactive merge conflict resolution
#   - Automatic cleanup of worktrees and branches
#   - Bash/Zsh completion support
#   - Comprehensive error handling and user feedback
#
# INSTALLATION:
#   1. Add this script to your PATH (e.g., ~/.local/bin/)
#   2. Make it executable: chmod +x worktree.sh
#   3. Source it in your shell config or use it directly
#
# Add to ~/.zshrc or ~/.bashrc and reload your shell

# --- Helpers ---------------------------------------------------------------

# Validate that the agent is supported
_validate_agent() {
    local agent="$1"
    case "$agent" in
        claude|codex|vibe|opencode) return 0 ;;
        *) return 1 ;;
    esac
}

# Get the command for a given agent
_get_agent_command() {
    local agent="$1"
    case "$agent" in
        claude) echo "claude" ;;
        codex) echo "codex" ;;
        vibe) echo "vibe" ;;
        opencode) echo "opencode" ;;
        *) echo "claude" ;; # default fallback
    esac
}

# Echo the repo root for the current directory; exit non-zero if not in a repo
_git_repo_root() {
	git rev-parse --show-toplevel 2>/dev/null
}

# Echo the default main branch name (e.g., "main" or "master")
_git_default_main() {
	# origin/HEAD -> origin/main | origin/master -> strip "origin/"
	git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null | sed 's#^origin/##' || echo "main"
}

# Echo the worktree path for a given branch if it exists (empty if not)
_git_worktree_path_for_branch() {
	_branch="$1"
	git worktree list --porcelain | awk -v b="refs/heads/${_branch}" '
    /^worktree / { p=$2 }
    /^branch /   { if ($2==b) { print p; exit } }
  '
}

# Echo the path of the main worktree (where <main_branch> is checked out).
# Falls back to current repo root if not found in list.
_git_main_worktree_path() {
	_main_branch="$(_git_default_main)"
	_path="$(git worktree list --porcelain | awk -v b="refs/heads/${_main_branch}" '
    /^worktree / { p=$2 }
    /^branch /   { if ($2==b) { print p; exit } }
  ')"
	if [ -n "$_path" ]; then
		echo "$_path"
	else
		_git_repo_root
	fi
}

# --- Commands --------------------------------------------------------------

# 1) Create a new worktree and run a coding agent
# Creates a new worktree and branch in ../<branch-name>, cds into it, and runs the specified agent.
newtree() {
	local agent="claude" # default agent
	local branch=""

	# Parse arguments
	if [ "$1" = "-a" ] || [ "$1" = "--agent" ]; then
		if [ -z "$2" ]; then
			echo "Usage: newtree [-a|--agent <agent>] <branch-name>"
			echo "Supported agents: claude, codex, vibe, opencode"
			return 1
		fi
		agent="$2"
		shift 2
	fi

	if [ -z "$1" ]; then
		echo "Usage: newtree [-a|--agent <agent>] <branch-name>"
		echo "Supported agents: claude, codex, vibe, opencode"
		return 1
	fi
	branch="$1"

	# Validate agent
	if ! _validate_agent "$agent"; then
		echo "❌ Error: unsupported agent '$agent'. Supported agents: claude, codex, vibe, opencode"
		return 1
	fi

	repo_root="$(_git_repo_root)"
	if [ -z "$repo_root" ]; then
		echo "❌ Error: not inside a Git repository."
		return 1
	fi

	# Create alongside the repo root
	parent_dir="$(dirname "$repo_root")"
	worktree_path="${parent_dir}/${branch}"

	# Create worktree + branch, then enter and run the agent
	git -C "$repo_root" worktree add "$worktree_path" -b "$branch" || return 1
	cd "$worktree_path" || return 1
	
	# Get agent command and verify it's available
	local agent_cmd="$(_get_agent_command "$agent")"
	if ! command -v "$agent_cmd" >/dev/null 2>&1; then
		echo "❌ Error: '$agent_cmd' command not found. Is the '$agent' agent installed?"
		return 1
	fi
	
	"$agent_cmd"
}

# 2) Merge <branch> into main, clean up, and push.
# Automatically jumps to the main worktree for the operations.
mergetree() {
	if [ -z "$1" ]; then
		echo "Usage: mergetree <branch-name>"
		echo "Note: This will merge the specified branch into the main branch."
		return 1
	fi

	branch="$1"
	main_branch="$(_git_default_main)"

	# Ensure we’re in a repo
	any_root="$(_git_repo_root)"
	if [ -z "$any_root" ]; then
		echo "❌ Error: not inside a Git repository."
		return 1
	fi

	# Jump to the *main worktree* path (where main/master is checked out)
	main_path="$(_git_main_worktree_path)"
	if [ -z "$main_path" ] || [ ! -d "$main_path" ]; then
		echo "❌ Error: could not locate main worktree path for branch '$main_branch'."
		echo "Make sure your main branch is checked out in a worktree."
		return 1
	fi

	# Save current dir and go to main worktree root
	old_pwd="$PWD"
	cd "$main_path" || return 1

	# --- UPDATE MAIN ---
	echo "🔄 Fetching remotes..."
	if ! git fetch --prune origin; then
		echo "❌ Error: failed to fetch from origin."
		cd "$old_pwd"
		return 1
	fi

	echo "🔄 Switching to '$main_branch' worktree and updating..."
	# If main_branch is locked elsewhere, this will already be that worktree
	if ! git checkout "$main_branch"; then
		echo "❌ Error: failed to checkout '$main_branch' branch."
		cd "$old_pwd"
		return 1
	fi
	
	if ! git pull --ff-only origin "$main_branch"; then
		echo "❌ Error: failed to pull latest changes from origin/$main_branch."
		cd "$old_pwd"
		return 1
	fi

	# --- MERGE PROCESS ---
	echo "🔄 Merging '$branch' into '$main_branch'..."
	if ! git merge --no-ff "$branch"; then
		echo "⚠️  Merge conflicts detected. Please resolve them before continuing."
	fi

	# Wait until conflicts are resolved (MERGE_HEAD exists during an in-progress merge)
	while git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; do
		echo
		echo "📝 Unmerged files:"
		git diff --name-only --diff-filter=U || true
		echo
		echo "💡 Resolve conflicts by editing files, then 'git add <files>', and 'git commit'."
		printf "🔠 Type 'a' to abort the merge, or press Enter to re-check: "
		read -r input
		if [ "$input" = "a" ]; then
			echo "🔄 Aborting merge..."
			git merge --abort
			cd "$old_pwd"
			return 1
		fi
		echo "🔄 Checking merge status..."
	done

	# --- PUSH RESULT ---
	echo "📤 Pushing '$main_branch' to origin..."
	if ! git push origin "$main_branch"; then
		echo "❌ Error: failed to push to origin/$main_branch."
		cd "$old_pwd"
		return 1
	fi

	# --- CLEAN UP WORKTREE FOR FEATURE BRANCH (IF ANY) ---
	# Prefer removing the exact feature worktree path if it exists.
	feature_path="$(_git_worktree_path_for_branch "$branch")"

	if [ -n "$feature_path" ] && [ -d "$feature_path" ]; then
		echo "🗑️  Removing feature worktree at '$feature_path'..."
		if ! git worktree remove --force "$feature_path" 2>/dev/null; then
			echo "⚠️  Warning: failed to remove worktree at '$feature_path'. You may need to clean it up manually."
		fi
	else
		# Fallback: try standard sibling path next to main worktree
		fallback_path="$(dirname "$main_path")/${branch}"
		echo "🗑️  Removing feature worktree (fallback) at '$fallback_path'..."
		if ! git worktree remove --force "$fallback_path" 2>/dev/null; then
			echo "⚠️  Warning: failed to remove worktree at '$fallback_path'. You may need to clean it up manually."
		fi
	fi

	# Prune any stale worktree refs
	git worktree prune >/dev/null 2>&1 || true

	# --- OPTIONAL: DELETE BRANCHES ---
	printf "🗑️  Delete local and remote branch '%s'? [y/N] " "$branch"
	read -r response
	case "$response" in
	y | Y)
		echo "🗑️  Deleting local branch '$branch'..."
		if ! git branch -d "$branch"; then
			if ! git branch -D "$branch"; then
				echo "⚠️  Warning: failed to delete local branch '$branch'. You may need to delete it manually."
			fi
		fi

		echo "🗑️  Deleting remote branch 'origin/$branch'..."
		if ! git push origin --delete "$branch"; then
			echo "⚠️  Warning: failed to delete remote branch 'origin/$branch'. You may need to delete it manually."
		fi
		;;
	*) : ;;
	esac

	echo "✅ Success! Merged '$branch' into '$main_branch' and cleaned up."
	cd "$old_pwd"
}

# --- Completion Support ----------------------------------------------------

# Bash/Zsh completion function
_worktree_completion() {
    local cur prev words cword
    if [[ "$1" == "bash" ]]; then
        cur="${COMP_WORDS[COMP_CWORD]}"
        prev="${COMP_WORDS[COMP_CWORD-1]}"
        words=("${COMP_WORDS[@]}")
        cword=$COMP_CWORD
    else
        # Zsh
        cur="${words[$CURRENT]}"
        prev="${words[$CURRENT-1]}"
        cword=$CURRENT
    fi

    # Available commands
    local commands="newtree mergetree"
    
    # Supported agents
    local agents="claude codex vibe opencode"
    
    # Get current command
    local cmd="${words[1]}"
    
    case "$prev" in
        newtree|mergetree)
            # Complete branch names for newtree/mergetree
            if [[ "$cur" != "-"* ]]; then
                local branches=$(git branch --format="%(refname:short)" 2>/dev/null)
                COMPREPLY=($(compgen -W "$branches" -- "$cur"))
                return 0
            fi
            ;;
        -a|--agent)
            # Complete agent names after -a/--agent
            COMPREPLY=($(compgen -W "$agents" -- "$cur"))
            return 0
            ;;
        *)
            # Complete commands
            if [[ "$cur" == "-"* ]]; then
                COMPREPLY=($(compgen -W "--agent -a" -- "$cur"))
            else
                COMPREPLY=($(compgen -W "$commands" -- "$cur"))
            fi
            ;;
    esac
}

# Register completion for bash
if [[ "$BASH_VERSION" ]]; then
    complete -F _worktree_completion worktree
fi

# Register completion for zsh
if [[ "$ZSH_VERSION" ]]; then
    compdef _worktree_completion worktree
fi
