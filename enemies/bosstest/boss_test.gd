extends CharacterBody2D

@onready var player : CharacterBody2D = Global.player
var diff : Vector2
var blockers : Array

func _physics_process(delta):
	diff = player.position - self.position
	velocity.x += max(diff.x * 20, sign(diff.x) * 800) * delta
	print(diff.y)
	if -diff.y > 5 * Global.block_size:
		if is_on_floor():
			velocity.y = -500
		
		if is_on_wall_only():
			velocity.y -= 300
			velocity.x += 300
	
	velocity.y += 600 * delta
	
	if is_on_floor():
		velocity.x /= 1.05
	else:
		velocity.x /= 1.025
	
	move_and_slide()


func die():
	for b in blockers:
		b.queue_free()
	self.queue_free()
