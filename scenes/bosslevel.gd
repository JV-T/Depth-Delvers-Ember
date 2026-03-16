extends Node2D

var crab = preload("res://scenes/babycrab.tscn")

func _on_timer_timeout() -> void:
	var enemy = crab.instantiate()
	add_child(enemy)
	if randi() % 2 == 0:
		enemy.position = Vector2(-2078, -1028)
	else:
		enemy.position = Vector2(1943, -1025)
