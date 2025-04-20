extends CharacterBody3D

#Player node refes
@onready var head: Node3D = $stand_collider/Head
@onready var camera_3d: Camera3D = $stand_collider/Head/Camera3D
@onready var stand_collider: CollisionShape3D = $stand_collider
@onready var ray_cast_3d: RayCast3D = $stand_collider/crouch_check
@onready var coyote_timer: Timer = $coyote_timer
@onready var edge_friction_check: RayCast3D = $edge_friction_check
@onready var lean_check: ShapeCast3D = $stand_collider/lean_check
@onready var fullscreen_message: Label = $UI_Crosshair/fullscreen_message

#World constants for override
const NEW_GRAVITY = Vector3(0, -20, 0)

#Movement variables
var current_speed = 5.0: set = _set_current_speed, get = _get_current_speed
var input_dir = Vector3.ZERO
var direction = Vector3.ZERO
var disable_movement: bool = true

#Player movement variables
@export var WALK_SPEED = 6.0
@export var RUN_SPEED = 9.0
@export var CROUCH_SPEED = 2.0
const PLAYER_DEFAULT_HEIGHT = Vector3(0.0,1.8,0.0)
var friction_mod = 1.0: set = _set_friction_mod
const FRICTION_GOAL = 0.8


var crouch_depth = 0.8
var crouch_jump_add = crouch_depth * 0.1
const CROUCH_CAM_SPEED = 8.0
var default_crouch_collider_height
var default_head_height

@export var JUMP_VELOCITY = 6

const HEAD_LEAN_OFFSET = 1.5
const HEAD_LEAN_ANGLE = 7.5
const HEAD_LEAN_SPEED = 8

#Player state flags
var is_crouching: bool = false
var is_sprinting: bool = false
var is_jumping: bool = false
var js: bool = false
var lean_left: bool = false
var lean_right: bool = false

#Camera variables
const DEFAULT_FOV = 90.0
const SPRINT_FOV = 110.0
const FOV_LERP_SPEED = 5.0

#Input variables
const MOUSE_SENS = 0.3
const MAX_LOOK_X = 85
const MIN_LOOK_X = -85

const MOVE_DRAG_SPEED = 15

var hide_mouse: bool = false
var momentum = Vector3.ZERO

#stepping sound
@export var step_interval_sec = 0.15
@export var speed_threshold = 0.75
@onready var footsteps: AudioStreamPlayer3D = $footsteps
var _step_timer = 0.0
@export var step_sounds: Array[AudioStream]


func _ready() -> void:
	_step_timer = step_interval_sec
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) # Hide mouse
	camera_3d.fov = DEFAULT_FOV
	default_head_height = head.position.y
	ray_cast_3d.target_position.y = crouch_depth + 0.2

func _unhandled_input(event: InputEvent) -> void:
	#toggle_mouse()
	
	#Handles looking with mouse
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(MIN_LOOK_X), deg_to_rad(MAX_LOOK_X))
		head.rotation.y = 0 # clamp rotation of head to 0 otherwise overreach causes control inversion during lean

func _physics_process(delta: float) -> void:
	if !is_sprinting:
		step_interval_sec = 0.5
	else:
		step_interval_sec = 0.3
	if is_on_floor() and velocity.length() > speed_threshold:
		_step_timer -= delta
		if _step_timer <= 0:
			play_footstep()
			_step_timer = step_interval_sec
	else:
		_step_timer = step_interval_sec
	#Movement related functions
	handle_gravity(delta)
	handle_move(delta)
	#handle_jump()
	#handle_crouch(delta)
	handle_sprint(delta)
	#head_roll(input_dir, delta)
	#handle_lean(delta)
	edge_friction(delta)
	var was_on_floor = is_on_floor()
	move_and_slide()
	coyote_time(was_on_floor) #MUST COME AFTER MOVE

## Movement Functions

# Add the gravity.
func handle_gravity(delta):
	if not is_on_floor():
		velocity += NEW_GRAVITY * delta
	# Get the input direction and handle the movement/deceleration.
