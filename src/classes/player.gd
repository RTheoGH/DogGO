extends Resource
class_name Player


enum MODES {USER, RANDOM, MONTECARLO}

enum HEURISTICS {DUMB}

@export var name: String
@export var ai_mode:MODES = MODES.USER
@export var heuristic:HEURISTICS = HEURISTICS.DUMB
@export var nb_pierres = 25

@export_enum("o", "x") var team := "o"

var montecarlo = preload("res://src/scripts/montecarlo.gd").new()

func _play(board):
	var heuristic_fun:Callable;
	match heuristic:
		HEURISTICS.DUMB:
			heuristic_fun = heuristic_dumb
	
	
	
	match ai_mode:
		MODES.RANDOM:
			play_random(board)
		MODES.MONTECARLO:
			play_montecarlo(board)

func _finish_turn():
	Gamemaster.turn_finished.emit()


func play_random(board):
	for i in range(600):
		if (await board.try_take(
			Vector2i(
				randi_range(0, board.map_size.x-1),
				randi_range(0, board.map_size.y-1),
			)
		)):
			
			Gamemaster.current_player._finish_turn()
			return
	print("PAS TROUVE D'EMPLACEMENT")

func play_minmax(board):
	var preview = board.preview()

func heuristic_dumb():
	pass
	

func win_condition():
	pass


func play_montecarlo(board):
	var preview = board.preview()
	montecarlo.play(team, "x", board.map_size, board, preview)
	
func montercarlo_rec(preview:Array, n_moves:int, n_bests:int, k:int):
	var possible_moves:Array[Vector2i] = []
	
