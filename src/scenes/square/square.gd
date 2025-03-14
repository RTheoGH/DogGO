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
	
func activate(player:Player) -> void:
	disabled = true
	$AnimatedSprite2D.play("default")
	$AnimatedSprite2D.animation_finished.connect(
		func ():
			if $AnimatedSprite2D.animation == "default":
				$AnimatedSprite2D.play(player.team)
	)

func _on_minimum_size_changed() -> void:
	$AnimatedSprite2D.scale = Vector2.ONE * 1.563 * (custom_minimum_size.y / 50.0)
	$AnimatedSprite2D.position = custom_minimum_size/2.0
