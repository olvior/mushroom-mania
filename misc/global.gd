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

func _ready():
	self.add_to_group("for_save")

func save():
	var save_dict = {
		"current_area" : current_area.area_name
	}
	
	return save_dict

func start(area_name):
	player = player_scene.instantiate()
	main_scene.add_child(player)
	
	var new_scene : GameArea = game_areas[area_name].instantiate()
	main_scene.add_child(new_scene)
	current_area = new_scene

func change_area(exit : AreaExit):
	current_area.queue_free()
	var new_scene : GameArea = game_areas[exit.connects_to_area].instantiate()
	new_scene.identify_exits()
	
	main_scene.call_deferred("add_child", new_scene) 
	
	current_area = new_scene
	var new_exit : AreaExit = new_scene.exits[exit["connects_to_loc"]]
	player.position = new_exit.spawn_loc.get_global_position()


func save_game(file_path):
	var path = "user://" + file_path + ".save"
	var all_nodes = get_tree().get_nodes_in_group("for_save")
	var save_file = FileAccess.open(path, FileAccess.WRITE)
	
	for node in all_nodes:
		var node_data = node.save()
		var json_string = JSON.stringify(node_data)
		save_file.store_line(json_string)
	
	print("save done")

func load_save(file_path):
	var path = "user://" + file_path + ".save"
	if not FileAccess.file_exists(path):
		return
	
	var first = true
	var save_game = FileAccess.open(path, FileAccess.READ)
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()
		var json = JSON.new()
		
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue
		
		var node_data = json.get_data()
		
		if first: # Global node, has setup stuff idk
			var new_area_name = node_data["current_area"]
			var new_area = game_areas[new_area_name].instantiate()
			current_area.queue_free()
			main_scene.add_child(new_area)
			current_area = new_area
			print("i might have  changed")
			first = false
		
		else:
			var node = get_tree().get_root().get_node(node_data["scene_path"])
			
			if node.has_method("on_load"):
				node.call_deferred("on_load")
			
			var skip_next = false
			for i in node_data.keys():
				if skip_next:
					skip_next = false
				
				elif i == "file_path" or i == "scene_path":
					pass
				
				elif i[-2] == ".":
					node.set(i.substr(0, len(i) - 2), Vector2(node_data[i.substr(0, len(i) - 2) + ".x"], node_data[i.substr(0, len(i) - 2) + ".y"]))
					skip_next = true
				
				else:
					node.set(i, node_data[i])

				
