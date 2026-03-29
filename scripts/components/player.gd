extends CharacterBody2D

@onready var player_sprite: Sprite2D = $Sprite2D
@export var SPEED = 300.0
@export var JUMP_VELOCITY = -600.0


func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	flip_char_on_move()

func flip_char_on_move() -> void:
	if velocity.x > 0:
		player_sprite.flip_h = false
	if velocity.x < 0:	
		player_sprite.flip_h = true
		
