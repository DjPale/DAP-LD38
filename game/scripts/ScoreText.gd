extends Node2D

export var score = 0

onready var label = get_node("Label")
onready var anim = get_node("AnimationPlayer")

func _ready():
	label.set_text(("-" if score < 0 else "") + "$" + str(abs(score)))
	
	if score < 0:
		anim.play("Fade-InOut-Red")
	else:
		anim.play("Fade-InOut-Green")