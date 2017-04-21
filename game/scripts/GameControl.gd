extends Node

func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		if event.pressed: return
		
		var key = event.scancode
		
		if key == KEY_R:
			reset_level()

func reset_level():
	get_tree().reload_current_scene()
