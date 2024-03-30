extends Area2D

@export var boss_scene : PackedScene
@export var blockers : Array
@export var position_node : Node2D

var used = false

func _on_body_entered(body):
	if body == Global.player:
		print("IINN", used)
		used = false
		if not used:
			print("a")
			spawn()
			used = true

func spawn():
	print("spawnign")
	var new_boss = boss_scene.instantiate()
	Global.current_area.add_child(new_boss)
	new_boss.position = position_node.get_global_position()
	for b in blockers:
		get_node(b).close()
