class_name SplashScreen
extends Control

const GAME_MENU = preload("uid://4ht2ox1qqc7q")

@export var fade_in_time: float = 1.5
@export var hold_time: float = 0.5
@export var fade_out_time: float = 1.5
@export var scene_fade_duration: float = 0.6

@onready var logo_container: MarginContainer = %Logo
@onready var godot_teeth: TextureRect = %GodotTeeth
@onready var logo: TextureRect = %GodotLogo

func _ready() -> void:
	yoyo()
	_play_intro()

func _play_intro() -> void:
	logo_container.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(logo_container, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(hold_time)
	tween.tween_property(logo_container, "modulate:a", 0.0, fade_out_time)
	await tween.finished
	await utils.fade_to_white(self, scene_fade_duration)
	get_tree().change_scene_to_packed(GAME_MENU)

func yoyo() -> void:
	var speed := 0.1
	var wide := 10.0
	var tween := create_tween().set_loops()
	tween.tween_property(godot_teeth, "position:y", wide, speed).as_relative()
	tween.tween_property(godot_teeth, "position:y", -wide, speed).as_relative()
