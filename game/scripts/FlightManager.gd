extends Node

const ThePlane = preload("res://entities/Plane.tscn")
const TheFlight = preload("res://entities/Flight.tscn")

export var time_scale = 1.0
export var start_pos = Vector2(20, 256)
export var end_pos = Vector2(1024 - 20, 256)
export var max_time_scale = 2.0
export var spacing = 50.0
export var flight_speed = 20.0
export var allowed_overshoot = 50.0
export var flight_spawn_interval = Vector2(5, 10)
export var airport_spawn_to_flight_ratio = 10

var money = 0

var sel_flight = null

var next_spawn = 0.0
var next_airport = 0.0

var airline_codes = ["DY", "SK", "WF", "DA", "KL"] 

onready var airports = get_node("Airports")
onready var label = get_node("FlightInfo")

func _ready():
	set_next_spawn()
	set_process(true)

func _process(delta):
	_do_timers(delta)
	_sync_info()
	
func _do_timers(delta):
	if next_spawn > 0:
		next_spawn -= delta
		if next_spawn <= 0:
			do_spawn()
	
func _sync_info():
	var f = get_selected_flight()
	
	if f != null:
		label.set_text(f.flight)
	else:
		label.set_text("---")
	
func set_next_spawn():
	next_spawn = rand_range(flight_spawn_interval.x, flight_spawn_interval.y)
	
func do_spawn():
	var flight = TheFlight.instance()
	flight.flight = get_rand_flight()
	flight.from = get_rand_airport()
	flight.to = get_rand_airport(flight.from)
	
	add_child(flight)
	set_next_spawn()
	
func get_rand_airport(exclude = null):
	var cnt = 0
	for c in airports.get_children():
		if not c.is_hidden() and c.get_name() != exclude:
			cnt += 1
	
	if cnt == 0:
		return "n/a"
	
	var r = int(rand_range(0, cnt))
	prints(r, "of", cnt)
	
	cnt = -1
	for c in airports.get_children():
		if not c.is_hidden() and c.get_name() != exclude:
			cnt += 1		
		
		if cnt == r:
			return c.get_name()

			
	return "huh?"
	
func get_rand_flight():
	return airline_codes[int(rand_range(0, airline_codes.size()))] + str(int(rand_range(100, 9000)))
		
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
	var ap = airports.find_node(name, true, false)
	
	if ap != null and not ap.is_hidden:
		return
	
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
	
func failed_flight(flight, reward):
	var r = reward
	prints("reward for timeout ", flight.flight, r)
	
	money += r
	flight.die()
	
func complete_flight(flight):
	if flight == null:
		print("complete_flight with null!")
		return
	
	var ap = get_airport(flight.to)
	
	if ap != null:
		ap.free_slot()
	else:
		print("could not find airport ", flight.to)

	var r = flight.get_reward(ap.get_name())
	prints("reward for", flight.flight, r)

	money += r
	
	flight.die()
	
