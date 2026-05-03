extends CharacterBody2D

const SPEED = 40.0
const MAX_HEALTH = 3

var health = MAX_HEALTH
var target = null

@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionArea

func _physics_process(delta):
	if target:
		var direction = (target.global_position - global_position).normalized()
		velocity = direction * SPEED

		if direction.x < 0:
			sprite.flip_h = true
		elif direction.x > 0:
			sprite.flip_h = false
	else:
		velocity = Vector2.ZERO

	move_and_slide()

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		target = body

func _on_detection_area_body_exited(body):
	if body == target:
		target = null

func _on_hurtbox_area_entered(area):
	if area.is_in_group("player_attack"):
		take_damage(1, area.global_position)

func take_damage(amount, source_position):
	health -= amount
	modulate = Color(1, 0, 0) # Flash red

	# Knockback
	var knockback_dir = (global_position - source_position).normalized()
	velocity = knockback_dir * 150
	move_and_slide()

	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)

	if health <= 0:
		die()

func die():
	queue_free()
