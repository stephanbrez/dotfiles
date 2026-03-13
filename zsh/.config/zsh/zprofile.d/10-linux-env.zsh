# Linux-specific environment

# Add Linux-specific paths if they exist
[[ -d /usr/local/cuda/bin ]] && path=(/usr/local/cuda/bin $path)
[[ -d /opt/bin ]]            && path=(/opt/bin $path)

export PATH
