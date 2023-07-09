extends Node
class_name Manager

enum State {
	OPENING,
	MONSTER_INTRO,
	COST,
	TYPE,
	POWER,
	HEALTH,
	ART,
	NAME,
	RESOLVE,
	DEFEAT,
	VICTORY,
	TIE
}

@export var state = State.OPENING
@onready var animator = $AnimationPlayer

@onready var dialogue_ui = $dialogue_ui as DialogueUI

# Called when the node enters the scene tree for the first time.
func _ready():
	randomize_vars()
	# start listening to all option buttons
	get_tree().call_group("PickOption", "hook_to_manager", self)
	# begin with opening dialogue
	change_state(State.OPENING)

func randomize_vars():
	GameState.probo_money = randi_range(3, 6)
	$MyHUD/CostIcon2/Number.text = str(GameState.probo_money)
	GameState.enemy_type = ["wet", "dirt", "guy"].pick_random()
	$EnemyCard/BG/TypeIcon/TypeText.text = GameState.enemy_type.to_upper()
	$EnemyCard/BG/TypeIcon.texture = load("res://ui/icon_" + GameState.enemy_type + ".png")
	$EnemyCard/BG/Art.texture = load("res://ui/monster_" + GameState.enemy_type + ".png")
	match GameState.enemy_type:
		"wet":
			GameState.enemy_cardname = "BLORB"
			$EnemyCard/BG/Cardname.text = GameState.enemy_cardname
		"dirt":
			GameState.enemy_cardname = "SODBOX"
			$EnemyCard/BG/Cardname.text = GameState.enemy_cardname
		"guy":
			GameState.enemy_cardname = "JIM"
			$EnemyCard/BG/Cardname.text = GameState.enemy_cardname
	GameState.enemy_power = randi_range(4, 8)
	$EnemyCard/BG/PowerIcon/Number.text = str(GameState.enemy_power)
	GameState.enemy_health = randi_range(3, 11)
	$EnemyCard/BG/HealthIcon/Number.text = str(GameState.enemy_health)
	
	# cost options
	set_option_group("Cost", 2, 7, GameState.probo_money, false)
	# power options
	set_option_group("Power", 1, 6, int(GameState.enemy_health / 2))
	# health options
	set_option_group("Health", 3, 6, int(GameState.enemy_power))

func set_option_group(groupname, min, max, guarantee, higher = true):
	var options = get_tree().get_nodes_in_group(groupname)
	var values = []
	for o in options:
		var v = randi_range(min, max)
		o.value = v
		values.append(v)
	if higher:
		if values.all(func(x): return x <= guarantee):
			var rindex = randi_range(0, 3)
			options[rindex].value = guarantee + 1
	else:
		if values.all(func(x): return x > guarantee):
			var rindex = randi_range(0, 3)
			options[rindex].value = guarantee


func _on_text_edit_text_changed():
	if state == State.NAME:
		$MyCard/BG/CardName.text = $Sidebar/BG/NamePanel/TextEdit.text.to_upper()

func change_state(new_state: State):
	state = new_state
	print("Changing to state " + str(new_state))
	match state:
		State.OPENING:
			dialogue_ui.show_dlg("opening")
			await dialogue_ui.dialogue_ended
			change_state(State.MONSTER_INTRO)
		State.MONSTER_INTRO:
			animator.play("monster_intro")
			await animator.animation_finished
			change_state(State.COST)
		State.COST:
			print("state is already set up")
		State.TYPE:
			$Sidebar/BG/CostPanel.visible = false
			$Sidebar/BG/TypePanel.visible = true
		State.POWER:
			$Sidebar/BG/TypePanel.visible = false
			$Sidebar/BG/PowerPanel.visible = true
		State.HEALTH:
			$Sidebar/BG/PowerPanel.visible = false
			$Sidebar/BG/HealthPanel.visible = true
		State.ART:
			$Sidebar/BG/HealthPanel.visible = false
			$Sidebar/BG/ArtPanel.visible = true
		State.NAME:
			$Sidebar/BG/ArtPanel.visible = false
			$Sidebar/BG/NamePanel.visible = true
			$Sidebar/BG/NamePanel/TextEdit.grab_focus()
		State.RESOLVE:
			animator.play("begin_fight")
			await animator.animation_finished
			dialogue_ui.show_dlg("resolve")
		State.DEFEAT:
			pass
		State.VICTORY:
			pass
		State.TIE:
			pass
		_:
			print("unimplemented state")

func on_choose_option(value):
	print("option received")
	match state:
		State.OPENING:
			if value is String and value == "skip":
				Anime.end()
				dialogue_ui.hide_dlg()
		State.COST:
			if value is int:
				GameState.cost = value
				$MyCard/BG/CostIcon/Number.text = str(GameState.cost)
				$MyCard/BG/CostIcon.visible = true
				change_state(State.TYPE)
			else:
				print("not a number, do nothing")
		State.TYPE:
			if value is String:
				GameState.type = value
				$MyCard/BG/TypeIcon.texture = load("res://ui/icon_" + GameState.type + ".png")
				$MyCard/BG/TypeIcon/TypeText.text = GameState.type.to_upper()
				$MyCard/BG/TypeIcon.visible = true
				change_state(State.POWER)
			else:
				print("not a number, do nothing")
		State.POWER:
			if value is int:
				GameState.power = value
				$MyCard/BG/PowerIcon/Number.text = str(GameState.power)
				$MyCard/BG/PowerIcon.visible = true
				change_state(State.HEALTH)
			else:
				print("not a number, do nothing")
		State.HEALTH:
			if value is int:
				GameState.health = value
				$MyCard/BG/HealthIcon/Number.text = str(GameState.health)
				$MyCard/BG/HealthIcon.visible = true
				change_state(State.ART)
			else:
				print("not a number, do nothing")
		State.ART:
			if value is String and value == "done":
				change_state(State.NAME)
			else:
				print("not done, do nothing")
		State.NAME:
			if value is String and value == "done":
				GameState.cardname = $Sidebar/BG/NamePanel/TextEdit.text.to_upper()
				change_state(State.RESOLVE)
			else:
				print("not done, do nothing")
		_:
			print("unimplemented state for option")

func deal_damage():
	$EnemyCard/BG/HealthIcon/Number.text = str(GameState.enemy_health)
	$MyCard/BG/HealthIcon/Number.text = str(GameState.health)
	if GameState.enemy_health <= 0 and GameState.health <= 0:
		animator.play("double_ded")
	elif GameState.health <= 0:
		animator.play("me_ded")
	elif GameState.enemy_health <= 0:
		animator.play("enemy_ded")

func pay_cost():
	$MyHUD/CostIcon2/Number.text = str(GameState.probo_money)
