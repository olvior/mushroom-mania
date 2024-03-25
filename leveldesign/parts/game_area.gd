extends Node2D
class_name GameArea


@export_category("a")
@export var area_name : StringName
@export_node_path("TestEnemy") var a

var exits : Dictionary

func get_data():
	return

func _on_ready():
	for c in self.get_children():
		if c is AreaExit:
			exits[c.name_id] = c
			
