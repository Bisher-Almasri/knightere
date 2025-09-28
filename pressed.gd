extends Area2D

@export var pressed: bool = false

func _ready() -> void:
	pressed = false
 
func _body_shape_entered(_body_rid:RID, _body:Node2D, _body_shape_index:int, _local_shape_index:int):
	if not pressed:
		pressed = true
		print("Button pressed")