func handle_move(delta):
	if disable_movement:
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		#direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized() #Without move drag/dampening.
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * MOVE_DRAG_SPEED) # includes move drag/dampening. Use if no edge friciton
	else:
		input_dir = Vector3.ZERO
		direction = lerp(direction,(transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta * MOVE_DRAG_SPEED)
	if direction:
		velocity.x = direction.x * _get_current_speed()
		velocity.z = direction.z * _get_current_speed()

	else:
		velocity.x = move_toward(velocity.x, 0,_get_current_speed())
		velocity.z = move_toward(velocity.z, 0, _get_current_speed())
		
@onready var _original_capsule_height = $stand_collider.shape.height

# Handle crouch. Player speed is reduced. Source-like crouch jumping behaviour from https://www.youtube.com/@MajikayoGames
func handle_crouch(delta):
	var was_crouched_last_frame = is_crouching
	var _crouch_cam_speed = CROUCH_CAM_SPEED
	if disable_movement:
		if Input.is_action_pressed("crouch"):
			is_crouching = true
			if is_on_floor(): #Waits to adjust the player's speed until they hit the floor. NB: try to fix FOV adjust to coincide with
				is_sprinting = false
				_set_current_speed(CROUCH_SPEED)
		elif is_crouching and not self.test_move(self.global_transform, Vector3(0, crouch_depth, 0)): #checks if the player has enough room to uncrouch
			is_crouching = false
			_set_current_speed(WALK_SPEED)
			_crouch_cam_speed*=2.5
	
	var translate_y_if_possible := 0.0
	if was_crouched_last_frame != is_crouching and not is_on_floor(): # check if the player was on the floor when the started the crouch
		translate_y_if_possible = crouch_jump_add if is_crouching else -crouch_jump_add #small value added or removed from the height depending on above.
	if translate_y_if_possible != 0.0:
		var result = KinematicCollision3D.new() #estimates the jump and any collisions that might occur before adding a bit of extra height
		self.test_move(self.global_transform, Vector3(0,translate_y_if_possible,0),result)
		self.position.y+= result.get_travel().y #adds the additional y to the jump. makes jump a little floatier
		
	head.position = lerp(head.position, Vector3(0, (0.8 - crouch_depth if is_crouching else 0.8),0), _crouch_cam_speed * delta)
	stand_collider.shape.height = lerp(stand_collider.shape.height, (_original_capsule_height - crouch_depth if is_crouching else _original_capsule_height), _crouch_cam_speed * delta)
	stand_collider.position.y = lerp(stand_collider.position.y, (stand_collider.shape.height / 2), _crouch_cam_speed * delta)

# Sprint changes player FOV and move speed. Only works if player is moving forwards. Thanks to @Polydachi for cleaning this up and fixing various functions
func handle_sprint(delta):
	if is_sprinting:
		_set_current_speed(RUN_SPEED)
		camera_3d.fov = lerp(camera_3d.fov, SPRINT_FOV,FOV_LERP_SPEED*delta)
	elif !is_crouching:
		_set_current_speed (WALK_SPEED * friction_mod)
		if !is_sprinting:
			camera_3d.fov = lerp(camera_3d.fov, DEFAULT_FOV, (FOV_LERP_SPEED * 3) *delta)
	if Input.is_action_pressed("sprint") and !is_crouching and is_on_floor():
		if Input.is_action_pressed("forward"): 
			is_sprinting = true
# we only start sprinting if the player is on the ground, not crouching, and holding forward

	if (is_on_floor() and !Input.is_action_pressed("sprint")) or is_crouching:
		is_sprinting = false
# basically, this wont activate until the player is on the ground and not pressing sprint, so if they're in the air it wont stop them sprinting
			
#Handle jump. Coyote timer added for additional jump leeway
func handle_jump():
	if disable_movement:
		if Input.is_action_just_pressed("jump") and (is_on_floor() or !coyote_timer.is_stopped()):
			velocity.y = JUMP_VELOCITY

#Edge friction slows the player down a little bit as they approach the edge of geometry. Only functions from the player's relative forward.
#Disabled when the player is crouching or sprinting
func edge_friction(delta):
	if !edge_friction_check.is_colliding() and !is_crouching and !is_sprinting and is_on_floor():
		_set_friction_mod(lerp(friction_mod, FRICTION_GOAL, 3 * delta))
	else:
		_set_friction_mod(lerp(friction_mod, 1.0, 10 * delta))

#Gives players a small window of leeway to jump after they have left the ground
func coyote_time(was_on_floor):
	if was_on_floor and !is_on_floor() and not Input.is_action_pressed("jump"): #starts timer the frame the player leaves the floor
		coyote_timer.start()
	return coyote_timer.is_stopped()

#Tilts camera sideways when player is strafing
func head_roll(dir, delta):
	if dir:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, -deg_to_rad(dir.x * 1.3), 8 * delta)
		camera_3d.rotation.z = clamp(camera_3d.rotation.z, deg_to_rad(-10), deg_to_rad(10))
	else:
		camera_3d.rotation.z = lerp(camera_3d.rotation.z, 0.0, 12 * delta)

