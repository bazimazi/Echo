class_name SimulationManager
extends Node
## One fixed-step entry point. Extend ordering here as systems are introduced.

@export var player: CharacterController
@export var spawn: Marker2D
var tick: int = 0

func _physics_process(delta: float) -> void:
	player.simulate_tick(delta)
	tick += 1
	# A recovery guard, not a death/recording mechanic.
	if player.position.y > 1000.0:
		restart_run()

func restart_run() -> void:
	tick = 0
	player.reset_to(spawn.global_position)
	player.get_node("Camera2D").reset_smoothing()
