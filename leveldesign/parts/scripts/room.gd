@tool
extends Area2D
class_name Room

@export var collision_shape : CollisionShape2D

@export var run = false:
	set(new_run):
		run = false
		start_process()

@export var block_size : int = 32:
	set(new_block_size):
		block_size = new_block_size
		change_collision_shape()
		snap_pos()

@export var extent = Vector2i(32, 18):
	set(new_extent):
		extent = new_extent
		if collision_shape:
			change_collision_shape()

@export var pos = Vector2(0, 0):
	set(new_pos):
		pos = new_pos
		snap_pos()
		if collision_shape:
			change_collision_shape()

func _enter_tree() -> void:
	if Engine.is_editor_hint():
		set_notify_transform(true)
		self.name = "Room"

func _notification(what: int) -> void:
	if Engine.is_editor_hint():
		if what == NOTIFICATION_TRANSFORM_CHANGED:
			if not (fmod(position.x, block_size / 2) == 0 and fmod(position.y, block_size / 2) == 0):
				pos = position / (block_size)
				pos.x = int(floor(pos.x))
				pos.y = int(floor(pos.y))
				print("room_move")


func start_process():
	if Engine.is_editor_hint():
		collision_shape = CollisionShape2D.new()
		self.add_child(collision_shape)
		collision_shape.owner = get_tree().edited_scene_root
		collision_shape.name = "CollisionShape2D"
		
		collision_shape.shape = RectangleShape2D.new()

func snap_pos():
	if Engine.is_editor_hint():
		self.position = pos * block_size

func change_collision_shape():
	if Engine.is_editor_hint():
		collision_shape.shape.size = Vector2(extent.x * block_size, extent.y * block_size)
