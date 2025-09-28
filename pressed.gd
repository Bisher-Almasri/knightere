extends Area2D

signal pressed_button

@export var pressed: bool = false

func _ready() -> void:
	pressed = false

func _body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body is CharacterBody2D:
		if not pressed:
			$AudioStreamPlayer.play()
			pressed = true
			print("Button pressed")
			emit_signal("pressed_button")
