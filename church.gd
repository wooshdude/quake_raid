extends Node

const test_enemy = preload("res://test_enemy.tscn")
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	multiplayer.peer_connected.connect(add_enemy)

# Get a random position within a radius around a 3D object
func get_random_position_around_object(object_pos: Vector3, radius: float) -> Vector3:
	# Generate a random point within a cube
	var random_point = Vector3(randf(), 0, randf())

	# Normalize the point to ensure it's within the radius
	random_point = random_point.normalized() * radius

	# Translate the point to the object's position
	random_point += object_pos

	return random_point


func _on_timer_timeout():
	print("spawned new enemy")
	
	add_enemy(multiplayer.get_instance_id())


func add_enemy(peer_id):
	if not is_multiplayer_authority(): return
	
	var new_test_enemy = test_enemy.instantiate()
	new_test_enemy.name = str(peer_id)
	new_test_enemy.global_position = get_random_position_around_object($Spawner.global_position, 2)
	add_child(new_test_enemy)
