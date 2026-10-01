extends Node

@onready var simulation: SimulationManager = $SimulationManager
@onready var ui: CanvasLayer = $UI

func _ready() -> void:
	ui.restart_requested.connect(simulation.restart_run)
	simulation.restart_run()
