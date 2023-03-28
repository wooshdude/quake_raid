extends Resource
class_name WeaponStats

@export var damage: int = 0
@export var mag_size: int = 0
@export var rpm: float = 0
@export var full_auto: bool = false
@export var recoil: int = 0
@export var reload: float = 1
@export var model: Mesh
@export var muzzle_pos: Vector3
@export var icon: Texture

@export var custom_trait: Script

var ammo = mag_size
