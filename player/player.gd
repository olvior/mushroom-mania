extends CharacterBody2D

#walking
var max_speed = 300.0
var accel = 10
var direction = 0

#jumping
var jump_power = 565
var max_jumps = 1
var jumps = max_jumps
var gravity_up = 1100
var gravity_down = 1250
var y_floor = 0
var cancel_jump = false
var has_fallen = false
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
@onready var wall_coyote_timer : Timer = get_node("Wall coyote timer")

#other
var time = 0
var time_started = false
var old_speed = Vector2(12, 0)
var magnitude = 1
var current_health = 4
var max_health


# melee attack
var melee_damage : int = 5
var kb = Vector2i(100, -100)
var last_direction = direction

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

func floor_check():
	if is_on_floor():
		jumps = max_jumps
		y_floor = self.position.y
		has_fallen = false
		
		if abs(velocity.x) > max_speed:
			velocity.x /= 1.05
		
	if not is_on_floor():
		if not has_fallen and y_floor < self.position.y and not on_wall:
			has_fallen = true
			coyote_timer.start()

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
	if has_fallen and jumps > 0 or coyote_timer.time_left > 0:
		jumps -= 1
		has_fallen = false
	if jumps > 0 or coyote_timer.time_left > 0:
			velocity.y = -jump_power
			time = 0
			jumps -= 1

func check_jump():
	return jumps >= 1 or on_wall

func jump_b():
	if on_wall:
		wall_jump(-1 if wall_cast_left.is_colliding() else 1)
	else:
		jump()

func walking(delta):
	direction = Input.get_axis("left", "right")
	if velocity.x * direction < max_speed:
		velocity.x += direction * max_speed * accel * delta

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

func slow_down():
	if not time_started: # initial config
		time = 0
		time_started = true
		old_speed = velocity
		magnitude = velocity.x / abs(velocity.x)
	
	# equation I found to slow down nicely
	velocity.x = (abs(old_speed.x) - (3 * (time + 1.5)) * (3 * (time + 1.5))) * magnitude
	if velocity.x * magnitude < 0:
		velocity.x = 0
		time_started = false

func wall_hold():
	if velocity.y > wall_terminal_velocity:
		velocity.y = wall_terminal_velocity

func wall_jump(dir):
	velocity.y = -jump_power
	velocity.x = dir * wall_jump_side_force
	time = 0
	
	# had glitch where on some wall-jumps the dash wouldn't come back
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

func is_touching_wall():
	return (wall_cast_left.is_colliding() or wall_cast_right.is_colliding()) and not is_on_floor()

func check_can_dash():
	return true if (is_on_floor() or on_wall) and dash_refreshed else can_dash

func _physics_process(delta):
	time += delta
	
	last_direction = direction if direction != 0 else last_direction
	
	#attack
	if Input.is_action_just_pressed("attack"):
		create_attack()
	
	#basic tests
	
	if was_on_wall:
		coyote_timer.start()
	
	on_wall = is_touching_wall()
	was_on_wall = on_wall
	can_dash = check_can_dash()
	if on_wall:
		jumps = max_jumps - 1
		magnitude = int(not (Input.is_action_pressed("left") == Input.is_action_pressed("right")))
		magnitude *= -1 if Input.is_action_pressed("left") else 1
	
	floor_check()
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
	
	#jump stuff
	if cancel_jump:
		jump_canceling()
	if Input.is_action_just_pressed("jump") and not on_wall:
		if jumps >= 1 or coyote_timer.time_left > 0:
			jump()
	if Input.is_action_just_pressed("jump") and on_wall or wall_coyote_timer.time_left:
		wall_jump(-1 if wall_cast_left.is_colliding() else 1)
	elif Input.is_action_just_released("jump"):
		cancel_jump = true
	
	if Input.is_action_just_pressed("dash"):
		if can_dash:
			dash()

		print(is_on_floor() or on_wall, can_dash)
	
	walking(delta)
	
	if dashing:
		keep_dash()
	
	if on_wall:
		if magnitude != 0:
			wall_hold()
	
	if not direction and old_speed.x == velocity.x and not velocity.x == 0:
		slow_down()
	else:
		time_started = false
	
	
	old_speed = velocity
	time += delta
	buffer_timer += delta
	
	move_and_slide()
	debug_label.text = str(velocity)


func _on_room_detector_area_entered(area):
	if area is Room:
		camera.set_limits(area)
	
	
	elif area is AreaExit:
		print("bbb")
		Global.change_area(area)
	
	else:
		print("ccc")

func die():
	print("ded")

func static_damage():
	spawn_detector.go_to_pos()

func take_kb(dir):
	self.velocity = Vector2i(kb.x * dir, kb.y)

func create_attack():
	var new_attack : MeleeAttack = attack_scene.instantiate()
	
	new_attack.damage = melee_damage
	new_attack.time_left = 0.1
	new_attack.attacker = self
	
	var diff = get_global_mouse_position() - self.get_global_position()
	new_attack.rotation = diff.angle()
	
	self.add_child(new_attack)
