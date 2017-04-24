extends Node

onready var player = get_node("SamplePlayer")

func _ready():
	player.set_default_volume(0.5)

func play(name):	
	player.play(name)