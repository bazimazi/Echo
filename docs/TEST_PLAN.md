# Test plan

## Automated checks

Run from the project root with Godot 4.5 (standard build, no .NET required):

```text
godot --headless --path . --editor --quit
godot --headless --path . --script tests/run_tests.gd
godot --headless --path . --quit-after 120
```

Use the actual executable path if Godot is not on PATH. Import first on a fresh
checkout so the script class cache is generated. The dependency-free test
runner loads the real main scene and uses real physics and InputMap events.
It prints each result and exits nonzero on a failed assertion.

Coverage: all eight action mappings, 60 Hz configuration, gravity, floor and
wall collision, horizontal movement and release, facing, jump and landing,
airborne jump rejection, held-jump behavior, ceiling collision, climbing all
three platforms, following camera, pause/menu focus, frozen simulation, resume
by button and Escape, restart by key and menu, tick reset, bounds recovery.

The reserved unit/integration/gameplay directories support later milestone
suites. For now the cohesive foundation checks live in `tests/run_tests.gd`.

## Verified results — 2026-10-01

- Godot 4.5.stable.official.876b29033: headless editor import passed.
- Automated runner: **35 / 35 checks passed**, exit code 0.
- Main scene headless smoke run (`--quit-after 120`): passed without errors.
- Native rendered launch: passed with the Compatibility/OpenGL renderer.
- Inspected rendered captures of the starting room, pause menu, right side of
  the room and a 960 x 540 resized window. Labels and HUD are readable; the
  pause menu is centered and the resume button has visible focus.
- These are automated input and rendering checks, not a human playtest. Audio,
  controllers, other operating systems and future gameplay systems are untested.

To reproduce visual captures with a rendering driver:

```text
godot --path . --script tests/capture_preview.gd
```

PNGs are written to the ignored `.godot/previews/` directory.

## Visual/manual checklist

- Launch main scene (F6 opens only the currently selected scene; use F5).
- Read the HUD and instructions at 1280 x 720 and a resized window.
- Walk both directions, climb each platform and jump into the low ceiling.
- Walk to the right marker; observe camera following and boundary limits.
- Pause mid-jump; resume with mouse, keyboard or Escape.
- Restart while paused, then move and jump again. Quit through the menu.

Do not claim replay, controller support, save compatibility or later milestones
are verified by these tests. Their implementations do not exist yet.
