extends Node

var block_size = 32

var player : CharacterBody2D
var player_scene = preload("res://player/player.tscn")

var current_area : GameArea
var game_areas = {
	"main" : preload("res://leveldesign/areas/main.tscn"),
	"test_area" : preload("res://leveldesign/areas/test_area.tscn")
}

@onready var main_scene : Node2D

func start():
	print("A")
	player = player_scene.instantiate()
	main_scene.add_child(player)
	
	var new_scene : GameArea = game_areas["main"].instantiate()
	main_scene.add_child(new_scene)
	current_area = new_scene
	


func change_area(exit : AreaExit):
	current_area.queue_free()
	var new_scene : GameArea = game_areas[exit.connects_to_area].instantiate()
	main_scene.add_child_deffered(new_scene)
	
	current_area = new_scene
	var new_exit : AreaExit = new_scene.exits[exit["connects_to_loc"]]
	player.position = new_exit.spawn_loc.get_global_position()

