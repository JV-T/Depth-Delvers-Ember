extends CharacterBody2D

const SPEED = 110.0
const DAMAGE_PER_SECOND = 8.0
const VERTICAL_AMPLITUDE = 30.0
const VERTICAL_SPEED = 0.7
const GRAVITY = 300.0


var _direction: float = 1.0
var _time: float = 0.0
var _player_contact: bool = false
var _player=null
@export var enemyhealth = 100

const SHOOT_RANGE = 500.0
const SHOOT_COOLDOWN = 10.0
var _shoot_timer: float = 0.0
var _enemy_projectile_scene = preload("res://scenes/enemy_projectile.tscn")
@export var unlimited_range: bool = false

func _ready() -> void:
	
	enemyhealth = int(enemyhealth * pow(1.25, UserInterface.level))
	$ProgressBar.max_value = enemyhealth
	# Randomise start time and direction so each stingray feels independent
	_time = randf() * TAU
	_direction = 1.0 if randf() > 0.5 else -1.0
	$Sprite2D.flip_h = _direction < 0.0
	$HurtArea.body_entered.connect(_on_body_entered)
	$HurtArea.body_exited.connect(_on_body_exited)
	_shoot_timer = randf_range(2.0, SHOOT_COOLDOWN)
	await get_tree().process_frame
	_player = get_tree().current_scene.get_node_or_null("miner")

func _on_body_entered(body: Node2D) -> void:
	if body.name == "miner":
		_player_contact = true
		_player = body
		
func _physics_process(delta: float) -> void:
	_time += delta

	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	else:
		velocity.y = 0.0

	# Horizontal patrol only (removed vertical sine drift)
	velocity.x = _direction * SPEED

	move_and_slide()

	# Reverse on wall hit
	if is_on_wall():
		_direction *= -1
		$Sprite2D.flip_h = _direction < 0.0

func _process(delta: float) -> void:
	$ProgressBar.value = enemyhealth
	_shoot_timer -= delta
	if _player != null and _shoot_timer <= 0.0:
		var dist = global_position.distance_to(_player.global_position)
		if unlimited_range or dist <= SHOOT_RANGE:
			_shoot_timer = SHOOT_COOLDOWN
			var proj = _enemy_projectile_scene.instantiate()
			proj.global_position = global_position
			proj.rotation = global_position.direction_to(_player.global_position).angle()
			if unlimited_range:
				proj.max_distance = 99999.0
			get_tree().current_scene.add_child(proj)
	if _player_contact and !$GPUParticles2D2.emitting and $Timer.is_stopped():
		$GPUParticles2D2.emitting = true
		$Timer.start()
		GlobalWorldEnvironment.get_node("zap").zapeffect()
		$AudioStreamPlayer2.play()
		UserInterface.shakeamount += 50
		UserInterface.knockback = -10
		UserInterface.oxygen -= DAMAGE_PER_SECOND
		
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
