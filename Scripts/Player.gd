extends CharacterBody3D


var current_speed = 5.0

@export var walking_speed = 12.0

const sprinting_speed = 13.0

const crouching_speed = 5.0 
@onready var world_environment = $"../env/WorldEnvironment"

const jump_velocity = 4.5

var lerp_speed = 8

var dash_velocity = 24.0

var crouch_anim_speed = 7

var fov_change_speed = 1

var crouching_depth = 0.5

var direction = Vector3.ZERO


@onready var environment = load("res://Scenes/environment.tres")
@onready var skymat1 = load("res://Scenes/skymaterial1.tres")
@onready var skymat2 = load("res://Scenes/skymaterial2.tres")
@onready var skymat3 = load("res://Scenes/skymaterial3.tres")
@onready var skymat4 = load("res://Scenes/skymaterial4.tres")
@onready var skymat5 = load("res://Scenes/skymaterial5.tres")
@onready var skymat6 = load("res://Scenes/skymaterial6.tres")

@onready var ray_cast_3d = $RayCast3D

var acceleration = 9.5
var decceleration = 7
@onready var rich_text_label = $"../GUI/DebugGUI/RichTextLabel"

var input_dir = Vector2(0,0)

var base_fov = 90

var dashtimer = 0.2
var dashtimersave

@onready var head = $Head
@onready var camera = $Head/Camera3D

const mouse_sens = 0.24
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 9.8


func _input(event):
	if(event is InputEventMouseMotion):
		rotate_y(deg_to_rad(-event.relative.x * mouse_sens))
		head.rotate_x(deg_to_rad(-event.relative.y * mouse_sens))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-60),deg_to_rad(60))

func _ready():
	dashtimersave = dashtimer
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func round_place(num,places):
	return (round(num*pow(10,places))/pow(10,places))

func _physics_process(delta):
	dashtimer -= delta
	rich_text_label.text = str("Debug Menu:\n", "Dash Delay: ", round_place(dashtimer, 3), "\n", "Input Dir: ",input_dir,"\n","Velocity: ",velocity )
	if(Input.is_action_just_pressed("quit")):
		Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	if(Input.is_action_just_pressed("dash")):
		if(dashtimer <=0):
			if(input_dir != Vector2(0,0)):
			
				velocity += direction * dash_velocity
				dashtimer = dashtimersave
			else:
				
				velocity += transform.basis *Vector3(0, 0, -1).normalized() * dash_velocity
				dashtimer = dashtimersave
		
	if(Input.is_action_just_pressed("crouch")):
		velocity.y -= jump_velocity
	if(Input.is_action_pressed("crouch")):
		current_speed = crouching_speed
		if(is_on_floor()):
			head.position.y = lerp(head.position.y, 0.6 - crouching_depth, delta * crouch_anim_speed)
		else:
			head.position.y = lerp(head.position.y, 0.6 - crouching_depth, delta * crouch_anim_speed * 2)
		
		$standing_collision_shape.disabled = true
		$crouching_collision_shape.disabled = false
	elif(!ray_cast_3d.is_colliding()):
		current_speed = walking_speed
		if(Input.is_action_pressed("sprint")):
			current_speed = sprinting_speed
		head.position.y = lerp(head.position.y, 0.6, delta * crouch_anim_speed)
		gravity = 9.8
		$standing_collision_shape.disabled = false
		$crouching_collision_shape.disabled = true
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("left", "right", "forward", "backward")
	direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed )

	if direction != Vector3.ZERO:
		if(input_dir == Vector2(0,0)):
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * decceleration )
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * decceleration )
		else:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * acceleration )
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * acceleration )
	else:
		
		velocity.x = lerp(velocity.x, direction.x * current_speed, delta * acceleration )
		velocity.z = lerp(velocity.z, direction.z * current_speed, delta * acceleration )

	move_and_slide()
