extends Control


@export var player : CharacterBody2D
@export var hboxcont : HBoxContainer

@export var textureon : Texture2D
@export var textureoff : Texture2D

var r : TextureRect

var old_player_health : int

func _process(_delta):
	if not old_player_health == player.current_health:
		update(player.current_health)
	old_player_health = player.current_health

func update(h):
	var rects = hboxcont.get_children()
	
	for rdx in rects.size():
		r = rects[rdx]
		if rdx < h:
			r.texture = textureon
		else:
			r.texture = textureoff
