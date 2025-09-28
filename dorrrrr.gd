extends Area2D

@export var unlocked: bool = false

func unlock():
	unlocked = true
	$AnimatedSprite2D.play("open")
