extends CharacterBody2D
@export var speed: float = 600.0
@export var rotation_speed: float = 8.0
@export var rotation_offset: float = PI / 2
@onready var anim: AnimatedSprite2D = $playeranimation
@onready var weapon_pivot: Node2D = $WeaponPivot
@onready var weapon_sprite: Sprite2D = $WeaponPivot/WeaponSprite
@onready var weapon_anim: AnimationPlayer = $WeaponPivot/WeaponAnimPlayer
var _equipped_weapon_name: String = ""
var _swing_offset: float = 0.0
var _stab_offset: float = 0.0
var _base_weapon_x: float = 0.0
var _is_swinging: bool = false
var _trail_timer: float = 0.0

var projectile_scene = preload("res://scenes/crab_projectile.tscn")

func _ready() -> void:
	$playeranimation.modulate = UserInterface.colorpicked
	weapon_pivot.position = Vector2.ZERO
	_base_weapon_x = weapon_sprite.position.x

func _process(delta: float) -> void:
	if _is_swinging and UserInterface.weapon != null and UserInterface.weapon.attack_type == "swing":
		_trail_timer -= delta
		if _trail_timer <= 0:
			_trail_timer = 0.02
			_create_trail()

func _create_trail() -> void:
	var trail = Sprite2D.new()
	trail.texture = weapon_sprite.texture
	trail.global_position = weapon_sprite.global_position
	trail.global_rotation = weapon_sprite.global_rotation
	trail.scale = weapon_sprite.global_scale
	trail.modulate.a = 0.4
	get_tree().current_scene.add_child(trail)
	var t = create_tween()
	t.tween_property(trail, "modulate:a", 0.0, 0.15)
	t.tween_callback(trail.queue_free)

func _physics_process(delta):
	if UserInterface.weapon != null and UserInterface.weapon.name == "Trident":
		speed = 750 * UserInterface.speed_multiplier
	else:
		speed = 600 * UserInterface.speed_multiplier
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	if input_vector != Vector2.ZERO:
		var target_angle = input_vector.angle() + rotation_offset
		rotation = lerp_angle(rotation, target_angle, rotation_speed * delta)
		velocity = input_vector.normalized() * speed * (UserInterface.knockback+1)
		UserInterface.knockback *= 0.7
	else:
		velocity = Vector2.ZERO
	if velocity.x > 0:
		$playeranimation.flip_h = false
	elif velocity.x < 0:
		$playeranimation.flip_h = true
	var approxspeed = (abs(velocity.x) + abs(velocity.y))/2000
	UserInterface.shakeamount += approxspeed
	scale = Vector2(1.176 - approxspeed / 5, 1.207 - approxspeed / 5)
	move_and_slide()
	
	weapon_pivot.position = Vector2.ZERO
	var mouse_pos = get_global_mouse_position()
	var angle_to_mouse = global_position.direction_to(mouse_pos).angle()
	var snapped_angle = round(angle_to_mouse / (PI / 64.0)) * (PI / 64.0)
	
	var is_facing_left = abs(angle_to_mouse) > PI / 2.0
	if is_facing_left:
		weapon_pivot.scale.x = -1
	else:
		weapon_pivot.scale.x = 1
		
	var actual_swing_offset = -_swing_offset if is_facing_left else _swing_offset
	weapon_pivot.global_rotation = snapped_angle + PI/2 + actual_swing_offset
	
	_update_weapon()
	if Input.is_action_pressed("attack"):
		if UserInterface.weapon != null and not _is_swinging:
			UserInterface.shakeamount += 20
			$AudioStreamPlayer.play()
			if UserInterface.weapon.attack_type == "stab":
				_do_stab()
			else:
				_do_swing()
				
			if UserInterface.weapon.name == "Crab Spear" and projectile_scene:
				var proj = projectile_scene.instantiate()
				proj.global_position = global_position
				proj.rotation = angle_to_mouse
				get_tree().current_scene.add_child(proj)
				
			$WeaponPivot/attackarea.monitorable = true
			$WeaponPivot/attackarea.monitoring = true

func _do_swing() -> void:
	_is_swinging = true
	var spd = UserInterface.swing_speed
	var tween = create_tween()
	tween.tween_property(self, "_swing_offset", -1.2, 0.08 / spd) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_swing_offset", 1.6, 0.12 / spd) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(_disable_hitbox)
	tween.tween_property(self, "_swing_offset", 0.0, 0.1 / spd) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_end_attack)

func _do_stab() -> void:
	_is_swinging = true
	var spd = UserInterface.swing_speed
	var tween = create_tween()
	tween.tween_property(self, "_stab_offset", -20.0, 0.06 / spd) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "_stab_offset", 80.0, 0.10 / spd) \
		.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_callback(_disable_hitbox)
	tween.tween_property(self, "_stab_offset", 0.0, 0.14 / spd) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_end_attack)

func _disable_hitbox() -> void:
	$WeaponPivot/attackarea.monitorable = false
	$WeaponPivot/attackarea.monitoring = false

func _end_attack() -> void:
	_is_swinging = false

func _update_weapon() -> void:
	var w = UserInterface.weapon
	if w == null:
		weapon_sprite.visible = false
		_equipped_weapon_name = ""
		return
	weapon_sprite.visible = true
	if w.name != _equipped_weapon_name:
		weapon_sprite.texture = load(w.texture_path)
		_equipped_weapon_name = w.name
		
		var target_scale = w.scale
		weapon_sprite.scale = Vector2.ZERO
		var t = create_tween()
		t.tween_property(weapon_sprite, "scale", Vector2(target_scale * 1.5, target_scale * 1.5), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		t.tween_property(weapon_sprite, "scale", Vector2(target_scale, target_scale), 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	
	var rot_offset = -0.83
	if w.has("rot_offset"):
		rot_offset = w.rot_offset
	
	weapon_sprite.rotation = rot_offset
	
	if w.attack_type == "stab":
		weapon_sprite.position.x = 0
		weapon_sprite.position.y = -101 - _stab_offset
	else:
		weapon_sprite.position.x = 0
		weapon_sprite.position.y = -101
