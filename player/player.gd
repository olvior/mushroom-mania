extends CharacterBody2D

#walking
var max_speed = 300.0
var accel = 10
var direction = 0

#jumping
var jump_power = 565
var gravity_up = 1100
var gravity_down = 1250
var cancel_jump = false
var terminal_velocity = 700

#dashing
var can_dash = true
var dashing = false
var dash_speed = 750
var dash_direction = Vector2(0, 0)
var dash_refreshed = true

#wall climbing
var wall_terminal_velocity = 100
var on_wall = false
var was_on_wall = on_wall
var wall_jump_side_force = 500

#buffer
var buffer = []
var buffer_time = 0.15
var buffer_timer = 0
var bufferables = ["dash", "jump"]
var buffer_dict = {
	"dash": check_dash,
	"jump": check_jump
}
var buffer_dict_run = {
	"dash": dash,
	"jump": jump_b
}

#coyote
var was_on_floor = false
var was_floor_ypos : float = 0.0
@onready var wall_coyote_timer : Timer = get_node("Wall coyote timer")

#other
var time = 0
var magnitude = 1
var current_health = 8
var max_health

# melee attack
var melee_damage : int = 5
var last_direction = direction

@onready var attack_cooldown : Timer = get_node("Attack cooldown")

# bow
@onready var bow = get_node("Bow")

# preload scenes
var attack_scene = preload("res://player/attack/player_attack.tscn")


@onready var camera : Camera2D = get_node("Camera2D")

@onready var dash_timer : Timer = get_node("Dash cooldown")
@onready var dashing_timer : Timer = get_node("Dash length")
@onready var coyote_timer : Timer = get_node("Coyote Timer")

@onready var wall_cast_right : RayCast2D = get_node("Wall cast right")
@onready var wall_cast_left : RayCast2D = get_node("Wall cast left")

@onready var debug_label : Label = get_node("debug")

@onready var spawn_detector : SpawnDetector = get_node("Spawn detector")

func gravity(delta):
	if velocity.y > 0:
		velocity.y += gravity_down * delta
	else:
		velocity.y += gravity_up * delta
	if velocity.y > terminal_velocity:
		velocity.y = terminal_velocity

func jump_canceling():
	if velocity.y < 0:
		velocity.y /= 1.5
	else:
		cancel_jump = false

func jump():
	velocity.y = -jump_power
	time = 0

func jump_b():
	if c_is_on_wall_only():
		wall_jump(-1 if wall_cast_left.is_colliding() else 1)
	else:
		jump()

func c_is_on_wall_only():
	return (wall_cast_left.is_colliding() or wall_cast_right.is_colliding()) and not is_on_floor()

func check_jump():
	return is_on_floor() or c_is_on_wall_only()

func dash():
	var left_right = Input.get_axis("left", "right")
	var up_down = Input.get_axis("up", "down")
	
	if abs(left_right) and abs(up_down):
		dash_direction = Vector2(sqrt(2) / 2 * left_right, sqrt(2) / 2 * up_down)
	else:
		dash_direction = Vector2(left_right, 0)
	
	if abs(left_right)	:
		dash_refreshed = false
		dash_timer.start()
		dashing_timer.start()
		can_dash = false
		dashing = true

func keep_dash():
	if dash_direction.x:
		velocity.x = dash_speed * dash_direction.x
		velocity.y = dash_speed * dash_direction.y

func _on_dashing_timeout():
	dashing = false
	dashing_timer.stop()
	velocity /= 2

func _on_dash_timer_timeout():
	dash_refreshed = true
	dash_timer.stop()

func check_dash():
	return can_dash

func wall_jump(dir):
	print("ab")
	print(dir, "wall	")
	velocity.y = -jump_power
	velocity.x = dir * wall_jump_side_force
	time = 0
	
	can_dash = true

