extends Node2D

const SQUARE = preload("res://src/scenes/square/square.tscn")

const square_size := 125
var goban_size := 7
var map_size := Vector2i(goban_size, goban_size)
const winning_length:int = 3

@export var player_1:Player
@export var player_2:Player

class Square:
	var button:Button
	var team:String
		
	func _init(button) -> void:
		self.button = button
		self.team = "NEUTRAL"
	
	func is_mine():
		return team == Gamemaster.current_player.team
	
	func is_free():
		return team == "NEUTRAL"
	
	func take(player:Player):
		button.activate(player)
		player.nb_pierres -= 1
		team = player.team
		
	func clear():
		self.team = "NEUTRAL"
		button.activate()
	
var grid:Array[Array] #[[Square]]

func _ready() -> void:
	Gamemaster.players.append(player_1)
	Gamemaster.players.append(player_2)
	Gamemaster.board_node = self
	for i in map_size.x:
		grid.append([])
		var row := VBoxContainer.new()
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.custom_minimum_size.y = square_size
		$squares/HBoxContainer.add_child(row)
		for j in map_size.y:
			var new_square:Button = SQUARE.instantiate()
			new_square.grid_position = Vector2i(i, j)
			new_square.custom_minimum_size = Vector2i(square_size, square_size)
			new_square.board = self
			row.add_child(new_square)
			
			grid[i].append(Square.new(new_square))
	Gamemaster.launch_game()

func try_take(pos:Vector2i, try:bool = false) -> bool:
	for n in get_neighbors(pos):
		print(n)
	var surrounded_list:Array = []
	if grid[pos.x][pos.y].is_free():
		var other_player:Player = Gamemaster.players[(Gamemaster.current_player_index+1)%2]
		
		if !surrounded_iter(pos, Gamemaster.current_player.team, surrounded_list):
			if !try:
				grid[pos.x][pos.y].take(Gamemaster.current_player)
		else:
			return false
		
		for n in get_neighbors(pos):
			if grid[n .x][n .y].team == "NEUTRAL": continue
			if grid[n.x][n.y].team == Gamemaster.current_player.team: continue
			surrounded_list = []
			var v := surrounded_iter(n, other_player.team, surrounded_list)
			if v:
				for p in surrounded_list:
					if !try:
						grid[p.x][p.y].clear()
						print(p, "  TAKEN")
		if !try:
			check_win_condition(pos)
		return true
	return false
	
func get_neighbors(pos:Vector2i):
	var neighbors = []
	assert(goban_size >= 2, "minimum size : 2")
	if pos.x == 0:
		neighbors.append(Vector2i(pos.x+1, pos.y))
		if pos.y == 0:
			#neighbors.append(Vector2i(pos.x+1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
		elif pos.y == goban_size-1:
			#neighbors.append(Vector2i(pos.x+1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
		else:
			#neighbors.append(Vector2i(pos.x+1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
			#neighbors.append(Vector2i(pos.x+1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
	elif pos.x == goban_size-1:
		neighbors.append(Vector2i(pos.x-1, pos.y))
		if pos.y == 0:
			#neighbors.append(Vector2i(pos.x-1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
		elif pos.y == goban_size-1:
			#neighbors.append(Vector2i(pos.x-1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
		else:
			#neighbors.append(Vector2i(pos.x-1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
			#neighbors.append(Vector2i(pos.x-1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
	else:
		neighbors.append(Vector2i(pos.x-1, pos.y))
		neighbors.append(Vector2i(pos.x+1, pos.y))
		if pos.y == 0:
			#neighbors.append(Vector2i(pos.x-1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
			#neighbors.append(Vector2i(pos.x+1, pos.y+1))
		elif pos.y == goban_size-1:
			#neighbors.append(Vector2i(pos.x-1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
			#neighbors.append(Vector2i(pos.x+1, pos.y-1))
		else:
			#neighbors.append(Vector2i(pos.x-1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
			#neighbors.append(Vector2i(pos.x+1, pos.y+1))
			#neighbors.append(Vector2i(pos.x-1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
			#neighbors.append(Vector2i(pos.x+1, pos.y-1))
	return neighbors
	
var same_team_neighbors = []

