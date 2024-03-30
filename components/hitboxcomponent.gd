extends Area2D
class_name HitBoxComponent

@export var health_component : HealthComponent
@export var static_hazard_damage : int
@export var parent : CharacterBody2D
@export var inv_cooldown : float
@export var animation_player : AnimationPlayer

var invincibility_timer

func _ready():
	invincibility_timer = get_node("Invincibility Timer")
	invincibility_timer.wait_time = inv_cooldown

func damage(raw_amount):
	health_component.damage(raw_amount)
	
	if animation_player:
		animation_player.play("take_damage")

func take_kb(attacker):
	var kb_direction : Vector2
	var kb_strength : float
	
	if attacker is MeleeAttack or attacker is Arrow:
		kb_direction = attacker.kb_direction
		kb_strength = attacker.kb_strength
		
	elif attacker.get_parent() is CharacterBody2D:
		var diff = attacker.global_position.x - self.global_position.x
		kb_direction = Vector2(-abs(diff) / diff, 0)
		kb_strength = 300
	
	else:
		pass
	
	kb_direction.y /= 3
	
	if abs(kb_direction.x) > abs(kb_direction.y):
		kb_direction.y -= abs(kb_direction.x) / 3
		kb_direction = kb_direction.normalized()
	
	if attacker is MeleeAttack:
		attacker.attacker.velocity = -kb_direction * kb_strength
		attacker.attacker.velocity.x /= 1.5
		attacker.attacker.velocity.y *= 1.5
		
		if attacker.attacker == Global.player:
			attacker.attacker.on_melee_hit()
			
	parent.velocity = kb_direction * kb_strength

func _on_area_entered(area):
	if invincibility_timer.time_left == 0:
		var attacker
		var damage_amount
		var kbdir
		
		
		if area is MeleeAttack:
			attacker = area.attacker
			damage_amount = area.damage
		else:
			attacker = area
			damage_amount = 1
		
		if attacker == self.get_parent():
			return
		
		take_kb(area)
		damage(damage_amount)
		
		invincibility_timer.start()
		
		if parent.has_method("on_hit"):
			parent.on_hit()


func _on_body_entered(body):
	if body is Arrow:
		if body.attacker != self.get_parent():
			take_kb(body)
			self.damage(body.damage)
			body.queue_free()
	
	else:
		self.damage(static_hazard_damage)
		
		print(body)
		if parent.has_method("static_damage"):
			parent.static_damage()
	
	if parent.has_method("on_hit"):
		parent.on_hit()
