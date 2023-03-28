extends Area3D

signal shot(damage, object)


func shot_at(damage, object):
	print("hit by ", object, " for ", damage)
	self.shot.emit(damage, object)
