extends Control

@export var player: Player 
@onready var damage_flash: ColorRect = %DamageFlash

@onready var health_bar: TextureRect = $HealthBar

var health_textures: Array[Texture2D] = []

var previous_health: int = -1

func _ready() -> void:
	for i in range(8):
		var path = "res://assets/ui/Healthbar_" + str(i) + "HP.png"

		if ResourceLoader.exists(path):
			health_textures.append(load(path))
		else:
			health_textures.append(null)
	
	health_bar.texture = health_textures[7]

	if player != null:
		previous_health = player.PLAYER_HEALTH
		player.health_changed.connect(update_health_display)

func update_health_display(current: int, max_hp: int) -> void:
	var current_index = clamp(current, 0, health_textures.size() - 1)

	if health_textures[current_index] != null:
		health_bar.texture = health_textures[current_index]
	elif current_index == 0:
		health_bar.texture = null

	if previous_health != -1 and current < previous_health:
		trigger_negative_feedback()

	previous_health = current

func trigger_negative_feedback() -> void:
	flash_screen()
	shake_camera()

func flash_screen() -> void:
	var tween = get_tree().create_tween()
	
	damage_flash.modulate.a = 0.7 
	
	tween.tween_property(damage_flash, "modulate:a", 0.0, 0.4)

func shake_camera() -> void:
	var cam = get_viewport().get_camera_2d()
	
	if cam != null:
		var tween = get_tree().create_tween()
		
		tween.tween_property(cam, "offset", Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.03)
		tween.tween_property(cam, "offset", Vector2(randf_range(-5, 5), randf_range(-5, 5)), 0.03)
		tween.tween_property(cam, "offset", Vector2.ZERO, 0.05)
