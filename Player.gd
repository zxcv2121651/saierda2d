extends CharacterBody2D

const SPEED = 100.0

enum State { IDLE, MOVE, ATTACK }
var current_state = State.IDLE
var facing_direction = Vector2.DOWN

@onready var sprite = $Sprite2D
@onready var animation_player = $AnimationPlayer
@onready var attack_area = $AttackArea
@onready var attack_collision = $AttackArea/CollisionShape2D

func _ready():
	attack_collision.disabled = true

func _physics_process(delta):
	match current_state:
		State.IDLE:
			idle_state(delta)
		State.MOVE:
			move_state(delta)
		State.ATTACK:
			attack_state(delta)

	move_and_slide()
	_process_slide_collisions()

func idle_state(delta):
	var input_vector = get_input_vector()
	if Input.is_action_just_pressed("attack"):
		current_state = State.ATTACK
		start_attack()
	elif input_vector != Vector2.ZERO:
		current_state = State.MOVE

func move_state(delta):
	var input_vector = get_input_vector()
	if Input.is_action_just_pressed("attack"):
		current_state = State.ATTACK
		start_attack()
		velocity = Vector2.ZERO
		return

	if input_vector == Vector2.ZERO:
		current_state = State.IDLE
		velocity = Vector2.ZERO
	else:
		facing_direction = input_vector
		velocity = input_vector * SPEED
		update_sprite_direction()

func attack_state(delta):
	velocity = Vector2.ZERO
	# Attack duration handled by animation or timer
	# If no animation player setup is complete, we'll use a simple timer logic
	pass

func get_input_vector() -> Vector2:
	var x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	var y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	return Vector2(x, y).normalized()

func update_sprite_direction():
	if facing_direction.x < 0:
		sprite.flip_h = true
	elif facing_direction.x > 0:
		sprite.flip_h = false

func start_attack():
	# Temporary logic for attack duration
	attack_collision.disabled = false
	# Position attack area based on direction
	attack_area.position = facing_direction * 16.0

	# Simulate animation length
	await get_tree().create_timer(0.3).timeout
	attack_collision.disabled = true
	current_state = State.IDLE

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_hitbox"):
		take_damage()

func take_damage():
	# Simple flash or knockback could be added here
	modulate = Color(1, 0, 0)
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

func interact():
	pass

# Add push box logic
func _process_slide_collisions():
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		if collider is RigidBody2D and collider.is_in_group("environment"):
			collider.apply_central_impulse(-collision.get_normal() * 10)

# Modify _physics_process to call _process_slide_collisions
