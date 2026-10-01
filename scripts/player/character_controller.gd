class_name CharacterController
extends CharacterBody2D
## SimulationManager drives this controller; it has no independent physics loop.
## Task 002 will replace these live input reads with CharacterActions.

var motor := CharacterMotor.new()
var state := CharacterState.new()

func simulate_tick(delta: float) -> void:
	var move_axis := Input.get_axis("move_left", "move_right")
	motor.step(self, move_axis, Input.is_action_just_pressed("jump"), delta)
	state.grounded = is_on_floor()
	if not is_zero_approx(move_axis):
		state.facing = 1 if move_axis > 0.0 else -1

func reset_to(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	state.grounded = false
	state.facing = 1
