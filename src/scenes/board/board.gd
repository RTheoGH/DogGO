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
	
	func take():
		button.activate(Gamemaster.current_player)
		team = Gamemaster.current_player.team
	
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

func try_take(pos:Vector2i) -> bool:
	for n in get_neighbors(pos):
		print(n)
	if grid[pos.x][pos.y].is_free():
		grid[pos.x][pos.y].take()
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
		elif pos.y == goban_size:
			#neighbors.append(Vector2i(pos.x+1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
		else:
			#neighbors.append(Vector2i(pos.x+1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
			#neighbors.append(Vector2i(pos.x+1, pos.y-1))
			neighbors.append(Vector2i(pos.x, pos.y-1))
	elif pos.x == goban_size:
		neighbors.append(Vector2i(pos.x-1, pos.y))
		if pos.y == 0:
			#neighbors.append(Vector2i(pos.x-1, pos.y+1))
			neighbors.append(Vector2i(pos.x, pos.y+1))
		elif pos.y == goban_size:
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
		elif pos.y == goban_size:
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

func preview():
	var res:Array
	
	for i in map_size.x:
		res.append([])
		for j in map_size.y:
			res[i].append(
				grid[i][j].team
			)
	return res

func check_win_condition(pos:Vector2i):
	# lines
	var count := 1
	for i in range(1, winning_length):
		if pos.x+i >= map_size.x: break
		if grid[pos.x+i][pos.y].is_mine():
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.x-i < 0: break
		if grid[pos.x-i][pos.y].is_mine():
			count+=1
		else: break
	if count >= winning_length:
		Gamemaster.win()
		
	# columns
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= map_size.y: break
		if grid[pos.x][pos.y+i].is_mine():
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i < 0: break
		if grid[pos.x][pos.y-i].is_mine():
			count+=1
		else: break
	if count >= winning_length:
		Gamemaster.win()
	
	# diag " / "
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= map_size.y or pos.x+i >= map_size.x: break
		if grid[pos.x+i][pos.y+i].is_mine():
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i <0 or pos.x-i < 0: break
		if grid[pos.x-i][pos.y-i].is_mine():
			count+=1
		else: break
	if count >= winning_length:
		Gamemaster.win()
	
		# diag " \ "
	count = 1
	for i in range(1, winning_length):
		if pos.y+i >= map_size.y or pos.x-i <0: break
		if grid[pos.x-i][pos.y+i].is_mine():
			count+=1
		else: break
	for i in range(1, winning_length):
		if pos.y-i <0 or pos.x+i >= map_size.x: break
		if grid[pos.x+i][pos.y-i].is_mine():
			count+=1
		else: break
	if count >= winning_length:
		Gamemaster.win()
