extends CharacterBody2D
class_name Arrow


var collision : KinematicCollision2D
@onready var collision_box : CollisionShape2D = get_node("CollisionShape2D")

var damage : int
var attacker : CharacterBody2D
var knockback_strength : float

func setup(damage_local : int, attacker_local : CharacterBody2D, knockback_strength_local : float):
	damage = damage_local
	attacker = attacker_local
	knockback_strength = knockback_strength_local

func _physics_process(delta):
	velocity /= 1.02
	velocity.y += 10 * delta
	self.rotation = velocity.angle()
	
	collision = move_and_collide(velocity)
	
	if collision:
		if collision.get_collider() is TileMap:
			self.queue_free()
		
