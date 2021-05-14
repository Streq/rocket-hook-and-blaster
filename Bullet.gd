extends Area2D


var speed = 1500
var recoil = 200
var power = 400
var parent : Node

func _physics_process(delta):
	position += transform.x * speed * delta

func _on_Bullet_body_entered(body):
	if body != parent:
		if body is RigidBody2D:
			body.apply_central_impulse(Vector2.RIGHT.rotated(rotation)*power)
		self.queue_free()
	
