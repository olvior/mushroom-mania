extends Node2D

@onready var cooldown : Timer = get_node("cooldown")
@onready var parent : CharacterBody2D = get_parent()

var arrow_scene = preload("res://player/attack/arrow.tscn")

var diff : Vector2

func _process(delta):
	diff = get_global_mouse_position() - self.get_global_position()
	var current = self.rotation
	var target = diff.angle()
	
	self.rotation = lerp_angle(current, target, 0.05)
	
	if Input.is_action_just_pressed("bow"):
		if cooldown.time_left > 0:
			pass
		else:
			cooldown.start()
			apply_kb()
			create_arrow()


func apply_kb():
	var kb = diff.normalized() * 300
	kb.x /= 1.2
	kb.y *= 1.1
	parent.velocity -= kb
	print("AS")

func create_arrow():
	var new_arrow = arrow_scene.instantiate()
	new_arrow.velocity = diff.normalized() * 200
	new_arrow.rotation = diff.angle()
	new_arrow.position = self.get_global_position() + Vector2(cos(diff.angle()), sin(diff.angle())) * 36
	Global.current_area.add_child(new_arrow)
