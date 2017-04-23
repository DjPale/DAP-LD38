extends Node2D

onready var label = get_node("Label")
export(Color) var color = Color(1.0, 1.0, 1.0, 0.8)
export(float) var len_offset = -24.0
export(float) var line_width = 10.0
export(float) var speed_modifier = 1.0

var dest = null
var cur_flight = null

onready var mgr = get_tree().get_root().find_node("FlightManager", true, false)
onready var sprite = get_node("Sprite")

func _ready():
	sprite.set_modulate(color)
	set_process(true)

func _process(delta):
	_update_pos(delta)
	update()

func _draw():
	if dest == null: return
	
	var v = dest.get_global_pos() - get_global_pos()
	
	var tgt = v.normalized() * (v.length() + len_offset)
	draw_line(Vector2(), tgt, Color(0, 0, 0), line_width * 1.5)
	draw_line(Vector2(), tgt, color, line_width)

func set_color(the_color):
	color = the_color
	sprite.set_modulate(color)

func get_flight():
	if cur_flight != null:
		return cur_flight.get_ref()
		
	return null

func _update_pos(delta):
	if dest == null: return
	var gpos = get_global_pos()
	
	var dir = dest.get_global_pos() - gpos
	if dir.length() < 10.0:
		completed_flight()
		dest = null
	else:
		set_global_pos(gpos + (dir.normalized() * mgr.flight_speed * speed_modifier * delta))  
	
func has_destination():
	return (dest != null)

func get_destination():
	return dest

func set_destination(flight, airport):
	if airport == null or flight == null: return
	
	dest = airport
	label.set_text(flight.flight + " > " + airport.get_name())
	
	set_color(flight.get_color())
	
	cur_flight = weakref(flight)
		
func completed_flight():
	mgr.complete_flight(get_destination(), get_flight())
	die()
	
func lost_flight():
	if dest != null:
		dest.free_slot()
		
	dest = null
	die()
	
func die():
	queue_free()