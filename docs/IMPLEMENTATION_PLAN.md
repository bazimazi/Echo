# Echo

## Complete Game Implementation Plan

**Genre:** Roguelite + Puzzle + Time Manipulation
**Core mechanic:** Every run can become an AI-controlled ghost that replays the player's previous actions.
**Target:** First playable prototype → complete vertical slice → expandable full game.

---

# 1. Game Concept

## 1.1 Core Idea

The player controls a character through puzzle-oriented levels.

When the player dies or restarts a run, that run can become a ghost.

The ghost replays the player's previous actions while the player starts a new run.

Eventually the level may contain:

```text
Ghost #1
Ghost #2
Ghost #3
Current Player
```

The player must cooperate with previous versions of themselves.

Example:

```text
Run 1:
    Player activates Switch A.

Run 2:
    Ghost #1 activates Switch A.
    Current player passes through Door A.

Run 3:
    Ghost #1 activates Switch A.
    Ghost #2 blocks a laser.
    Current player reaches the exit.
```

The number of simultaneous timelines becomes an important progression mechanic.

---

# 2. Design Pillars

The game should be built around these principles:

1. **Deterministic cooperation**

   * Ghosts should reliably repeat what the player previously did.

2. **Readable behavior**

   * The player should always understand what each ghost is doing.

3. **Emergent puzzle solving**

   * Multiple timelines should create solutions that are impossible in a single run.

4. **Progressive complexity**

   * Introduce mechanics gradually.

5. **Replayability**

   * Levels should support multiple possible solutions.

6. **Predictability**

   * Players should be able to reason about ghost behavior.

7. **Recoverability**

   * Failed runs should be easy to retry without excessive frustration.

8. **Extensibility**

   * New puzzle mechanics should not require rewriting the ghost system.

---

# 3. Core Gameplay Loop

```text
Start Level
    |
    v
Existing Ghosts Begin Replay
    |
    v
Current Player Explores
    |
    v
Solve Puzzle / Fight / Interact
    |
    +----> Reach Exit
    |          |
    |          v
    |       Level Complete
    |
    +----> Die / Restart
               |
               v
        Finalize Current Run
               |
               v
        Create New Ghost
               |
               v
          Start New Run
```

The exact rules for when a recording becomes a ghost should be configurable.

Recommended initial behavior:

* Death creates a ghost.
* Manual restart creates a ghost.
* Successful level completion does not automatically create a ghost.
* Ghosts persist until the level is restarted or their recording is removed.

---

# 4. Recommended Technology

## 4.1 Engine

Use:

* Godot 4.x
* GDScript
* 2D renderer
* Godot's scene system
* Godot's physics system initially
* Git for version control

The initial implementation should avoid unnecessary third-party dependencies.

---

# 5. Project Structure

Create the following structure:

```text
echo/
├── project.godot
├── README.md
├── LICENSE
│
├── docs/
│   ├── GAME_DESIGN.md
│   ├── ARCHITECTURE.md
│   ├── GHOST_SYSTEM.md
│   ├── PUZZLE_SYSTEM.md
│   ├── SAVE_SYSTEM.md
│   └── TEST_PLAN.md
│
├── assets/
│   ├── characters/
│   ├── environments/
│   ├── effects/
│   ├── audio/
│   └── ui/
│
├── scenes/
│   ├── main/
│   ├── levels/
│   ├── player/
│   ├── ghosts/
│   ├── enemies/
│   ├── interactables/
│   └── ui/
│
├── scripts/
│   ├── core/
│   ├── player/
│   ├── ghosts/
│   ├── recording/
│   ├── physics/
│   ├── puzzles/
│   ├── combat/
│   ├── enemies/
│   ├── progression/
│   ├── save/
│   └── ui/
│
├── resources/
│   ├── levels/
│   ├── abilities/
│   ├── enemies/
│   └── upgrades/
│
└── tests/
    ├── unit/
    ├── integration/
    └── gameplay/
```

---

# 6. High-Level Architecture

The game should have a central simulation.

```text
                         GameManager
                              |
                              v
                     SimulationManager
                              |
          +-------------------+-------------------+
          |                   |                   |
          v                   v                   v
       Player              Ghosts              Enemies
          |                   |                   |
          +-------------------+-------------------+
                              |
                              v
                       Physics / World
                              |
          +-------------------+-------------------+
          |                   |                   |
          v                   v                   v
      Puzzles            Interactables         Objects
                              |
                              v
                         Level State
```

---

# 7. Core Systems

Implement these systems as separate modules:

| System                | Responsibility                           |
| --------------------- | ---------------------------------------- |
| `GameManager`         | Overall game state and scene transitions |
| `SimulationManager`   | Fixed timestep and simulation ordering   |
| `PlayerController`    | Current player's actions                 |
| `CharacterController` | Shared character behavior                |
| `CharacterMotor`      | Movement and physics                     |
| `GhostManager`        | Ghost lifecycle                          |
| `GhostPlayback`       | Replay of recordings                     |
| `RunRecorder`         | Recording player actions                 |
| `PuzzleManager`       | Puzzle state                             |
| `EnemyManager`        | Enemy lifecycle                          |
| `SaveManager`         | Persistent data                          |
| `ProgressionManager`  | Unlocks and upgrades                     |
| `UIManager`           | HUD and menus                            |

