extends Button

var board:Node2D
var grid_position:Vector2i
var scale_factor := 1.0
var base_pos:Vector2
func _ready() -> void:
	_on_minimum_size_changed()

func _on_pressed() -> void:
	if Gamemaster.current_player != null:
		
		if Gamemaster.current_player.ai_mode != Player.MODES.USER or not Gamemaster.game_on or not Gamemaster.can_play :
			print("Player tried to play when it wasn't a player's turn")
			return
		
		if board.try_take(grid_position):
			await board.take(grid_position)
			Gamemaster.current_player._finish_turn()
	
func activate(player:Player = null) -> void:
	#disabled = true
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
	
	$Node2D.position = Vector2(0, 1500).rotated(randf_range(0, 2 * PI))
	$Node2D.rotation = 1.2
	
	tween.tween_property(
		$Node2D,
		"position",
		base_pos,
		0.4
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(
		$Node2D,
		"rotation",
		0,
		0.5
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)

func clear():
	var tween:Tween = create_tween()
	
	tween.tween_property(
		$Node2D,
		"position",
		Vector2(0, 1500).rotated(randf_range(0, 2 * PI)),
		0.4
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.parallel()
	tween.tween_property(
		$Node2D,
		"rotation",
		0.5,
		0.5
		).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	
	await tween.finished
	
	$Node2D/O.hide()
	$Node2D/X.hide()

func _on_minimum_size_changed() -> void:
	$Node2D.scale = Vector2.ONE * 0.5 * (custom_minimum_size.y / 50.0)
	base_pos = custom_minimum_size/2.0
	

func _draw():
	var couleur = Color(1.0,1.0,1.0,0.25)
	
	var zone = custom_minimum_size.y
	draw_rect(Rect2(0.0,0.0,zone+4,zone+4),couleur)
	
	var centre = zone / 2.0
	
	draw_line(Vector2(centre,0),Vector2(centre,zone+4),Color.BLACK,5.0)
	draw_line(Vector2(0,centre),Vector2(zone+4,centre),Color.BLACK,5.0)
