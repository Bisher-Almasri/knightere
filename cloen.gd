extends CharacterBody2D

signal clone_died
signal gravity_changed(new_gravity: Vector2)

@export var speed: float = 500.0
@export var jump_force: float = 500.0
@export var gravity_direction := 1
@export var gravity_strength: float = 1000.0

var master_gravity := Vector2.DOWN

func _ready():
	$LifetimeTimer.start()
	$LifetimeTimer.connect("timeout", Callable(self, "_on_LifetimeTimer_timeout"))


func _physics_process(delta):
	var input_dir := Vector2.ZERO
	match gravity_direction:
			1: set_gravity(Vector2.DOWN)
			2: set_gravity(Vector2.RIGHT)
			3: set_gravity(Vector2.UP)
			4: set_gravity(Vector2.LEFT)
	
	match master_gravity:
		Vector2.DOWN, Vector2.UP:
			input_dir.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
		Vector2.LEFT, Vector2.RIGHT:
			input_dir.y = Input.get_action_strength("down") - Input.get_action_strength("up")

	if Input.is_action_pressed("move_left"):
		$AnimatedSprite2D.flip_h = true
	else:
		$AnimatedSprite2D.flip_h = false

	if master_gravity == Vector2.DOWN or master_gravity == Vector2.UP:
		velocity.x = input_dir.x * speed
	else:
		velocity.y = input_dir.y * speed  

	if master_gravity == Vector2.DOWN and is_on_floor() and Input.is_action_just_pressed("up"):
		velocity = -master_gravity * jump_force
	elif master_gravity == Vector2.UP and is_on_ceiling() and Input.is_action_just_pressed("down"):
		velocity = -master_gravity * jump_force
	elif master_gravity == Vector2.LEFT and is_on_wall() and Input.is_action_just_pressed("move_right"):
		velocity = -master_gravity * jump_force
	elif master_gravity == Vector2.RIGHT and is_on_wall() and Input.is_action_just_pressed("move_left"):
		velocity = -master_gravity * jump_force


	if Input.is_action_just_pressed("spawn_clone"):
		_on_LifetimeTimer_timeout()
		
	if Input.is_action_just_pressed("flip_gravity"):
		gravity_direction = (gravity_direction % 4) + 1
		match gravity_direction:
			1: set_gravity(Vector2.DOWN)
			2: set_gravity(Vector2.RIGHT)
			3: set_gravity(Vector2.UP)
			4: set_gravity(Vector2.LEFT)
			
	velocity += master_gravity * gravity_strength * delta
	move_and_slide()


func set_gravity(dir: Vector2):
	master_gravity = dir
	update_sprite_rotation()
	emit_signal("gravity_changed", dir)

func update_sprite_rotation():
	match master_gravity:
		Vector2.DOWN:  $AnimatedSprite2D.rotation_degrees = 0
		Vector2.UP:    $AnimatedSprite2D.rotation_degrees = 180
		Vector2.LEFT:  $AnimatedSprite2D.rotation_degrees = 90
		Vector2.RIGHT: $AnimatedSprite2D.rotation_degrees = -90

func _on_LifetimeTimer_timeout():
	print("weqrwthyjkyhtrewqrghjmhj")
	emit_signal("clone_died", self)
	queue_free()

func die():
	_on_LifetimeTimer_timeout()
