# GenAI — personal LLM training lab

Hands-on LLM learning and experiments: Stanford CS336 implementations, plus SFT, LoRA/QLoRA,
DPO, GRPO, evaluation and small-scale model training. Runs on ephemeral Lambda Cloud A100
instances; everything heavy lives on persistent NFS.

## New instance quickstart

```bash
bash /lambda/nfs/llm-storage/bootstrap/bootstrap.sh   # first time on an instance (or scripts/setup/bootstrap_lambda.sh)
cd ~/projects && git clone https://github.com/ygGao1120/GenAI.git && cd GenAI
cp .env.example .env    # fill in HF_TOKEN / WANDB_API_KEY
make setup              # uv sync --locked, NFS symlinks, nbstripout
make gpu-check          # torch version, CUDA, device name
make check              # ruff + CPU tests
```

## Layout

| Path | Purpose |
|------|---------|
| `src/llmlab/` | Reusable training infrastructure (data, models, trainers, eval). Tested, kept tidy. |
| `src/cs336/` | CS336 from-scratch implementations, one subpackage per assignment. Learning code. |
| `configs/` | One YAML file = one reproducible run. Variants are configs, not new scripts. |
| `scripts/` | Thin CLI entry points that load a config and call into `src/`. No logic here. |
| `experiments/` | Lab notebook: one markdown file per question, plus an index table. |
| `notebooks/` | Exploration and analysis only. Numbered: `01_data_eda.ipynb`. |
| `tests/` | pytest. GPU tests are marked `@pytest.mark.gpu`; `make check` skips them. |

### Rules

- `cs336` may import `llmlab`; `llmlab` never imports `cs336`. Promote useful CS336 code into
  `llmlab` (with tests) instead of importing across.
- Logic lives in `src/`. Once a notebook helper is needed in a second place, move it there.
- Large files never go in git. Configs reference storage via `${oc.env:LLM_STORAGE}`, not
  hardcoded paths.

## Persistent storage (`$LLM_STORAGE` = `/lambda/nfs/llm-storage`)

| Path | Contents |
|------|----------|
| `datasets/<name>/raw/` | Original data, immutable |
| `datasets/<name>/processed/<version>/` | Derived data, rebuilt by scripts |
| `huggingface/` | HF hub + datasets cache (`HF_HOME`, set in `~/.bashrc`) |
| `outputs/genai/<run_name>/` | Resolved config, git SHA, logs, metrics, eval results |
| `checkpoints/genai/<run_name>/` | Model weights / adapters |

`outputs/` and `checkpoints/` in the repo root are gitignored symlinks into these (created by
`make setup`).

## Environment

- Python 3.11 (`.python-version`), managed by uv. `uv.lock` is committed; always sync with
  `uv sync --locked` on new machines.
- PyTorch comes from the CUDA 13.0 index (matches the Lambda driver). torch is pinned to the
  version current vLLM requires, so vLLM can be added later without a torch change.
- Add a dependency: `uv add <pkg>` (or `uv add --group dev <pkg>`), then commit
  `pyproject.toml` and `uv.lock` together.
- Dependency groups: `dev` (pytest, ruff) and `notebook` (ipykernel, matplotlib, pandas,
  nbstripout) are installed by default.
