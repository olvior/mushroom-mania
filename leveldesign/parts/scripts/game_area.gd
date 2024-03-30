extends Node2D
class_name GameArea

@export var area_name : StringName
@export var tilemap : TileMap

var exits : Dictionary

func identify_exits():
	for c in self.get_children():
		if c is AreaExit:
			exits[c.name_id] = c
	