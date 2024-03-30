extends Area2D

class_name SpawnDetector

@export var parent : CharacterBody2D
@export var bottom_diff : Vector2

var current_position : Vector2

func _on_area_entered(area):
	if area is SpawnArea:
		print("ABBA")
		print(area.spawn_point)
		current_position = area.spawn_point.get_global_position()
		print(current_position)
	



func go_to_pos():
	parent.position = current_position - bottom_diff
	parent.velocity = Vector2(0, 0)
