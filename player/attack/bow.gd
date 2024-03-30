extends Node2D

@onready var cooldown : Timer = get_node("cooldown")
@onready var parent : CharacterBody2D = get_parent()

@onready var sprite : Sprite2D = get_node("Sprite2D")
var without_arrow : Texture2D = preload("res://art/bow.png")
var with_arrow : Texture2D = preload("res://art/bow_with_arrow.png")

var arrow_scene = preload("res://player/attack/arrow.tscn")

var diff : Vector2
var basic_damage : int = 5

func _process(_delta):
	diff = get_global_mouse_position() - self.get_global_position()
	var current = self.rotation
	var target = diff.angle()
	
	self.rotation = lerp_angle(current, target, 0.1)
	
	if Input.is_action_just_pressed("bow"):
		if cooldown.time_left > 0:
			pass
		else:
			sprite.texture = without_arrow
			cooldown.start()
			apply_kb()
			create_arrow()

func reset_cooldown():
	_on_cooldown_timeout()
	cooldown.stop()

func _on_cooldown_timeout():
	sprite.texture = with_arrow


func apply_kb():
	var kb = diff.normalized() * 250
	if self.get_parent().velocity.y > 0:
		if kb.y > 0:
			kb.y *= 2
			kb.y *= 1 + (self.get_parent().velocity.y / 700)
	parent.velocity -= kb

func create_arrow():
	var new_arrow : Arrow = arrow_scene.instantiate()
	new_arrow.velocity = diff.normalized() * 30
	new_arrow.rotation = diff.angle()
	new_arrow.position = self.get_global_position() + diff.normalized() * 48 
	
	new_arrow.setup(5, self.get_parent(), 100)
	
	Global.current_area.add_child(new_arrow)

