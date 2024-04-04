extends Control

func _on_quit_button_up():
	get_tree().quit()

func _on_continue_button_up():
	get_tree().paused = false
	self.queue_free()

func _on_save_button_up():
	Global.save_game("savefile1")

func _on_load_button_up():
	Global.load_save("savefile1")
