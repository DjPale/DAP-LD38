extends Node

const ThePlane = preload("res://entities/Plane.tscn")
const TheFlight = preload("res://entities/Flight.tscn")
const TheAirport = preload("res://entities/Airport.tscn")

export var time_scale = 1.0
export var start_pos = Vector2(20, 256)
export var end_pos = Vector2(1024 - 20, 256)
export var max_time_scale = 2.0
export var spacing = 50.0
export var flight_speed = 20.0
export var min_max_allowed_time = Vector2(2.0, 30.0)
export var allowed_overshoot = 50.0
export var flight_spawn_interval = Vector2(5, 10)
export var airport_spawn_to_flight_ratio = 10
export var max_flights = 3
export var money = 0
export var distance_to_money = 0.5
export var distance_to_time = 0.25


var sel_flight = null

var next_spawn = 0.0
var next_airport = 0.0

var airline_codes = ["DY", "SK", "WF", "DA", "KL"] 

onready var airports = get_tree().get_root().find_node("Airports", true, false)
onready var flights = get_tree().get_root().find_node("Flights", true, false)
onready var planes = get_tree().get_root().find_node("Planes", true, false)
onready var label = get_node("FlightInfo")
onready var score_label = get_node("Score")
onready var SFX_Manager = get_node("/root/SFX_Manager")

onready var debug_label = get_node("DEBUG")

var active_flights = 0

func _ready():
	add_airports()
	set_next_spawn()
	update_score()
	set_process(true)

func _process(delta):
	_do_timers(delta)
	_sync_info()
	debug_label.set_text(str(active_flights))
	
func _do_timers(delta):
	if next_spawn > 0:
		next_spawn -= delta
		if next_spawn <= 0:
			do_spawn()
			set_next_spawn()
	
func _sync_info():
	var f = get_selected_flight()
	
	if f != null:
		label.set_text(f.flight)
	else:
		label.set_text("---")
	
func set_next_spawn():
	next_spawn = rand_range(flight_spawn_interval.x, flight_spawn_interval.y)
	
func find_slot():
	var prev_idx = 0
	
	for i in range(0, 10):
		var isfree = true
		
		for f in flights.get_children():
			if f.list_pos == i:
				isfree = false
				
		if isfree:
			return i
			
	print("no free slots!")
	return 0
		
	
func do_spawn():
	if active_flights >= max_flights:
		return
	
	var retries = 10
	var dist = 0
	var initial_time = 0
	
	var str_from = "NONO!"
	var str_to = "NONO!"
	
	while retries > 0 and (initial_time < min_max_allowed_time.x or initial_time > min_max_allowed_time.y):
		str_from = get_rand_airport()
		str_to = get_rand_airport(str_from)	
		var ap_from = get_airport(str_from)
		var ap_to = get_airport(str_to)
		dist = (ap_to.get_global_pos() - ap_from.get_global_pos()).length()
		initial_time = floor(dist * distance_to_time)
		#prints("Trying to spawn", str_from, str_to, dist, initial_time)
		retries -= 1
		
	if retries == 0:
		print("Failed to spawn flight due to min / max distance")
		return
	
	var flight = TheFlight.instance()
	flight.mgr = self
	flight.flight = get_rand_flight()
	flight.set_name("Flight-" + flight.flight)
	flight.from = str_from
	flight.to = str_to
	
	flight.initial_time = initial_time
	flight.reward = floor(dist * distance_to_money)
	
	active_flights += 1
	flight.list_pos = find_slot()
	
	flights.add_child(flight)
	
func update_score():
	score_label.set_text(str(money))
	
func get_rand_airport(exclude = null):
	var cnt = 0
	for c in airports.get_children():
		if not c.is_hidden() and c.get_name() != exclude:
			cnt += 1
	
	if cnt == 0:
		return "n/a"
	
	var r = int(rand_range(0, cnt))
	
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
	
func find_plane(flight):
	return get_tree().get_root().find_node("Plane-" + flight.flight, true, false)
	
func get_plane(flight):
	var plane = get_tree().get_root().find_node("Plane-" + flight.flight, true, false)
	
	if plane == null:
		plane = ThePlane.instance()
		plane.set_name("Plane-" + flight.flight)
		planes.add_child(plane)
		
		var ap = get_airport(flight.from)
		if ap != null:
			prints("ap", ap.get_name(), ap.get_global_pos())
			plane.set_global_pos(ap.get_global_pos())
		else:
			print("Could not find from Airport ", flight.from)
		

		
	return plane
	
