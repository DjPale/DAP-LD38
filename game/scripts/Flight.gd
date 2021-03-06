extends Node

export(String) var flight
export(String) var from
export(String) var to
export(int) var reward = 0
export(float) var initial_time = 0.0
export(int) var list_pos = 0

var time_counter = 0.0

var mgr = null #get_tree().get_root().find_node("FlightManager", true, false)

onready var timeline = get_node("Timeline")
onready var sprite = get_node("Timeline/TimelineSprite")

func set_frame(number):
	sprite.set_frame(number)

func get_color():
	return sprite.get_modulate()
	
func set_color(color):
	sprite.set_modulate(color)

func _ready():
	timeline.set_hidden(false)
	_setup_labels()
	_calc_pos()
	set_process(true)
	
func _process(delta):
	_do_timers(delta)
	_calc_pos()
	
func _do_timers(delta):
	time_counter += (delta * mgr.time_scale)
	
	if time_counter >= get_absolute_max():
		fail_flight()

func _calc_pos():
	var y_pos = mgr.start_pos.y + (list_pos * mgr.spacing)
	var d_x = mgr.end_pos.x - mgr.start_pos.x
	var max_time = get_absolute_max()
	
	var tl_scale = (d_x / max_time)
	var time_pct = time_counter / max_time
	var x_pos = tl_scale * time_counter

	if time_pct < 0.05:
		timeline.set_opacity(time_pct / 0.05)

			
	if time_pct > 0.9:
		timeline.set_opacity((1 - time_pct) / 0.10)
		
	
	timeline.set_global_pos(Vector2(mgr.start_pos.x + x_pos, y_pos))
	
func get_absolute_max():
	var it = initial_time * (1.0 / mgr.time_scale)
	return (it + it * mgr.allowed_overshoot)
	
func get_reward(dest):
	var ret = 0
	
	# wrong airport
	if dest != to:
		return floor(reward * mgr.reward_wrong)
	
	# on time
	if time_counter <= initial_time:
		print("positive reward ", reward)
		return reward
	else:
		# overtime
		return floor(reward * mgr.reward_delayed)
	
func _setup_labels():
	get_node("Timeline/Flight").set_text(flight)
	get_node("Timeline/Path").set_text(from + "-" + to)
	get_node("Timeline/Time").set_text(str(initial_time - time_counter))
	get_node("Timeline/Reward").set_text("$" + str(reward))

func _on_TimelineSprite_clicked(pressed, global_pos, offset):
	mgr.timeline_click(self, pressed, offset)
	
func fail_flight():
	mgr.failed_flight(self, floor(reward * mgr.reward_failed))
	die()
	
func die():
	queue_free()
