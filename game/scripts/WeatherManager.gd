extends Node2D

const Hurricane = preload("res://entities/Hurricane.tscn")

export var random_spawntime = Vector2(60, 120)
export var random_lifetime = Vector2(20, 60)
export var random_scale = Vector2(0.75, 2.0)
export var random_speed = Vector2(4, 10)

onready var airports = get_tree().get_root().find_node("Airports", true, false)
onready var weather = get_tree().get_root().find_node("Weather", true, false)

var next_spawn = 2.0

func _ready():
	set_process(true)
		
func _process(delta):
	next_spawn -= delta
	
	if next_spawn <= 0:
		do_spawn()
		next_spawn = rand_range(random_spawntime.x, random_spawntime.y)
		
func do_spawn():
	var h = Hurricane.instance()
	h.lifetime = rand_range(random_lifetime.x, random_lifetime.y)
	h.speed = rand_range(random_speed.x, random_speed.y)
	weather.add_child(h)
	
	h.set_scaled_size(rand_range(random_scale.x, random_scale.y))
	
	var apidx = rand_range(0, airports.get_child_count())
	var ap = airports.get_child(apidx)
	
	var dir = Vector2(rand_range(-1, 1), rand_range(-1, 1)).normalized()
	var hpos = ap.get_global_pos() + (dir * rand_range(200, 400))
	h.set_global_pos(hpos)
	h.direction = -dir
	
	