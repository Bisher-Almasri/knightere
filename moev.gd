extends CharacterBody2D

@export var speed: float = 400.0
@export var jump_force: float = 400.0
@export var gravity_strength: float = 1000.0
@export var clone_scene: PackedScene = preload("res://cloen.tscn")
@export var cangravity: bool = true

var clones: Array = []
var gravity_vector := Vector2.DOWN
var gravity_direction: int = 1
var control_locked: bool = false

@onready var player_camera: Camera2D = get_node_or_null("Camera2D")

func _physics_process(delta: float) -> void:
	var input_dir := Vector2.ZERO

	if not control_locked:
		handle_animation()

		match gravity_vector:
			Vector2.DOWN, Vector2.UP:
				input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
				velocity.x = input_dir.x * speed
			Vector2.LEFT, Vector2.RIGHT:
				input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
				velocity.y = input_dir.y * speed

		if can_jump():
			#$Jump.play()
			if gravity_vector == Vector2.DOWN and Input.is_action_just_pressed("up"):
				velocity = -gravity_vector * jump_force
			elif gravity_vector == Vector2.UP and Input.is_action_just_pressed("down"):
				velocity = -gravity_vector * jump_force
			elif gravity_vector == Vector2.LEFT and Input.is_action_just_pressed("move_right"):
				velocity = -gravity_vector * jump_force
			elif gravity_vector == Vector2.RIGHT and Input.is_action_just_pressed("move_left"):
				velocity = -gravity_vector * jump_force

	velocity += gravity_vector * gravity_strength * delta
	move_and_slide()

	if Input.is_action_just_pressed("flip_gravity") and cangravity and can_jump():
		gravity_direction = (gravity_direction % 4) + 1
		match gravity_direction:
			1: set_gravity(Vector2.DOWN)
			2: set_gravity(Vector2.RIGHT)
			3: set_gravity(Vector2.UP)
			4: set_gravity(Vector2.LEFT)
		cangravity = false
		$Timer.start()

	if not control_locked and Input.is_action_just_pressed("spawn_clone") and clones.is_empty():
		spawn_clone()

func handle_animation() -> void:
	# Check for movement and gravity direction
	if (Input.is_action_pressed("move_left") and gravity_direction == 1) \
	or (Input.is_action_pressed("down") and gravity_direction == 2) \
	or (Input.is_action_pressed("move_right") and gravity_direction == 3) \
	or (Input.is_action_pressed("up") and gravity_direction == 4):
		$AnimatedSprite2D.flip_h = true
		#$AnimatedSprite2D.play("walk")
		## Only play walk sound if it is not already playing
		#if not $Walk.is_playing():
			#$Walk.play()
	elif (Input.is_action_pressed("move_right") and gravity_direction == 1) \
	or (Input.is_action_pressed("up") and gravity_direction == 2) \
	or (Input.is_action_pressed("move_left") and gravity_direction == 3) \
	or (Input.is_action_pressed("down") and gravity_direction == 4):
		$AnimatedSprite2D.flip_h = false
		#$AnimatedSprite2D.play("walk")
		## Only play walk sound if it is not already playing
		#if not $Walk.is_playing():
			#$Walk.play()
	else:
		# Stop walk sound when idle
		$AnimatedSprite2D.play("idle")
			#if $Walk.is_playing():
				#$Walk.stop()



func spawn_clone() -> void:
	if not clone_scene:
		return

	$AnimatedSprite2D.play("summon")
	$Clone.play()
	var clone = clone_scene.instantiate()
	var offset = 100
	var new_position := position

	match gravity_direction:
		1: new_position.x -= offset
		2: new_position.y += offset
		3: new_position.x += offset
		4: new_position.y -= offset

	clone.position = position
	clone.master_gravity = gravity_vector
	clone.gravity_direction = gravity_direction

	get_parent().add_child(clone)
	clones.append(clone)

	control_locked = true

	var cam := Camera2D.new()
	cam.name = "Camera2D"
	cam.position_smoothing_enabled = true
	clone.add_child(cam)

	cam.make_current()

	clone.connect("gravity_changed", Callable(self, "_on_clone_gravity_changed"))
	clone.connect("clone_died", Callable(self, "_on_clone_died"))


func _on_clone_gravity_changed(new_gravity: Vector2) -> void:
	set_gravity(new_gravity)


func _on_clone_died(clone_node) -> void:
	clones.erase(clone_node)
	control_locked = false

	if is_instance_valid(player_camera):
		player_camera.make_current()

		await get_tree().process_frame
		$AnimatedSprite2D.play("awaken")


func set_gravity(dir: Vector2) -> void:
	gravity_vector = dir
	update_sprite_rotation()

func update_sprite_rotation() -> void:
	match gravity_vector:
		Vector2.DOWN:  rotation_degrees = 0
		Vector2.UP:    rotation_degrees = 180
		Vector2.LEFT:  rotation_degrees = 90
		Vector2.RIGHT: rotation_degrees = -90

func can_jump() -> bool:
	if gravity_vector == Vector2.DOWN and is_on_floor():
		return true
	if gravity_vector == Vector2.UP and is_on_ceiling():
		return true
	if gravity_vector == Vector2.RIGHT and is_on_wall():
		return get_wall_normal().x < 0
	if gravity_vector == Vector2.LEFT and is_on_wall():
		return get_wall_normal().x > 0
	return false

func die() -> void:
	get_tree().reload_current_scene()

func _on_timer_timeout() -> void:
	cangravity = true
