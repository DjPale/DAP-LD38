extends Node

const Shake = preload("res://scripts/Shake.gd")

func shake(obj, duration = 0.2, frequency = 15.0, amplitude = 8.0):
	var n = Node.new()
	n.set_script(Shake)
	obj.add_child(n)
	n.shake(obj, duration, frequency, amplitude)