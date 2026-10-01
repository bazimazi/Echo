# Architecture

## Current scene graph

```text
Echo (GameManager)
  TestRoom (static collision geometry, spawn, labels)
  Player (CharacterController / CharacterBody2D)
    CollisionShape2D
    Presentation (visuals only)
    Camera2D
  SimulationManager
  UI (always-processing CanvasLayer)
    HUD
    PauseOverlay
```

`SimulationManager` owns the single `_physics_process` entry point at 60 Hz.
It calls `CharacterController.simulate_tick`, increments the tick counter and
checks the out-of-bounds recovery guard. No other gameplay node runs its own
physics loop. It also resets player state and camera smoothing on restart.

The controller currently samples the InputMap. `CharacterMotor` accepts a
horizontal axis and jump flag, applies gravity and calls `move_and_slide`.
`CharacterState` exposes grounded and facing state. Presentation reads state
and never writes gameplay values. Character layer 2 collides with world layer 1.

`GameManager` connects the UI restart signal to the simulation. The UI processes
while paused and sets `SceneTree.paused`; the player, physics and simulation
inherit the normal pausable mode. The resume button takes keyboard focus on
pause. Restart resumes before resetting the world.

## Next boundary: Task 002

Introduce `CharacterActions` and `PlayerInputAdapter`. Remove Input reads from
`CharacterController` and pass actions from the simulation. Keep the motor and
observable movement behavior unchanged. Only after that should recording and
ghost providers be introduced.

Fixed ticks alone do not establish replay determinism. Future tests must verify
the same build, starting state, seed and action stream. Native physics does not
promise cross-version or cross-platform bitwise determinism. Gameplay currently
uses no randomness or wall-clock timing.

Engine references: [CharacterBody2D](https://docs.godotengine.org/en/4.5/classes/class_characterbody2d.html)
and [pausing](https://docs.godotengine.org/en/4.5/tutorials/scripting/pausing_games.html).
