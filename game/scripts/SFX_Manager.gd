extends Node

onready var player = get_node("SamplePlayer")

func play(name):
	player.play(name)