#!/usr/bin/env bash

set -e

echo "========================================"
echo "Lambda LLM bootstrap starting..."
echo "========================================"

STORAGE="/lambda/nfs/llm-storage"
PROJECTS="$HOME/projects"

# --------------------------------------------------
# 1. Check persistent storage
# --------------------------------------------------

if [ ! -d "$STORAGE" ]; then
    echo "ERROR: Persistent filesystem not found at:"
    echo "$STORAGE"
    exit 1
fi

echo "[OK] Persistent storage found."

# --------------------------------------------------
# 2. Create persistent directories
# --------------------------------------------------

mkdir -p "$STORAGE/datasets"
mkdir -p "$STORAGE/huggingface"
mkdir -p "$STORAGE/checkpoints"
mkdir -p "$STORAGE/outputs"

mkdir -p "$PROJECTS"

echo "[OK] Directory structure ready."

# --------------------------------------------------
# 3. Install basic system tools
# --------------------------------------------------

echo "Installing system packages..."

sudo apt-get update

sudo apt-get install -y \
    git \
    curl \
    wget \
    build-essential \
    tmux \
    htop \
    tree \
    unzip \
    jq

echo "[OK] System packages installed."

# --------------------------------------------------
# 4. Install uv
# --------------------------------------------------

if command -v uv >/dev/null 2>&1; then
    echo "[OK] uv already installed: $(uv --version)"
else
    echo "Installing uv..."

    curl -LsSf https://astral.sh/uv/install.sh | sh

    export PATH="$HOME/.local/bin:$PATH"

    echo "[OK] uv installed."
fi

# --------------------------------------------------
# 5. Configure persistent Hugging Face cache
# --------------------------------------------------

if ! grep -q "LLM_STORAGE_CONFIG" "$HOME/.bashrc"; then

cat >> "$HOME/.bashrc" <<'EOF'

# ===== LLM_STORAGE_CONFIG =====
export LLM_STORAGE="/lambda/nfs/llm-storage"
export HF_HOME="/lambda/nfs/llm-storage/huggingface"
export HF_HUB_CACHE="/lambda/nfs/llm-storage/huggingface/hub"
export HF_DATASETS_CACHE="/lambda/nfs/llm-storage/huggingface/datasets"
export PATH="$HOME/.local/bin:$PATH"
# ===== END_LLM_STORAGE_CONFIG =====

EOF

fi

export LLM_STORAGE="$STORAGE"
export HF_HOME="$STORAGE/huggingface"
export HF_HUB_CACHE="$STORAGE/huggingface/hub"
export HF_DATASETS_CACHE="$STORAGE/huggingface/datasets"
export PATH="$HOME/.local/bin:$PATH"

echo "[OK] Hugging Face cache configured."

# --------------------------------------------------
# 6. Install Claude Code
# --------------------------------------------------

if command -v claude >/dev/null 2>&1; then
    echo "[OK] Claude Code already installed: $(claude --version)"
else
    echo "Installing Claude Code..."

    curl -fsSL https://claude.ai/install.sh | bash

    export PATH="$HOME/.local/bin:$PATH"

    echo "[OK] Claude Code installed."
fi

# --------------------------------------------------
# 7. Install Node.js if needed
# --------------------------------------------------

if command -v node >/dev/null 2>&1; then
    echo "[OK] Node already installed: $(node --version)"
else
    echo "Installing Node.js..."

    curl -fsSL https://deb.nodesource.com/setup_22.x | sudo -E bash -
    sudo apt-get install -y nodejs

    echo "[OK] Node installed: $(node --version)"
fi

# --------------------------------------------------
# 8. Install Codex
# --------------------------------------------------

if command -v codex >/dev/null 2>&1; then
    echo "[OK] Codex already installed: $(codex --version)"
else
    echo "Installing Codex..."

    sudo npm install -g @openai/codex

    echo "[OK] Codex installed."
fi

# --------------------------------------------------
# 9. Show GPU information
# --------------------------------------------------

echo
echo "GPU information:"
nvidia-smi || true

# --------------------------------------------------
# 10. Summary
# --------------------------------------------------

echo
echo "========================================"
echo "Bootstrap complete"
echo "========================================"

echo
echo "Projects directory:"
echo "$PROJECTS"

echo
echo "Persistent storage:"
echo "$STORAGE"

echo
echo "uv:"
uv --version || true

echo
echo "Claude Code:"
claude --version || true

echo
echo "Codex:"
codex --version || true

echo
echo "Next:"
echo "  cd ~/projects"
echo
echo "If this is a new instance, authenticate:"
echo "  claude"
echo "  codex"
echo
