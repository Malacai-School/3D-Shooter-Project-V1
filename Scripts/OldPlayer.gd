extends CharacterBody3D


var SPEED = 5.0


const WALKSPEED = 5.0
const SPRINTSPEED = 9.0

const JUMP_VELOCITY = 4.5

const SENSITIVITY = 0.003

const BOB_FREQ = 2.0
const BOB_AMP = 0.1
var t_bob = 0.0

var BASE_FOV = 75
const FOV_CHANGE = 1.5 


@onready var head = $Head
@onready var camera = $Head/Camera3D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8

func _unhandled_input(event):
	if event is  InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))

func _ready():
	camera.fov = BASE_FOV
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINTSPEED * 2)
	var target_fov = BASE_FOV+ FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
	
	
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("sprint"):
		SPEED = SPRINTSPEED
	else:
		SPEED = WALKSPEED
		
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if(is_on_floor()):
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = lerp(velocity.x, direction.x * SPEED, delta * 3)
			velocity.z = lerp(velocity.z, direction.z * SPEED, delta * 3)


	move_and_slide()
func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
