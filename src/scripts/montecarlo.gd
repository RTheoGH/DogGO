extends Node

var move_idx:Vector2i
var team:String
var adversary:String
var winning_length:int
var board_size:Vector2i
var real_board:Node

var current_id:Dictionary = {"x":0, "o":0} # Pour incrémenter le numéro du groupe quand on pose une pierre 
var pos_deg_liberte:Dictionary = {"x":{}, "o":{}} # Pour un id de groupe, donne la position des libertés
var groups:Dictionary = {"x":{}, "o":{}} # Pour un id de groupe, donne tous les squares présents dans le groupe

var max_test := 70
var max_width := 5
var max_depth := 4

func play(team:String, adversary:String, board_size:Vector2i, real_board):
	self.team = team
	self.adversary = adversary
	self.winning_length = winning_length
	self.board_size = board_size
	self.real_board = real_board
	return montecarlo(real_board);
	



func choose_moves(n:int, moves:Array[Vector2i], board, team:String):
	var res:Array[Vector2i] = []
	for i in min(n , moves.size()):
		res.append(moves.pop_at(randi_range(0, moves.size()-1)))
		
	return res
func get_all_moves(board, team:String, adversary:String):
	var res:Array[Vector2i] = []
	
	for i in range(board_size.x-1):
		for j in range(board_size.y-1):
			var p = Vector2i(i, j)
			if real_board.try_take(p):
				res.append(p)
	
	return res


func evaluate_move(board, pos:Vector2i, team:String, adversary:String) -> int:
	var res = 0
	if has_created_eye(board, pos, team):
		res += 1
	
	res += reduces_enemy(board, pos, team)
	
	res += take_enemy(pos, team, adversary)
	return res

#FIXME : peut-être passer les dicos en paramètre pour pouvoir les dupliquer en fonction de la récursion ?
func montecarlo(board):
	var time:int = Time.get_ticks_msec()
	var value := -999
	var moves:Array[Vector2i] = get_all_moves(board, team, adversary)
	if moves.is_empty(): return null
	
	var to_try = choose_moves(max_test, moves, board, team)
	var best_move
	for move in to_try:
		var res = evaluate_move(board, move, team, adversary)
		if res > value:
			value = res
			best_move = move
			
	print("MOVE CHOSEN: ", best_move)
	return best_move
	
func is_eye(board, pos:Vector2i, team:String) -> bool:
	var neighbors = real_board.get_neighbors(pos)
	for n in neighbors:
		if real_board.grid[pos.x][pos.y].team != team:
			return false
	return true

func has_created_eye(board, pos:Vector2i, team:String) -> bool:
	for n in real_board.get_neighbors(pos):
		if is_eye(board, n, team):
			return true
	return false

func reduces_enemy(board, pos, team):
	for n in real_board.get_neighbors(pos):
		if real_board.grid[n.x][n.y].team == adversary:
			var n_group = real_board.grid[n.x][n.y].group_id
			return max(1, 4 - real_board.pos_deg_liberte[adversary][n_group].size())
	return 0

func take_enemy(pos:Vector2i, team:String, adversary:String):
	var res = 0
	for n in real_board.get_neighbors(pos):
		if real_board.grid[n.x][n.y].team == adversary:
			var n_group = real_board.grid[n.x][n.y].group_id
			if real_board.pos_deg_liberte[adversary][n_group].size() == 1:
				res += real_board.groups[adversary][n_group].size()
	return res

func printboard(board:Array):
	print("BOARD: ")
	for i in board:
		print("\t", i)
	print("$$$$$")
