# macOS-specific environment

# Homebrew — add to PATH & set env vars. Brew's installer writes this to the
# existing shell config, but stowing overwrites that with the dotfiles version,
# so it must live here to persist. Apple Silicon only (/opt/homebrew).
if [[ -x /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi
