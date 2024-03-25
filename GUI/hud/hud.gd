extends Control


var player : CharacterBody2D

@onready var hboxcont : HBoxContainer = get_node("MargainContainer/MarginContainer/HBoxContainer")

@export var pause : PackedScene
@export var textureon : Texture2D
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
			Global.main_scene.get_node("CanvasLayer").add_child(pause_menu)
		
		else:
			pause_menu.queue_free()

func update(h):
	var rects = hboxcont.get_children()
	
	for rdx in rects.size():
		r = rects[rdx]
		if rdx < h:
			r.texture = textureon
		else:
			r.texture = textureoff
