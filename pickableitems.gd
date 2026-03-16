extends Node2D

const WEAPONS = [
	{"name": "Crab Spear", "type": "weapon", "texture_path": "res://CrabSpear.png", "damage": 20, "swing_speed": 0.4, "scale": 2.25, "pickup_scale": 0.5, "attack_type": "stab", "rot_offset": -0.83},
	{"name": "Trident", "type":"weapon","texture_path":"res://Sword Pack/trident.png", "damage": 35, "swing_speed": 0.3, "scale": 0.375, "pickup_scale": 0.125, "attack_type": "stab", "rot_offset": -0.83},
	{"name": "Black Sword", "type": "weapon", "texture_path": "res://Sword Pack/Black Sword.png", "damage": 30, "swing_speed": 0.4, "scale": 3.0, "pickup_scale": 1.0, "attack_type": "swing", "rot_offset": -0.83},
	{"name": "Katana", "type": "weapon", "texture_path": "res://Sword Pack/Katana.png", "damage": 30, "swing_speed": 0.2, "scale": 3.0, "pickup_scale": 1.0, "attack_type": "swing", "rot_offset": -0.83},
	{"name": "Cutlass", "type": "weapon", "texture_path": "res://Cutlass.png", "damage": 30, "swing_speed": 0.3, "scale": 2.0, "pickup_scale": 0.5, "attack_type": "swing", "rot_offset": -1.57}
]
var item_data: Dictionary = {}
var player_in_range: bool = false
var forced_weapon_name: String = ""


func _ready() -> void:
	randomize()
	if forced_weapon_name != "":
		for w in WEAPONS:
			if w.name == forced_weapon_name:
				item_data = w
				break
	if item_data.is_empty():
		var weights = [5, 3, 3, 4, 5]
		var total = 0
		for w in weights:
			total += w
		var roll = randi() % total
		var cumulative = 0
		for i in range(weights.size()):
			cumulative += weights[i]
			if roll < cumulative:
				item_data = WEAPONS[i]
				break
	$"item sprite".texture = load(item_data.texture_path)
	var s = item_data.pickup_scale
	$"item sprite".scale = Vector2(s, s)
	$"item sprite/AnimationPlayer".play("open")

	var area = Area2D.new()
	area.name = "PickupArea"
	var shape = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 40.0
	shape.shape = circle
	area.add_child(shape)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	add_child(area)


func _prompt_text() -> String:
	var already_have: bool
	var slot_full: bool

	if item_data.type == "weapon":
		already_have = UserInterface.weapon != null and UserInterface.weapon.name == item_data.name
		slot_full = UserInterface.weapon != null
	else:
		already_have = (UserInterface.powerups[0] != null and UserInterface.powerups[0].name == item_data.name) \
					or (UserInterface.powerups[1] != null and UserInterface.powerups[1].name == item_data.name)
		slot_full = UserInterface.powerups[0] != null and UserInterface.powerups[1] != null

	if already_have:
		return item_data.name + "  [Already have this]"
	elif slot_full:
		return item_data.name + "  —  Swap"
	else:
		return item_data.name + "  —  Pick Up"


func _already_have() -> bool:
	if item_data.type == "weapon":
		return UserInterface.weapon != null and UserInterface.weapon.name == item_data.name
	return (UserInterface.powerups[0] != null and UserInterface.powerups[0].name == item_data.name) \
		or (UserInterface.powerups[1] != null and UserInterface.powerups[1].name == item_data.name)


func _on_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		player_in_range = true
		PromptUI.show_prompt(_prompt_text())


func _on_body_exited(body: Node2D) -> void:
	if body.name == "miner":
		player_in_range = false
		PromptUI.hide_prompt()


func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		if _already_have():
			return
		var old_item = UserInterface.swap_item(item_data)
		InventoryUI.refresh()

		if old_item.is_empty():
			PromptUI.hide_prompt()
			queue_free()
		else:
			$AudioStreamPlayer.play()
			item_data = old_item
			$"item sprite".texture = load(item_data.texture_path)
			var s2 = item_data.pickup_scale
			$"item sprite".scale = Vector2(s2, s2)
			PromptUI.show_prompt(_prompt_text())
