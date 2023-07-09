extends Node

@onready var panel = get_tree().get_first_node_in_group("Anime")
var shaking = false
var is_ready = false

signal readied

# Called when the node enters the scene tree for the first time.
func _ready():
	panel.visible = false
	is_ready = true
	readied.emit()

func _process(delta):
	if shaking:
		var offset = Vector2(randi_range(-2, 2), randi_range(-2, 2))
		panel.position = offset

func end():
	panel.visible = false

func shot(numstr):
	panel.texture = load("res://anime/shot" + numstr + ".png")
	panel.visible = true

func shake(duration):
	shaking = true
	$Timer.wait_time = duration
	$Timer.start()

func _on_timer_timeout():
	shaking = false
	panel.position = Vector2.ZERO
