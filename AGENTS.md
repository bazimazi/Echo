# Echo engineering instructions

Echo is a Godot 4 / GDScript 2D puzzle roguelite built around recorded actions
and cooperation with previous runs. Read README.md and docs/ARCHITECTURE.md
before changing code. The full roadmap is in docs/IMPLEMENTATION_PLAN.md.

- Work one verified milestone at a time; keep the game playable.
- Use a fixed simulation timestep with explicit ordering.
- Player and future ghosts must share character controller, motor and state.
- Ghosts consume recorded CharacterActions, never live input or AI decisions.
- Keep gameplay state independent of presentation and animation timing.
- Make puzzles react to world state, never specific ghost IDs.
- Version recordings and persistent data; detect replay divergence with
  checkpoints. Never silently teleport a divergent ghost.
- Prefer simple deterministic implementations without third-party dependencies.
- Do not add procedural generation, multiplayer, advanced physics, complex AI
  or online features unless the current task requires them.
- Before coding: inspect the repository, read relevant docs, identify the current
  milestone and make a small plan. Then implement, test, fix, document and verify.
- Every new mechanic needs an explicit recording/replay policy, divergence
  behavior, interactions with other ghosts and appropriate automated coverage.
- Report only checks actually performed, including limitations and next task.

Current milestone: Task 001, playable foundation. Do not implement recording,
ghosts, enemies or puzzle mechanics as part of this task. Next is Task 002,
CharacterActions and PlayerInputAdapter, before recording.

Validation (Godot 4.5, executable may be named differently):

```text
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_tests.gd
godot --path .
```
