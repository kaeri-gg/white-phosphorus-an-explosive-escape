class_name Player
extends CharacterBody2D

@onready var player_sprite: PlayerExpressions = %PlayerExpressionController
@onready var burn_timer: Timer = %BurnTimer
@onready var damage_timer: Timer = %DamageTimer
@onready var water_exit_delay_timer: Timer = %VibrateTimer

@onready var player_camera: Camera2D = $Camera2D

@export var SPEED: float = 220.0
@export var JUMP_VELOCITY: float = -480.0
@export var PLAYER_HEALTH: int = 7

## Seconds between each -1 HP tick while the player is BURNING.
@export var DAMAGE_INTERVAL: float = 1.5

@export_group("Camera")
@export var camera_bounds: Rect2 = Rect2(0, 0, 1280, 720)

var current_health: int

signal stabilized
signal burned
signal shook

signal died
signal health_timer_value(time_left: float)
signal switch_pressed

signal state_change(new_state: int)
signal movement_change(is_moving: bool)
signal health_changed(current: int, max_hp: int)

enum STATE { STABLE, BURNING, VIBRATING, DEAD, EVOLVED }
enum ENV { AIR, WATER }

const MAX_JUMP: int = 2

# ─────────────────────────────────────────────────────────────
# ANIMATION CONFIG
# ─────────────────────────────────────────────────────────────

const _ANIMATIONS := {
	STATE.STABLE: {
		"idle": "stable",
		"moving": "stable_moving",
		"jump": "stable_jump",
	},
	STATE.BURNING: {
		"idle": "repeat_burning",
		"moving": "burning_moving",
		"jump": "burning_jump",
		"intro": "start_burning",
		"intro_duration": 0.5,
	},
	STATE.VIBRATING: {
		"idle": "vibrating",
		"moving": "vibrating_moving",
		"jump": "vibrating_jump",
	},
	STATE.EVOLVED: {
		"idle": "evolved",
	},
}

const _DEATH_INTRO_ANIM := "start_burning"
const _DEATH_INTRO_DURATION := 0.7
const _DEATH_FINAL_ANIM := "dead"

var jump_count: int
var current_state: STATE = STATE.STABLE
var env_state: ENV = ENV.AIR
var was_moving: bool = false
var is_dying: bool = false
var just_left_water: bool = false

func _ready() -> void:
	current_health = PLAYER_HEALTH
	health_changed.emit(current_health, PLAYER_HEALTH)

	add_to_group("can_interact_with_water")
	_apply_camera_bounds()

	damage_timer.wait_time = DAMAGE_INTERVAL
	damage_timer.timeout.connect(_on_damage_tick)
	burn_timer.timeout.connect(_on_burn_timer_timeout)
	water_exit_delay_timer.timeout.connect(_on_water_exit_delay_timer_timeout)
	state_change.connect(player_sprite.on_player_state_change)
	movement_change.connect(player_sprite.on_player_movement_change)
	player_sprite.animation_finished.connect(_on_player_anim_finished)

	detect_environment()
	update_visual_state()

	state_change.emit(current_state)
	movement_change.emit(was_moving)

func _apply_camera_bounds() -> void:
	var bounds := camera_bounds.abs()
	player_camera.limit_left = floori(bounds.position.x)
	player_camera.limit_top = floori(bounds.position.y)
	player_camera.limit_right = ceili(bounds.end.x)
	player_camera.limit_bottom = ceili(bounds.end.y)

func change_state(new_state: STATE) -> void:
	if current_state == STATE.DEAD:
		return
	if current_state == new_state:
		return

	current_state = new_state
	state_change.emit(current_state)

	if new_state != STATE.DEAD:
		update_visual_state()

	match new_state:
		STATE.STABLE:
			stabilized.emit()
		STATE.BURNING:
			burned.emit()
		STATE.VIBRATING:
			shook.emit()