func check_buffer():
	for b in buffer:
		var action = b[0]
		time = b[1]
		if (buffer_timer) < (time + buffer_time):
			var can_do_action = buffer_dict[action].call()
			if can_do_action:
				buffer_dict_run[action].call()
				print("CAlLLED " + action)
				buffer.remove_at(buffer.find(b))

		else:
			if (buffer_timer) > (time + buffer_time):
				buffer.remove_at(buffer.find(b))

func check_can_dash():
	return true if (is_on_floor() or on_wall) and dash_refreshed else can_dash

func _physics_process(delta):
	time += delta
	direction = Input.get_axis("left", "right")
	
	if is_on_floor() and abs(velocity.x) > max_speed:
		velocity.x /= 1.05
	
	if not direction:
		if abs(velocity.x) > 0:
			velocity.x /= 1.2
			velocity.x -= 5 * (velocity.x) / abs(velocity.x)
		
		if abs(velocity.x) < 5:
			velocity.x = 0
			
	
	last_direction = direction if direction != 0 else last_direction
	
	#attack
	if Input.is_action_just_pressed("attack"):
		if attack_cooldown.time_left:
			pass
		else:
			create_attack()
			attack_cooldown.start()
	
	#walking
	if velocity.x * direction < max_speed:
		velocity.x += direction * max_speed * accel * delta
	
	
	if was_on_wall and not c_is_on_wall_only(): #if was on wall
		wall_coyote_timer.start()
	
	if was_on_floor and not is_on_floor():
		print("not on floor anymore")
		if position.y > was_floor_ypos:
			coyote_timer.start()
	
	was_on_wall = c_is_on_wall_only()
	
	can_dash = check_can_dash()
	
	if not is_on_floor():
		gravity(delta)
	
	#buffer checks
	for b in range(len(bufferables)):
		var b_string = bufferables[b]
		if Input.is_action_just_pressed(b_string):
			if not buffer_dict[b_string].call():
				print("cannot ", b_string)
				buffer.append([b_string, buffer_timer])
	
	check_buffer()
	
	if c_is_on_wall_only():
		if direction:
			velocity.y = min(wall_terminal_velocity, velocity.y)

	
	#jump stuff
	if cancel_jump:
		jump_canceling()
	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or coyote_timer.time_left > 0:
			jump()
		elif c_is_on_wall_only() or wall_coyote_timer.time_left:
			var wall_jump_direction = 1
			if wall_cast_left.is_colliding():
				wall_jump_direction = -1
			print("aa")
			wall_jump(wall_jump_direction)
			print("bb")
	
	if Input.is_action_just_released("jump"):
		cancel_jump = true
	
	if Input.is_action_just_pressed("dash") and can_dash:
		dash()
	
	if dashing:
		keep_dash()
	
	was_on_floor = is_on_floor()
	if is_on_floor():
		was_floor_ypos = position.y
	time += delta
	buffer_timer += delta
	
	move_and_slide()
	debug_label.text = str(velocity)


##################################################################
func _on_room_detector_area_entered(area):
	if area is Room:
		camera.set_limits(area)
	
	elif area.is_in_group("exits"):
		Global.call_deferred("change_area", area)

func die():
	print("ded")

func static_damage():
	spawn_detector.go_to_pos()

func create_attack():
	var new_attack : MeleeAttack = attack_scene.instantiate()
	var diff = get_global_mouse_position() - self.get_global_position()
	
	new_attack.damage = melee_damage
	new_attack.time_left = 0.1
	new_attack.attacker = self
	new_attack.kb_strength = 300
	new_attack.kb_direction = diff.normalized()
	
	new_attack.rotation = diff.angle()
	
	self.add_child(new_attack)

func on_melee_hit():
	bow.reset_cooldown()

func save():
	var save_dict = {
		"file_path" : get_scene_file_path(),
		"scene_path" : get_tree().get_root().get_path_to(self),
		"position.x" : position.x,
		"position.y" : position.y
	}
	
	return save_dict
