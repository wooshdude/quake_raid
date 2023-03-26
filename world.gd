extends Node

@onready var main_menu = $CanvasLayer/PanelContainer
@onready var address_entry = $CanvasLayer/PanelContainer/MarginContainer/VBoxContainer/AddressEntry

const player = preload("res://player.tscn")

const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_host_button_pressed():
	main_menu.hide()

	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(add_player)
	
	add_player(multiplayer.get_unique_id())


func _on_join_button_pressed():
	main_menu.hide()

	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer


func add_player(peer_id):
	var player = player.instantiate()
	player.name = str(peer_id)
	add_child(player)
