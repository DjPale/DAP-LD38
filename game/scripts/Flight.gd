extends Node

export(String) var flight
export(String) var from
export(String) var to
export(int) var reward = 0
export(float) var initial_time = 0.0
export(int) var list_pos = 0

var time_counter = 0.0

onready var mgr = get_tree().get_root().find_node("FlightManager", true, false)

onready var timeline = get_node("Timeline")
onready var sprite = get_node("Timeline/TimelineSprite")

func get_color():
	return sprite.get_modulate()
	
func set_color(color):
	sprite.set_modulate(color)

func _ready():
	_setup_labels()
	set_process(true)
	
func _process(delta):
	_do_timers(delta)
	_calc_pos()
	
func _do_timers(delta):
	time_counter += (delta * mgr.time_scale)
	
	if time_counter >= get_absolute_max():
		time_counter = 0

func _calc_pos():
	var y_pos = mgr.start_pos.y + (list_pos * mgr.spacing)
	var d_x = mgr.end_pos.x - mgr.start_pos.x
	var max_time = get_absolute_max() * mgr.time_scale
	
	var tl_scale = d_x / max_time
	var time_pct = time_counter / max_time
	var x_pos = tl_scale * time_counter
	
	timeline.set_global_pos(Vector2(mgr.start_pos.x + x_pos, y_pos))
	
func get_absolute_max():
	return (initial_time + initial_time * mgr.allowed_overshoot)
	
func get_reward():
	if time_counter <= initial_time:
		return reward
	else:
		return reward * ((initial_time - time_counter) / get_absolute_max())
	
func _setup_labels():
	get_node("Timeline/Flight").set_text(flight)
	get_node("Timeline/Path").set_text(from + "-" + to)
	get_node("Timeline/Time").set_text(str(initial_time - time_counter))
	get_node("Timeline/Reward").set_text("$" + str(reward))

func _on_TimelineSprite_clicked(pressed, offset):
	mgr.timeline_click(self, pressed, offset)
