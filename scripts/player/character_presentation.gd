extends Node2D
## Presentation only; the eye follows facing without controlling gameplay.

@onready var actor: CharacterController = get_parent()

func _process(_delta: float) -> void:
	$Eye.position.x = 6.0 * actor.state.facing
