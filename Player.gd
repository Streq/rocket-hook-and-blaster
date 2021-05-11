extends RigidBody2D


export var fuel_power := 10000

var Bullet : PackedScene = preload("res://Bullet.tscn")
var Explosion : PackedScene = preload("res://FuelExplosion.tscn")


var move_dir : Vector2
var aiming_at : Vector2
var wanna_shoot : bool = false
var wanna_jump : bool = false
var can_shoot : bool = true
var jump_force : float = 5000
var spawn_pos: Vector2
#used to calculate collisions
var vel : Vector2

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
	if is_network_master():
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
	if is_network_master():
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
		rpc_unreliable("update_pos_and_vel", position, linear_velocity)

func jump():
	var rotation = (-aiming_at).angle()
	rpc("instance_explosion", position, rotation)
	var e = Explosion.instance()
	e.parent = self
	get_parent().add_child(e)
	e.position = position
	e.rotation = rotation
	apply_central_impulse(-aiming_at * e.recoil)
	
func shoot():
	var rotation = aiming_at.angle()
	rpc("instance_bullet", position, rotation)
	var b = Bullet.instance()
	b.parent = self
	get_parent().add_child(b)
	b.position = position
	b.rotation = rotation
	apply_central_impulse(-aiming_at * b.recoil)
	
	can_shoot = false
	$GunCooldown.start()

puppet func instance_bullet(position, rotation):
	var b = Bullet.instance()
	b.parent = self
	get_parent().add_child(b)
	b.position = position
	b.rotation = rotation
	

puppet func instance_explosion(position, rotation):
	var b = Explosion.instance()
	b.parent = self
	get_parent().add_child(b)
	b.position = position
	b.rotation = rotation
	

func die():
	sleeping = true
	yield(get_tree(), "idle_frame")
	position = spawn_pos
	sleeping = false
	linear_velocity = Vector2.ZERO
	

func _on_GunCooldown_timeout():
	can_shoot = true


func _on_HitBox_body_entered(body):
	die()

func set_player_name(new_name):
	get_node("labelName").set_text(new_name)

puppet func update_pos_and_vel(pos, vel):
	position = pos
	linear_velocity = vel
	
