extends Area2D


var speed = 1500
var power = 1000
var recoil = 1000
var parent : Node

func _physics_process(delta):
	position -= transform.x * speed * delta

func _on_FuelExplosion_body_entered(body):
	if body != parent:
		if body is RigidBody2D:
			body.apply_central_impulse(Vector2.LEFT.rotated(rotation)*power)


func _on_Timer_timeout():
	queue_free()
