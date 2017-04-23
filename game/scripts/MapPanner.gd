extends Node2D

export(Rect2) var rect = Rect2()
export(Vector2) var upper = Vector2()
export(Vector2) var lower = Vector2()
export(float) var pan_scale_factor = 1.25

onready var map_frame = get_node("MapFrame")

var is_panning = false
var orig_pos = Vector2()
var offset = Vector2()
var mpos = Vector2()

var pan_velocity = Vector2()

func _ready():
	clamp_pos()
	set_process(true)
	set_process_input(true)

func _input(ev):	
	if ev.type == InputEvent.MOUSE_BUTTON and ev.button_index == BUTTON_LEFT:
		var ev_pos = ev.global_pos
		var s_pos = get_global_pos()

		if ev.pressed and not is_panning:
			if rect.has_point(ev_pos):
				is_panning = true
				orig_pos = ev_pos
				offset = s_pos - ev_pos

		if not ev.pressed and is_panning:
			is_panning = false
			
	if ev.type == InputEvent.MOUSE_MOTION: mpos = ev.global_pos
	
func clamp_pos():
	var g = get_global_pos()
	if g.x < upper.x:
		g.x = upper.x
	if g.y < upper.y:
		g.y = upper.y
		
	if g.x > lower.x:
		g.x = lower.x
	if g.y > lower.y:
		g.y = lower.y
		
	set_global_pos(g)

func _process(delta):
	if is_panning:
		set_global_pos(mpos + offset)
		clamp_pos()