func _physics_process(_delta: float) -> void:
	_update_health_timer_label()

	if current_state == STATE.DEAD:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_on_floor():
		velocity += get_gravity() * _delta

	if is_on_floor():
		jump_count = 0

	if Input.is_action_just_pressed("jump") and jump_count < MAX_JUMP:
		var jump_anim: String = _anims_for(current_state).get("jump", "")
		if not jump_anim.is_empty():
			player_sprite.stop()
			player_sprite.play(jump_anim)
		jump_count += 1
		velocity.y = JUMP_VELOCITY

	var direction := Input.get_axis("move_left", "move_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	var is_moving_now: bool = abs(velocity.x) > 0.1
	if is_moving_now != was_moving:
		was_moving = is_moving_now
		_refresh_locomotion_animation()
		movement_change.emit(was_moving)

	move_and_slide()
	_flip_on_move()

func detect_environment() -> void:
	if current_state == STATE.DEAD:
		return

	if env_state == ENV.WATER:
		_stop_timers()
		change_state(STATE.STABLE)
		return

	if just_left_water:
		if burn_timer.is_stopped():
			burn_timer.start()
		return

	if current_state != STATE.BURNING:
		change_state(STATE.VIBRATING)

	if burn_timer.is_stopped():
		burn_timer.start()

func _stop_timers() -> void:
	if not burn_timer.is_stopped():
		burn_timer.stop()
	if not damage_timer.is_stopped():
		damage_timer.stop()
	if not water_exit_delay_timer.is_stopped():
		water_exit_delay_timer.stop()

func enter_water() -> void:
	just_left_water = false
	update_environment(ENV.WATER)
	detect_environment()

func leave_water() -> void:
	just_left_water = true
	update_environment(ENV.AIR)
	water_exit_delay_timer.start()

func update_environment(location: ENV) -> void:
	env_state = location

func _on_water_exit_delay_timer_timeout() -> void:
	just_left_water = false
	if env_state == ENV.AIR:
		detect_environment()

func _on_burn_timer_timeout() -> void:
	if just_left_water or current_state == STATE.BURNING:
		return

	change_state(STATE.BURNING)
	damage_timer.start()
	take_damage(1)

func _on_damage_tick() -> void:
	if env_state != ENV.AIR:
		return
	take_damage(1)

func take_damage(amount: int) -> void:
	if current_state == STATE.DEAD:
		return

	current_health -= amount
	health_changed.emit(current_health, PLAYER_HEALTH)

	if current_health <= 0:
		die()

func heal(amount: int) -> void:
	if current_state == STATE.DEAD:
		return
	if current_health >= PLAYER_HEALTH:
		return

	current_health = mini(current_health + amount, PLAYER_HEALTH)
	health_changed.emit(current_health, PLAYER_HEALTH)

func die() -> void:
	if is_dying or current_state == STATE.DEAD:
		return

	var state_before_death := current_state

	is_dying = true
	_stop_timers()

	current_state = STATE.DEAD
	state_change.emit(current_state)

	await _play_death_animation(state_before_death)
	died.emit()

func _play_death_animation(prev_state: STATE) -> void:
	
	if prev_state != STATE.BURNING:
		player_sprite.play(_DEATH_INTRO_ANIM)
		await utils.timeout(_DEATH_INTRO_DURATION)

	player_sprite.play(_DEATH_FINAL_ANIM)
	await player_sprite.animation_finished
	visible = false


# ─────────────────────────────────────────────────────────────
# ANIMATION DRIVERS
# ─────────────────────────────────────────────────────────────

func _anims_for(state: STATE) -> Dictionary:
	return _ANIMATIONS.get(state, {})

func _is_animation_locked() -> bool:
	var anim := player_sprite.animation
	for state_anims in _ANIMATIONS.values():
		if anim == state_anims.get("jump", ""):
			return true
		if anim == state_anims.get("intro", ""):
			return true
	return false

func _is_jump_animation(anim: StringName) -> bool:
	for state_anims in _ANIMATIONS.values():
		if anim == state_anims.get("jump", ""):
			return true
	return false

func _refresh_locomotion_animation(force: bool = false) -> void:
	if current_state == STATE.DEAD:
		return
	if not force and _is_animation_locked():
		return

	var anims := _anims_for(current_state)
	if anims.is_empty():
		return

	var key := "moving" if was_moving and anims.has("moving") else "idle"
	var anim_name: String = anims.get(key, "")
	if not anim_name.is_empty():
		player_sprite.play(anim_name)

func update_visual_state() -> void:
	var state_at_call := current_state
	var anims := _anims_for(current_state)

	if anims.has("intro"):
		var intro_anim: String = anims["intro"]
		var intro_duration: float = anims.get("intro_duration", 0.5)
		player_sprite.play(intro_anim)
		await utils.timeout(intro_duration)

		if current_state != state_at_call:
			return
		if _is_jump_animation(player_sprite.animation):
			return
		_refresh_locomotion_animation(true)
		return

	_refresh_locomotion_animation()

func _on_player_anim_finished() -> void:
	if current_state == STATE.DEAD:
		return
	if _is_jump_animation(player_sprite.animation):
		_refresh_locomotion_animation(true)


# ─────────────────────────────────────────────────────────────
# UI / MISC
# ─────────────────────────────────────────────────────────────

func time_until_next_damage() -> float:
	if current_state == STATE.BURNING and not damage_timer.is_stopped():
		return damage_timer.time_left
	return float(current_health)

func _update_health_timer_label() -> void:
	health_timer_value.emit(time_until_next_damage())

func _flip_on_move() -> void:
	if velocity.x > 0:
		player_sprite.flip_h = false
	if velocity.x < 0:
		player_sprite.flip_h = true

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("press_e_to_interact") and not event.is_echo():
		switch_pressed.emit()
