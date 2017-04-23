extends Sprite

signal clicked(pressed, global_pos, offset)

var s_size = Vector2()

func _ready():
	s_size = get_texture().get_size()
	set_process_input(true)
	
func _input(ev):
	if ev.type == InputEvent.MOUSE_BUTTON and ev.button_index == BUTTON_LEFT:
		var ev_pos = ev.global_pos
		var s_pos = get_global_pos()
		var a_size = s_size * get_scale()

		var rect = Rect2(s_pos.x - a_size.x / 2, s_pos.y - a_size.y / 2, a_size.x, a_size.y)
		if rect.has_point(ev_pos):
			emit_signal("clicked", ev.is_pressed(), ev_pos, s_pos - ev_pos)