LLM_STORAGE ?= /lambda/nfs/llm-storage
PROJECT := genai
ENV_FILE := $(if $(wildcard .env),--env-file .env,)

.PHONY: setup check fmt test gpu-check

setup:  ## Install env, link persistent storage, configure notebook output stripping
	uv sync --locked
	mkdir -p $(LLM_STORAGE)/outputs/$(PROJECT) $(LLM_STORAGE)/checkpoints/$(PROJECT)
	ln -sfn $(LLM_STORAGE)/outputs/$(PROJECT) outputs
	ln -sfn $(LLM_STORAGE)/checkpoints/$(PROJECT) checkpoints
	uv run nbstripout --install

check:  ## Lint, format check, CPU tests
	uv run ruff check .
	uv run ruff format --check .
	uv run $(ENV_FILE) pytest -m "not gpu"

fmt:
	uv run ruff check --fix .
	uv run ruff format .

test:
	uv run $(ENV_FILE) pytest

gpu-check:
	uv run python -c "import torch; print(torch.__version__, torch.version.cuda, torch.cuda.is_available(), torch.cuda.get_device_name())"
