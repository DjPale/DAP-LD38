extends Node2D

export(int) var max_capacity = 1
export(int) var free_capacity = 0

var landing_radius = 0.0

onready var mgr = get_tree().get_root().find_node("FlightManager", true, false)
onready var size1 = get_node("Size1")
onready var size2 = get_node("Size2")
onready var size3 = get_node("Size3")
onready var sprite = get_node("MapSprite")

func _ready():
	free_capacity = max_capacity
	
	if max_capacity > 0:
		size1.show()
	if max_capacity > 1:
		size2.show()
	if max_capacity > 2:
		size3.show()

	get_node("Label").set_text(get_name())
	set_process(true)

func _process(delta):
	pass
	
func _draw():
    if landing_radius > 0.0:
        draw_circle(sprite.get_pos(), landing_radius, Color(1, 1, 1, 0.5))

func set_landing_radius(radius):
    landing_radius = radius

func get_capacity():
	return free_capacity
	
func get_slot():
	if free_capacity > 0:
		free_capacity -= 1
		update_capacity()
		return true
		
	update_capacity()
	return false
	
func free_slot():
	free_capacity += 1
	if free_capacity > max_capacity:
		free_capacity = max_capacity
		
	update_capacity()

func update_capacity():
	size1.set_frame(0)
	size2.set_frame(0)
	size3.set_frame(0)
	
	var occupied = max_capacity - free_capacity
	if occupied > 0:
		size1.set_frame(1)
	if occupied > 1:
		size2.set_frame(1)
	if occupied > 2:
		size3.set_frame(1)

func _on_MapSprite_clicked( pressed, global_pos, offset ):
	if global_pos.x > 620: return
	mgr.airport_click(self, pressed, offset)
