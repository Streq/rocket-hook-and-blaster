extends Area2D


var power = 10000
var recoil = 10000
var parent : Node

func _on_FuelExplosion_body_entered(body):
	if body != parent:
		if body is RigidBody2D:
			body.apply_central_impulse(Vector2.LEFT.rotated(rotation)*power)


func _on_Timer_timeout():
	queue_free()
