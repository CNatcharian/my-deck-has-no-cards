extends PickOption
class_name NumberOption

@export var value := 0:
	set(new_val):
		value = new_val
		text = str(value)

func get_option_value():
	return value
