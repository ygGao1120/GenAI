import pytest


def test_imports():
    import peft  # noqa: F401
    import transformers  # noqa: F401
    import trl  # noqa: F401

    import cs336  # noqa: F401
    import llmlab  # noqa: F401


@pytest.mark.gpu
def test_cuda_available():
    import torch

    assert torch.cuda.is_available()
    x = torch.randn(64, 64, device="cuda", dtype=torch.bfloat16)
    assert (x @ x).isfinite().all()
