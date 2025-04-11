extends Resource
class_name Player


enum MODES {USER, RANDOM, MONTECARLO}

enum HEURISTICS {DUMB}

@export var name: String
@export var ai_mode:MODES = MODES.MONTECARLO
@export var heuristic:HEURISTICS = HEURISTICS.DUMB
@export var nb_pierres = 25

@export_enum("o", "x") var team := "o"

var montecarlo = preload("res://src/scripts/montecarlo.gd").new()

func _play(board):
	var heuristic_fun:Callable;
	
	
	
	match ai_mode:
		MODES.RANDOM:
			play_random(board)
		MODES.MONTECARLO:
			play_montecarlo(board)

func _finish_turn():
	Gamemaster.turn_finished.emit()


func play_random(board):
	for i in range(600):
		
		var essai :=  Vector2i(
				randi_range(0, board.map_size.x-1),
				randi_range(0, board.map_size.y-1),
			)
		if (board.try_take(essai)):
			await board.take(essai)
			Gamemaster.current_player._finish_turn()
			return
	print("PAS TROUVE D'EMPLACEMENT")


func play_montecarlo(board):
	var move = montecarlo.play(team, "x" if team == "o" else "o", board.map_size, board)
	
	if board.try_take(move):
		await board.take(move)
		Gamemaster.current_player._finish_turn()
	else:
		print("DEFAULTING TO ARNDOM")
		play_random(board)
