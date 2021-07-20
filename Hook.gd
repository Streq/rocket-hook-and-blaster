extends Node2D

var speed = 400
var max_length = 400
var origin :Node2D = null
var head : Node2D
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func shoot(origin:Node2D, direction:Vector2):
	self.origin = origin
	position = origin.position
	rotation = direction.angle()
	$rigidTip.linear_velocity += direction*speed
	

func _process(delta):
	$Chain.rotation = $rigidTip.position.angle()
	$Chain.region_rect.size.x = $rigidTip.position.length()
	$Chain.position = $rigidTip.position/2
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	position = origin.position
