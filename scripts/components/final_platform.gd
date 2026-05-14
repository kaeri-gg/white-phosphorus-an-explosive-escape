class_name FinalPlatform
extends StaticBody2D

@export_file("*.tscn") var next_scene_path: String = ""
@export var fade_duration: float = 1.0

## Total seconds from the player touching the oven until the fade to the next
## scene begins. Should be >= final_form_delay so the final_form animation has
## a chance to play before the scene transitions.
@export var hold_duration: float = 11.0

## Seconds the aura glows around the player before fading out. During this
## window the player is locked to STABLE state with horizontal-only movement
## (no jumping).
@export var aura_duration: float = 4.0

## Seconds after the player touches the oven before the final_form animation
## plays. Independent of aura_duration — typically set slightly after the aura
## ends so the transformation reads as a follow-through.
@export var final_form_delay: float = 4.0

@export_group("Oven Aura")
## Permanent ambient aura color shown before the player triggers the platform
## and again after the trigger aura times out.
@export var default_aura_color: Color = Color(0.82756937, 1.0, 0.9360444, 1.0)
## Color of the dissolving aura around the oven sprite while the player is in
## the final-form window.
@export var aura_color: Color = Color(0.45490196, 1.0, 0.8392157, 1.0)
## Aura radius in texels (matches HealingWater convention).
@export var aura_width: float = 130.0
## Falloff curve: 1.0 = wide soft haze, 3.0 = tighter rim.
@export var aura_spread: float = 2.0
## Peak alpha of the aura (0 – 1).
@export var aura_brightness: float = 1.3
## How fast the aura pulses (cycles per second).
@export var aura_pulse_speed: float = 5.0

@onready var detection_area: Area2D = %DetectionArea
@onready var hold_timer: Timer = %StableTimer
@onready var aura_timer: Timer = %AuraTimer
@onready var oven_sprite: Sprite2D = %Oven

const _AURA_SHADER := preload("res://scripts/shaders/healing_aura.gdshader")

var current_player: Player
var has_triggered: bool = false
var is_transitioning: bool = false
var _aura_material: ShaderMaterial

func _ready() -> void:
	detection_area.body_entered.connect(_on_body_entered)
	hold_timer.wait_time = hold_duration
	hold_timer.one_shot = true
	hold_timer.timeout.connect(_on_hold_timeout)
	aura_timer.wait_time = aura_duration
	aura_timer.one_shot = true
	aura_timer.timeout.connect(_on_aura_timeout)
	_apply_aura(default_aura_color)

func _on_body_entered(body: Node) -> void:
	if has_triggered or body is not Player:
		return
	has_triggered = true
	current_player = body
	current_player.enter_final_aura()
	_set_aura_color(aura_color)
	aura_timer.start()
	hold_timer.start()
	_schedule_final_form()

func _on_aura_timeout() -> void:
	_set_aura_color(default_aura_color)

func _schedule_final_form() -> void:
	await get_tree().create_timer(final_form_delay).timeout
	if not is_instance_valid(current_player):
		return
	current_player.transform_to_final_form()

func _on_hold_timeout() -> void:
	advance()

func advance() -> void:
	if is_transitioning:
		return

	if next_scene_path.is_empty():
		push_warning("%s is missing a Next Scene." % name)
		return

	var resolved := ResourceUID.ensure_path(next_scene_path)
	if resolved.is_empty():
		push_warning("Could not resolve: %s" % next_scene_path)
		return

	is_transitioning = true
	sound_manager.play("ReachPortal")
	await utils.fade_to_white(get_tree().current_scene, fade_duration)
	get_tree().change_scene_to_file(resolved)

func _apply_aura(color: Color) -> void:
	_aura_material = ShaderMaterial.new()
	_aura_material.shader = _AURA_SHADER
	_aura_material.set_shader_parameter("aura_color", color)
	_aura_material.set_shader_parameter("aura_radius", aura_width)
	_aura_material.set_shader_parameter("spread", aura_spread)
	_aura_material.set_shader_parameter("brightness", aura_brightness)
	_aura_material.set_shader_parameter("pulse_speed", aura_pulse_speed)
	_aura_material.set_shader_parameter("enabled", true)
	oven_sprite.material = _aura_material

func _set_aura_color(color: Color) -> void:
	if _aura_material:
		_aura_material.set_shader_parameter("aura_color", color)
