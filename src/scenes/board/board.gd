extends Node2D

const SQUARE = preload("res://src/scenes/square/square.tscn")

var square_size := 125
var goban_size := Gamemaster.boardsize
var map_size := Vector2i(goban_size, goban_size)
const winning_length:int = 3
var current_id:Dictionary = {"x":0, "o":0} # Pour incrémenter le numéro du groupe quand on pose une pierre 
var pos_deg_liberte:Dictionary = {"x":{}, "o":{}} # Pour un id de groupe, donne la position des libertés
var groups:Dictionary = {"x":{}, "o":{}} # Pour un id de groupe, donne tous les squares présents dans le groupe

@export var player_1:Player
@export var player_2:Player

class Square:
	var button:Button
	var team:String
	var group_id:int
		
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
		button.clear()
	
var grid:Array[Array] #[[Square]]

func _ready() -> void:
	$new.hide()
	$exit.hide()
	$win.hide()
	$show_board.hide()
	$squares.show()
	print("boardsize : ",Gamemaster.boardsize)
	if Gamemaster.players.is_empty():
		Gamemaster.players.append(player_1)
		Gamemaster.players.append(player_2)
	Gamemaster.board_node = self
	
	square_size = 125 * (7.0 / Gamemaster.boardsize)
	
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

func clear_all(team:String, group_id:int):
	await get_tree().create_timer(0.2).timeout
	for p in groups[team][group_id]:
		await get_tree().create_timer(0.15).timeout
		
		for n in get_neighbors(p):
			var n_team:String = grid[n.x][n.y].team
			var n_id:int = grid[n.x][n.y].group_id
			
			if n_team != "NEUTRAL":
				pos_deg_liberte[n_team][n_id].append(p)
		
		grid[p.x][p.y].clear()
	
	groups[team].erase(group_id)
	pos_deg_liberte[team].erase(group_id)

func try_take(pos:Vector2i) -> bool:
	if grid[pos.x][pos.y].team != "NEUTRAL": return false
	for n in get_neighbors(pos):
		if grid[n.x][n.y].team == "NEUTRAL":
			print("yes")
			return true
		elif grid[n.x][n.y].team == Gamemaster.current_player.team && (pos_deg_liberte[Gamemaster.current_player.team][grid[n.x][n.y].group_id].size() > 1):
			return true
			
		elif grid[n.x][n.y].team != Gamemaster.current_player.team:
			
			if pos_deg_liberte[grid[n.x][n.y].team][grid[n.x][n.y].group_id].size() <= 1:
				return true
			
	return false

func take(pos:Vector2i):
	var curr_team := Gamemaster.current_player.team
	var curr_id:int = current_id[curr_team]
	print(grid[pos.x][pos.y].group_id)
	grid[pos.x][pos.y].take(Gamemaster.current_player)
	grid[pos.x][pos.y].group_id = curr_id
	pos_deg_liberte[curr_team][curr_id] = []
	groups[curr_team][ curr_id ] = [pos]
	
	update_nb_pions_placed()
	
	var enemy_groups_surrounded := []
	for n in get_neighbors(pos):
		var n_team:String = grid[n.x][n.y].team
		var n_id:int = grid[n.x][n.y].group_id
		
		
		if n_team == "NEUTRAL" : 
			if n not in pos_deg_liberte[curr_team][curr_id]:
				pos_deg_liberte[curr_team][curr_id].append(n)
	
		elif n_team == curr_team:
			
			for j in pos_deg_liberte[curr_team][n_id]:
					if (j != pos) and (j not in pos_deg_liberte[curr_team][ current_id[curr_team] ]):
						pos_deg_liberte[curr_team][ current_id[curr_team] ].append(j)
			
			for g in groups[n_team][n_id]:
				grid[g.x][g.y].group_id = grid[pos.x][pos.y].group_id
				groups[curr_team][grid[pos.x][pos.y].group_id].append(g)
			groups[n_team].erase(n_id)
			pos_deg_liberte[n_team].erase(n_id)
			
		else:
			pos_deg_liberte[n_team][n_id].erase(pos)
			if pos_deg_liberte[n_team][n_id].is_empty():
				await clear_all(n_team, n_id)
				pos_deg_liberte[n_team].erase(n_id)
	current_id[curr_team] += 1
	print("les tailels en o: ")
	for i in pos_deg_liberte["o"].keys():
		print(i, " ", pos_deg_liberte["o"][i].size())
	print("les tailles en x: ")
	for i in pos_deg_liberte["x"].keys():
		print(i, " ", pos_deg_liberte["x"][i].size())

