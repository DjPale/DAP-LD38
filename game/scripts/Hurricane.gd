extends Area2D

export var lifetime = 20.0
export var speed = 10.0
export var direction = Vector2(1,1)

var lifecounter = 0

var is_dead = false

func _ready():
	set_process(true)

func set_scaled_size(the_scale):
	get_node("Particles2D").set_scale(get_scale() * the_scale)
	#var shape = get_node("CollisionShape2D").get_shape()
	#shape.set_radius(shape.get_radius() * the_scale)

func _process(delta):
	if is_dead:
		lifecounter -= delta
		if lifecounter <= 0:
			queue_free()
			
		return

	lifecounter += delta
	
	if lifecounter >= lifetime:
		die()
		
	set_pos(get_pos() + (direction * speed * delta))

func _on_Hurricane_body_enter( body ):
	var p = body.get_parent()
	
	if p != null and p extends preload("Plane.gd"):
		p.report_failed_flight()
		
func die():
	is_dead = true
	lifecounter = 4
	get_node("Particles2D").set_emitting(false)
	
