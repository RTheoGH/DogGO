extends Control

func _ready() -> void:
	print("hello")
	
	
const setup = "res://src/scenes/UI/setup_game.tscn"

func _on_start_pressed() -> void:
	pass # Replace with function body.	
	get_tree().change_scene_to_file(setup)
	
func _on_quit_pressed() -> void:
	pass # Replace with function body.
	get_tree().quit()
	
	
func _on_options_pressed() -> void:
	pass # Replace with function body.
	print("Load Options Menu")

func _on_start_mouse_entered() -> void:
	$Menu.play()

func _on_quit_mouse_entered() -> void:
	$Menu.play()

func _on_options_mouse_entered() -> void:
	$Menu.play()
