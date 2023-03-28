extends RigidBody3D

var speed = 50
var damage

# Called when the node enters the scene tree for the first time.
func _ready():
	apply_impulse(-transform.basis.z * speed, Vector3(0,0,1))
	


func explode():
	$Timer.start()
	$MeshInstance3D.hide()
	$GPUParticles3D.restart()
	$BlastRadius.monitoring = true

func _on_area_3d_area_entered(area):
	explode()


func _on_area_3d_body_entered(body):
	explode()


func _on_blast_radius_area_entered(area):
	area.shot_at(damage, self)


func _on_timer_timeout():
	self.queue_free()
