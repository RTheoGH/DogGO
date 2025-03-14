extends Node

signal turn_finished

var board_node:Node
var players = []

var game_on:bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	game_on = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var current_player_index:int
var current_player:Player

func launch_game():
	current_player_index = 0
	current_player = players[0]
	while (game_on):
		await next_turn()

func next_turn():
	await get_tree().create_timer(0.5).timeout
	print("Playing: ", current_player.name)
	print("awaiting turn finished...")
	current_player._play.call_deferred(board_node)
	await turn_finished
	print("turn finished\n")
	current_player_index = (current_player_index+1) % players.size()
	current_player = players[current_player_index]

func win():
	game_on = false
	print("WINNER: ", current_player.team)
