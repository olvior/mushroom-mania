extends Control

@export var main_scene : PackedScene


func _on_new_game_button_up():
	var main = main_scene.instantiate()
	get_tree().get_root().add_child(main)
	Global.main_scene = main
	Global.start("tutorial_area")
	self.queue_free()


func _on_settings_button_up():
	pass # Replace with function body.


func _on_open_last_save_button_up():
	pass # Replace with function body.


func _on_quit_button_up():
	get_tree().quit()

