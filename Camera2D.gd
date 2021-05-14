extends Camera2D


signal zoom_changed(newsize)


func _input(event):
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			5:
				zoom = zoom * 2
				emit_signal("zoom_changed",zoom)
			4:
				zoom = zoom * 0.5
				emit_signal("zoom_changed",zoom)
