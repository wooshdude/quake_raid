extends Node

@export var enemy: PackedScene
var enet_peer = ENetMultiplayerPeer.new()

func _ready():
	#multiplayer.peer_connected.connect(add_enemy)
	pass

# Get a random position within a radius around a 3D object
func get_random_position_around_object(object_pos: Vector3, radius: float) -> Vector3:
	var random_point = Vector3(randf(), 0, randf())
	random_point = random_point.normalized() * radius
	random_point += object_pos

	return random_point


func _on_timer_timeout():
	print("spawned new enemy")
	add_enemy.rpc(multiplayer.get_instance_id())


@rpc("any_peer", "call_local", "unreliable_ordered")
func add_enemy(peer_id):
	#if not is_multiplayer_authority(): return
	
	var new_enemy = enemy.instantiate()
	new_enemy.name = str(peer_id)
	new_enemy.global_position = get_random_position_around_object(self.global_position, 2)
	get_parent().add_child(new_enemy)
