extends Node

onready var map_camera = get_tree().get_root().find_node("MapCamera", true, false)

func _ready():
	set_process_input(true)

func _input(event):
	if event.type == InputEvent.KEY:
		if event.pressed: return
		
		var key = event.scancode
		
		if key == KEY_R:
			reset_level()
			
		if key == KEY_LEFT:
			pan(-1, 0)
		
		if key == KEY_RIGHT:
			pan(1, 0)

func reset_level():
	get_tree().reload_current_scene()

func pan(x, y):
	prints("pan", x, y)
	map_camera.set_pos(map_camera.get_pos() + Vector2(x * 50.0, 0))