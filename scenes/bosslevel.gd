extends Node2D

var crab = preload("res://scenes/babycrab.tscn")

func _on_timer_timeout() -> void:
	var crab_count = get_children().filter(func(c): return c is CharacterBody2D).size()
	if crab_count >= 25:
		return
	var enemy = crab.instantiate()
	enemy.unlimited_range = true
	add_child(enemy)
	if randi() % 2 == 0:
		enemy.position = Vector2(-2078, -1028)
	else:
		enemy.position = Vector2(1943, -1025)
