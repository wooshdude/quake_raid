extends CharacterBody3D

@onready var username_text = get_node("UsernameHover/SubViewport/Label")
@onready var name_hover = $UsernameHover
@onready var subviewport = $UsernameHover/SubViewport
@onready var camera = $Head/Camera3D
@onready var ray = $Head/Camera3D/RayCast3D
@onready var ammo_count = $HUD/CanvasLayer/AmmoCount
@onready var weapon = $Head/Camera3D/Weapon
@onready var head = $Head

@export var speed: float
@export var jump: float
@export var sensitivity: float
@export var inventory: Resource

var currently_equiped = 0

var aim_sens = sensitivity * 0.2
var username: set = _set_username, get = _get_username

enum {
	WALK,
	CROUCH,
	SPRINT
}
var STATE = WALK

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2


func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _set_username(name):
	get_node("UsernameHover/SubViewport/Label").text = str(name)


func _get_username():
	return username


func _ready():
	if not is_multiplayer_authority(): return
	
	weapon.update.rpc()
	
	for item in inventory.equipable:
		item.ammo = item.mag_size
	
	get_node("HUD/CanvasLayer/AmmoCount").visible = true
	
	name_hover.texture = subviewport.get_texture()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (sensitivity * 0.001))
		head.rotate_x(-event.relative.y * (sensitivity * 0.001))
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		
	if Input.is_action_just_pressed("scroll_up"):
		if currently_equiped != 0:
			currently_equiped -= 1
		else:
			currently_equiped = len(inventory.equipable)-1
		weapon.sound.stream = weapon.resource.sound
			
		weapon.animator.stop()
			
	if Input.is_action_just_pressed("scroll_down"):
		if currently_equiped != len(inventory.equipable)-1:
			currently_equiped += 1
		else:
			currently_equiped = 0
			
		weapon.sound.stream = weapon.resource.sound

		weapon.animator.stop()
		
	if Input.is_action_just_pressed("shift") and Input.is_action_pressed("up"):
		if STATE != SPRINT:
			STATE = SPRINT
		else:
			STATE = WALK
	
	if not Input.is_action_pressed("up"):
		STATE = WALK


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	#print(inventory.equipable[0])
	if ray.is_colliding():
		weapon.ray.look_at(ray.get_collision_point())
	else:
		pass
	
	weapon.resource = inventory.equipable[currently_equiped]
	weapon.update.rpc()
	
	camera.fov = lerp_angle(camera.fov, 75, 1)
	
	get_node("HUD/CanvasLayer/AmmoCount").text = str(weapon.resource.ammo)
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump

	match STATE:
		WALK:
			walk(delta)
		CROUCH:
			pass
		SPRINT:
			sprint(delta)
	

	move_and_slide()

func walk(delta):
	movement(delta, speed)


func sprint(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x/2, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * (speed + (speed/2)), speed/2)
		velocity.z = move_toward(velocity.z, direction.z * (speed + (speed/2)), speed/2)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


func movement(delta, new_speed):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * new_speed, speed/2)
		velocity.z = move_toward(velocity.z, direction.z * new_speed, speed/2)
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)


@rpc("call_local")
func _on_eyasluna_shoot():
	camera.fov = 76


func _on_weapon_aiming(value):
	pass
