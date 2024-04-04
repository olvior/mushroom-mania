extends Area2D

@export var boss_scene : PackedScene
@export var blockers : Array
@export var position_node : Node2D

var used = false

func _on_body_entered(body):
	if body == Global.player:
		if not used:
			spawn()
			used = true

func _ready():
	for i in range(len(blockers)):
		blockers[i] = get_node(blockers[i])

func spawn():
	var new_boss = boss_scene.instantiate()
	Global.current_area.call_deferred("add_child", new_boss)
	new_boss.position = position_node.get_global_position()
	for b in blockers:
		b.close()
	
	new_boss.blockers = blockers

func save():
	var save_dict = {
		"file_path" : get_scene_file_path(),
		"scene_path" : get_tree().get_root().get_path_to(self),
		"used" : used
	}
	
	return save_dict
