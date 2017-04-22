extends Node

const ThePlane = preload("res://entities/Plane.tscn")

export var time_scale = 1.0
export var start_pos = Vector2(20, 256)
export var end_pos = Vector2(1024 - 20, 256)
export var max_time_scale = 2.0
export var spacing = 50.0
export var flight_speed = 20.0
export var allowed_overshoot = 50.0

var money = 0

var sel_flight = null

onready var label = get_node("FlightInfo")

func _ready():
	set_process(true)

func _process(delta):
	_do_timers(delta)
	_sync_info()
	
func _do_timers(delta):
	pass
	
func _sync_info():
	var f = get_selected_flight()
	
	if f != null:
		label.set_text(f.flight)
	else:
		label.set_text("---")
	
func get_selected_flight():
	if sel_flight != null:
		var r = sel_flight.get_ref()
		return r

	return null
	
func get_plane(flight):
	var plane = get_tree().get_root().find_node("Plane-" + flight.flight, true, false)
	
	if plane == null:
		plane = ThePlane.instance()
		plane.set_name("Plane-" + flight.flight)
		
		var ap = get_airport(flight.from)
		if ap != null:
			plane.set_global_pos(ap.get_global_pos())
		else:
			print("Could not find from Airport ", flight.from)
		
		add_child(plane)
		
	return plane
	
func get_airport(name):
	return get_tree().get_root().find_node(name, true, false)
	
func check_connection(airport):
	var flight = get_selected_flight()
	
	if flight == null:
		return
		
	if airport.get_name() == flight.flight:
		return
	
	if airport.get_slot():
		var plane = get_plane(flight)
		
		if plane == null:
			print("Could not find plane or from airport")
			return
			
		if plane.has_destination():
			plane.dest.free_slot()
			
		plane.set_destination(flight, airport)
		
		sel_flight = null
		
	
func timeline_click(flight, pressed, offset):
	if pressed: return
	prints("flight clicked", flight.flight, pressed, offset)
	sel_flight = weakref(flight)
	
func airport_click(airport, pressed, offset):
	if pressed: return
	prints("airport clicked", airport.get_name(), pressed, offset)
	check_connection(airport)
	
func failed_flight(flight):
	pass
	
func complete_flight(flight):
	if flight == null:
		print("complete_flight with null!")
		return
		
	var r = flight.get_reward()
	prints("reward for", flight.flight, r)
	
	var ap = get_airport(flight.to)
	
	if ap != null:
		ap.free_slot()
	else:
		print("could not find airport ", flight.to)
		
	money += flight.get_reward()
	
