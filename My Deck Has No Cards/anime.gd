extends Node

@onready var panel = get_tree().get_first_node_in_group("Anime")
@onready var flashbang = get_tree().get_first_node_in_group("Flash")
var shaking = false

func rebind():
	panel = get_tree().get_first_node_in_group("Anime")
	flashbang = get_tree().get_first_node_in_group("Flash")
	panel.visible = false
	flashbang.visible = true
	flashbang.color = Color.TRANSPARENT

# Called when the node enters the scene tree for the first time.
func _ready():
	panel.visible = false
	flashbang.visible = true
	flashbang.color = Color.TRANSPARENT

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

func flash():
	var t = get_tree().create_tween()
	t.tween_property(flashbang, "color", Color.WHITE, 0.05)
	t.tween_property(flashbang, "color", Color.TRANSPARENT, 1)

func _on_timer_timeout():
	shaking = false
	panel.position = Vector2.ZERO
