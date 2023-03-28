extends Node3D

@onready var animator = $AnimationPlayer
@onready var meshinstance = $Model/MeshInstance3D
@onready var model = $Model
@onready var muzzle = $Model/Muzzle
@onready var flash = $Model/Muzzle/Sprite3D
@onready var ray = $Model/Muzzle/RayCast3D

@export var resource: Resource
var custom_trait

var can_shoot = true

signal shoot
signal aiming(value)


func _enter_tree():
	pass


func _ready():
	if not is_multiplayer_authority(): return
	animator.play('RESET')
	
	self.show()
	model.show()
	meshinstance.show()
	
	meshinstance.mesh = resource.model
	muzzle.position = resource.muzzle_pos
	#custom_trait = resource.get(resource.custom_trait)
	
	var custom_script = resource.custom_trait
	custom_trait = custom_script.new()
	
	flash.hide()


func _process(delta):
	if not is_multiplayer_authority(): return
	#print(can_shoot)
	
	model.rotation.x = lerp_angle(model.rotation.x, 0, 0.03)
	model.rotation.y = lerp_angle(model.rotation.y, 0, 0.1)
	
	
	if Input.is_action_pressed("aim"):
		print("hello world")
		model.position = lerp(model.position, Vector3(-0.36, 0.047, 0.115), 0.1)
		aiming.emit(true)
	else:	
		model.position = lerp(model.position, Vector3(0,0,0), 0.05)
		aiming.emit(false)
	
	if can_shoot == true and animator.is_playing() == false:
		if resource.full_auto == true:
			if Input.is_action_pressed("shoot"):
				if resource.ammo > 0:
					resource.ammo -= 1
					shoot_anim.rpc()
		elif resource.full_auto == false:
			if Input.is_action_just_pressed("shoot"):
				if resource.ammo > 0:
					resource.ammo -= 1
					shoot_anim.rpc()


@rpc("call_local")
func update():
	if not is_multiplayer_authority(): return
	
	meshinstance.mesh = resource.model
	muzzle.position = resource.muzzle_pos

	var custom_script = resource.custom_trait
	custom_trait = custom_script.new()


@rpc("call_local")
func shoot_anim():
	if not is_multiplayer_authority(): return
	#animator.stop()
	#animator.play('shoot')
	print(custom_trait)
	custom_trait.shoot(self)
	
	print(resource.damage)
	flash.show()
	shoot.emit()
	can_shoot = false
	$Model/Muzzle/Timer.start(0.08)
	print(float((resource.rpm/60)))
	var tween = create_tween()
	print(resource.recoil)
	model.rotation.x = lerp_angle(model.rotation.x, deg_to_rad(resource.recoil), 0.8)
	model.rotation.y = lerp_angle(model.rotation.y, deg_to_rad(randf_range(-0.3, 0.3)), 1)
	
	$SPR.start(float(1/(resource.rpm/60)))


func reload():
	#var tween = get_tree().create_tween()
	#tween.tween_property($Model, "rotation.x", deg_to_rad(360), 1)
	
	if resource.ammo <= resource.mag_size:
		resource.ammo = resource.mag_size


func _unhandled_input(event):
	if not is_multiplayer_authority(): return
	
	if Input.is_action_just_pressed("reload") and not resource.ammo >= resource.mag_size:
		animator.play('swirl_reload', -1, resource.reload)
		reload()


func _on_spr_timeout():
	can_shoot = true


func _on_timer_timeout():
	flash.hide()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "swirl_reload":
		model.rotation.x = 0
