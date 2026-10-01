extends SceneTree
## Optional rendered visual QA. Requires a display/rendering driver (not headless).
## Outputs ignored PNGs to .godot/previews/.

func _initialize() -> void:
	_capture.call_deferred()

func snapshot(filename: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png("res://.godot/previews/" + filename)
	if result != OK:
		push_error("Could not write preview: " + filename)
		quit(1)

func _capture() -> void:
	DirAccess.make_dir_recursive_absolute("res://.godot/previews")
	var scene: PackedScene = load("res://scenes/main/main.tscn")
	var game: Node = scene.instantiate()
	root.add_child(game)
	current_scene = game
	for index in range(30):
		await physics_frame
	await snapshot("room.png")
	game.get_node("UI").set_paused(true)
	await snapshot("pause.png")
	game.get_node("UI").set_paused(false)
	game.get_node("Player").reset_to(Vector2(1740, 530))
	game.get_node("Player/Camera2D").reset_smoothing()
	for index in range(30):
		await physics_frame
	await snapshot("room_end.png")
	root.size = Vector2i(960, 540)
	await snapshot("resized.png")
	quit()
