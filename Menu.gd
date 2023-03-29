extends Node3D

@onready var planet = $Planet


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	planet.rotate_y(0.1 * delta)
