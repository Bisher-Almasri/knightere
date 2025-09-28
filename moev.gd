extends CharacterBody2D

@export var speed: float = 400.0
@export var jump_force: float = 400.0
@export var gravity_strength: float = 1000.0
@export var clone_scene: PackedScene = preload("res://cloen.tscn")

var clones: Array = []
var gravity_vector := Vector2.DOWN
var gravity_direction = 1
var control_locked: bool = false  

func _physics_process(delta):
	var input_dir := Vector2.ZERO
	
	if not control_locked:
		 
		if Input.is_action_pressed("move_left") and gravity_direction == 1 or Input.is_action_pressed("down") and gravity_direction == 2 or Input.is_action_pressed("move_right") and gravity_direction == 3 or Input.is_action_pressed("up") and gravity_direction == 4:
			$AnimatedSprite2D.flip_h = true
			$AnimatedSprite2D.play("walk")
		elif Input.is_action_pressed("move_right") and gravity_direction == 1 or Input.is_action_pressed("up") and gravity_direction == 2 or Input.is_action_pressed("move_left") and gravity_direction == 3 or Input.is_action_pressed("down") and gravity_direction == 4:
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("walk")
		else:
			$AnimatedSprite2D.play("idle")
			
		match gravity_vector:
			Vector2.DOWN, Vector2.UP:
				input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			Vector2.LEFT, Vector2.RIGHT:
				input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")
		if gravity_vector == Vector2.DOWN or gravity_vector == Vector2.UP:
			velocity.x = input_dir.x * speed
		else:
			velocity.y = input_dir.y * speed

		if gravity_vector == Vector2.DOWN and can_jump() and Input.is_action_just_pressed("up"):
			velocity = -gravity_vector * jump_force
		elif gravity_vector == Vector2.UP and can_jump() and Input.is_action_just_pressed("down"):
			velocity = -gravity_vector * jump_force
		elif gravity_vector == Vector2.LEFT and can_jump() and Input.is_action_just_pressed("move_right"):
			velocity = -gravity_vector * jump_force
		elif gravity_vector == Vector2.RIGHT and can_jump() and Input.is_action_just_pressed("move_left"):
			velocity = -gravity_vector * jump_force

	velocity += gravity_vector * gravity_strength * delta
	move_and_slide()
	
	if Input.is_action_just_pressed("flip_gravity"):
		gravity_direction = (gravity_direction % 4) + 1
		match gravity_direction:
			1: set_gravity(Vector2.DOWN)
			2: set_gravity(Vector2.RIGHT)
			3: set_gravity(Vector2.UP)
			4: set_gravity(Vector2.LEFT)

	if not control_locked and Input.is_action_just_pressed("spawn_clone") and clones.is_empty():
		spawn_clone()
		
func spawn_clone():
	if not clone_scene:
		return
	
	velocity = Vector2.ZERO
	
	var clone = clone_scene.instantiate()
	
	var offset = 100
	var new_x = position.x
	var new_y = position.y

	match gravity_direction:
		1:
			new_x -= offset
		2: 
			new_y += offset
		3: 
			new_x += offset
		4: 
			new_y -= offset

	clone.position = Vector2(new_x, new_y)
	
	clone.master_gravity = gravity_vector
	clone.gravity_direction = gravity_direction
	
	clone.velocity = Vector2.ZERO
	
	get_parent().add_child(clone)
	clones.append(clone)

	control_locked = true
	
	clone.connect("gravity_changed", Callable(self, "_on_clone_gravity_changed"))
	clone.connect("clone_died", Callable(self, "_on_clone_died"))

func _on_clone_gravity_changed(new_gravity: Vector2):
	set_gravity(new_gravity)
	velocity = Vector2.ZERO


func _on_clone_died(clone_node):
	clones.erase(clone_node)
	control_locked = false


func set_gravity(dir: Vector2):
	gravity_vector = dir
	update_sprite_rotation()


func update_sprite_rotation():
	match gravity_vector:
		Vector2.DOWN:  
			rotation_degrees = 0
		Vector2.UP:
			rotation_degrees = 180
		Vector2.LEFT:
			rotation_degrees = 90
		Vector2.RIGHT:
			rotation_degrees = -90


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
