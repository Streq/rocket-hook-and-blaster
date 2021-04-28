extends RigidBody2D


export var fuel_power := 1000
var move_dir : Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if move_dir.is_equal_approx(Vector2.ZERO):
		$Fire.hide()
	else:
		$Fire.rotation = move_dir.angle()
		$Fire.show()

func _physics_process(delta):
	move_dir = Vector2(
			float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left")),
			float(Input.is_action_pressed("ui_down")) - float(Input.is_action_pressed("ui_up"))
		).normalized()
	apply_central_impulse(move_dir * fuel_power * delta)
	
