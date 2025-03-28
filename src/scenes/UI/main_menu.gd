extends Control

func _ready() -> void:
	print("hello")
	

func _on_start_pressed() -> void:
	pass # Replace with function body.	
	get_tree().change_scene_to_packed(preload("res://src/scenes/UI/setup_game.tscn"))
	
func _on_quit_pressed() -> void:
	pass # Replace with function body.
	get_tree().quit()
	
	
func _on_options_pressed() -> void:
	pass # Replace with function body.
	print("Load Options Menu")
