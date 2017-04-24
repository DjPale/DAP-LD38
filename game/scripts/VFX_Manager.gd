extends Node

const Shake = preload("res://scripts/Shake.gd")
const FloatingText = preload("res://entities/FloatingText.tscn")
const ScoreText = preload("res://entities/ScoreText.tscn")
const Explosion = preload("res://entities/Explosion.tscn")

func get_fx_root():
	return get_node("/root/Test-Level")

func shake(obj, duration = 0.2, frequency = 15.0, amplitude = 8.0):
	var n = Node.new()
	n.set_script(Shake)
	obj.add_child(n)
	n.shake(obj, duration, frequency, amplitude)
	
func floating_text(message, tgt = null):
	var t = FloatingText.instance()
	var lbl = t.get_node("Label")
	lbl.set_text(message)
	
	get_fx_root().add_child(t)

	var pos = Vector2(120, 60)
	if tgt != null:
		pos = tgt.get_global_pos()
			
	t.set_global_pos(pos)

func score_text(score, pos):
	var t = ScoreText.instance()
	t.score = score

	get_fx_root().add_child(t)

	t.set_global_pos(pos)
	
func explosion(pos):
	var e = Explosion.instance()
	get_fx_root().add_child(e)
	e.set_global_pos(pos)
	e.set_emitting(true)
