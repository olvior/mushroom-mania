extends Control


var player : CharacterBody2D

@onready var hboxcont : HBoxContainer = get_node("MargainContainer/MarginContainer/HBoxContainer")
@onready var vignette : ColorRect = get_node("Vignette")

@export_category("HUD Variables")
@export var pause : PackedScene

@export_group("Health")
@export var textureon : Texture2D
@export var texturehalf : Texture2D
@export var textureoff : Texture2D

var pause_menu

var r : TextureRect

var old_player_health : int


func _process(_delta):
	if Global.player:
		player = Global.player
	
	if player:
		if not old_player_health == player.current_health:
			update(player.current_health)
		old_player_health = player.current_health
	
	if Input.is_action_just_pressed("escape"):
		get_tree().paused = not get_tree().paused
	
		if get_tree().paused:
			pause_menu = pause.instantiate()
			self.add_child(pause_menu)
			vignette.call_deferred("darken")
		
		else:
			pause_menu.queue_free()
			vignette.call_deferred("lighten")

func update(h):
	var rects = hboxcont.get_children()
	
	for rdx in rects.size():
		r = rects[rdx]
		if rdx * 2 + 1 < h:
			r.texture = textureon
		elif rdx * 2 + 1 == h:
			r.texture = texturehalf
		else:
			r.texture = textureoff
