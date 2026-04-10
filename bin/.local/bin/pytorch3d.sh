   1   │ uv add setuptools wheel
   2   │
   3   │ # 1) Clear uv caches for builds + git checkouts (forces a clean rebuild)
   4   │ rm -rf ~/.cache/uv/builds-v0 ~/.cache/uv/git-v0/checkouts
   5   │
   6   │ # 2) Build flags for GB10 (SM 12.1) + known NVCC workaround + disable Pulsar
   7   │ export TORCH_CUDA_ARCH_LIST="12.1+PTX"
   8   │ export NVCC_FLAGS="-static-global-template-stub=false"
   9   │ export PYTORCH3D_NO_PULSAR=1
  10   │
  11   │ # 3) Install PyTorch3D from the stable branch (from source) without build isolation
  12   │ # uv add --no-build-isolation "git+https://github.com/facebookresearch/pytorch3d.git@stable"
  13   │
  14   │
  15   │ # 3) (Preferred) Install PyTorch3D from the main branch (from source) without build isolation
  16   │ uv add --no-build-isolation "git+https://github.com/facebookresearch/pytorch3d.git@main"
