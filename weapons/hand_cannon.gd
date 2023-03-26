extends Node3D

@onready var animator = $AnimationPlayer

@export var damage: float

signal shoot

func _enter_tree():
	pass

func _ready():
	if not is_multiplayer_authority(): return
	animator.play('RESET')


@rpc("call_local")
func shoot_anim():
	animator.stop()
	animator.play('shoot')
	shoot.emit()


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("reload") and animator.is_playing() == false:
		animator.play('reload')
		
	if Input.is_action_just_pressed("shoot") and animator.is_playing() == false:
		shoot_anim.rpc()
