extends Node

const JELLYFISH_SCENE = preload("res://scenes/first layer/jellyfish.tscn")
const STINGRAY_SCENE = preload("res://scenes/stingray.tscn")
const CRAB_SCENE = preload("res://scenes/babycrab.tscn")
var JELLYFISH_COUNT = 6
var STINGRAY_COUNT = 4
var CRAB_COUNT = 10
const MIN_DIST_FROM_PLAYER = 350.0

var _last_scene: Node = null


func _process(_delta: float) -> void:
	var current = get_tree().current_scene
	if current != null and current != _last_scene:
		_last_scene = current
		JELLYFISH_COUNT = 6 + UserInterface.level * 4
		STINGRAY_COUNT = 4 + UserInterface.level * 2
		CRAB_COUNT = 10 + UserInterface.level * 6
		call_deferred("_spawn_enemies")


func _spawn_enemies() -> void:
	if get_tree().current_scene.scene_file_path != "res://scenes/bosslevel.tscn":
		var root = get_tree().current_scene
		if root == null:
			return

		var tilemap = _find_tilemap(root)
		var player = root.get_node_or_null("miner")
		if tilemap == null or player == null:
			return

		var used_cells: Array = Array(tilemap.get_used_cells())
		if used_cells.is_empty():
			return

		# Build occupied set in cell space
		var occupied: Dictionary = {}
		for cell in used_cells:
			occupied[cell] = true

		# Compute cell-space bounds
		var min_cx: int = used_cells[0].x
		var max_cx: int = used_cells[0].x
		var min_cy: int = used_cells[0].y
		var max_cy: int = used_cells[0].y
		for cell in used_cells:
			if cell.x < min_cx: min_cx = cell.x
			if cell.x > max_cx: max_cx = cell.x
			if cell.y < min_cy: min_cy = cell.y
			if cell.y > max_cy: max_cy = cell.y

		# Inset 3 cells from edges to avoid spawning right on the border
		min_cx += 3; max_cx -= 3
		min_cy += 3; max_cy -= 3

		if min_cx >= max_cx or min_cy >= max_cy:
			return

		var player_pos = player.global_position

		_spawn_group(JELLYFISH_SCENE, JELLYFISH_COUNT, root, tilemap, occupied,
			player_pos, min_cx, max_cx, min_cy, max_cy)
		_spawn_group(STINGRAY_SCENE, STINGRAY_COUNT, root, tilemap, occupied,
			player_pos, min_cx, max_cx, min_cy, max_cy)
		_spawn_group(CRAB_SCENE, CRAB_COUNT, root, tilemap, occupied,
			player_pos, min_cx, max_cx, min_cy, max_cy)


func _spawn_group(
	scene: PackedScene,
	count: int,
	root: Node,
	tilemap: Node,
	occupied: Dictionary,
	player_pos: Vector2,
	min_cx: int, max_cx: int,
	min_cy: int, max_cy: int
) -> void:
	var spawned = 0
	var attempts = 0
	var max_attempts = count * 40

	while spawned < count and attempts < max_attempts:
		attempts += 1

		# Pick a random cell within bounds
		var cell = Vector2i(
			randi_range(min_cx, max_cx),
			randi_range(min_cy, max_cy)
		)

		if not _cell_is_open(cell, occupied):
			continue

		# Convert cell centre to world position
		var world_pos = tilemap.to_global(tilemap.map_to_local(cell))

		if world_pos.distance_to(player_pos) < MIN_DIST_FROM_PLAYER:
			continue

		var instance = scene.instantiate()
		root.add_child(instance)
		instance.global_position = world_pos
		spawned += 1


func _cell_is_open(cell: Vector2i, occupied: Dictionary) -> bool:
	# The cell and all 8 neighbours must be free of tiles
	for dx in range(-1, 2):
		for dy in range(-1, 2):
			if occupied.has(Vector2i(cell.x + dx, cell.y + dy)):
				return false
	return true



func _find_tilemap(node: Node) -> Node:
	if node.get_class() == "TileMapLayer":
		return node
	for child in node.get_children():
		var result = _find_tilemap(child)
		if result != null:
			return result
	return null
