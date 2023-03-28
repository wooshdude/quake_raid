extends Node

@onready var main_menu = $CanvasLayer/PanelContainer
@onready var address_entry = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/AddressEntry
@onready var username_entry = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/UsernameEntry

var username: set = _set_username

const player = preload("res://player.tscn")
const test_enemy = preload("res://test_enemy.tscn")

const PORT = 9999
var address: set = _set_address, get = _get_address
var enet_peer = ENetMultiplayerPeer.new()


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _set_username(name):
	username = name


func _set_address(value):
	address = value


func _get_address():
	return address


func _on_host_button_pressed():
	main_menu.hide()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())


func _on_join_button_pressed():
	main_menu.hide()

	enet_peer.create_client(str("localhost"), PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var player = player.instantiate()
	player.name = str(peer_id)
	print(username)
	player._set_username(username)
	add_child(player)

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
	var enemy = test_enemy.instantiate()
	#enemy.name = str(multiplayer.get_unique_id())
	$Spawner.add_child(enemy)
	enemy.global_position = get_random_position_around_object($Spawner.global_position, 4)
	enemy.rotate_y(randi_range(0,360))


func _on_username_entry_text_changed(new_text):
	_set_username(new_text)


func _on_address_entry_text_changed(new_text):
	_set_address(new_text)
