extends Node2D

class_name HealthComponent

@export var parent : CharacterBody2D
@export var max_health : int
@export var display : bool

@onready var current_health = max_health

var protection = 1

func _ready():
	if display:
		update_display()

func damage(raw_amount):
	current_health -= int(raw_amount / protection)
	
	if current_health <= 0:
		current_health = 0
		
		if parent.has_method("die"):
			parent.die()
		else:
			print("parent has no die method", parent, parent.get_path())
	
	if display:
		update_display()

func heal(raw_amount):
	current_health += raw_amount
	
	if current_health > max_health:
		current_health = max_health
	
	if display:
		update_display()

func update_display():
	parent.current_health = current_health

func save():
	var save_dict = {
		"file_path" : get_scene_file_path(),
		"scene_path" : get_tree().get_root().get_path_to(self),
		"current_health" : current_health,
		"max_health" : max_health
	}
	
	return save_dict

func on_load():
	update_display()
