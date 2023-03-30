extends CharacterBody3D

@onready var HUDsprite = $HUD/Sprite3D
@onready var subviewport = $HUD/Sprite3D/SubViewport

@onready var health_bar = $HUD/Sprite3D/SubViewport/ProgressBar

@onready var navagent = $NavigationAgent3D

@onready var sight = $Sight

@onready var crit_box = $Critical_Hitbox
@onready var body_box = $Body_Hitbox

@export var health = 15: set = _set_health
@export var speed = 3
@export var view_distance = 10

var enet_peer = ENetMultiplayerPeer.new()

var looking_at = []

func update_target_location(target_location):
	navagent.set_target_position(target_location)


@rpc("any_peer", "reliable")
func damage(value):
	#if not is_multiplayer_authority(): return
	
	print('hit')
	var new_health = health - value
	_set_health(new_health)
	_set_health.rpc(new_health)
	print(health)
	
	if health <= 0:
		queue_free()


@rpc("any_peer", "reliable")
func _set_health(value):
	#if not is_multiplayer_authority(): return
	health = value
	get_node("HUD/Sprite3D/SubViewport/ProgressBar").value = health


func _ready():
	#if not is_multiplayer_authority(): return
	multiplayer.multiplayer_peer = enet_peer
	
	health_bar.max_value = health
	
	HUDsprite.texture = subviewport.get_texture()
	
	crit_box.connect("shot", _on_critical_hitbox_shot)
	body_box.connect("shot", _on_body_hitbox_shot)
	sight.connect("area_entered", _on_sight_area_entered)
	sight.connect("area_exited", _on_sight_area_exited)


func _physics_process(delta):
	#if not is_multiplayer_authority(): return
	
	$SyncNode.health = health
	$SyncNode.pos = global_position
	$SyncNode.rot = rotation
	
	if !looking_at.is_empty():
		navagent.target_position = looking_at[0].global_position
		look_at(looking_at[0].global_position)
	
	move.rpc(delta)

@rpc("any_peer")
func move(delta):
	#if not is_multiplayer_authority(): return
	
	if !looking_at.is_empty():
		navagent.target_position = looking_at[0].global_position
		look_at(looking_at[0].global_position)
		
	var current_location = global_transform.origin
	var next_location = navagent.get_next_path_position()
	
	var new_velocity = (next_location - current_location).normalized() * speed
	velocity = new_velocity
	
	move_and_slide()


@rpc("any_peer")
func look(object):
	if object.get_parent() not in looking_at:
		looking_at.append(object.get_parent())

@rpc("any_peer", "call_local")
func _on_critical_hitbox_shot(value, object):
	#if not is_multiplayer_authority(): return
	
	print('hit by ', object.get_parent().get_parent())
	#print("hit for %s damage" % value)
	damage(value * 2)
	damage.rpc(value * 2)
	
	#print(object._get_username())
	look.rpc_id(object.get_parent().get_parent().get_parent().multiplayer.get_unique_id(), object)


@rpc("any_peer", "call_remote")
func _on_body_hitbox_shot(value, object):
	#if not is_multiplayer_authority(): return
	
	print('hit by ', object.get_parent())
	#print("hit for %s damage" % value)
	damage(value)
	damage.rpc(value)

	look.rpc_id(object.get_parent().get_parent().get_parent().multiplayer.get_unique_id(), object)


func _on_sight_area_entered(area):
	#if not is_multiplayer_authority(): return
	
	#print(area)
	if area.get_parent() not in looking_at:
		looking_at.append(area.get_parent())


func _on_navigation_agent_3d_target_reached():
	pass # Replace with function body.


func _on_sight_area_exited(area):
	#if not is_multiplayer_authority(): return
	
	looking_at.erase(area)


@rpc("any_peer")
func get_random_radius(object_pos: Vector3, radius: float) -> Vector3:
	# Generate a random point within a cube
	var random_point = Vector3(randf(), 0, randf())

	# Normalize the point to ensure it's within the radius
	random_point = random_point.normalized() * radius

	# Translate the point to the object's position
	random_point += object_pos

	return random_point


func _on_timer_timeout():
	var rand = randi_range(1, 5)
	if rand == 1:
		navagent.target_position = get_random_radius(self.position, 5)
	elif rand == 2:
		look_at(get_random_radius(self.position, 5))
	
