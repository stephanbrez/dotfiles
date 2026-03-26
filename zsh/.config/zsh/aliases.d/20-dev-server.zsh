# Dev server-specific aliases
export JUPYTER_CONFIG_DIR=~/.config/jupyter/   # Use xdg spec for config
alias comfy='source ~/.local/src/comfyui/.venv/bin/activate && python3 ~/.local/src/comfyui/main.py --enable-manager --listen 0.0.0.0'
alias owui="docker run -d \
  --network=host \
  --gpus all \
  --restart always \
  --name open-webui \
  -v open-webui:/app/backend/data \
  -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
  ghcr.io/open-webui/open-webui:cuda"

function owuiup ()
{
    CONTAINER="open-webui"
    IMAGE="ghcr.io/open-webui/open-webui:cuda"

    if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER}$"; then
        docker rm -f "$CONTAINER"
    fi

    docker pull "$IMAGE"

    docker run -d \
    --network=host \
    --gpus all \
    --restart unless-stopped \
    --name "$CONTAINER" \
    -v open-webui:/app/backend/data \
    -e OLLAMA_BASE_URL=http://127.0.0.1:11434 \
    "$IMAGE"
}

# alias jns="cd ~/.local/src/ && conda activate jupyter-env && jupyter notebook --no-browser --port=8888 --ip='192.168.20.10'"
