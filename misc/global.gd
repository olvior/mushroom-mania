extends Node

var block_size = 32

@onready var player = get_tree().get_first_node_in_group("player")
@onready var tilemap = get_tree().get_first_node_in_group("tilemap")
