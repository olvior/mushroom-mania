extends Area2D
class_name melee_attack

var animator : AnimationPlayer
var damage : int
var collision_shape : CollisionShape2D
var attacker : CharacterBody2D
var time_left : float
var knockback_strength : Vector2

func _physics_process(delta):
	if time_left > 0:
		time_left -= delta
	
	elif time_left <= 0:
		self.queue_free()
