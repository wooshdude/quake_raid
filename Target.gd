extends Node3D

@onready var particle_material = preload("res://text_particle_process.tres")
@onready var particle_pass = preload("res://text_particle_material.tres")


func _on_area_3d_shot(damage, object):
	var new_particle = GPUParticles3D.new()
	new_particle.draw_pass_1 = particle_pass
	new_particle.process_material = particle_material
	new_particle.local_coords = true
	new_particle.lifetime = 1
	new_particle.one_shot = true
	new_particle.amount = 1
	new_particle.emitting = true
	new_particle.draw_pass_1.text = str(damage)
	
	add_child(new_particle)
	new_particle.restart()
	print(new_particle.get_parent())
	print(new_particle.global_position)
	print(new_particle.emitting)

func _on_timer_timeout():
	print("stopping timer")
	$GPUParticles3D.emitting = false