func get_neighbors(pos:Vector2i):
	var neighbors = []
	assert(goban_size >= 2, "minimum size : 2")
	
	for v in [Vector2i(pos.x+1, pos.y), Vector2i(pos.x-1, pos.y), Vector2i(pos.x, pos.y+1), Vector2i(pos.x, pos.y-1),]:
		if 0 <= v.x && v.x <= goban_size-1 && 0 <= v.y && v.y <= goban_size-1:
			neighbors.push_back(v)
	return neighbors

func preview():
	var res:Array
	
	for i in map_size.x:
		res.append([])
		for j in map_size.y:
			res[i].append(
				grid[i][j].team
			)
	return {"board" : res, "pos_deg_liberte" : pos_deg_liberte, "groups" : groups, "current_id" : current_id}
	
func check_can_play() -> bool:
	for i in map_size.x:
		for j in map_size.y:
			if await try_take(Vector2i(i, j)):
				return true
	return false
 
func check_win_condition(pos:Vector2i):
	var skip_turn = false # à faire : si les deux joueurs skippent leur tour
	if((player_1.nb_pierres == 0 and player_2.nb_pierres == 0) or skip_turn or !(await check_can_play())):
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
		announce_winner()

func _on_pass_pressed() -> void:
	var tour = Gamemaster.current_player.team
	print(tour)
	if tour == "o":
		$Chase/Text.show_pass()
	elif tour == "x":
		$Marshall/Text.show_pass()
	Gamemaster.current_player._finish_turn()
	show_turn_message()

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_new_pressed() -> void:
	Gamemaster.restart_with_same_settings()
	#$squares.show()

func get_nb_pions_placed():
	var cpt_chase = 0
	var cpt_marshall = 0
	for i in map_size.x:
		for j in map_size.y:
			if grid[i][j].team == "x":
				cpt_marshall += 1
			if grid[i][j].team == "o":
				cpt_chase += 1
				
	return [cpt_marshall,cpt_chase]
	
func update_nb_pions_placed():
	var list_pions = get_nb_pions_placed()
	$Chase/ColorRect2/Chase_cpt.text = str("[center]",list_pions[1])
	$Marshall/ColorRect2/Marshall_cpt.text = str("[center]",list_pions[0])

func announce_winner():
	var text = ""
	var list_pions = get_nb_pions_placed()
	$squares.hide()
	
	if list_pions[0] > list_pions[1]:
		text = "[center][color=red]Marshall[color=black] gagne !"
	elif list_pions[0] < list_pions[1]:
		text = "[center][color=blue]Chase[color=black] gagne !"
	else:
		text = "[center]Match nul !"
	$win/win_text.text = text
	$win.show()
	$exit.show()
	$new.show()
	$show_board.show()

func _on_show_board_pressed() -> void:
	if $show_board.text == "Cache la grille":
		$show_board.text = "Affiche la grille"
	else:
		$show_board.text = "Cache la grille"
		
	print($squares.is_visible())
	print($win.is_visible())
	
	if $squares.is_visible():
		$squares.hide()
	else:
		$squares.show()
	
	if $win.is_visible():
		$win.hide()
	else:
		$win.show()
		
func show_turn_message():
	var tour = Gamemaster.current_player.team
	
	print(tour)
	if tour == "o":
		$turn/turn_text.text = "[center]C'est au tour de [color=blue]Chase[color=black] de jouer"
	elif tour == "x":
		$turn/turn_text.text = "[center]C'est au tour de [color=red]Marshall[color=black] de jouer"
	else:
		$turn/turn_text.text = "Erreur tour"
