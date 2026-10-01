class_name CharacterMotor
extends RefCounted
## The only character movement implementation. No input or visual dependencies.

const SPEED: float = 260.0
const GRAVITY: float = 1200.0
const JUMP_VELOCITY: float = -480.0
const MAX_FALL_SPEED: float = 900.0

func step(body: CharacterBody2D, move_axis: float, jump: bool, delta: float) -> void:
	body.velocity.x = clampf(move_axis, -1.0, 1.0) * SPEED
	if jump and body.is_on_floor():
		body.velocity.y = JUMP_VELOCITY
	else:
		body.velocity.y = minf(body.velocity.y + GRAVITY * delta, MAX_FALL_SPEED)
	body.move_and_slide()