func get_airport(name):
	var ap = airports.find_node(name, true, false)
	
	if ap != null and not ap.is_hidden():
		return ap
		
	return null
	
func check_connection(airport):
	var flight = get_selected_flight()
	
	if flight == null:
		return
		
	if airport.get_name() == flight.from:
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
	
	var dirty = flight.get_color() != Color(1,1,1)
	if (!dirty):
		var r = float(randi() % 75 + 25) / 100
		var g = float(randi() % 75 + 25) / 100
		var b = float(randi() % 75 + 25) / 100
		var color = Color(r, g, b, 0.75)
		flight.set_color(color)

	for i in flights.get_children():
		i.set_frame(0)
	
	flight.set_frame(1)
	
	sel_flight = weakref(flight)
	
func airport_click(airport, pressed, offset):
	if pressed: return
	prints("airport clicked", airport.get_name(), pressed, offset)
	SFX_Manager.play("select")
	check_connection(airport)
	
func failed_flight(flight, reward):
	var r = reward
	prints("reward for timeout ", flight.flight, r)
	
	money += r
	
	update_score()
	
	active_flights -= 1
	SFX_Manager.play("plane-crashed")
	
	var plane = find_plane(flight)
	if plane != null:
		plane.lost_flight()
	else:
		print("termintated flight without plane (usually OK)!")
	
	flight.die()
	
func complete_flight(dest_airport, flight):
	if flight == null:
		print("complete_flight with null!")
		return
	
	var ap = dest_airport
	
	if ap != null:
		ap.free_slot()
	else:
		print("complete_flight with no ap ", flight.to)

	var r = flight.get_reward(ap.get_name())
	prints("reward for", flight.flight, r)

	money += r
	SFX_Manager.play("complete_flight")
	
	update_score()
	
	active_flights -= 1
	flight.die()
	
func add_airport(name, iata_code, capacity, x_coord, y_coord):
	var ap = TheAirport.instance()
	
	ap.set_pos(Vector2(x_coord, y_coord) * 5.0)
	ap.set_name(iata_code)
	ap.max_capacity = capacity
	
	airports.add_child(ap)
	

func add_airports():
	add_airport("Beijin Capital International Airport", "PEK", 3, 399, 103)
	add_airport("Dubai International Airport", "DXB", 3, 309, 129)
	add_airport("Los Angeles International Airport", "LAX", 3, 69, 111)
	add_airport("Tokyo International Airport", "HND", 3, 429, 110)
	add_airport("Heathrow Airport", "LHR", 3, 232, 78)
	add_airport("Charles de Gaulle Airport", "CDG", 3, 238, 85)
	add_airport("Amsterdam Airport Schiphol", "AMS", 3, 241, 77)
	add_airport("Frankfurt Airport", "FRA", 3, 247, 85)
	add_airport("Istanbul Atatürk Airport", "IST", 3, 272, 99)
	add_airport("Singapore Changi Airport", "SIN", 3, 377, 169)
	add_airport("Seoul Incheon International Airport", "ICN", 3, 410, 106)
	add_airport("Suvarnabhumi Airport", "BKK", 3, 374, 147)
	add_airport("Indira Gandhi International Airport", "DEL", 3, 343, 133)
	add_airport("Madrid Barajas Airport", "MAD", 3, 228, 100)
	add_airport("Toronto Pearson International Airport", "YYZ", 3, 120, 96)
	add_airport("Sydney Kingsford-Smith Airport", "SYD", 3, 443, 226)
	add_airport("Leonardo da Vinci–Fiumicino Airport", "FCO", 3, 254, 99)
	add_airport("Benito Juárez International Airport", "MEX", 3, 95, 137)
	add_airport("John F. Kennedy International Airport", "JFK", 3, 128, 100)
	add_airport("Campo de Marte Airport", "MAE", 1, 169, 209)
	add_airport("Sheremetyevo International Airport", "SVO", 2, 289, 69)
	add_airport("Avalon Airport", "AVV", 2, 426, 227)
	add_airport("El Dorado International Airport", "BOG", 2, 132, 163)
	add_airport("Oslo Airport, Gardermoen", "OSL", 1, 246, 62)
	add_airport("Stockholm Arlanda Airport", "ARN", 2, 257, 59)
	add_airport("Copenhagen Airport", "CPH", 1, 249, 70)
	add_airport("O. R. Tambo International Airport", "JNB", 2, 272, 221)