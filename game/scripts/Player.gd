extends KinematicBody2D

onready var VFX_Manager = get_node("/root/VFX_Manager")
onready var SFX_Manager = get_node("/root/SFX_Manager")

export var gravity = Vector2(0, 200.0)
export(float,0,1000,10) var walk_speed = 200.0

export(float,1.0,400.0,1.0) var jump_max_height = 20.0
export(float,1.0,120,1.0) var jump_max_length = 64.0
export(float,0.01,1.0,0.05) var jump_time_to_height = 0.2
export(float,0,5.0,0.05) var jump_pause = 0.1
export(float,0,1,0.05) var jump_grace = 0.1

export var input_enable = true
export var invincible = false

var move_speed_y = 0.0
var jump_timer = 0.0
var jump_move_x_scale = 0.0
var jump_grace_counter = 0

var velocity = Vector2()
var was_airborne = true
var on_ground = false
var face_sign = 1

var raycast_left
var raycast_right

func _ready():
	raycast_left = get_node("RayLeft")
	raycast_left.add_exception(self)

	raycast_right = get_node("RayRight")
	raycast_right.add_exception(self)
	
	_set_jump_equation(jump_max_height, jump_max_length, jump_time_to_height)	
	
	set_fixed_process(true)

func _fixed_process(delta):
	_do_timers(delta)
	
	_check_state()
		
	velocity.x = 0
	if on_ground: 
		velocity.y = 0
	else:
		velocity.y += delta * gravity.y

	if (input_enable && Input.is_action_pressed("ui_left")):
		velocity.x = -walk_speed
		face_sign = -1
	elif (input_enable && Input.is_action_pressed("ui_right")):
		velocity.x = walk_speed
		face_sign = 1

	if not on_ground:
		velocity.x *= jump_move_x_scale
		
	if input_enable && Input.is_action_pressed("ui_accept"):
		_jump()

	if on_ground:
		var vel_add = false
		
		if raycast_left.is_colliding(): 
			var obj = raycast_left.get_collider()
			_deadly_collision_check(obj)
			if obj != null && "velocity" in obj: 
				velocity.x += obj.velocity.x
				vel_add = true
			
		if raycast_right.is_colliding(): 
			var obj = raycast_left.get_collider()
			_deadly_collision_check(obj)
			if not vel_add && obj != null && "velocity" in obj: 
				velocity.x += obj.velocity.x

	var motion = velocity * delta
	motion = move(motion)

	if (is_colliding()):
		var n = get_collision_normal()
		var obj = get_collider()
		_deadly_collision_check(obj)
			
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)

		# ceiling?
		#if n.y == 1: _crack_tile()
		
	_update_anim()
	
func _do_timers(delta):
	if jump_timer > 0:
		jump_timer -= delta
		if jump_timer < 0: jump_timer = 0
		
	if jump_grace_counter > 0:
		jump_grace_counter -= delta
		if jump_grace_counter < 0: jump_grace_counter = 0

func _check_state():
	on_ground = _is_on_ground()
	
	if on_ground:
		jump_grace_counter = jump_grace
		
		if was_airborne: 
			jump_timer = jump_pause
		
	was_airborne = !on_ground

func _is_on_ground():
	return raycast_left.is_colliding() || raycast_right.is_colliding()

func _jump():
	if (jump_timer > 0 || (not on_ground and jump_grace_counter <= 0)) : return
	
	SFX_Manager.play("Jump")
	
	if was_airborne: velocity.y = 0

	jump_timer = jump_pause
	
	velocity.y -= move_speed_y
	
func _deadly_collision_check(obj):
	pass
	
func _update_anim():
	pass
	
func hit(obj):
	if invincible: return
	
	reset_level()

func _set_jump_equation(max_height, max_length, time_to_height):
	gravity.y = (2.0 * max_height) / (time_to_height * time_to_height)
	
	move_speed_y = sqrt(2 * gravity.y * max_height)
	jump_move_x_scale = (max_length / time_to_height) / walk_speed
	
	prints("jumpeq", gravity, move_speed_y, jump_move_x_scale)