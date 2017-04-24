extends Node

onready var player = get_node("SamplePlayer")
onready var stream = get_node("StreamPlayer")

func _ready():
	player.set_default_volume(0.5)

func play(name):	
	player.play(name)

func music(name):
	var song = load("res://sfx/" + name + ".ogg")
	stream.set_stream(song)
	
	stream.play()
	