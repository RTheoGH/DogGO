extends Resource
class_name Player


enum MODES {USER, RANDOM, MINMAX}

@export var name: String
@export var ai_mode:MODES = MODES.USER

@export_enum("o", "x") var team := "o"

func _play(board):
	match ai_mode:
		MODES.RANDOM:
			play_random(board)
		MODES.MINMAX:
			play_minmax(board)

func _finish_turn():
	Gamemaster.turn_finished.emit()


func play_random(board):
	for i in range(600):
		if (board.try_take(
			Vector2i(
				randi_range(0, board.map_size.x-1),
				randi_range(0, board.map_size.y-1),
			)
		)):
			Gamemaster.current_player._finish_turn()
			return
	print("PAS TROUVE D'EMPLACEMENT")

func play_minmax(board):
	var preview = board.get_preview()

func heuristic():
	pass
func win_condition():
	pass

func minmax_rec(preview:Array, depth:int, my_turn:bool):
	
	if depth == 0 or preview:
		return heuristic()
	
	var value:float
	if my_turn:
		value = -99999
		for child in ["all possibilities"]:
			value = max(value, minmax_rec(child, depth - 1, false))
	else:
		value = 99999
		for child in ["all possibilities"]:
			value = min(value, minmax_rec(child, depth - 1, true))
	return value
