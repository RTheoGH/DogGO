extends Node

signal turn_finished

var board_node:Node
var players = []
var boardsize:int = 7

var game_on:bool
var can_play := true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_on = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var current_player_index:int
var current_player:Player

func launch_game():
	print("in gamemaster boardsize :",boardsize)
	current_player_index = 0
	can_play = true
	game_on = true
	current_player = players[0]
	while (game_on):
		await next_turn()

func next_turn():
	board_node.show_turn_message()
	print("Playing: ", current_player.name)
	print("awaiting turn finished...")
	can_play = true
	current_player._play.call_deferred(board_node)
	await turn_finished
	if !game_on: return
		
	print("turn finished\n")
	current_player_index = (current_player_index+1) % players.size()
	current_player = players[current_player_index]
	
	can_play = false
	await get_tree().create_timer(0.7).timeout
	
	if game_on:
		board_node.check_win_condition()

func win(player: Player):
	game_on = false
	print("WINNER: ", player.team)

func restart_with_same_settings(): #changé parce que pas le temps
	game_on = false
	can_play = true
	players = []
	turn_finished.emit()
	get_tree().change_scene_to_packed(preload("res://src/scenes/UI/setup_game.tscn"))

func to_menu():
	game_on = false
	can_play = true
	turn_finished.emit()
	get_tree().change_scene_to_packed(preload("res://src/scenes/UI/mainmenue.tscn"))
