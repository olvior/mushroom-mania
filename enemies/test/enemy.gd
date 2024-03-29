extends CharacterBody2D
class_name TestEnemy

var target_pos : Vector2

var accel = 300
var max_speed = 500
var direction : int = 1
var block_size : int = Global.block_size # 32 right now

@onready var player : CharacterBody2D = Global.player
@onready var animation_player : AnimationPlayer = get_node("AnimationPlayer")
@onready var tile_map : TileMap = get_parent().tilemap
@onready var run_timer : Timer = get_node("Run")
@onready var run_cooldown_timer : Timer = get_node("RunCooldown")

var kb = Vector2(300, -100)

func die():
	self.queue_free()

func take_kb(dir):
	run_timer.stop()
	run_cooldown_timer.start()
	velocity.x = kb.x * dir
	velocity.y = kb.y

func _physics_process(delta):
	var diff = abs(player.position - self.position)
	
	velocity.y += 300 * delta
	
	if abs(velocity.x) < max_speed:
		velocity.x += accel * direction * delta
	else:
		velocity.x -= (velocity.x - max_speed) * 5 * delta
	
	if diff.x < 6 * block_size and diff.y < 1 * block_size:
		if run_timer.time_left == 0:
			if run_cooldown_timer.time_left == 0:
				run_timer.start()
				run_cooldown_timer.start()
				direction = (player.position.x - self.position.x) / abs(player.position.x - self.position.x)
				max_speed = 200
	
	if run_timer.time_left > 0:
		if not animation_player.current_animation:
			animation_player.play("run_right")
	else:
		if not animation_player.current_animation:
			animation_player.play("wandering")
		max_speed = 7
		
		# direction_change_logic
		var block_position = Vector2(floor(self.position.x / block_size + 0.5 * direction), floor(self.position.y / block_size))
		# anything in layer 0 is a normal platform
		var tile_data_under = tile_map.get_cell_tile_data(0, Vector2(block_position.x, block_position.y + 1))
		var tile_data_lr = tile_map.get_cell_tile_data(0, Vector2(block_position.x, block_position.y))
		if tile_data_lr or not tile_data_under:
			self.velocity.x = (max_speed - 1) * direction
			direction *= -1
			
		
	move_and_slide()