Avoid unnecessary direct dependencies between these systems.

Use signals/events where appropriate.

---

# 8. Simulation System

The simulation should use a fixed timestep.

Recommended:

```text
60 simulation ticks per second
```

Every simulation tick should execute in a predictable order.

## 8.1 Update Order

```text
1. Collect player input
2. Convert input into CharacterActions
3. Record current player actions
4. Retrieve ghost actions
5. Apply player actions
6. Apply ghost actions
7. Update character movement
8. Resolve physics/collisions
9. Update interactables
10. Evaluate puzzles
11. Update enemies
12. Resolve combat/damage
13. Evaluate death conditions
14. Evaluate checkpoints
15. Evaluate exit conditions
16. Store replay/checkpoint information
```

The order must remain deterministic.

Do not allow individual systems to arbitrarily update themselves in unpredictable order.

---

# 9. Input Abstraction

The character controller must not directly depend on keyboard input.

Create an abstract action object.

Example:

```gdscript
class_name CharacterActions
extends RefCounted

var move_x: float = 0.0
var move_y: float = 0.0

var jump_pressed: bool = false
var interact_pressed: bool = false
var attack_pressed: bool = false
var ability_pressed: bool = false
```

There should be two primary input providers:

```text
PlayerInputAdapter
        |
        v
CharacterActions

GhostPlayback
        |
        v
CharacterActions
```

This is one of the most important architectural decisions.

The character should not know whether its actions came from:

* keyboard
* controller
* replay
* AI
* automated testing

---

# 10. Player Controller

Separate character behavior into:

```text
CharacterController
    |
    +-- CharacterMotor
    |
    +-- CharacterState
    |
    +-- CharacterPresentation
```

## 10.1 Character Motor

Responsible for:

* horizontal movement
* gravity
* jumping
* collision
* ground detection
* velocity
* basic movement states

## 10.2 Character Presentation

Responsible for:

* sprite
* animation
* particles
* sounds
* ghost visual effects

Gameplay code should not depend on animation timing.

---

# 11. Initial Movement Features

The MVP should implement:

* Walking
* Jumping
* Gravity
* Ground detection
* Wall collision
* Ceiling collision
* Moving platforms
* Death zones
* Checkpoints
* Basic interaction

Avoid advanced movement mechanics initially.

Do not implement:

* wall jumping
* dashing
* grappling
* complex physics abilities

until the recording system is stable.

---

# 12. Run Recording System

The recording system is the heart of the game.

The preferred model is:

> Record player actions, not simply player positions.

This allows the ghost to behave like the original player rather than becoming a prerecorded video.

---

# 13. Run Data Model

A run should contain:

```text
RunRecording
├── schema_version
├── run_id
├── level_id
├── simulation_version
├── simulation_hz
├── starting_state
├── input_frames
├── checkpoints
├── important_events
├── final_state
└── checksum
```

Example:

```json
{
  "schema_version": 1,
  "run_id": "run_00042",
  "level_id": "level_01",
  "simulation_hz": 60,
  "frames": [
    {
      "tick": 0,
      "move_x": 1,
      "move_y": 0,
      "jump_pressed": false,
      "interact_pressed": false,
      "attack_pressed": false,
      "ability_pressed": false
    }
  ]
}
```

The final production implementation should use a compact representation rather than unnecessarily large JSON objects for every frame.

---

# 14. RunRecorder

Responsibilities:

* Start recording
* Record actions
* Record simulation ticks
* Record important events
* Create checkpoints
* Stop recording
* Finalize recording
* Serialize recording
* Validate recording

Example interface:

```gdscript
class_name RunRecorder
extends Node

func start_run(level_id: String) -> void:
    pass

func record_actions(actions: CharacterActions) -> void:
    pass

func record_event(event_type: String, data: Dictionary) -> void:
    pass

func create_checkpoint() -> void:
    pass

func finalize_run() -> RunRecording:
    pass
```

---

# 15. Ghost Playback

Every ghost receives a `RunRecording`.

The ghost should consume one recorded action per simulation tick.

Example:

```gdscript
class_name GhostPlayback
extends Node

var recording: RunRecording
var playback_tick: int = 0

func get_current_actions() -> CharacterActions:
    pass

func advance() -> void:
    playback_tick += 1

func is_finished() -> bool:
    return playback_tick >= recording.frames.size()
```

The ghost must never read current player input.

---

# 16. Ghost Lifecycle

```text
SPAWNING
   |
   v
PLAYING
   |
   +------> PAUSED
   |
   v
FINISHED
   |
   v
PERSISTING
```

Potential additional states:

```text
DESYNCHRONIZED
DISABLED
REMOVED
```

---

# 17. Ghost Behavior After Recording Ends

Initial rule:

> A ghost remains in the world after reaching the end of its recording.

Example:

```text
Ghost walks onto pressure plate
        |
        v
Recording ends
        |
        v
Ghost remains on pressure plate
        |
        v
Door remains open
```

This is essential for many puzzles.

The ghost should not automatically disappear at the end of its recording.

---

# 18. Ghost Manager

Responsibilities:

* Spawn ghosts
* Remove ghosts
* Pause ghosts
* Resume ghosts
* Restart ghosts
* Enforce ghost limit
* Track ghost identity
* Track source recordings
* Report ghost status

