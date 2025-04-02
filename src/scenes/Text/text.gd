extends Node2D

@onready var text_node = $RichTextLabel
@onready var text_bg = $ColorRect
@onready var timer = $Timer

const char_time = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false

func show_pass(wait_time = 2):
	visible = true
	
	var duration = text_node.text.length() * char_time
	var tween:Tween = create_tween()
	tween.tween_property(text_node,"visible_characters",text_node.text.length(),duration)
	
	tween.finished.connect(func():
		timer.start(wait_time)
	)

func _on_timer_timeout() -> void:
	visible = false
