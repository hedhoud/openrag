"""Tests for the upcoming Postgres WorkspaceRepository.

Reserved placeholder — real tests land once Person A's 7A.2
``workspace_repo.py`` implementation merges. Colocated with the
implementation (project convention). The port ABC is expected to land
in the same commit (no ``workspace_repo.py`` exists under
``openrag/core/ports/`` yet). Will cover both the workspace CRUD and
the workspace ↔ files join table.
"""

import pytest

pytestmark = pytest.mark.skip(reason="awaiting 7A.2 workspace_repo + port from Person A")


def test_placeholder() -> None:
    pass
