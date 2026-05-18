@tool
extends Water
class_name HealingWater

## Seconds between each heal tick.
@export var heal_interval: float = 0.5

## How much HP is restored on each tick.
@export var heal_amount: int = 1

@export_group("Player Aura")
## Color of the dissolving aura around the player while they are healing.
@export var player_aura_color: Color = Color(0.72, 0.911, 1.0, 1.0)
## Aura radius in texels. With player scale 0.1: desired_px / 0.1 = texels.
## e.g. 10 screen-px → 100 texels.
@export var player_aura_width: float = 100.0
## Falloff curve: 1.0 = wide soft haze, 3.0 = tighter rim.
@export var player_aura_spread: float = 1.8
## Peak alpha of the aura (0 – 1). Below 1.0 keeps it from looking solid.
@export var player_aura_brightness: float = 0.65
## How fast the player aura pulses (cycles per second).
@export var player_aura_pulse_speed: float = 2.5

# ── internals ──────────────────────────────────────────────────────────────
var _heal_timer: Timer
var _current_healing_player: Player
var _player_original_material: Material

const _AURA_SHADER := preload("res://scripts/shaders/healing_aura.gdshader")

# ── lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint():
		return

	_heal_timer = Timer.new()
	_heal_timer.wait_time = heal_interval
	_heal_timer.one_shot = false
	_heal_timer.timeout.connect(_on_heal_tick)
	add_child(_heal_timer)

# ── player aura ────────────────────────────────────────────────────────────

func _apply_player_aura(player: Player) -> void:
	var mat := ShaderMaterial.new()
	mat.shader = _AURA_SHADER
	mat.set_shader_parameter("aura_color", player_aura_color)
	mat.set_shader_parameter("aura_radius", player_aura_width)
	mat.set_shader_parameter("spread", player_aura_spread)
	mat.set_shader_parameter("brightness", player_aura_brightness)
	mat.set_shader_parameter("pulse_speed", player_aura_pulse_speed)
	mat.set_shader_parameter("enabled", true)
	_player_original_material = player.player_sprite.material
	player.player_sprite.material = mat

func _remove_player_aura(player: Player) -> void:
	if is_instance_valid(player):
		player.player_sprite.material = _player_original_material
	_player_original_material = null

# ── water body callbacks ───────────────────────────────────────────────────

func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	if body is Player and _heal_timer:
		_current_healing_player = body
		sound_manager.play("Heal")
		_heal_timer.wait_time = heal_interval
		_heal_timer.start()
		_apply_player_aura(body)

func _on_body_exited(body: Node2D) -> void:
	super._on_body_exited(body)
	if body is Player and body == _current_healing_player:
		_remove_player_aura(body)
		_current_healing_player = null
		if _heal_timer:
			_heal_timer.stop()

func _on_heal_tick() -> void:
	if _current_healing_player == null or not is_instance_valid(_current_healing_player):
		_heal_timer.stop()
		return
	_current_healing_player.heal(heal_amount)