Example:

```gdscript
class_name GhostManager
extends Node

var ghosts: Array[Node] = []

func spawn_ghost(recording: RunRecording) -> Node:
    pass

func remove_ghost(ghost_id: String) -> void:
    pass

func remove_all_ghosts() -> void:
    pass

func get_active_ghost_count() -> int:
    return ghosts.size()
```

---

# 19. Ghost Identity

Every ghost should have:

```text
ghost_id
recording_id
creation_order
current_tick
status
```

Example:

```text
Ghost #1
Ghost #2
Ghost #3
```

Ghost identity must remain stable during the current level.

---

# 20. Ghost Visualization

Ghosts should be visually distinct from the current player.

Possible features:

* translucent character
* outline
* ghost trail
* unique visual identifier
* subtle glow
* ghost number

Do not rely only on color.

Each ghost should have an additional identifier such as:

```text
①
②
③
```

This helps players distinguish ghosts even when multiple ghosts overlap.

---

# 21. Replay Desynchronization

Input replay may diverge because of:

* physics changes
* collision differences
* moving platforms
* enemy interactions
* object interactions
* game updates

Use periodic checkpoints.

A checkpoint may contain:

```text
tick
position
velocity
grounded
facing
character_state
world_state_hash
```

---

# 22. Desynchronization Detection

At a checkpoint:

```text
Expected State
      |
      v
Compare
      |
      +----> Within tolerance
      |           |
      |           v
      |        Continue
      |
      +----> Outside tolerance
                  |
                  v
           DESYNCHRONIZED
```

Do not immediately teleport the ghost to the expected position.

Initially:

* mark the ghost as desynchronized
* show a visual warning
* continue or stop playback according to a configurable policy

Later versions can implement recovery mechanisms.

---

# 23. Determinism

The game should target deterministic behavior for:

```text
same build
same level
same starting state
same seed
same recording
```

This should result in:

```text
same gameplay state
```

Use seeded randomness.

Avoid using wall-clock time for gameplay.

Do not introduce random behavior into the core simulation unless it is explicitly seeded.

---

# 24. Physics Strategy

Separate gameplay into two categories.

## Action-based mechanics

Examples:

* walking
* jumping
* switches
* doors
* basic interactions

These should be implemented first.

## Precision physics mechanics

Examples:

* pushing boxes
* transferring momentum
* complex collision chains
* physics-based object puzzles

These are more difficult to replay deterministically.

Implement them later.

---

# 25. Puzzle System

The puzzle system must be reusable.

Puzzle components should communicate through state rather than hardcoded references to individual ghosts.

Basic architecture:

```text
Input
  |
  v
Condition
  |
  v
Puzzle Logic
  |
  v
Output
```

Example:

```text
Switch A ----\
              AND ----> Door
Switch B ----/
```

---

# 26. Initial Interactables

Implement:

1. Pressure plate
2. Switch
3. Door
4. Laser
5. Control panel
6. Moving platform
7. Death zone
8. Exit

---

# 27. Interactable Interface

Create a common interface/base class.

Example:

```gdscript
class_name Interactable
extends Node2D

func can_interact(actor: Node) -> bool:
    return false

func interact(actor: Node) -> void:
    pass

func get_interaction_state() -> Dictionary:
    return {}
```

---

# 28. Pressure Plates

Pressure plates should detect:

* player
* ghosts
* physics objects

These should be configurable.

Example:

```gdscript
@export var accepts_player: bool = true
@export var accepts_ghost: bool = true
@export var accepts_objects: bool = false
@export var required_occupants: int = 1
```

The pressure plate should derive its state from current occupants.

Do not rely exclusively on old interaction events.

---

# 29. Switches

Switches can be:

* momentary
* toggle
* timed

Example:

```text
Momentary:
    actor present -> ON
    actor leaves -> OFF

Toggle:
    interaction -> change state

Timed:
    interaction -> ON for N seconds
```

---

# 30. Doors

Doors should not know which ghost opened them.

They should only know whether their activation condition is satisfied.

Example:

```text
Switch A = ON
Switch B = ON

AND

Door = OPEN
```

---

# 31. Puzzle Logic Operators

Initially support:

* AND
* OR
* NOT
* TIMER
* TOGGLE

Avoid building a general visual scripting system initially.

---

# 32. Laser System

Lasers should support:

* emitter
* beam
* collision detection
* damage
* configurable activation
* configurable blocking

Possible blocking actors:

```text
Player
Ghost
Object
```

A ghost can potentially sacrifice itself or block a laser long enough for the current player to pass.

---

# 33. Example Multi-Ghost Puzzle

Example:

```text
Ghost #1
    |
    v
Switch A
    |
    v
Door A
    |
    v

Ghost #2
    |
    v
Laser blocker
    |
    v

Ghost #3
    |
    v
Switch B
    |
    v
Exit power

Current Player
    |
    v
Exit
```

The puzzle system should not contain special logic like:

```text
if ghost_1:
    open_door()

if ghost_2:
    disable_laser()
```

Instead:

```text
Switch A -> Door A
Ghost occupancy -> Laser blocker
Switch B -> Exit power
```

This keeps the system generic.

---

# 34. Enemy System

Add enemies only after the ghost/puzzle system works.

Initial enemies:

1. Patrol enemy
2. Turret

