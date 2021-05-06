extends Camera2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			5:
				zoom = zoom * 2
			4:
				zoom = zoom * 0.5
