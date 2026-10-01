# Echo

A 2D puzzle roguelite about cooperating with previous versions of yourself.
Runs will become ghosts that replay the player's actions. Multiple timelines
will make otherwise impossible solutions possible.

## Task 001: first steps

The current build is a movement lab, not yet the Echo puzzle loop. Walk through
a gray-box room, climb three platforms, test a low ceiling and restart. The
rightmost marker is a visual destination, not a functional exit. There are no
hazards, ghosts, puzzles, combat or saves yet.

Movement uses constant horizontal speed, gravity and a grounded-only jump. The
room has solid walls and platforms; platform undersides also block movement.
The follow camera stays inside room bounds. Pause freezes the simulation and
offers resume, restart and quit. Falling out of bounds returns to the spawn.

## Design constraints

Deterministic cooperation, readable behavior, progressive complexity,
recoverability and extensibility guide future work. Ghosts must share movement
with the player and consume actions. Their eventual default behavior is to
remain after a recording ends. Desynchronization must be visible rather than
silently corrected by teleportation.

Next milestones: input abstraction, recording, replay validation, ghosts, then
the first pressure-plate/door puzzle. See [the supplied roadmap](IMPLEMENTATION_PLAN.md).
