class_name FactScene
extends Control

@export_file("*.tscn") var next_scene_path: String = ""
@export var fade_duration: float = UiConstants.DEFAULT_FADE_DURATION
@export var return_to_home: bool = false
@export var return_to_home_delay: float = 5.0

const DESIGN_SIZE := Vector2(1280.0, 720.0)

var _comics: Array[Comic] = []
var _next_screen: ActionButton
var _auto_redirect_started: bool = false

func _ready() -> void:
	set_anchors_preset(Control.PRESET_TOP_LEFT)
	size = DESIGN_SIZE
	_fit_canvas()
	get_viewport().size_changed.connect(_fit_canvas)

	utils.fade_from_overlay(fade_duration)
	_wire_button("NextScreen", next_scene_path)
	_next_screen = get_node_or_null("%NextScreen")
	if _next_screen:
		_next_screen.visible = false
	_start_comic_sequence()

func _fit_canvas() -> void:
	var vp := get_viewport_rect().size
	var s := minf(vp.x / DESIGN_SIZE.x, vp.y / DESIGN_SIZE.y)
	scale = Vector2(s, s)
	position = (vp - DESIGN_SIZE * s) / 2.0

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		for comic in _comics:
			if not comic.visible:
				comic.fade_in()
				_check_sequence_complete()
				break

func _start_comic_sequence() -> void:
	for child in get_children():
		if child is Comic:
			_comics.append(child)
	_comics.sort_custom(func(a: Comic, b: Comic) -> bool: return a.sequence < b.sequence)
	for comic in _comics:
		get_tree().create_timer(comic.duration).timeout.connect(func() -> void:
			comic.fade_in()
			_check_sequence_complete()
		)

func _check_sequence_complete() -> void:
	for comic in _comics:
		if not comic.visible:
			return
	if return_to_home:
		if not _auto_redirect_started:
			_auto_redirect_started = true
			get_tree().create_timer(return_to_home_delay).timeout.connect(func() -> void:
				_change_scene(next_scene_path)
			)
		return
	if _next_screen:
		_next_screen.visible = true

func _wire_button(unique_name: String, scene_path: String) -> void:
	var button: ActionButton = get_node_or_null("%" + unique_name)
	if not button:
		return
	button.pressed.connect(_change_scene.bind(scene_path))

func _change_scene(path: String) -> void:
	if path.is_empty():
		push_warning("%s is missing a scene path." % name)
		return

	var resolved_scene_path: String = ResourceUID.ensure_path(path)
	if resolved_scene_path.is_empty():
		push_warning("%s could not resolve scene path: %s" % [name, path])
		return

	sound_manager.play("EnterGame")
	await utils.fade_to_white(self, fade_duration)
	get_tree().change_scene_to_file(resolved_scene_path)
