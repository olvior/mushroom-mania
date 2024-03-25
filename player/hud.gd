extends Control


var player : CharacterBody2D

@onready var hboxcont : HBoxContainer = get_node("MargainContainer/MarginContainer/HBoxContainer")

@export var textureon : Texture2D
@export var textureoff : Texture2D

var r : TextureRect

var old_player_health : int

func _process(_delta):
	if Global.player:
		player = Global.player
	
	if player:
		if not old_player_health == player.current_health:
			update(player.current_health)
		old_player_health = player.current_health
	
	print("A")
	if Input.is_action_just_pressed("escape"):
		print("E")
		get_tree().paused = not get_tree().paused

func update(h):
	var rects = hboxcont.get_children()
	
	for rdx in rects.size():
		r = rects[rdx]
		if rdx < h:
			r.texture = textureon
		else:
			r.texture = textureoff
