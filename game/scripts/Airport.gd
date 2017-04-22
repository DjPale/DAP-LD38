extends Node2D

export(int) var max_capacity = 1
export(int) var free_capacity = 1

onready var mgr = get_tree().get_root().find_node("FlightManager", true, false)

func _ready():
	get_node("Label").set_text(get_name())
	_update_label()
	set_process(true)

func _process(delta):
	pass
	
func _update_label():
	get_node("Capacity").set_text(str(free_capacity) + "/" + str(max_capacity))
	
func get_capacity():
	return free_capacity
	
func get_slot():
	if free_capacity > 0:
		free_capacity -= 1
		_update_label()
		return true
		
	return false
	
func free_slot():
	free_capacity += 1
	if free_capacity > max_capacity:
		free_capacity = max_capacity
		
	_update_label()

func _on_MapSprite_clicked( pressed, offset ):
	mgr.airport_click(self, pressed, offset)
