# Echo

A 2D puzzle roguelite about cooperating with previous versions of yourself.
Built with Godot 4 and GDScript, without third-party dependencies.

**Current milestone: Task 001 — playable foundation.** One gray-box room with
walking, jumping, gravity, floor/wall/ceiling collision, three climbable
platforms, a following camera, restart and a keyboard/mouse pause menu.
Ghost recording, enemies, puzzles and saves are intentionally not implemented.

## Open and run

1. Install the standard [Godot 4.5 editor](https://godotengine.org/download/archive/4.5-stable/)
   (the baseline used for this project; no .NET needed).
2. Import `project.godot` into the Project Manager and open it.
3. Press **F5** to run the main scene.

From a terminal with Godot on PATH:

```text
godot --editor --path .
godot --path .
```

On Windows, use the full path to `Godot_v4.5-stable_win64_console.exe` when it
is not on PATH. The Compatibility renderer supports modest desktop hardware.

## Controls

| Action | Keys | Status |
| --- | --- | --- |
| Move | A / D or Left / Right | Implemented |
| Jump | Space, W or Up | Grounded only |
| Restart room | R | Implemented |
| Pause / resume | Escape | Implemented |
| Menu navigation | Tab / arrows, Enter / Space, or mouse | Implemented |
| Interact | E | Reserved |
| Attack | J | Reserved |
| Ability | Q | Reserved |

Climb the three platforms or walk through the room to its far-right marker.
This is a movement lab; the marker does not finish a level. Restart resets the
player and simulation tick. No run is recorded.

## Validation

```text
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --quit-after 120
```

The test runner exercises real movement, physics, pause and restart. See
[TEST_PLAN](docs/TEST_PLAN.md) for coverage and visual checks.

## Project map

- `scenes/`: main scene, reusable player, test room and UI.
- `scripts/`: simulation orchestration, motor, state, controller and presentation.
- `assets/`, `resources/`: reserved content directories, tracked with `.gitkeep`.
- `tests/`: dependency-free Godot test runner and future suite directories.
- `docs/`: [design](docs/GAME_DESIGN.md), [architecture](docs/ARCHITECTURE.md),
  [ghost contract](docs/GHOST_SYSTEM.md), puzzle/save plans and the
  [original implementation roadmap](docs/IMPLEMENTATION_PLAN.md).

Next task: **Task 002 — Input Abstraction**. Introduce `CharacterActions` and
`PlayerInputAdapter`, remove live input reads from the shared controller and
preserve movement behavior. Recording follows as Task 003.

Known limits: placeholder visuals, no audio or controller bindings, no progress
persistence, and no replay determinism claim at this milestone.

Licensed under the existing [MIT license](LICENSE).
