@tool
extends Water
class_name HealingWater

## Seconds between each heal tick.
@export var heal_interval: float = 0.5

## How much HP is restored on each tick.
@export var heal_amount: int = 1

@export_group("Surface Glow")
## Color of the animated glow on top of the water surface.
@export var surface_glow_color: Color = Color(0.0, 1.0, 1.0, 1.0)
## Width of the innermost (brightest) glow layer. Each outer layer is one step wider.
@export var surface_glow_width: float = 6.0
## How many times per second the glow brightens and dims.
@export var surface_glow_pulse_speed: float = 2.0

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

@export_group("Entry Blink")
## Color to flash when the player first enters the water (Mario mushroom style).
@export var blink_color: Color = Color.YELLOW
## Number of blink cycles on entry.
@export var blink_count: int = 3
## Duration of one full blink cycle (yellow + back to normal), in seconds.
@export var blink_duration: float = 0.18

# ── internals ──────────────────────────────────────────────────────────────
var _heal_timer: Timer
var _current_healing_player: Player

var _glow_lines: Array[Line2D] = []
var _glow_tween: Tween
var _blink_tween: Tween

var _player_original_material: Material

# Stacked Line2Ds, outermost first. Wide layers are faint to hide the hard edge;
# inner layers are brighter to form a soft core. Array length drives the layer count.
const _GLOW_ALPHAS: Array[float] = [0.03, 0.06]

const _AURA_SHADER := preload("res://scripts/shaders/healing_aura.gdshader")

# ── lifecycle ──────────────────────────────────────────────────────────────

func _ready() -> void:
	super._ready()
	_setup_surface_glow()
	if Engine.is_editor_hint():
		return

	_heal_timer = Timer.new()
	_heal_timer.wait_time = heal_interval
	_heal_timer.one_shot = false
	_heal_timer.timeout.connect(_on_heal_tick)
	add_child(_heal_timer)

# ── surface glow ───────────────────────────────────────────────────────────

func _setup_surface_glow() -> void:
	for gl in _glow_lines:
		if is_instance_valid(gl):
			gl.queue_free()
	_glow_lines.clear()

	var mat := CanvasItemMaterial.new()
	mat.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD

	var layer_count := _GLOW_ALPHAS.size()
	for i in range(layer_count):
		var gl := Line2D.new()
		gl.material = mat
		# Width decreases from outermost to innermost
		gl.width = surface_glow_width * (layer_count - i)
		gl.default_color = Color(
			surface_glow_color.r,
			surface_glow_color.g,
			surface_glow_color.b,
			_GLOW_ALPHAS[i]
		)
		gl.begin_cap_mode = Line2D.LINE_CAP_ROUND
		gl.end_cap_mode = Line2D.LINE_CAP_ROUND
		add_child(gl)
		_glow_lines.append(gl)

	_start_glow_pulse()

func _start_glow_pulse() -> void:
	if _glow_tween and _glow_tween.is_valid():
		_glow_tween.kill()
	if _glow_lines.is_empty():
		return
	var half: float = 1.0 / max(surface_glow_pulse_speed, 0.1)
	_glow_tween = create_tween().set_loops()
	_glow_tween.tween_method(_set_glow_alpha, 0.5, 1.0, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_glow_tween.tween_method(_set_glow_alpha, 1.0, 0.5, half) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_glow_alpha(alpha: float) -> void:
	for gl in _glow_lines:
		if is_instance_valid(gl):
			gl.modulate.a = alpha

func update_visuals() -> void:
	super.update_visuals()
	if surface_line == null or _glow_lines.is_empty():
		return
	for gl in _glow_lines:
		if is_instance_valid(gl):
			gl.points = surface_line.points

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

# ── entry blink ────────────────────────────────────────────────────────────

func _blink_entry(player: Player) -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
	_blink_tween = create_tween()
	var half: float = blink_duration * 0.5
	for i in range(blink_count):
		_blink_tween.tween_property(player.player_sprite, "modulate", blink_color, half)
		_blink_tween.tween_property(player.player_sprite, "modulate", Color.WHITE, half)

func _cancel_blink(player: Player) -> void:
	if _blink_tween and _blink_tween.is_valid():
		_blink_tween.kill()
		_blink_tween = null
	if is_instance_valid(player):
		player.player_sprite.modulate = Color.WHITE

# ── water body callbacks ───────────────────────────────────────────────────

func _on_body_entered(body: Node2D) -> void:
	super._on_body_entered(body)
	if body is Player and _heal_timer:
		_current_healing_player = body
		sound_manager.play("Heal")
		_heal_timer.wait_time = heal_interval
		_heal_timer.start()
		_apply_player_aura(body)
		_blink_entry(body)

func _on_body_exited(body: Node2D) -> void:
	super._on_body_exited(body)
	if body is Player and body == _current_healing_player:
		_cancel_blink(body)
		_remove_player_aura(body)
		_current_healing_player = null
		if _heal_timer:
			_heal_timer.stop()

func _on_heal_tick() -> void:
	if _current_healing_player == null or not is_instance_valid(_current_healing_player):
		_heal_timer.stop()
		return
	_current_healing_player.heal(heal_amount)
