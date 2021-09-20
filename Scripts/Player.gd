extends KinematicBody2D

const ACCELERATION = 512
const MAX_SPEED = 60 
const FRICTION = 0.25 
const GRAVITY = 300
const JUMP_FORCE = 170
const AIR_RESISTACE = 0.02
const CLIMBING_JERK = 20

var motion = Vector2.ZERO
var state = IDLE
var double_jp = true
var dash_move = true


onready var sprite = $Sprite
onready var animationPlayer = $AnimationPlayer
onready var right_wall = get_node("RightRayCast")
onready var left_wall = get_node("LeftRayCast")


enum {
	IDLE,
	WALKING,
	IN_AIR,
	ON_WALL,
	IN_DASH
}

func _physics_process(delta):
	apply_gravity(delta)
	check_state()
	match state:
		IDLE:
			move(delta)
			dash()
			jump()
		WALKING:
			jump()
			dash()
		IN_AIR:
			move(delta)
			dash()
			double_jump()
			animationPlayer.play("Jump")
		ON_WALL:
			move(delta)
			wall_jump(delta)
			dash()
			wall_resistance()
			animationPlayer.play("wall_jump")
		IN_DASH:
			pass
			
	motion = move_and_slide(motion, Vector2.UP)
	
func move(delta):
	var x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	if x_input !=0  :
		animationPlayer.play("run")
		motion.x += x_input*ACCELERATION*delta
		if (x_input  > 0):
			motion.x = lerp(motion.x, MAX_SPEED, FRICTION)
		else:
			motion.x = lerp(motion.x, -MAX_SPEED, FRICTION)
		sprite.flip_h = x_input < 0
	# блокує інерція руху
	else:
		motion.x = 	lerp(motion.x, 0, FRICTION)
		animationPlayer.play("stand")


func jump():
	if Input.is_action_just_pressed("ui_up"):
		motion.y = -JUMP_FORCE
	if Input.is_action_just_released("ui_up") and motion.y < -JUMP_FORCE/2:
		motion.y = -JUMP_FORCE/2	


func wall_jump(delta):
	if left_wall.get_collider():
		sprite.flip_h = false
		if Input.is_action_just_pressed("ui_up"): 
			motion.x += 2*CLIMBING_JERK*ACCELERATION*delta
			motion.y -= CLIMBING_JERK*ACCELERATION*delta
	if right_wall.get_collider():
		sprite.flip_h = true
		if Input.is_action_just_pressed("ui_up"): 
			motion.x -= 2*CLIMBING_JERK*ACCELERATION*delta
			motion.y -= CLIMBING_JERK*ACCELERATION*delta


func double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jp:
		motion.y = -JUMP_FORCE
		double_jp = false


func dash():
	if Input.is_action_just_pressed("shift") and dash_move :
		dash_move = false
		if (sprite.flip_h):
			motion.x = -clamp(motion.x, MAX_SPEED*15, MAX_SPEED*30)
		else:
			motion.x = clamp(motion.x, MAX_SPEED*15, MAX_SPEED*30)


func check_state():
	if is_on_floor():
		state = IDLE
		double_jp = true
		dash_move = true
	elif right_wall.get_collider() or left_wall.get_collider():
		state = ON_WALL
		double_jp = true
		dash_move = true
	else:
		state = IN_AIR
	pass


func apply_gravity(delta):
	motion.y += GRAVITY * delta

func wall_resistance():
	motion.y = clamp(motion.y, -MAX_SPEED*3, MAX_SPEED)
