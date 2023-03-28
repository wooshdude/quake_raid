extends Area3D

signal shot(damage, object)

@rpc("any_peer")
func shot_at(damage, object):
	self.shot.emit(damage, object)