Later:

3. Chaser
4. Guard
5. Advanced enemy types

---

# 35. Enemy State Machine

Example:

```text
PATROL
   |
   v
TARGET DETECTED
   |
   v
ALERT
   |
   v
ATTACK
   |
   v
TARGET LOST
   |
   v
INVESTIGATE
   |
   v
PATROL
```

---

# 36. Ghost Combat

Eventually ghosts can:

* attack
* distract enemies
* block projectiles
* activate combat mechanisms
* draw enemy attention
* use abilities

Do not implement all of these initially.

Start with:

```text
Ghost distraction
```

Then:

```text
Ghost attack
```

Then:

```text
Ghost defensive interaction
```

---

# 37. Object Interaction

Later ghosts should be able to manipulate objects.

Possible actions:

* pick up
* carry
* drop
* push
* pull
* activate
* throw

Object state should belong to the world, not solely to the character.

---

# 38. Object Ownership

Every interactive object should have a stable ID.

Example:

```text
crate_001
battery_003
key_002
```

When carried:

```text
object.owner = ghost_02
```

Only one actor can own an object at a time.

---

# 39. Object Persistence Rules

Initial rules:

* Objects have stable IDs.
* Objects have world state.
* Carried objects have an owner.
* Dropped objects remain where they were dropped.
* Level restart resets object state.
* Persistent objects can be explicitly configured.

---

# 40. Momentum Mechanics

Momentum-based mechanics should be implemented later.

A ghost's recorded actions can apply forces through the normal physics system.

Do not simply record an object's resulting position and teleport the object during replay.

For critical physics puzzles, use deterministic/custom physics where necessary.

---

# 41. Progression

Ghost capacity should become a progression mechanic.

Example:

```text
Tutorial:
    1 ghost

Early:
    2 ghosts

Mid:
    3 ghosts

Advanced:
    4 ghosts

Late:
    5+ ghosts
```

These values should be configurable.

---

# 42. Ghost Limit

The `GhostManager` should enforce the maximum active ghost count.

Possible policies when the limit is reached:

1. Replace oldest ghost.
2. Ask player which ghost to remove.
3. Prevent creation of another ghost.
4. Require timeline reset.

Make this a progression/level configuration rather than hardcoding it.

---

# 43. Level Architecture

Each level should be data-driven.

Example:

```text
LevelDefinition
├── level_id
├── display_name
├── spawn_position
├── exit
├── maximum_ghosts
├── checkpoints
├── interactables
├── enemies
├── objects
├── puzzle_connections
└── allowed_abilities
```

---

# 44. Level Creation

Levels should be handcrafted initially.

Do not build procedural generation until the core gameplay has been validated.

The game depends heavily on timing and spatial relationships, making handcrafted puzzles more appropriate during development.

---

# 45. Tutorial Level Sequence

## Level 1 — First Echo

Teach:

* movement
* jumping
* death
* restart
* basic recording
* ghost playback

Puzzle:

```text
Player activates switch
Player dies/restarts
Ghost activates switch
Player passes door
```

---

## Level 2 — Cooperation

Introduce:

* pressure plates
* ghost persistence
* doors

Puzzle:

```text
Ghost holds pressure plate
Current player passes through door
```

---

## Level 3 — Timing

Introduce:

* lasers
* timed switches
* precise coordination

Puzzle:

```text
Ghost activates mechanism
Laser temporarily turns off
Player crosses
```

---

## Level 4 — Multiple Timelines

Introduce:

* two ghosts
* multiple switches
* simultaneous requirements

Puzzle:

```text
Ghost 1 -> Switch A
Ghost 2 -> Switch B
Player  -> Exit
```

---

# 46. Save System

The save system should persist:

* unlocked levels
* progression
* upgrades
* ghost recordings
* level records
* settings where appropriate

---

# 47. Save Data

Example:

```json
{
  "save_version": 1,
  "current_level": "level_01",

  "unlocked_levels": [
    "level_01"
  ],

  "unlocked_upgrades": [],

  "progression": {
    "max_ghosts": 1
  },

  "level_records": {
    "level_01": {
      "best_completion_ticks": null,
      "ghost_recordings": []
    }
  }
}
```

---

# 48. Save Versioning

Every persistent data format must have a schema version.

Example:

```text
save_version = 1
```

When the format changes:

```text
Version 1
   |
   v
Migration
   |
   v
Version 2
```

Do not simply assume that old save files are compatible.

---

# 49. Recording Storage

Store recordings separately from the main progression save where practical.

Example:

```text
saves/
├── profile.json
└── recordings/
    ├── run_00001.dat
    ├── run_00002.dat
    └── run_00003.dat
```

This prevents the main save from becoming unnecessarily large.

---

# 50. UI

The player must always understand the current timeline state.

HUD should display:

```text
TIMELINES
3 / 4

Ghost #1   00:38
Ghost #2   00:24
Ghost #3   00:12

Current Run
00:47
```

---

# 51. Ghost Status UI

For each ghost show:

* ghost ID
* playback time
* recording duration
* current state
* desync state
* important interaction state

Example:

```text
Ghost #2
PLAYING
00:24 / 00:41
Holding Switch B
```

---

# 52. Ghost Inspection

The player should eventually be able to inspect a ghost.

Possible information:

