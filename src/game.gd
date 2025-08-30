extends Node2D

var menu_active = false

func _ready() -> void:
	# Connect Board1 signals
	$Board.score_increased.connect(_on_board1_score_increased)
	$Board.score_reset.connect(_on_board1_score_reset)
	$Board.game_finished.connect(_on_board_game_finished)
	
	# Connect Board2 signals
	$Board2.game_finished.connect(_on_board_game_finished)
	
	# Set different seeds for random tile spawning
	$Board.board_id = 0
	$Board2.board_id = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("menu"):
		toggle_menu(!menu_active)
	
	# Pass input to both boards - they'll handle it if active
	if not menu_active:
		handle_dual_board_input(event)

func handle_dual_board_input(event: InputEvent) -> void:
	# Both boards process the same input
	if event.is_action_pressed("up") or event.is_action_pressed("down") or \
	   event.is_action_pressed("left") or event.is_action_pressed("right"):
		# Move both boards
		$Board.process_input(event)
		$Board2.process_input(event)
		
		# After movement, check for symmetry
		await get_tree().create_timer(0.3).timeout  # Wait for animations

func _on_board1_score_reset() -> void:
	$Score.reset_score()


func _on_board1_score_increased(amount) -> void:
	$Score.increase_score(amount)


func _on_board_game_finished() -> void:
	# Don't end game for now - continuous play
	pass
	
func _on_menu_new_game() -> void:
	$Board.reset_game()
	$Board2.reset_game()
	toggle_menu(false)

func _on_menu_quit_game() -> void:
	get_tree().quit()
	
func toggle_menu(enabled: bool) -> void:
	if enabled and menu_active:
		return
	elif enabled:
		menu_active = true
		$Menu.visible = true
		$Board.active = false
		$Board2.active = false
	elif not enabled:
		menu_active = false
		$Menu.visible = false
		$Board.active = true
		$Board2.active = true
