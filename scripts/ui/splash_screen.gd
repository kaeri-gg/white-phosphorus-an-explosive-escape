class_name SplashScreen
extends Control

const GAME_MENU_PATH := "uid://4ht2ox1qqc7q"

@export var fade_in_time: float = 1.5
@export var hold_time: float = 0.5
@export var fade_out_time: float = 1.5
@export var scene_fade_duration: float = UiConstants.DEFAULT_FADE_DURATION

@onready var logo_container: MarginContainer = %Logo
@onready var godot_teeth: TextureRect = %GodotTeeth
@onready var logo: TextureRect = %GodotLogo
@onready var progress_bar: ProgressBar = $Logo/ProgressBar/ProgressBar

func _ready() -> void:
	progress_bar.min_value = 0.0
	progress_bar.max_value = 100.0
	progress_bar.value = 0.0
	ResourceLoader.load_threaded_request(GAME_MENU_PATH)
	yoyo()
	_animate_progress()
	_play_intro()

func _animate_progress() -> void:
	var tween := create_tween()
	tween.tween_property(progress_bar, "value", 100.0, fade_in_time + hold_time)

func _play_intro() -> void:
	logo_container.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(logo_container, "modulate:a", 1.0, fade_in_time)
	tween.tween_interval(hold_time)
	tween.tween_property(logo_container, "modulate:a", 0.0, fade_out_time)
	await tween.finished
	while ResourceLoader.load_threaded_get_status(GAME_MENU_PATH) != ResourceLoader.THREAD_LOAD_LOADED:
		await get_tree().process_frame
	var scene: PackedScene = ResourceLoader.load_threaded_get(GAME_MENU_PATH)
	await utils.fade_to_white(self, scene_fade_duration)
	get_tree().change_scene_to_packed(scene)

func yoyo() -> void:
	var speed := 0.1
	var wide := 10.0
	var tween := create_tween().set_loops()
	tween.tween_property(godot_teeth, "position:y", wide, speed).as_relative()
	tween.tween_property(godot_teeth, "position:y", -wide, speed).as_relative()
