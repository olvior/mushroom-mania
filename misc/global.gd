extends Node

var block_size = 32

@onready var player = get_tree().get_first_node_in_group("player")
@onready var tilemap = get_tree().get_first_node_in_group("tilemap")

var current_area : GameArea
var game_areas = {
	"main" : preload("res://leveldesign/areas/main.tscn"),
	"test_area" : preload("res://leveldesign/areas/test_area.tscn")
}

func change_area(exit : AreaExit):
	current_area.queue_free()
	var new_scene = game_areas[exit.connects_to_area].instantiate()
	### nearly tehre
