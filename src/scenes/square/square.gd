extends Button

var board:Node2D
var grid_position:Vector2i

func _on_pressed() -> void:
	if Gamemaster.current_player != null:
		
		if Gamemaster.current_player.ai_mode != Player.MODES.USER:
			print("Player tried to play when it wasn't a player's turn")
			return
		
		if board.try_take(grid_position):
			Gamemaster.current_player._finish_turn()
	
func activate(player:Player = null) -> void:
	disabled = true
	if player == null:
		$Node2D/X.hide()
		$Node2D/O.hide()
	elif player.team == "x":
		$Node2D/X.show()
		$Node2D/O.hide()
	else:
		$Node2D/O.show()
		$Node2D/X.hide()
	animate()

func animate():
	var tween:Tween = create_tween()
	
	$Node2D.position = Vector2(randf_range(-1000, 1000), randf_range(-1000, 1000))
	$Node2D.rotation = 1.2
	
	tween.tween_property(
		$Node2D,
		"position",
		Vector2(0, 0),
		0.4
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(
		$Node2D,
		"rotation",
		0,
		0.5
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func _on_minimum_size_changed() -> void:
	$Node2D.scale = Vector2.ONE * 0.7 * (custom_minimum_size.y / 50.0)
	$Node2D.position = custom_minimum_size/2.0
