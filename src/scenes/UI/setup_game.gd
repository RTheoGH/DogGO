extends Control
var player_selection  = ["User", "Random", "Montecarlo"]
var bsize = [7, 14]

func _ready() -> void:
	print("hello")


func _on_launch_pressed() -> void:
	pass # Replace with function body.
	var player1 = Player.new()
	var player2 = Player.new()
	
	player1.team = "o"
	player2.team = "x"
	

	player1.ai_mode = $player1Options/Player1Selection.selected
	player2.ai_mode = $player2Options/Player2Selection.selected
	
	Gamemaster.players = [player1, player2]
	get_tree().change_scene_to_packed(preload("res://src/scenes/board/board.tscn"))


func _on_select_player_item_selected(index: int) -> void:
	pass # Replace with function body.
	
	print(player_selection[index])


func _on_back_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_packed(preload("res://src/scenes/UI/MainMenu.tscn"))
	print("back")


func _on_board_size_item_selected(index: int) -> void:
	pass # Replace with function body.
	Gamemaster.boardsize = bsize[index]
	print("board size ", bsize[index])

func _on_back_mouse_entered() -> void:
	$Menu.play()

func _on_launch_mouse_entered() -> void:
	$Menu.play()

func _on_player_1_selection_mouse_entered() -> void:
	$Menu.play()

func _on_player_2_selection_mouse_entered() -> void:
	$Menu.play()

func _on_board_size_mouse_entered() -> void:
	$Menu.play()
