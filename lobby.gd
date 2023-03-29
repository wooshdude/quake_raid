extends Node

@onready var main_menu = $Menu
@onready var menu_canvas = $Menu/CanvasLayer
@onready var host_button = $Menu/CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/HostButton
@onready var option_button = $Menu/CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/OptionButton
@onready var address_entry = $Menu/CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/AddressEntry
@onready var username_entry = $Menu/CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/UsernameEntry

@onready var world = $World
@onready var forest_scene = preload("res://church.tscn").instantiate()
@onready var boss_scene = preload("res://boss_arena_test.tscn").instantiate()
var maps = ["res://church.tscn", "res://boss_arena_test.tscn"]

@export var username: String

const player = preload("res://player.tscn")
const test_enemy = preload("res://test_enemy.tscn")

const PORT = 9999
var address = "localhost"
var enet_peer = ENetMultiplayerPeer.new()


var current_scene = null


func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if Input.is_action_just_pressed("shoot") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

# Called when the node enters the scene tree for the first time.
func _ready():
	maps = [forest_scene, boss_scene]
	
	option_button.add_item("Church")
	option_button.add_item("Arena")
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_button_pressed():
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())
	start_game()


func _on_join_button_pressed():
	#world.add_child(maps[option_button.selected])
	main_menu.hide()
	menu_canvas.hide()

	enet_peer.create_client(str(address), PORT)
	multiplayer.multiplayer_peer = enet_peer
	start_game()


func add_player(peer_id):
	var new_player = player.instantiate()
	new_player.name = str(peer_id)
	print(username)
	new_player.username = username
	add_child(new_player)


func start_game():
	menu_canvas.hide()
	main_menu.hide()
	match option_button.selected:
		0:
			change_level.call_deferred(load("res://church.tscn"))
		1:
			change_level.call_deferred(load("res://boss_arena_test.tscn"))


func change_level(scene: PackedScene):
	# Remove old level if any.
	for c in world.get_children():
		world.remove_child(c)
		c.queue_free()
	# Add new level.
	world.add_child(scene.instantiate())


func _on_username_entry_text_changed(new_text):
	username = new_text


func _on_address_entry_text_changed(new_text):
	address = new_text


func _on_option_button_item_selected(index):
	match index:
		0:
			current_scene = forest_scene
		1:
			current_scene = boss_scene


func _on_timer_timeout():
#	var new_enemy = load("res://test_enemy.tscn").instantiate()
#	new_enemy.name = str(multiplayer.get_unique_id())
#
#	add_child(new_enemy)
	pass
	


func _on_multiplayer_spawner_spawned(node):
	print("spawned ", node)
