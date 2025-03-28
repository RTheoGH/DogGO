extends Control

func _ready() -> void:
	print("hello")

func _on_launch_pressed() -> void:
	pass # Replace with function body.
	get_tree().change_scene_to_packed(preload("res://src/scenes/board/board.tscn"))
