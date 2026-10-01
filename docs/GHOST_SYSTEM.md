# Ghost system contract (not implemented)

Task 001 intentionally contains no recording, playback or ghost entities.

Future input path:

```text
PlayerInputAdapter -> CharacterActions -> shared CharacterController
GhostPlayback      -> CharacterActions -> shared CharacterController
```

Record one action frame per simulation tick, not just positions. Include schema
and simulation versions, level ID, run ID, starting state, simulation Hz,
periodic checkpoints, events and final state. Validate serialization before
implementing playback. A ghost must never read current player input.

Playback consumes one action per tick. Finished ghosts remain in the world;
their stable identity and playback status must be visible. Puzzle components
react to occupancy/state and never special-case a ghost ID. Divergence must be
detected with checkpoints and surfaced; do not teleport to conceal it.

Before adding advanced mechanics, test that identical conditions and actions
reproduce the same result. Recording, playback and puzzle integration are
separate subsequent tasks in the supplied implementation plan.
