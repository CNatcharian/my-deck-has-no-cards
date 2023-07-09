extends Node2D
class_name DialogueUI

@onready var box = $DialogueBox
@onready var text = $DialogueBox/DText
@onready var portrait = $DialogueBox/Portrait
@onready var speaker = $DialogueBox/Speaker

var current_dlg: DialogueResource = null
var next_line_id: String
var waiting_for_input = false
var extra_states: Array[Node] = []
var mut_behaviour = DialogueManager.MutationBehaviour.Wait

signal dialogue_ended

func _ready():
	box.visible = false
	text.finished_typing.connect(on_finished_typing)
	print("dialogue Initialized.")

func _process(delta):
	pass

## Listen for the user to dismiss the current dialogue line
func _unhandled_input(event: InputEvent):
	if waiting_for_input:
		if event.is_action_pressed("progress"):
			continue_dlg()
	# only the dialogue window is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()

func load_dlg(dlg_name: String):
	var dlg_path = "res://dialogue/" + dlg_name + ".dialogue"
	return load(dlg_path)

func show_dlg(dlg_name: String, extras: Array[Node] = [], mut_b = DialogueManager.MutationBehaviour.Wait):
	current_dlg = load_dlg(dlg_name)
	self.extra_states = extras
	self.mut_behaviour = mut_b
	var line: DialogueLine = await current_dlg.get_next_dialogue_line("start", [$".."])
	display_line(line)

func hide_dlg():
	waiting_for_input = false
	box.visible = false
	dialogue_ended.emit()

func display_line(line: DialogueLine):
	next_line_id = line.next_id
	box.visible = true
	speaker.text = line.character if line.character != null else ""
	portrait.texture = load("res://ui/portrait_" + line.character.to_lower() + ".png")
	text.dialogue_line = line
	text.type_out()

## Assign this to handle the finished_typing signal from the dialogue label
func on_finished_typing():
	print("Done typing")
	$DialogueBox/ProceedMarker.visible = true
	waiting_for_input = true

func continue_dlg():
	waiting_for_input = false
	$DialogueBox/ProceedMarker.visible = false
	var next_line = await current_dlg.get_next_dialogue_line(next_line_id, extra_states, mut_behaviour)
	if next_line == null:
		hide_dlg()
	else:
		display_line(next_line)
