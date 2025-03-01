@tool
class_name WaveCascadeParameters extends Resource

signal scale_changed

@export var tile_length: Vector2 = Vector2(50, 50): set = _set_tile_length
@export_range(0, 2) var displacement_scale: float = 1.0: set = _set_displacement_scale
@export_range(0, 2) var normal_scale: float = 1.0: set = _set_normal_scale
@export var wind_speed: float = 20.0: set = _set_wind_speed
@export_range(-360, 360) var wind_direction: float = 0.0: set = _set_wind_direction
@export var fetch_length: float = 550.0: set = _set_fetch_length
@export_range(0, 2) var swell: float = 0.8: set = _set_swell
@export_range(0, 1) var spread: float = 0.2: set = _set_spread
@export_range(0, 1) var detail: float = 1.0: set = _set_detail
@export_range(0, 2) var whitecap: float = 0.5: set = _set_whitecap
@export_range(0, 10) var foam_amount: float = 5.0: set = _set_foam_amount

var spectrum_seed: Vector2i = Vector2i.ZERO
var should_generate_spectrum: bool = true

var time: float
var foam_grow_rate: float
var foam_decay_rate: float

var _tile_length = [tile_length.x, tile_length.y]
var _displacement_scale = [displacement_scale]
var _normal_scale = [normal_scale]
var _wind_speed = [wind_speed]
var _wind_direction = [deg_to_rad(wind_direction)]
var _fetch_length = [fetch_length]
var _swell = [swell]
var _detail = [detail]
var _spread = [spread]
var _whitecap = [whitecap]
var _foam_amount = [foam_amount]

func _set_tile_length(value: Vector2) -> void:
	tile_length = value
	should_generate_spectrum = true
	_tile_length = [value.x, value.y]
	scale_changed.emit()

func _set_displacement_scale(value: float) -> void:
	displacement_scale = value
	_displacement_scale = [value]
	scale_changed.emit()

func _set_normal_scale(value: float) -> void:
	normal_scale = value
	_normal_scale = [value]
	scale_changed.emit()

func _set_wind_speed(value: float) -> void:
	wind_speed = max(0.0001, value)
	should_generate_spectrum = true
	_wind_speed = [wind_speed]

func _set_wind_direction(value: float) -> void:
	wind_direction = value
	should_generate_spectrum = true
	_wind_direction = [deg_to_rad(value)]

func _set_fetch_length(value: float) -> void:
	fetch_length = max(0.0001, value)
	should_generate_spectrum = true
	_fetch_length = [fetch_length]

func _set_swell(value: float) -> void:
	swell = value
	should_generate_spectrum = true
	_swell = [value]

func _set_spread(value: float) -> void:
	spread = value
	should_generate_spectrum = true
	_spread = [value]

func _set_detail(value: float) -> void:
	detail = value
	should_generate_spectrum = true
	_detail = [value]

func _set_whitecap(value: float) -> void:
	whitecap = value
	should_generate_spectrum = true
	_whitecap = [value]

func _set_foam_amount(value: float) -> void:
	foam_amount = value
	should_generate_spectrum = true
	_foam_amount = [value]
