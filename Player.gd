extends RigidBody2D


export var fuel_power := 1000
export (PackedScene) var Bullet

var move_dir : Vector2
var aiming_at : Vector2
var wanna_shoot : bool = false
var can_shoot : bool = true

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _process(delta):
	if move_dir.is_equal_approx(Vector2.ZERO):
		$Fire.hide()
	else:
		$Fire.rotation = move_dir.angle()
		$Fire.show()

func _input(event):
	if event is InputEventMouseButton:
#		print("pressed:" + str(event.pressed))
#		print("index:" + str(event.button_index))
#		print("factor:" + str(event.factor))
#		print("doubeclick:" + str(event.doubleclick))
#		print("position:" + str(event.position))
		aiming_at = (event.position - Vector2(get_viewport_rect().size) * 0.5).normalized()
#		print(aiming_at)
		wanna_shoot = event.pressed
	elif event is InputEventMouseMotion:
		aiming_at = (event.position - Vector2(get_viewport_rect().size) * 0.5).normalized()
		

func _physics_process(delta):
	# move goddamnit
	move_dir = Vector2(
			float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left")),
			float(Input.is_action_pressed("ui_down")) - float(Input.is_action_pressed("ui_up"))
		).normalized()
	apply_central_impulse(move_dir * fuel_power * delta)
	
	# shoot
	if wanna_shoot and can_shoot:
		shoot()

func shoot():
	var b = Bullet.instance()
	owner.add_child(b)
	b.position = position
	b.rotation = aiming_at.angle()
	apply_central_impulse(-aiming_at * b.recoil)
	
	wanna_shoot = false
	can_shoot = false
	$GunCooldown.start()


func _on_GunCooldown_timeout():
	can_shoot = true
