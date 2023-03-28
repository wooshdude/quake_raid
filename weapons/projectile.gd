extends GDScript


func shoot(weapon):
	if weapon.ray.is_colliding():
		var hit_point = weapon.ray.get_collision_point()
		
		var new_rocket = load("res://weapons/rocket.tscn").instantiate()
		new_rocket.look_at(hit_point)
		new_rocket.damage = weapon.resource.damage
		weapon.muzzle.add_child(new_rocket)
	else:
		var new_rocket = load("res://weapons/rocket.tscn").instantiate()
		new_rocket.damage = weapon.resource.damage
		new_rocket.look_at(weapon.ray.target_position)
		weapon.muzzle.add_child(new_rocket)
		pass
