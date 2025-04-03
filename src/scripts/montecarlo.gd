extends Node

var move_idx:Vector2i
var team:String
var adversary:String
var winning_length:int
var board_size:Vector2i

var max_width := 30
var max_depth := 4

func play(team:String, adversary:String, board_size:Vector2i, board:Array):
	self.team = team
	self.adversary = adversary
	self.winning_length = winning_length
	self.board_size = board_size
	
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


func get_all_moves(board:Array, team:String):
	move_idx = Vector2i.ZERO
	var res:Array = []
	
	while (true):
		var idx = get_next_move(board)
		if idx == null: break #always returns: at the end it returns null
		res.append(idx)
	
	return res

func heuristic(board):
	var max_win_score_team := 0
	var max_win_score_adversary := 0
	for i in board_size.x:
		for j in board_size.y:
			var team:String = board[i][j]
			
			var win_score:int = win_condition(board, Vector2i(i, j), team)
			if team == self.team:
				max_win_score_team = max(win_score, max_win_score_team)
			else:
				max_win_score_adversary = max(win_score, max_win_score_adversary)
	
	if (max_win_score_team) >= winning_length: return 77777
	if (max_win_score_adversary) >= winning_length: return -77777
	
	return max_win_score_team #- max_win_score_adversary

#only the first depth needs to kep track of the move
func montecarlo(board:Array):
	var time:int = Time.get_ticks_msec()
	var value:float
	var best_move:Vector2i = Vector2i(-1, -1)
	#printboard((board))
	
	value = -99999
	var moves:Array = get_all_moves(board, team)
	if moves.is_empty(): return best_move
	for move in moves:
		var newboard :Array = getModifiedBoard(board, team, move)
		
		#if win_condition(newboard, move, team) >= winning_length: return move
		
		var res = minmax_rec(newboard, max_depth, false, move)
		if res > value:
			value = res
			best_move = move
		#print("| ",value)
	print ("playing ", best_move, " with value ", value, " (decided in ",Time.get_ticks_msec() - time, "ms).")
	return best_move #Vector2i(best_move.y, best_move.x)

func minmax_rec(board:Array, depth:int, my_turn:bool, last_move:Vector2i):
	if depth <= 0:
		return heuristic(board)

	if my_turn && win_condition(board, last_move, adversary) >= winning_length:
		#printboard(newboard)
		return -88888

	if !my_turn && win_condition(board, last_move, team) >= winning_length:
		#printboard(newboard)
		return 88888

	var value:float
	if my_turn:
		value = -99999
		var moves:Array = get_all_moves(board, team)
		#print("\t".repeat(max_depth - depth), "| DEPTH ", depth)
		if moves.is_empty(): return heuristic(board)
		for move in moves:
			
			var newboard :Array = getModifiedBoard(board, team, move)
			
			#if win_condition(newboard, move, team) >= winning_length: return 88888
			value = max(value, minmax_rec(newboard, depth-1, false, move))
			#print("\t".repeat(max_depth - depth), "| ",value)
			
	else:
		value = 99999
		var moves:Array = get_all_moves(board, adversary)
		if moves.is_empty(): return heuristic(board)
		#print("\t".repeat(max_depth - depth), "| DEPTH ", depth)
		for move in moves:
			var newboard :Array = getModifiedBoard(board, adversary, move)
			
			#if win_condition(newboard, move, adversary) >= winning_length: return -88888
			
			value = min(value, minmax_rec(newboard, depth-1, true, move))
	#print("\t".repeat(max_depth - depth), "| ",value)
	return value
	
# returns the closest to get to the solution. If win_condition returns >winning_length, it's a win.
func win_condition(grid, pos:Vector2i, team:String):
	# lines
	var global_count := 0
	var count := 1
	for i in range(1, winning_length):
		if pos.x+i >= board_size.x: break
		if grid[pos.x+i][pos.y] == team:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.x-i < 0: break
		if grid[pos.x-i][pos.y] == team:
			count+=1
		else: break
	
	
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	# columns
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= board_size.y: break
		if grid[pos.x][pos.y+i] == team:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i < 0: break
		if grid[pos.x][pos.y-i] == team:
			count+=1
		else: break
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	
	# diag " / "
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= board_size.y or pos.x+i >= board_size.x: break
		if grid[pos.x+i][pos.y+i] == team:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i <0 or pos.x-i < 0: break
		if grid[pos.x-i][pos.y-i] == team:
			count+=1
		else: break
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	
		# diag " \ "
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= board_size.y or pos.x-i <0: break
		if grid[pos.x-i][pos.y+i] == team:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i <0 or pos.x+i >= board_size.x: break
		if grid[pos.x+i][pos.y-i] == team:
			count+=1
		else: break
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	
	return global_count

func win_possibility(grid, pos:Vector2i, team:String):
	# lines
	var global_count := 0
	var count := 1
	for i in range(1, winning_length):
		if pos.x+i >= board_size.x: break
		if grid[pos.x+i][pos.y] in [team, "NEUTRAL"]:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.x-i < 0: break
		if grid[pos.x-i][pos.y] in [team, "NEUTRAL"]:
			count+=1
		else: break
	
	
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	# columns
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= board_size.y: break
		if grid[pos.x][pos.y+i] in [team, "NEUTRAL"]:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i < 0: break
		if grid[pos.x][pos.y-i] in [team, "NEUTRAL"]:
			count+=1
		else: break
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	
	# diag " / "
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= board_size.y or pos.x+i >= board_size.x: break
		if grid[pos.x+i][pos.y+i] in [team, "NEUTRAL"]:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i <0 or pos.x-i < 0: break
		if grid[pos.x-i][pos.y-i] in [team, "NEUTRAL"]:
			count+=1
		else: break
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	
		# diag " \ "
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= board_size.y or pos.x-i <0: break
		if grid[pos.x-i][pos.y+i] in [team, "NEUTRAL"]:
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i <0 or pos.x+i >= board_size.x: break
		if grid[pos.x+i][pos.y-i] in [team, "NEUTRAL"]:
			count+=1
		else: break
	if count >= winning_length:
		return winning_length
	global_count = max(global_count, count)
	
	return global_count


func printboard(board:Array):
	print("BOARD: ")
	for i in board:
		print("\t", i)
	print("$$$$$")
