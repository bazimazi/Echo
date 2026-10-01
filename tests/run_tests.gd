extends SceneTree
## Dependency-free integration runner against the actual main scene and physics.

const MAIN = preload("res://scenes/main/main.tscn")
const REQUIRED_ACTIONS = ["move_left", "move_right", "jump", "interact", "attack", "ability", "restart", "pause"]
var failures: int = 0
var checks: int = 0
var game: Node
var player: CharacterController
var simulation: SimulationManager

func _initialize() -> void:
	_run.call_deferred()

func check(condition: bool, label: String) -> void:
	checks += 1
	if condition:
		print("PASS: ", label)
	else:
		failures += 1
		push_error("FAIL: " + label)

func ticks(count: int) -> void:
	for index in range(count):
		await physics_frame
		await process_frame

func tap_key(code: Key) -> void:
	var event := InputEventKey.new()
	event.physical_keycode = code
	event.pressed = true
	Input.parse_input_event(event)
	await ticks(1)
	event = InputEventKey.new()
	event.physical_keycode = code
	event.pressed = false
	Input.parse_input_event(event)
	await ticks(1)

func _run() -> void:
	for action in REQUIRED_ACTIONS:
		check(InputMap.has_action(action) and not InputMap.action_get_events(action).is_empty(), "InputMap: " + action)
	check(Engine.physics_ticks_per_second == 60, "Fixed physics rate is 60 Hz")
	game = MAIN.instantiate()
	root.add_child(game)
	current_scene = game
	player = game.get_node("Player")
	simulation = game.get_node("SimulationManager")
	await ticks(30)
	check(player.state.grounded, "Gravity settles player on floor")
	check(absf(player.position.y - 538.0) < 0.5, "Floor prevents penetration")

	var start_x := player.position.x
	Input.action_press("move_right")
	await ticks(20)
	Input.action_release("move_right")
	check(player.position.x > start_x + 70.0, "Right input moves player")
	await ticks(2)
	check(is_zero_approx(player.velocity.x), "Release stops horizontal movement")
	Input.action_press("move_left")
	await ticks(70)
	Input.action_release("move_left")
	check(player.position.x >= 45.5 and player.position.x < 47.0, "Left movement stops at wall")
	check(player.state.facing == -1, "Facing follows left movement")

	player.reset_to(Vector2(200, 530))
	await ticks(10)
	await tap_key(KEY_SPACE)
	check(player.velocity.y < 0.0 and not player.state.grounded, "Jump leaves the ground")
	await ticks(8)
	var before_jump := player.velocity.y
	await tap_key(KEY_SPACE)
	check(player.velocity.y > before_jump, "A second airborne press cannot double jump")
	await ticks(60)
	check(player.state.grounded, "Jump lands on floor")

	Input.action_press("jump")
	await ticks(100)
	check(player.state.grounded, "Holding jump does not automatically jump after landing")
	Input.action_release("jump")
	await ticks(2)

	player.reset_to(Vector2(1300, 530))
	await ticks(10)
	await tap_key(KEY_SPACE)
	var ceiling_hit := false
	var min_y := player.position.y
	for index in range(35):
		await ticks(1)
		min_y = minf(min_y, player.position.y)
		ceiling_hit = ceiling_hit or player.is_on_ceiling()
	check(ceiling_hit and min_y >= 461.5, "Ceiling stops upward movement without penetration")
	await ticks(30)

	# Exercise real player movement from the floor onto each platform.
	player.reset_to(Vector2(350, 530))
	await ticks(10)
	for step in range(3):
		Input.action_press("move_right")
		await tap_key(KEY_SPACE)
		await ticks(25 if step == 0 else 44)
		Input.action_release("move_right")
		await ticks(35)
		var expected_y := 458.0 - step * 80.0
		check(player.state.grounded and absf(player.position.y - expected_y) < 0.5, "Reachable platform %d" % (step + 1))

	player.reset_to(Vector2(1700, 530))
	await ticks(20)
	Input.action_press("move_right")
	await ticks(60)
	Input.action_release("move_right")
	check(player.position.x <= 1874.5, "Right boundary stops player")
	var camera: Camera2D = player.get_node("Camera2D")
	check(camera.get_screen_center_position().x > 1000.0, "Camera follows player across room")

	await tap_key(KEY_ESCAPE)
	check(paused and game.get_node("UI/PauseOverlay").visible, "Escape opens pause menu")
	check(game.get_node("UI/PauseOverlay/Center/Panel/Margin/Buttons/Resume").has_focus(), "Pause menu has keyboard focus")
	var frozen_position := player.position
	var frozen_tick := simulation.tick
	Input.action_press("move_left")
	await ticks(10)
	Input.action_release("move_left")
	check(player.position == frozen_position and simulation.tick == frozen_tick, "Pause freezes movement and simulation ticks")
	game.get_node("UI").resume_button.pressed.emit()
	await ticks(2)
	check(not paused and not game.get_node("UI/PauseOverlay").visible, "Resume button unpauses")
	check(simulation.tick > frozen_tick, "Simulation resumes after pause")

	await tap_key(KEY_ESCAPE)
	await tap_key(KEY_ESCAPE)
	check(not paused, "Escape also resumes the paused game")
	await tap_key(KEY_R)
	check(absf(player.position.x - 144.0) < 0.1 and player.velocity.x == 0.0, "R resets position and movement")
	check(simulation.tick < 10, "Restart resets simulation tick")
	await tap_key(KEY_ESCAPE)
	game.get_node("UI").restart_button.pressed.emit()
	await ticks(2)
	check(not paused and absf(player.position.x - 144.0) < 0.1, "Menu restart resets room and unpauses")
	player.position.y = 1100.0
	await ticks(2)
	check(player.position.y < 540.0, "Out-of-bounds recovery returns player to spawn")

	for action in REQUIRED_ACTIONS:
		Input.action_release(action)
	print("RESULT: %d/%d checks passed" % [checks - failures, checks])
	quit(1 if failures else 0)
