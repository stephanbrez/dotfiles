uv add setuptools wheel

# 1) Clear uv caches for builds + git checkouts (forces a clean rebuild)
rm -rf ~/.cache/uv/builds-v0 ~/.cache/uv/git-v0/checkouts

# 2) Build flags for GB10 (SM 12.1) + known NVCC workaround + disable Pulsar
export TORCH_CUDA_ARCH_LIST="12.1+PTX"
export NVCC_FLAGS="-static-global-template-stub=false"
export PYTORCH3D_NO_PULSAR=1

# 3) Install PyTorch3D from the stable branch (from source) without build isolation
# uv add --no-build-isolation "git+https://github.com/facebookresearch/pytorch3d.git@stable"

# 3) (Preferred) Install PyTorch3D from the main branch (from source) without build isolation
uv add --no-build-isolation "git+https://github.com/facebookresearch/pytorch3d.git@main"
