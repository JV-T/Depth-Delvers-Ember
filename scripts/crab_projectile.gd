extends Area2D

@export var damage: float = 15.0
@export var speed: float = 900
@export var max_distance: float = 1200

var _distance_traveled: float = 0.0
var _pierce_count: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta: float) -> void:
	var step = speed * delta
	position += transform.x * step
	_distance_traveled += step
	if _distance_traveled >= max_distance:
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("walls") or body is TileMap or body is TileMapLayer or body is StaticBody2D:
		_spawn_impact_particles()
		queue_free()

func _on_area_entered(area: Area2D) -> void:
	if area.name == "HurtArea" or area.name == "hurtarea" or area.name == "hurt_area":
		_spawn_impact_particles()
		queue_free()

func _spawn_impact_particles() -> void:
	var p = CPUParticles2D.new()
	p.emitting = false
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = 12
	p.lifetime = 0.5
	p.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	p.emission_rect_extents = Vector2(5, 5)
	# Deflect slightly backwards from the direction it was traveling
	p.direction = -transform.x
	p.spread = 60.0
	p.gravity = Vector2(0, 600)
	p.initial_velocity_min = 150.0
	p.initial_velocity_max = 300.0
	p.scale_amount_min = 3.0
	p.scale_amount_max = 6.0
	p.color = Color(1.0, 0.5, 0.0, 1.0)
	p.global_position = global_position
	
	get_tree().current_scene.add_child(p)
	p.emitting = true
	
	var timer = p.get_tree().create_timer(1.0)
	timer.timeout.connect(p.queue_free)