```text
Ghost #2

Run duration: 41.2 sec
Status: Playing
Current action: Moving Right
Current objective: None
Interaction: Switch B
```

This becomes increasingly useful as puzzle complexity increases.

---

# 53. Ghost Feedback

Use visual feedback when a ghost:

* activates a switch
* blocks a laser
* gets hit
* attacks
* picks up an object
* becomes desynchronized
* reaches the end of its recording

The player should not need to constantly watch the HUD to understand the world.

---

# 54. Performance

Initial target:

```text
5 simultaneous ghosts
60 FPS
Typical desktop hardware
```

Optimize only after profiling.

Potential bottlenecks:

* physics
* collision detection
* ghost animation
* enemy AI
* puzzle checks
* particle effects
* recording memory

---

# 55. Performance Guidelines

Avoid:

* unnecessary allocations every frame
* searching the scene tree repeatedly
* duplicated physics calculations
* unnecessary signal creation
* storing excessive state per frame

Prefer:

* cached references
* arrays
* reusable objects
* fixed simulation
* event-driven puzzle updates

Do not introduce complex multithreading until the game actually needs it.

---

# 56. Testing Strategy

Testing should be implemented alongside the game.

Three levels:

```text
Unit Tests
    |
    v
Integration Tests
    |
    v
Gameplay Tests
```

---

# 57. Unit Tests

Test:

## Recording

* one frame per tick
* correct tick ordering
* input transitions
* serialization
* deserialization

## Playback

* cursor advancement
* end-of-recording behavior
* correct action retrieval

## Ghost Manager

* spawn
* remove
* limits
* identity

## Puzzle

* AND
* OR
* NOT
* timers
* toggles

## Save System

* save
* load
* migration
* validation

---

# 58. Integration Tests

Test:

1. Ghost activates pressure plate.
2. Ghost activates switch.
3. Ghost opens door.
4. Two ghosts activate two switches.
5. Ghost blocks laser.
6. Recording is saved.
7. Saved recording is loaded.
8. Loaded recording replays correctly.
9. Ghost remains on switch after recording ends.
10. Removing ghost updates puzzle state.
11. Restart resets level correctly.
12. Multiple ghosts replay simultaneously.

---

# 59. Deterministic Replay Test

Create a dedicated automated test:

```text
Start Level
    |
    v
Use fixed random seed
    |
    v
Execute predefined input sequence
    |
    v
Record run
    |
    v
Reset level
    |
    v
Replay recording as ghost
    |
    v
Compare checkpoints
```

The test should report the first divergent tick.

Example:

```text
Replay mismatch

Tick: 1842

Expected:
Position: (512, 224)
Velocity: (120, 0)

Actual:
Position: (515, 225)
Velocity: (118, 0)
```

This is extremely valuable for debugging.

---

# 60. Gameplay Regression Tests

Maintain a collection of known successful puzzle recordings.

Example:

```text
tests/gameplay/
├── level_01_basic_echo
├── level_02_pressure_plate
├── level_03_laser
└── level_04_multi_ghost
```

Each test should verify that the known solution still works after changes to:

* movement
* physics
* puzzles
* enemies
* recording
* ghost playback

---

# 61. Debug Tools

Build internal debugging tools early.

Recommended debug features:

```text
[ ] Show simulation tick
[ ] Show collision shapes
[ ] Show ghost IDs
[ ] Show ghost playback tick
[ ] Show recording checkpoints
[ ] Show puzzle states
[ ] Show interactable IDs
[ ] Show enemy state
[ ] Pause simulation
[ ] Advance one tick
[ ] Restart current run
[ ] Spawn recording
```

The single-tick advance feature will be particularly useful when debugging replay problems.

---

# 62. Replay Debugger

Eventually implement:

```text
Replay Debugger

Ghost: #2
Recording: run_00042
Tick: 1842 / 3200

Expected Position:
(512, 224)

Actual Position:
(515, 225)

State:
RUNNING

Last Interaction:
switch_003

Checkpoint:
#8
```

This should be developer-only.

---

# 63. Development Roadmap

Implement the project in the following order.

---

## Phase 1 — Project Foundation

### Goal

Create a playable character in a simple test room.

### Tasks

* Initialize Godot project.
* Create directory structure.
* Configure InputMap.
* Implement player scene.
* Implement movement.
* Implement jumping.
* Implement gravity.
* Implement collision.
* Add camera.
* Add test level.
* Add pause menu.
* Add README.
* Add architecture documentation.

### Acceptance Criteria

* Player can move.
* Player can jump.
* Collision works.
* Camera follows player.
* Game can pause.
* Level can reload.

Do not implement ghosts yet.

---

# Phase 2 — Input Abstraction

### Goal

Separate input from character behavior.

### Tasks

* Create `CharacterActions`.
* Create `PlayerInputAdapter`.
* Update character controller.
* Ensure controller accepts generic actions.
* Add unit tests.

### Acceptance Criteria

The character controller should work without knowing whether the input came from:

* keyboard
* controller
* replay

---

# Phase 3 — Run Recording

### Goal

Record a complete player run.

### Tasks

* Implement `RunRecorder`.
* Record actions every simulation tick.
* Store metadata.
* Add checkpoints.
* Add events.
* Serialize recordings.
* Load recordings.
* Validate recordings.

### Acceptance Criteria

