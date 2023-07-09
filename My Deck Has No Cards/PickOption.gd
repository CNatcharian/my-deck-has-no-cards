extends Button
class_name PickOption

signal choose_option(value)

func _ready():
	pressed.connect(_on_pressed)

func hook_to_manager(manager):
	choose_option.connect(manager.on_choose_option)

func get_option_value():
	return "nothing"

func _on_pressed():
	choose_option.emit(get_option_value())
