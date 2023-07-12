extends Node


var probo_money = 0
var enemy_power = 0
var enemy_health = 0
var enemy_type = ""
var enemy_cardname = ""
var cost = 0
var power = 0
var health = 0
var type = ""
var cardname = ""
var outcome = "tie"

@onready var main_scene = get_tree().get_first_node_in_group("Main")

func rebind():
	main_scene = get_tree().get_first_node_in_group("Main")

func cost_too_great():
	return probo_money < cost

## 1: enemy wins
## -1: probo wins
func type_matchup():
	match enemy_type:
		"wet":
			if type == "dirt":
				return 1
			if type == "wet":
				return 0
			if type == "guy":
				return -1
		"dirt":
			if type == "dirt":
				return 0
			if type == "wet":
				return -1
			if type == "guy":
				return 1
		"guy":
			if type == "dirt":
				return -1
			if type == "wet":
				return 1
			if type == "guy":
				return 0

func deal_damage():
	var mymod
	var enemymod
	match type_matchup():
		-1:
			mymod = 2
			enemymod = 1
		0:
			mymod = 1
			enemymod = 1
		1:
			mymod = 1
			enemymod = 2
	enemy_health -= int(power * mymod)
	health -= int(enemy_power * enemymod)
	main_scene.deal_damage()
	await main_scene.damage_dealt

func pay_cost():
	probo_money -= cost
	main_scene.pay_cost()

func both_are_alive():
	return enemy_health > 0 and health > 0

func dead():
	return health <= 0

func enemy_dead():
	return enemy_health <= 0

func get_type():
	return type.to_upper()

func get_enemy_type():
	return enemy_type.to_upper()