A complete run can be:

```text
recorded
    |
saved
    |
loaded
    |
validated
```

without losing gameplay information.

---

# Phase 4 — Ghost Playback

### Goal

Replay a recording using a ghost.

### Tasks

* Create ghost scene.
* Implement `GhostPlayback`.
* Implement `GhostManager`.
* Spawn ghost from recording.
* Feed replay actions into character controller.
* Synchronize replay with simulation.
* Implement ghost completion behavior.
* Add ghost visualization.

### Acceptance Criteria

A ghost can reproduce a previous run.

---

# Phase 5 — Determinism

### Goal

Make replay reliable.

### Tasks

* Add fixed timestep.
* Add seeded RNG.
* Add replay checkpoints.
* Add state comparison.
* Detect divergence.
* Create deterministic replay tests.
* Add replay debugging tools.

### Acceptance Criteria

The same recording consistently produces the same result under the same conditions.

---

# Phase 6 — Puzzle System

### Goal

Make ghosts useful.

### Tasks

* Implement interactable interface.
* Implement pressure plates.
* Implement switches.
* Implement doors.
* Implement puzzle connections.
* Implement AND.
* Implement OR.
* Implement laser hazards.

### Acceptance Criteria

A ghost can solve a puzzle while the current player performs another action.

---

# Phase 7 — First Vertical Slice

### Goal

Create a tiny but complete Echo experience.

Create 3–4 polished gray-box levels.

Required features:

* movement
* death
* restart
* recording
* ghost replay
* pressure plates
* switches
* doors
* lasers
* multiple ghosts
* exit
* level completion
* basic UI

The game should already communicate the core idea without requiring future mechanics.

---

# Phase 8 — Persistence

### Goal

Allow the game to survive application restarts.

### Tasks

* Save system.
* Recording persistence.
* Level progression.
* Unlocks.
* Ghost capacity.
* Save migrations.
* Corruption handling.

---

# Phase 9 — Enemies

### Goal

Introduce dynamic threats.

### Tasks

* Patrol enemy.
* Turret.
* Enemy targeting.
* Ghost distraction.
* Damage system.
* Death conditions.

Do not implement complex enemy AI yet.

---

# Phase 10 — Object Manipulation

### Goal

Allow ghosts to manipulate physical objects.

### Tasks

* Object IDs.
* Pick up.
* Carry.
* Drop.
* Push.
* Object ownership.
* Object persistence.
* Replay interaction events.

---

# Phase 11 — Advanced Mechanics

Implement individually:

1. Laser blocking
2. Ghost combat
3. Enemy distraction
4. Machine operation
5. Timed mechanisms
6. Momentum transfer
7. Physics objects
8. Advanced abilities

Each mechanic should have:

```text
Implementation
+
Recording support
+
Replay support
+
Tests
+
Tutorial usage
```

---

# Phase 12 — Progression

Introduce:

* additional ghost slots
* new abilities
* new puzzle types
* new enemy types
* new environments
* increasingly complex levels

Progression should increase the number of interactions the player must coordinate.

---

# Phase 13 — Content

Create handcrafted levels.

Recommended structure:

```text
Tutorial
    |
Basic Cooperation
    |
Timing
    |
Two Ghosts
    |
Three Ghosts
    |
Combat
    |
Object Manipulation
    |
Advanced Timeline Puzzles
    |
Endgame
```

---

# Phase 14 — Polish

Add:

* final art
* animation
* particles
* sound effects
* music
* UI polish
* screen effects
* accessibility
* settings
* controller support
* tutorials
* onboarding
* save management

---

# Phase 15 — Optimization and Release

Tasks:

* profile CPU usage
* profile memory
* test maximum ghost count
* test long recordings
* test repeated restarts
* test save migration
* test corrupted saves
* test controller input
* test different resolutions
* test window resizing
* package release builds

---

# 64. MVP Definition

The MVP is complete when all of the following work:

```text
[ ] Player movement
[ ] Player jumping
[ ] Collision
[ ] Fixed simulation
[ ] Input abstraction
[ ] Run recording
[ ] Recording serialization
[ ] Ghost playback
[ ] Ghost manager
[ ] Ghost persistence during a run
[ ] Replay determinism
[ ] Pressure plates
[ ] Switches
[ ] Doors
[ ] Lasers
[ ] Puzzle connections
[ ] Player death
[ ] Restart
[ ] Multiple ghosts
[ ] Exit
[ ] Level completion
[ ] Basic HUD
[ ] Basic save system
[ ] At least 3 complete levels
[ ] Automated tests
```

---

# 65. First Playable Prototype

Before adding art or advanced mechanics, create one gray-box room.

The room should contain:

```text
+------------------------------------------------+
|                                                |
|   Player                                       |
|      O                                         |
|     /|\             SWITCH                     |
|     / \               [ ]                      |
|                                                |
|       ========                                 |
|                    DOOR                        |
|                    |  |                        |
|                    |  |                        |
|                                                |
|                         EXIT                   |
|                          >>                    |
+------------------------------------------------+
```

The player performs:

```text
Run 1

Walk to switch
Activate switch
Continue into hazard
Die
```

Run 2:

```text
Ghost #1
    |
    +--> Walk to switch
    |
    +--> Activate switch

Current player
    |
    +--> Walk through door
    |
    +--> Reach exit
```

