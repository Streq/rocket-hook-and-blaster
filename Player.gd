extends RigidBody2D


export var fuel_power := 1000
export (PackedScene) var Bullet

var move_dir : Vector2
var aiming_at : Vector2
var wanna_shoot : bool = false
var wanna_jump : bool = false
var can_shoot : bool = true
var jump_force : float = 1500
onready var spawn_point = position

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
		aiming_at = (event.position - Vector2(get_viewport_rect().size) * 0.5).normalized()
#		print("pressed:" + str(event.pressed))
#		print("index:" + str(event.button_index))
#		print("factor:" + str(event.factor))
#		print("doubeclick:" + str(event.doubleclick))
#		print("position:" + str(event.position))
		match event.button_index:
			1:
				wanna_shoot = event.pressed 
			2:
				wanna_jump = event.pressed
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
	if wanna_shoot:
		wanna_shoot = false
		if can_shoot:
			shoot()
	
	# jump
	if wanna_jump:
		wanna_jump = false
		jump()
		
func jump():
	apply_central_impulse(-aiming_at * jump_force)
	$Explosion.visible = true
	$Explosion.rotation = (-aiming_at).angle()
	yield(get_tree().create_timer(0.1),"timeout")
	$Explosion.visible = false

func shoot():
	var b = Bullet.instance()
	b.parent = self
	owner.add_child(b)
	b.position = position
	b.rotation = aiming_at.angle()
	apply_central_impulse(-aiming_at * b.recoil)
	
	can_shoot = false
	$GunCooldown.start()

func die():
	sleeping = true
	yield(get_tree(), "idle_frame")
	sleeping = false
	position = spawn_point
	linear_velocity = Vector2.ZERO

func _on_GunCooldown_timeout():
	can_shoot = true


func _on_HitBox_body_entered(body):
	die()
