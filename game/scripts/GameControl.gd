extends Node

export var enable_debug = true

onready var flight_mgr = get_tree().get_root().find_node("FlightManager", true, false)
onready var weather_mgr = get_tree().get_root().find_node("WeatherManager", true, false)

func _ready():
	set_process_input(true)

func _input(event):
	if not enable_debug:
		return
	
	if event.type == InputEvent.KEY:
		if event.pressed: return
		
		var key = event.scancode
		
		if key == KEY_R:
			reset_level()
			
		if key == KEY_P:
			flight_mgr.open_airport()
			
		if key == KEY_H:
			weather_mgr.do_spawn()
			
		if key == KEY_X:
			VFX_Manager.explosion(Vector2(100, 100))
			
	if event.type == InputEvent.MOUSE_BUTTON:
		var pan_tooltip = get_node("GUI-Background/PanTooltip")
		var mouse_position = get_viewport().get_mouse_pos()
		var arrow_positions = [
			Vector2(625, 302),
			Vector2(320, 582),
			Vector2(17, 302)
		]
		
		if is_near(mouse_position, arrow_positions):
			pan_tooltip.show()
		else:
			pan_tooltip.hide()

func is_near(position, points):
	var radius = 20
	for i in points:
		if abs(position.x - i.x) < radius && abs(position.y - i.y) < radius:
			return true
	return false

func reset_level():
	get_tree().reload_current_scene()
