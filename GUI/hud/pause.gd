extends Control

func _on_quit_button_up():
	get_tree().quit()

func _on_continue_button_up():
	get_tree().paused = false
	self.queue_free()
