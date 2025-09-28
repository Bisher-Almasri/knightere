extends Area2D

@export var unlocked: bool = false
var player_in_area := false

var level_paths := [
	"res://level_0.tscn",
	"res://Level1.tscn",
	"res://Level2.tscn",
	"res://Level3.tscn",	
	"res://Level4.tscn",
]

func unlock():
	unlocked = true
	$AnimatedSprite2D.play("open")

func _on_body_entered(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_area = true
		print("erf")

func _on_body_exited(body: Node2D) -> void:
	if body is CharacterBody2D:
		player_in_area = false

func _process(delta: float) -> void:
	if not unlocked:
		return

	if player_in_area and Input.is_action_just_pressed("use"):
		var current_scene_path = get_tree().current_scene.scene_file_path

		if current_scene_path.ends_with("Level4.tscn"):
			get_tree().change_scene_to_file("res://MainMenu.tscn")
			return

		var index = level_paths.find(current_scene_path)
		if index != -1 and index + 1 < level_paths.size():
			var next_level = level_paths[index + 1]
			get_tree().change_scene_to_file(next_level)