If this works reliably, the central Echo mechanic has been proven.

---

# 66. Critical Architectural Rules

The coding agent must follow these rules throughout development.

## Rule 1

Do not duplicate player and ghost movement logic.

Both must use the same character controller.

---

## Rule 2

Ghosts consume recorded actions.

They do not independently decide what the player should have done.

---

## Rule 3

Puzzle objects should react to world state.

They should not contain special-case logic for specific ghost IDs.

Bad:

```gdscript
if ghost.id == "ghost_1":
    open_door()
```

Good:

```text
Switch A is active
    |
    v
Door condition satisfied
    |
    v
Door opens
```

---

## Rule 4

Gameplay state must be separated from presentation.

A sprite animation should never be the source of truth for gameplay.

---

## Rule 5

Use deterministic simulation for replay-sensitive mechanics.

---

## Rule 6

Version saved data and recordings.

---

## Rule 7

Do not implement advanced mechanics before replay reliability is proven.

---

## Rule 8

Every new mechanic must explicitly answer:

```text
Can the player perform it?
Can a ghost perform it?
How is it recorded?
How is it replayed?
What happens if replay diverges?
How does it interact with other ghosts?
How is it tested?
```

---

# 67. AI Coding Agent Master Instructions

The following should be placed in the project's agent instructions.

```text
You are the senior game engineer responsible for implementing Echo.

Echo is a 2D puzzle/roguelite game centered around deterministic time-loop recordings.

The player performs a run.

When the run ends, the recording can become a ghost.

On the next run, the ghost replays the previous player's actions.

Multiple ghosts can coexist.

The player must cooperate with previous versions of themselves.

CORE ENGINEERING PRINCIPLES

1. Use Godot 4 and GDScript.
2. Use a fixed simulation timestep.
3. Keep player and ghost character simulation identical.
4. Ghosts consume recorded actions.
5. Keep gameplay simulation separate from visual presentation.
6. Keep puzzle systems data-driven.
7. Do not hardcode specific ghost IDs into puzzle logic.
8. Version all persistent data.
9. Write automated tests for core gameplay systems.
10. Keep the game playable after every milestone.
11. Prefer simple deterministic implementations over complex systems.
12. Do not introduce unnecessary third-party dependencies.

GHOST SYSTEM

Ghosts are replay entities.

They must not read current player input.

They must consume recorded CharacterActions.

Recordings must be deterministic and versioned.

Use periodic checkpoints to detect replay divergence.

Do not silently teleport ghosts when they diverge unless an explicit recovery system has been implemented.

CHARACTER ARCHITECTURE

Player and ghosts must share:

CharacterController
CharacterMotor
CharacterState

Only their input source differs.

Player:

PlayerInputAdapter -> CharacterActions -> CharacterController

Ghost:

GhostPlayback -> CharacterActions -> CharacterController

PUZZLE ARCHITECTURE

Puzzles should respond to world state.

Do not write puzzle logic based on ghost IDs.

Example:

Correct:

Switch A -> AND -> Door

Incorrect:

Ghost #1 -> Door

DEVELOPMENT PROCESS

Before modifying code:

1. Inspect the repository.
2. Identify the current implementation state.
3. Read relevant documentation.
4. Determine the current milestone.
5. Make a small implementation plan.

Then:

1. Implement one cohesive feature.
2. Run relevant tests.
3. Fix regressions.
4. Update documentation.
5. Verify the result.
6. Report what was actually verified.

Do not claim that something works without testing it.

SCOPE CONTROL

Do not jump ahead.

Do not implement:

- procedural generation
- multiplayer
- advanced physics
- complex enemy AI
- online features

unless explicitly requested or required by the current milestone.

DEFINITION OF DONE

A feature is complete only when:

- implementation exists
- integration is complete
- tests exist where appropriate
- relevant tests pass
- documentation is updated
- no known regression has been introduced

When uncertain, prefer a smaller deterministic implementation over a larger speculative one.
```

---

# 68. First Agent Task

The first coding-agent task should be intentionally small.

```text
TASK 001 — Initialize Echo

Create the initial Godot 4 project.

Requirements:

1. Inspect the repository before making changes.

2. Create the Echo project structure.

3. Configure InputMap actions for:

   - move_left
   - move_right
   - jump
   - interact
   - attack
   - ability
   - restart
   - pause

4. Create a basic player scene.

5. Implement:

   - horizontal movement
   - gravity
   - jumping
   - ground detection
   - collision

6. Create a simple gray-box test level.

7. Add a camera following the player.

8. Add a minimal pause menu.

9. Create:

   docs/GAME_DESIGN.md
   docs/ARCHITECTURE.md
   docs/GHOST_SYSTEM.md
   docs/TEST_PLAN.md

10. Add a README describing:

   - how to open the project
   - how to run it
   - controls
   - current implementation status

11. Add basic automated tests where practical.

12. Run the project and tests.

13. Report:

   - files created
   - files changed
   - tests executed
   - tests passed
   - known issues
   - recommended next task

IMPORTANT:

Do NOT implement ghost recording yet.

Do NOT implement enemies.

Do NOT implement advanced puzzle mechanics.

The goal is only to establish a clean, playable foundation.
```

---

# 69. Second Agent Task

After Task 001 is verified:

