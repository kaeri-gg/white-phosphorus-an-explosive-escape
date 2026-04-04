class_name Player
extends CharacterBody2D

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite

@export var SPEED = 400.0
@export var JUMP_VELOCITY = -800.0
@export var AIR_SURVIVAL_TIME = 3.0

signal is_stable
signal is_burning
signal is_shaking

signal is_dead
signal is_evolved

enum STATE { STABLE, BURNING, SHAKING, DEAD, EVOLVED }
enum ENV { AIR, WATER }

var current_state: STATE = STATE.STABLE
var env_state: ENV = ENV.WATER
var air_timer: Timer

func set_timer() -> void:
	air_timer = Timer.new()
	air_timer.one_shot = true
	air_timer.wait_time = AIR_SURVIVAL_TIME
	air_timer.timeout.connect(_on_air_timer_timeout)
	add_child(air_timer)

func _ready() -> void:
	add_to_group("can_interact_with_water")
	set_timer()
	update_visual_state()

func change_state(new_state: STATE) -> void:
	if current_state == new_state:
		return
		
	current_state = new_state
	update_visual_state()
	
	# Emit corresponding signal
	match new_state:
		STATE.STABLE: 
			is_stable.emit()
		STATE.BURNING: 
			is_burning.emit()
		STATE.SHAKING: 
			is_shaking.emit()
		STATE.DEAD: 
			is_dead.emit()
		STATE.EVOLVED: 
			is_evolved.emit()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	if current_state == STATE.DEAD:
		move_and_slide()
		flip_char_on_move()
		return

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
	flip_char_on_move()

func detect_environment() -> void:
	if env_state == ENV.WATER:
		if not air_timer.is_stopped():
			air_timer.stop()

		change_state(STATE.STABLE)
		return

	check_hp()
	change_state(STATE.SHAKING)
	if air_timer.is_stopped():
		air_timer.start()

func enter_water() -> void:
	check_hp()
	update_environment(ENV.WATER)
	detect_environment()

func leave_water() -> void:
	check_hp()
	update_environment(ENV.AIR)
	detect_environment()

func update_environment(location: ENV) -> void:
	env_state = location
	
func check_hp() -> void:
	if current_state == STATE.DEAD:
		return
	# TODO: Add health
	
func burn() -> void:
	check_hp()

	if not air_timer.is_stopped():
		air_timer.stop()

	change_state(STATE.BURNING)
	
func die() -> void:
	if not air_timer.is_stopped():
		air_timer.stop()

	change_state(STATE.DEAD)

func _on_air_timer_timeout() -> void:
	if env_state != ENV.AIR:
		return

	burn()

func update_visual_state() -> void:
	match current_state:
		STATE.STABLE:
			player_sprite.play("stable")
		STATE.BURNING:
			player_sprite.play("burning")
		STATE.SHAKING:
			player_sprite.play("shaking")
		STATE.DEAD:
			player_sprite.play("dead")
		STATE.EVOLVED:
			player_sprite.play("evolved")
	
func flip_char_on_move() -> void:
	if velocity.x > 0:
		player_sprite.flip_h = false
	if velocity.x < 0:	
		player_sprite.flip_h = true
		