#Manually rolls the camera L/R, shifting the head slightly for players to peek around corners.
func handle_lean(delta):
	var _head_lean_offset
	var _head_lean_angle
	var _lean_check_dist
	if is_crouching:
		_head_lean_offset = HEAD_LEAN_OFFSET /2
		_head_lean_angle = HEAD_LEAN_ANGLE / 2
		lean_check.scale.y = 0.6
	else:
		_head_lean_offset = HEAD_LEAN_OFFSET
		_head_lean_angle = HEAD_LEAN_ANGLE
		lean_check.scale.y = 1
	if Input.is_action_pressed("lean_left") and !lean_right and !is_sprinting:
		lean_left = true
	else:
		lean_left = false
	if Input.is_action_pressed("lean_right") and !lean_left and !is_sprinting:
		lean_right = true
	else:
		lean_right = false
		
	if lean_left:
		lean_check.target_position.x = -1.3
		if !lean_check.is_colliding():
			head.position.x = move_toward(head.position.x, -_head_lean_offset, HEAD_LEAN_SPEED * delta)
			head.rotation.z = lerp(head.rotation.z, deg_to_rad(_head_lean_angle), HEAD_LEAN_SPEED * delta)
	elif lean_right:
		lean_check.target_position.x = 1.3
		if !lean_check.is_colliding():
			head.position.x = move_toward(head.position.x, _head_lean_offset, HEAD_LEAN_SPEED * delta)
			head.rotation.z = lerp(head.rotation.z, deg_to_rad(-_head_lean_angle), HEAD_LEAN_SPEED * delta)
	else:
		head.position.x = lerp(head.position.x, 0.0, HEAD_LEAN_SPEED * delta)
		head.rotation.z = lerp(head.rotation.z, 0.0, HEAD_LEAN_SPEED * delta)

# Button to toggle if the mouse is visible or not
func toggle_mouse(): 
	if Input.is_action_just_pressed("toggle_mouse_visible"):
		if !hide_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			hide_mouse = true
			
		elif hide_mouse:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			hide_mouse = false

## Getters and Setters
#External function to adjust/call player speed from multiple fucntions. Adds edge friction modifier.
func _set_current_speed(speed):
	current_speed = speed * friction_mod
func _get_current_speed():
	return current_speed
	
#Function needed as edge friciton speed lerps smoothly.
func _set_friction_mod(fric):
	friction_mod = fric

func play_footstep():
	var last_sound
	var play_random_sound = randf_range(0, step_sounds.size())
	if last_sound == play_random_sound:
		play_random_sound = randf_range(0, step_sounds.size())
	last_sound = play_random_sound
	footsteps.stream = step_sounds[play_random_sound]
	footsteps.pitch_scale = randf_range(0.9, 1.1)
	footsteps.play()
func toggle_final_message():
	fullscreen_message.visible = !fullscreen_message.visible