```text
TASK 002 — Input Abstraction

Refactor the character controller so it consumes CharacterActions rather than reading input directly.

Implement:

CharacterActions
PlayerInputAdapter

The character controller must be usable by both the player and future ghost playback.

Requirements:

1. Player input is converted into CharacterActions.
2. CharacterController receives CharacterActions.
3. CharacterController contains no direct keyboard/controller reads.
4. Existing movement behavior must remain unchanged.
5. Add tests for CharacterActions.
6. Run the existing test suite.
7. Update ARCHITECTURE.md.

Do not implement ghost playback yet.
```

---

# 70. Third Agent Task

```text
TASK 003 — Run Recording

Implement the first version of RunRecorder.

Requirements:

1. Record CharacterActions once per simulation tick.
2. Assign every run a unique run_id.
3. Store level_id.
4. Store simulation_hz.
5. Store schema_version.
6. Support starting a recording.
7. Support recording actions.
8. Support finalizing a recording.
9. Support serialization.
10. Support deserialization.
11. Validate recordings.
12. Add unit tests.

Do not implement ghost playback yet.

The recording system must not modify character behavior.
```

---

# 71. Fourth Agent Task

```text
TASK 004 — Ghost Playback

Implement GhostPlayback and GhostManager.

Requirements:

1. A ghost consumes RunRecording data.
2. Ghosts use CharacterActions.
3. Ghosts use the same CharacterController as the player.
4. Ghost playback advances according to simulation ticks.
5. Ghosts stop consuming input when their recording ends.
6. Ghosts remain in the world after their recording ends.
7. GhostManager can spawn and remove ghosts.
8. Add ghost IDs.
9. Add basic ghost visualization.
10. Add deterministic replay tests.

The player must be able to move independently while a ghost replays.

Do not implement puzzles yet.
```

---

# 72. Fifth Agent Task

```text
TASK 005 — First Echo Puzzle

Create the first complete Echo puzzle.

Requirements:

1. Add a pressure plate.
2. Add a door.
3. The player can activate the pressure plate.
4. The player can die and restart.
5. The previous recording becomes a ghost.
6. The ghost can activate the pressure plate.
7. The door opens while the ghost remains on the plate.
8. The current player can pass through the door.
9. Add an automated gameplay test reproducing this sequence.

This should be the first proof that the central Echo mechanic works.
```

---

# 73. Development Philosophy

The project should evolve in this order:

```text
Reliable Character
        |
        v
Input Abstraction
        |
        v
Recording
        |
        v
Deterministic Replay
        |
        v
Ghosts
        |
        v
Puzzle Interaction
        |
        v
Multiple Ghosts
        |
        v
Enemies
        |
        v
Objects
        |
        v
Advanced Timeline Mechanics
        |
        v
Progression
        |
        v
Content
        |
        v
Polish
```

Do not reverse this order by spending significant effort on art, combat, procedural generation, or advanced physics before the ghost system is reliable.

---

# 74. Long-Term Feature Ideas

Once the core system is proven, Echo can expand into significantly more complex mechanics.

Potential mechanics include:

## Ghost combat

A previous self attacks an enemy while the current player moves through the area.

## Sacrifice

A ghost intentionally takes damage or triggers a trap to allow the next timeline to progress.

## Object transfer

A ghost carries an object to a specific location and leaves it there.

## Momentum transfer

A ghost repeatedly pushes an object so that its momentum becomes useful to the current player.

## Enemy manipulation

One ghost attracts an enemy while another performs an interaction.

## Multiple simultaneous machines

Different ghosts operate different parts of a machine.

## Timed synchronization

Several ghosts must perform actions within specific timing windows.

## Ghost abilities

Specific progression upgrades could unlock:

* dash
* shield
* temporary invulnerability
* remote interaction
* object manipulation
* time pause
* rewind
* phase movement

Any new ability must be incorporated into the recording format and deterministic simulation.

---

# 75. Potential Endgame Direction

The game can eventually progress from:

```text
"I need one previous self."
```

to:

```text
"I need to construct an entire sequence
of previous selves."
```

The final puzzles could involve several coordinated timelines:

```text
Ghost #1
    |
    +--> activates machine

Ghost #2
    |
    +--> moves object

Ghost #3
    |
    +--> blocks enemy

Ghost #4
    |
    +--> activates second mechanism

Ghost #5
    |
    +--> opens final path

Current Player
    |
    +--> completes the sequence
```

At that point the player's skill is no longer primarily about reflexes.

The core skill becomes:

> **Planning a sequence of actions that will cause multiple versions of yourself to cooperate.**

That should remain the central identity of Echo.

---

# 76. Final Priority Order

When deciding what to implement next, use this priority:

```text
1. Replay correctness
2. Determinism
3. Core puzzle interaction
4. Player feedback
5. Level design
6. Progression
7. Enemy mechanics
8. Object physics
9. Art and animation
10. Advanced effects
11. Optimization
```

If a feature makes the game look better but makes replay less reliable, delay it.

If a feature makes the ghost mechanic more interesting while preserving determinism, prioritize it.

The fundamental success criterion for Echo is simple:

```text
The player performs an action.

That action becomes history.

History becomes a ghost.

The ghost performs that action again.

The player uses that history to accomplish something
that was impossible on the previous run.
```

That loop is the foundation of the entire game.
