extends Label


# Called when the node enters the scene tree for the first time.
func _ready():
	print(text)


func set_new_text(value):
	self.text = str(value)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
