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
	print("ouch")
	if animation_player:
		animation_player.play("take_damage")


func _on_area_entered(area):
	if invincibility_timer.time_left == 0:
		var attacker
		var damage_amount
		if area is melee_attack:
			attacker = area.attacker
			damage_amount = area.damage
		else:
			attacker = area
			damage_amount = 1
		
		if attacker == self.get_parent():
			return
		
		self.damage(damage_amount)
		
		var diff = attacker.global_position.x - self.global_position.x
		var kbdir = -abs(diff) / diff
		
		print(kbdir)
		parent.take_kb(kbdir)
		invincibility_timer.start()


func _on_body_entered(_body):
	self.damage(static_hazard_damage)
	
	if parent.has_method("static_damage"):
		parent.static_damage()
