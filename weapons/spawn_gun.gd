extends GDScript

func shoot(weapon):
	if weapon.ray.is_colliding():
		var hit_area = weapon.ray.get_collider()
		print(hit_area)
		var hit_obj = hit_area.get_parent()
		#hit_obj.rpc_id(hit_area.get_multiplayer_authority(), "damage", 5)
		hit_area.shot_at(weapon.resource.damage, weapon)
		#hit_area.shot_at.rpc(5, self)
		var hit_point = weapon.ray.get_collision_point()
		print(hit_point)
	else:
		weapon.ray.rotation = Vector3(0,0,0)
	
	var new_enemy = load("res://test_enemy.tscn").instantiate()
	weapon.get_parent().get_parent().get_parent().get_parent().add_child(new_enemy)
