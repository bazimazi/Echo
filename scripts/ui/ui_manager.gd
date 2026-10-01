extends CanvasLayer
## Always processes so Escape and menu buttons can resume a paused scene tree.

signal restart_requested

@onready var pause_panel: Control = $PauseOverlay
@onready var resume_button: Button = $PauseOverlay/Center/Panel/Margin/Buttons/Resume
@onready var restart_button: Button = $PauseOverlay/Center/Panel/Margin/Buttons/Restart
@onready var quit_button: Button = $PauseOverlay/Center/Panel/Margin/Buttons/Quit

func _ready() -> void:
	resume_button.pressed.connect(func() -> void: set_paused(false))
	restart_button.pressed.connect(restart)
	quit_button.pressed.connect(func() -> void: get_tree().quit())
	pause_panel.hide()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and not event.is_echo():
		set_paused(not get_tree().paused)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("restart") and not event.is_echo():
		restart()
		get_viewport().set_input_as_handled()

func set_paused(value: bool) -> void:
	get_tree().paused = value
	pause_panel.visible = value
	if value:
		resume_button.grab_focus()
	else:
		get_viewport().gui_release_focus()

func restart() -> void:
	set_paused(false)
	restart_requested.emit()