func is_surrounded(pos:Vector2i, same_team_neighbors:Array, team:String):
	for n in get_neighbors(pos):
		if grid[n.x][n.y].team  == "NEUTRAL" :
			return false
		if grid[n.x][n.y].team == team and n not in same_team_neighbors:
			return false
	same_team_neighbors.append(pos)
	return true

func rec_surrounded(pos:Vector2i,same_team_neighbors:Array, team:String):
	if is_surrounded(pos, same_team_neighbors, team):
		return true
	else:
		for n in get_neighbors(pos):
			#print(n)
			if Gamemaster.current_player.team == grid[n.x][n.y].team and n not in same_team_neighbors:
				same_team_neighbors.append(pos)
				return rec_surrounded(n, same_team_neighbors, team)

func surrounded_iter(pos:Vector2i, team:String, same_team_neighbors:Array) -> bool:
	var to_check:Array[Vector2i] = [pos]
	
	while !to_check.is_empty():
		var current_pos:Vector2i = to_check.pop_back()
		same_team_neighbors.append(current_pos)
		var n_enemy_sides := 0
		for n in get_neighbors(current_pos):
			if grid[n.x][n.y].team  == "NEUTRAL" :
				return false
			#print(n)
			if team == grid[n.x][n.y].team and n not in same_team_neighbors:
				to_check.append(n)
			else:
				n_enemy_sides += 1
		if to_check.is_empty() && n_enemy_sides == 4: return true
	
	return true;

func preview():
	var res:Array
	
	for i in map_size.x:
		res.append([])
		for j in map_size.y:
			res[i].append(
				grid[i][j].team
			)
	return res
	
func check_can_play() -> bool:
	for i in map_size.x:
		for j in map_size.y:
			if try_take(Vector2i(i, j), true):
				return true
	return false
 
func check_win_condition(pos:Vector2i):
	var skip_turn = false # à faire : si les deux joueurs skippent leur tour
	if((player_1.nb_pierres == 0 and player_2.nb_pierres == 0) or skip_turn or !check_can_play()):
		var nb_pierre_1 = 0
		var nb_pierre_2 = 0
		for i in map_size.x:
			for j in map_size.y:
				if grid[i][j].team == player_1.team:
					nb_pierre_1 += 1
				else:
					nb_pierre_2 += 1
		var winner = player_1 if nb_pierre_1 > nb_pierre_2 else player_2
		Gamemaster.win(winner)
	## lines
	#var count := 1
	#for i in range(1, winning_length):
		#if pos.x+i >= map_size.x: break
		#if grid[pos.x+i][pos.y].is_mine():
			#count+=1
		#else: break
	#for i in range(1, winning_length):
		#if pos.x-i < 0: break
		#if grid[pos.x-i][pos.y].is_mine():
			#count+=1
		#else: break
	#if count >= winning_length:
		#Gamemaster.win()
		#
	## columns
	#count = 1
	#for i in range(1, winning_length):
		#if pos.y+i >= map_size.y: break
		#if grid[pos.x][pos.y+i].is_mine():
			#count+=1
		#else: break
	#for i in range(1, winning_length):
		#if pos.y-i < 0: break
		#if grid[pos.x][pos.y-i].is_mine():
			#count+=1
		#else: break
	#if count >= winning_length:
		#Gamemaster.win()
	#
	## diag " / "
	#count = 1
	#for i in range(1, winning_length):
		#if pos.y+i >= map_size.y or pos.x+i >= map_size.x: break
		#if grid[pos.x+i][pos.y+i].is_mine():
			#count+=1
		#else: break
	#for i in range(1, winning_length):
		#if pos.y-i <0 or pos.x-i < 0: break
		#if grid[pos.x-i][pos.y-i].is_mine():
			#count+=1
		#else: break
	#if count >= winning_length:
		#Gamemaster.win()
	#
		## diag " \ "
	#count = 1
	#for i in range(1, winning_length):
		#if pos.y+i >= map_size.y or pos.x-i <0: break
		#if grid[pos.x-i][pos.y+i].is_mine():
			#count+=1
		#else: break
	#for i in range(1, winning_length):
		#if pos.y-i <0 or pos.x+i >= map_size.x: break
		#if grid[pos.x+i][pos.y-i].is_mine():
			#count+=1
		#else: break
	#if count >= winning_length:
		#Gamemaster.win()
