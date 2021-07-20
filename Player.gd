extends RigidBody2D


export var fuel_power := 2000

var Bullet : PackedScene = preload("res://Bullet.tscn")
var Explosion : PackedScene = preload("res://FuelExplosion.tscn")
var Hook : PackedScene = preload("res://Hook.tscn")



var lives := 10

var move_dir : Vector2
var aiming_at : Vector2
var wanna_shoot : bool = false
var wanna_jump : bool = false
var wanna_hook : bool = false
var can_shoot : bool = true
var spawn_pos: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	var camera = get_tree().get_root().find_node("camera", true, false)
	if camera:
		camera.connect("zoom_changed", self, "_on_camera_zoom_changed")
#	if is_network_master():
#		$labelName.hide()
	pass # Replace with function body.

func _process(delta):
	if move_dir.is_equal_approx(Vector2.ZERO):
		$AxisAligned/Fire.hide()
	else:
		$AxisAligned/Fire.rotation = move_dir.angle()
		$AxisAligned/Fire.show()

func _input(event):
	if !Global.peer || is_network_master():
		if event is InputEventMouseButton:
			aiming_at = (event.position - get_global_transform_with_canvas().origin).normalized()
	#		print("pressed:" + str(event.pressed))
	#		print("index:" + str(event.button_index))
	#		print("factor:" + str(event.factor))
	#		print("doubeclick:" + str(event.doubleclick))
	#		print("position:" + str(event.position))
			match event.button_index:
				1:
					wanna_shoot = event.is_pressed() 
				2:
					wanna_jump = event.is_pressed()
		elif event is InputEventMouseMotion:
			aiming_at = (event.position - get_global_transform_with_canvas().origin).normalized()
		elif event.is_action("hook"):
			wanna_hook = event.is_pressed()
			

func _physics_process(delta):
	if !Global.peer || is_network_master():
		# move goddamnit
		move_dir = Vector2(
				float(Input.is_action_pressed("ui_right")) - float(Input.is_action_pressed("ui_left")),
				float(Input.is_action_pressed("ui_down")) - float(Input.is_action_pressed("ui_up"))
			).normalized()
#		move_dir = Vector2(
#				-float(Input.is_action_pressed("ui_down")) + float(Input.is_action_pressed("ui_up")),
#				0
#			).normalized().rotated(aiming_at.angle())

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
			
		if wanna_hook:
			wanna_hook = false
			hook()
			
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

func hook():
	var b = Hook.instance()
	get_parent().add_child(b)
	b.shoot(self, aiming_at)
		
	

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
	lives -= 1
	position = spawn_pos
	sleeping = false
	linear_velocity = Vector2.ZERO
	if lives == 0:
		var cam = get_node("camera")
		remove_child(cam)
		get_parent().add_child(cam)
		queue_free()
	

func _on_GunCooldown_timeout():
	can_shoot = true


func _on_HitBox_body_entered(body):
	die()

func set_player_name(new_name):
	get_node("AxisAligned/labelName").set_text(new_name)

puppet func update_pos_and_vel(pos, vel):
	position = pos
	linear_velocity = vel
	
func _on_camera_zoom_changed(newsize):
	$AxisAligned/labelName.rect_scale = newsize
