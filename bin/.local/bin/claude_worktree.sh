# Add to ~/.zshrc or ~/.bashrc and reload your shell

# --- Helpers ---------------------------------------------------------------

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

# 1) Create a new worktree and run Claude
# Creates a new worktree and branch in ../<branch-name>, cds into it, and runs 'claude'.
newtree() {
	if [ -z "$1" ]; then
		echo "Usage: newtree <branch-name>"
		return 1
	fi
	branch="$1"

	repo_root="$(_git_repo_root)"
	if [ -z "$repo_root" ]; then
		echo "❌ Error: not inside a Git repository."
		return 1
	fi

	# Create alongside the repo root
	parent_dir="$(dirname "$repo_root")"
	worktree_path="${parent_dir}/${branch}"

	# Create worktree + branch, then enter and run claude
	git -C "$repo_root" worktree add "$worktree_path" -b "$branch" || return 1
	cd "$worktree_path" || return 1
	claude
}

# 2) Merge <branch> into main, clean up, and push.
# Automatically jumps to the main worktree for the operations.
mergetree() {
	if [ -z "$1" ]; then
		echo "Usage: mergetree <branch-name>"
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
		echo "❌ Error: could not locate main worktree path."
		return 1
	fi

	# Save current dir and go to main worktree root
	old_pwd="$PWD"
	cd "$main_path" || return 1

	# --- UPDATE MAIN ---
	echo "Fetching remotes..."
	git fetch --prune origin || {
		cd "$old_pwd"
		return 1
	}

	echo "Switching to '$main_branch' worktree and updating..."
	# If main_branch is locked elsewhere, this will already be that worktree
	git checkout "$main_branch" || {
		cd "$old_pwd"
		return 1
	}
	git pull --ff-only origin "$main_branch" || {
		cd "$old_pwd"
		return 1
	}

	# --- MERGE PROCESS ---
	echo "Merging '$branch' into '$main_branch'..."
	if ! git merge --no-ff "$branch"; then
		echo "⚠️  Merge conflicts detected."
	fi

	# Wait until conflicts are resolved (MERGE_HEAD exists during an in-progress merge)
	while git rev-parse -q --verify MERGE_HEAD >/dev/null 2>&1; do
		echo
		echo "Unmerged files:"
		git diff --name-only --diff-filter=U || true
		echo
		echo "Resolve conflicts (edit files, 'git add <files>', then 'git commit')."
		printf "Type 'a' to abort the merge, or press Enter to re-check: "
		read -r input
		if [ "$input" = "a" ]; then
			echo "Aborting merge..."
			git merge --abort
			cd "$old_pwd"
			return 1
		fi
	done

	# --- PUSH RESULT ---
	echo "Pushing '$main_branch' to origin..."
	git push origin "$main_branch" || {
		cd "$old_pwd"
		return 1
	}

	# --- CLEAN UP WORKTREE FOR FEATURE BRANCH (IF ANY) ---
	# Prefer removing the exact feature worktree path if it exists.
	feature_path="$(_git_worktree_path_for_branch "$branch")"

	if [ -n "$feature_path" ] && [ -d "$feature_path" ]; then
		echo "Removing feature worktree at '$feature_path'..."
		git worktree remove --force "$feature_path" 2>/dev/null || true
	else
		# Fallback: try standard sibling path next to main worktree
		fallback_path="$(dirname "$main_path")/${branch}"
		echo "Removing feature worktree (fallback) at '$fallback_path'..."
		git worktree remove --force "$fallback_path" 2>/dev/null || true
	fi

	# Prune any stale worktree refs
	git worktree prune >/dev/null 2>&1 || true

	# --- OPTIONAL: DELETE BRANCHES ---
	printf "Delete local and remote branch '%s'? [y/N] " "$branch"
	read -r response
	case "$response" in
	y | Y)
		echo "Deleting local branch '$branch'..."
		git branch -d "$branch" || git branch -D "$branch"

		echo "Deleting remote branch 'origin/$branch'..."
		git push origin --delete "$branch" || true
		;;
	*) : ;;
	esac

	echo "✅ Success! Merged '$branch' into '$main_branch' and cleaned up."
	cd "$old_pwd"
}
