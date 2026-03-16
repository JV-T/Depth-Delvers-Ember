extends CharacterBody2D

const SPEED = 110.0

var _player_contact: bool = false
var _player=null
var maxhealth = 100
@export var enemyhealth = 100

const MAJOR_SHOOT_COOLDOWN = 5.0
var _major_shoot_timer: float = 0.0
var _enemy_projectile_scene = preload("res://scenes/enemy_projectile.tscn")

func _ready() -> void:
	
	maxhealth = int(((UserInterface.level * 200) + 100) * 1.875)
	enemyhealth = maxhealth
	$ProgressBar.max_value = enemyhealth
	$HurtArea.body_entered.connect(_on_body_entered)
	$HurtArea.body_exited.connect(_on_body_exited)
	_major_shoot_timer = MAJOR_SHOOT_COOLDOWN
	await get_tree().process_frame
	_player = get_tree().current_scene.get_node_or_null("miner")
	
func _process(delta: float) -> void:
	$ProgressBar.value = enemyhealth
	_major_shoot_timer -= delta
	if _player != null and _major_shoot_timer <= 0.0:
		_major_shoot_timer = MAJOR_SHOOT_COOLDOWN
		var big_proj = _enemy_projectile_scene.instantiate()
		big_proj.global_position = global_position
		big_proj.rotation = global_position.direction_to(_player.global_position).angle()
		big_proj.damage = 30.0
		big_proj.max_distance = 99999.0
		big_proj.scale = Vector2(3, 3)
		get_tree().current_scene.add_child(big_proj)
		$BubbleSFX.play()
		_fire_delayed_volley()

func _fire_delayed_volley() -> void:
	for i in range(3):
		await get_tree().create_timer(2.0).timeout
		if not is_instance_valid(self) or _player == null or enemyhealth <= 0:
			return
		var proj = _enemy_projectile_scene.instantiate()
		proj.global_position = global_position
		proj.rotation = global_position.direction_to(_player.global_position).angle()
		proj.damage = 30.0
		proj.max_distance = 99999.0
		proj.scale = Vector2(3, 3)
		get_tree().current_scene.add_child(proj)
		$BubbleSFX.play()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = true
		_player = body
		
func _on_body_exited(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = false


func _on_hurt_area_area_entered(area: Area2D) -> void:
	if area.name == "attackarea" or area.name == "crab_projectile":
		$AudioStreamPlayer3.play()
		$AnimationPlayer.play("hit")
		if area.name == "crab_projectile":
			enemyhealth -= area.damage if "damage" in area else 15
		else:
			enemyhealth -= UserInterface.damage
		UserInterface.shakeamount += 40
		$bloodeffect.emitting = true
		if enemyhealth <= 0:
			GlobalWorldEnvironment.get_node("zap").blood()
			$AudioStreamPlayer.play()
			UserInterface.oxygen += 20
			UserInterface.shakeamount += 80
			$AnimationPlayer.play("death")
			if UserInterface.oxygen > 100:
				UserInterface.oxygen = 100
