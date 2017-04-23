extends Node2D

export(Rect2) var rect = Rect2()
export(Vector2) var upper = Vector2()
export(Vector2) var lower = Vector2()
export(float) var pan_speed = 400.0

onready var map_frame = get_node("MapFrame")

var status = "released"
var offset = Vector2()
var mpos = Vector2()

var pan_velocity = Vector2()

func _ready():
	clamp_pos()
	set_process(true)
	set_process_input(true)

func _input(ev):
	if ev.type == InputEvent.MOUSE_BUTTON and ev.button_index == BUTTON_LEFT and ev.is_pressed() and status != "dragging":
		var s_pos = get_global_pos()

		if rect.has_point(ev.global_pos):
			#print("clicked")
			status = "clicked"
			offset = s_pos - ev.global_pos

	if status == "clicked" and ev.type == InputEvent.MOUSE_MOTION:
		status = "dragging"
		#print("dragging")
			
	if (status == "dragging" || status == "clicked") and ev.type == InputEvent.MOUSE_BUTTON and ev.button_index == BUTTON_LEFT:
		if not ev.is_pressed():
			status = "released"
			#prints("released")
			
	mpos = get_global_mouse_pos()

	
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
	if status == "dragging":
		set_global_pos(mpos + offset)
		clamp_pos()
	else:
		var p = Vector2()
		if Input.is_action_pressed("ui_left"):
			p.x = 1
		elif Input.is_action_pressed("ui_right"):
			p.x = -1
		if Input.is_action_pressed("ui_up"):
			p.y = 1
		elif Input.is_action_pressed("ui_down"):
			p.y = -1
			
		if p.length() != 0:
			set_global_pos(get_global_pos() + p.normalized() * pan_speed * delta)
			clamp_pos()

