extends CharacterBody3D

@onready var username_text = get_node("UsernameHover/SubViewport/Label")
@onready var name_hover = $UsernameHover
@onready var subviewport = $UsernameHover/SubViewport
@onready var camera = $Camera3D
@onready var ray = $Camera3D/RayCast3D
@onready var weapon = $Camera3D/Eyasluna
@onready var ammo_count = $HUD/CanvasLayer/AmmoCount

@export var speed: float
@export var jump: float
@export var sensitivity: float

var username: set = _set_username, get = _get_username


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
	
	get_node("HUD/CanvasLayer/AmmoCount").visible = true
	
	#print($Sprite3D/SubViewport/Label2.text)
	
	#print(self)
	#print(name_hover)
	#print(subviewport)
	#print(username_text)
	
	name_hover.texture = subviewport.get_texture()
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	camera.current = true


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * (sensitivity * 0.001))
		camera.rotate_x(-event.relative.y * (sensitivity * 0.001))
		camera.rotation.x = clamp(camera.rotation.x, -PI/2, PI/2)


func _physics_process(delta):
	if not is_multiplayer_authority(): return
	# Add the gravity.
	
	get_node("HUD/CanvasLayer/AmmoCount").text = str(weapon.ammo)
	
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)

	move_and_slide()


@rpc("call_local")
func _on_eyasluna_shoot():
	if not is_multiplayer_authority(): return
	
	if ray.is_colliding():
		var hit_area = ray.get_collider()
		print(hit_area)
		var hit_obj = hit_area.get_parent()
		#hit_obj.rpc_id(hit_area.get_multiplayer_authority(), "damage", 5)
		hit_area.shot.emit(5, self)
		var hit_point = ray.get_collision_point()
		#print(hit_point)
		
	else:
		pass

