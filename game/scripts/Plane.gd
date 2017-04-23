extends Node2D

onready var label = get_node("Label")
export(Color) var color = Color(1.0, 1.0, 1.0, 0.5)
export(float) var len_offset = -24.0
export(float) var line_width = 10.0
export(float) var speed_modifier = 1.0
export(float) var slot_radius = 70.0
export(float) var land_radius = 10.0

var cur_dest = null
var cur_flight = null

var is_landing = false

var via_list = []

onready var mgr = get_tree().get_root().find_node("FlightManager", true, false)
onready var sprite = get_node("Sprite")

func _ready():
	sprite.set_modulate(color)
	set_process(true)

func _process(delta):
	_update_pos(delta)

func set_color(the_color):
	color = the_color
	sprite.set_modulate(color)

func get_flight():
	if cur_flight != null:
		return cur_flight.get_ref()
		
	return null

func _update_pos(delta):
	var dest = get_current_destination()
	var final = is_final_destination()
	
	if dest == null: return
	
	var gpos = get_global_pos()
	
	var dir = dest.get_global_pos() - gpos
	
	if final:
		if not is_landing and dir.length() < slot_radius:
			if not dest.get_slot():
				get_flight().fail_flight()
				 
			is_landing = true
	
	if dir.length() < land_radius:
		if final:
			completed_flight()
		else:
			print("removed ", via_list.pop_front())
	else:
		set_global_pos(gpos + (dir.normalized() * mgr.flight_speed * speed_modifier * delta))  
	
#func has_destination():
#	return (dest != null)
#
#func get_destination():
#	return dest

func get_current_destination():
	if via_list.size() == 0:
		print("plane via list empty - should not happen")
		return
	
	return via_list.front()
	
func get_final_destination():
	if via_list.size() == 0:
		print("plane via list empty - should not happen")
		return
		
	return via_list.back()
	
func is_final_destination():
	return (via_list.size() == 1)

func add_destination(flight, airport):
	if airport == null or flight == null or is_landing: return
	
	via_list.append(airport)
	
	label.set_text(flight.flight + " > " + airport.get_name())
	
	set_color(flight.get_color())
	
	cur_flight = weakref(flight)
		
func completed_flight():
	mgr.complete_flight(get_current_destination(), get_flight())
	die()
	
func report_failed_flight():
	var f = get_flight()
	if f != null:
		f.fail_flight()
	else:
		print("cannot report failed flight")
	
func lost_flight():
	if is_landing:
		var dest = get_final_destination()
		if dest != null:
			dest.free_slot()
			
	via_list.clear()
		
	die()
	
func die():
	queue_free()