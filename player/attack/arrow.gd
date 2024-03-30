extends CharacterBody2D
class_name Arrow


var collision : KinematicCollision2D
@onready var collision_box : CollisionShape2D = get_node("CollisionShape2D")

var damage : int
var attacker : CharacterBody2D
var kb_strength : float
var kb_direction : Vector2

func setup(damagel : int, attackerl : CharacterBody2D, kb_strengthl : float):
	damage = damagel
	attacker = attackerl
	kb_strength = kb_strengthl

func _physics_process(delta):
	velocity /= 1.02
	velocity.y += 10 * delta
	self.rotation = velocity.angle()
	kb_direction = velocity.normalized()
	
	collision = move_and_collide(velocity)
	
	if collision:
		if collision.get_collider() is TileMap:
			self.queue_free()
		
