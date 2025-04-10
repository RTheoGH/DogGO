extends Node2D

@export var on_right := false

@onready var text_node = $RichTextLabel
@onready var text_bg = $Panel
@onready var timer = $Timer

const char_time = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	
	if on_right:
		var p := ($Panel.get_theme_stylebox("panel") as StyleBoxFlat)
		p.corner_radius_bottom_left = 25
		p.corner_radius_bottom_right = 0

func show_pass(wait_time = 2):
	visible = true
	
	if on_right:
		text_node.text = "[color=red]"+text_node.text
	else:
		text_node.text = "[color=blue]"+text_node.text
	
	var duration = text_node.text.length() * char_time
	var tween:Tween = create_tween()
	tween.tween_property(text_node,"visible_characters",text_node.text.length(),duration)
	
	tween.finished.connect(func():
		timer.start(wait_time)
	)

func _on_timer_timeout() -> void:
	visible = false
