extends Node

var move_idx:Vector2i
var team:String
var adversary:String
var winning_length:int
var board_size:Vector2i

var current_id:Dictionary = {"x":0, "o":0} # Pour incrémenter le numéro du groupe quand on pose une pierre 
var pos_deg_liberte:Dictionary = {"x":{}, "o":{}} # Pour un id de groupe, donne la position des libertés
var groups:Dictionary = {"x":{}, "o":{}} # Pour un id de groupe, donne tous les squares présents dans le groupe

var max_test := 30
var max_width := 5
var max_depth := 4

func play(team:String, adversary:String, board_size:Vector2i, board:Array, preview:Dictionary):
	self.team = team
	self.adversary = adversary
	self.winning_length = winning_length
	self.board_size = board_size
	self.current_id = preview["current_id"]
	self.pos_deg_liberte = preview["pos_deg_liberte"]
	self.groups = preview["groups"]
	
	return montecarlo(board);
	
	

func getModifiedBoard(board:Array, team:String, idx:Vector2i):
	var res:Array = board.duplicate()
	for i in res.size():
		res[i] = res[i].duplicate()
	res[idx.x][idx.y] = team
	return res

func get_next_move(board:Array):
	while (
		move_idx.x < board_size.x && move_idx.y < board_size.y
	):
		var val:String = board[move_idx.x][move_idx.y]
		var curr_move := move_idx
		move_idx.x += 1
		if (move_idx.x == board_size.x): #FIXME bon indice?
			move_idx = Vector2i(0, move_idx.y+1)
			
		if val == "NEUTRAL":
			return curr_move
	return null

func get_neighbors(pos:Vector2i):
	var neighbors = []
	assert(board_size[0] >= 2, "minimum size : 2")
	
	for v in [Vector2i(pos.x+1, pos.y), Vector2i(pos.x-1, pos.y), Vector2i(pos.x, pos.y+1), Vector2i(pos.x, pos.y-1),]:
		if 0 <= v.x && v.x <= board_size[0]-1 && 0 <= v.y && v.y <= board_size[0]-1:
			neighbors.push_back(v)
	return neighbors
	
#func try_take(pos:Vector2i, board:Array) -> bool:
	

func get_all_moves(board:Array, team:String):
	
	move_idx = Vector2i.ZERO
	var res:Array = []
	
	while (true):
		var idx = get_next_move(board)
		if idx == null: break #always returns: at the end it returns null
		res.append(idx)
	
	return res

func heuristic(board):
	return 2

func choose_moves(n:int, moves:Array[Vector2i], board:Array, team:String):
	var res:Array[Vector2i] = []
	for i in min(n , moves.size()):
		res.append(moves.pop_at(randi_range(0, moves.size())))
		
	return res

func getHeuristicSortedList(moves:Array[Vector2i], board:Array, team:String):
	var heuristics:Array[float] = []
	for move in moves: heuristics.append(heuristic(move))

func montecarlo(board:Array):
	var time:int = Time.get_ticks_msec()
	
	var value:float = -99999999
	var best_move:Vector2i = Vector2i(-1, -1)
	#printboard((board))
	
	var moves:Array = get_all_moves(board, team)
	if moves.is_empty(): return best_move
	
	var to_try = choose_moves(max_test, moves, board, team)
	
	for move in to_try:
		var newboard :Array = getModifiedBoard(board, team, move)
		
		var res = montecarlo_rec(newboard, max_depth, false, move)
		if res > value:
			value = res
			best_move = move
	print ("playing ", best_move, " with value ", value, " (decided in ",Time.get_ticks_msec() - time, "ms).")
	return best_move

func montecarlo_rec(board:Array, depth:int, my_turn:bool, last_move:Vector2i):
	var best_move:Vector2i = Vector2i(-1, -1)
	var value:float = -9999.0
	var moves:Array = get_all_moves(board, team)
	if moves.is_empty(): return best_move
	
	var to_try = choose_moves(max_test, moves, board, team)
	
	if my_turn:
		for move in to_try:
			var newboard :Array = getModifiedBoard(board, team, move)
			
			var res = montecarlo_rec(newboard, max_depth, false, move)
			if res > value:
				value = res
				best_move = move
	else:
		for move in to_try:
			var newboard :Array = getModifiedBoard(board, team, move)
			
			var res = montecarlo_rec(newboard, max_depth, true, move)
			if res > value:
				value = res
				best_move = move
	

func win_possibility(grid, pos:Vector2i, team:String):
	# lines
	pass


func printboard(board:Array):
	print("BOARD: ")
	for i in board:
		print("\t", i)
	print("$$$$$")
