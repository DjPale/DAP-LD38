extends Node2D

onready var parent = get_parent()

func _ready():
	set_process(true)
	
func _process(delta):
	update()
	
func _draw():
	var prev_point = Vector2()
	
	for ap in parent.via_list:
		var dest = ap
	
		var tgt = dest.get_global_pos() - get_global_pos()
	
		draw_line(prev_point, tgt, Color(0, 0, 0), parent.line_width * 1.5)
		draw_line(prev_point, tgt, parent.color, parent.line_width)
		
		draw_circle(prev_point, parent.line_width * 0.5, Color(0, 0, 0))
		draw_circle(prev_point, parent.line_width * 0.25, parent.color)
		
		prev_point = dest.get_global_pos() - get_global_pos()
