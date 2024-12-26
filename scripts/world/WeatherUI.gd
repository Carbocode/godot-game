extends Control

# Sliders
@onready var fog_density_slider: HSlider = $Fog/Density/HSlider
@onready var fog_decay_slider: HSlider = $Fog/Decay/HSlider
@onready var fog_altitude_slider: HSlider = $Fog/Altitude/HSlider

@onready var clouds_height_slider: HSlider = $Clouds/Height/HSlider
@onready var clouds_thickness_slider: HSlider = $Clouds/Thickness/HSlider
@onready var clouds_density_slider: HSlider = $Clouds/Density/HSlider

@onready var wind_speed_slider: HSlider = $Wind/Speed/HSlider
@onready var wind_direction_slider: HSlider = $Wind/Direction/HSlider

@onready var sun_rotation_slider: HSlider = $Sun/Rotation/HSlider
@onready var atmosphere_temperature_slider: HSlider = $Sun/Temperature/HSlider

# Values (Label)
@onready var fog_density_value: Label = $Fog/Density/Value
@onready var fog_decay_value: Label = $Fog/Decay/Value
@onready var fog_altitude_value: Label = $Fog/Altitude/Value

@onready var clouds_height_value: Label = $Clouds/Height/Value
@onready var clouds_thickness_value: Label = $Clouds/Thickness/Value
@onready var clouds_density_value: Label = $Clouds/Density/Value

@onready var wind_speed_value: Label = $Wind/Speed/Value
@onready var wind_direction_value: Label = $Wind/Direction/Value

@onready var sun_rotation_value: Label = $Sun/Rotation/Value
@onready var atmosphere_temperature_value: Label = $Sun/Temperature/Value

# Weather System
var weather_system: Node3D = null

func _ready():
	# Trova il nodo WeatherSystem nella scena principale
	weather_system = get_node("../Weather")
	
	_setup_sliders()
	_setup_connections()
	_init_labels()
	
func _setup_sliders():
	fog_density_slider.min_value = 0.0
	fog_density_slider.max_value = 100.0
	fog_density_slider.step = 1

	fog_decay_slider.min_value = 0.1
	fog_decay_slider.max_value = 10.0
	fog_decay_slider.step = 0.1

	fog_altitude_slider.min_value = 0
	fog_altitude_slider.max_value = 1000
	fog_decay_slider.step = 1

	clouds_height_slider.min_value = 1000
	clouds_height_slider.max_value = 12000
	clouds_height_slider.step = 1

	clouds_thickness_slider.min_value = 50
	clouds_thickness_slider.max_value = 8000
	clouds_thickness_slider.step = 10

	clouds_density_slider.min_value = 0
	clouds_density_slider.max_value = 100.
	clouds_density_slider.step = 1

	wind_speed_slider.min_value = 0.0
	wind_speed_slider.max_value = 20.0
	wind_speed_slider.step = 0.1

	wind_direction_slider.min_value = 0
	wind_direction_slider.max_value = 360
	wind_direction_slider.step = 1

	sun_rotation_slider.min_value = 0
	sun_rotation_slider.max_value = 360
	sun_rotation_slider.step = 1

	atmosphere_temperature_slider.min_value = -20
	atmosphere_temperature_slider.max_value = 50
	atmosphere_temperature_slider.step = 1

func _setup_connections():
	fog_density_slider.connect("value_changed", Callable(self, "_on_fog_density_changed"))
	fog_decay_slider.connect("value_changed", Callable(self, "_on_fog_decay_changed"))
	fog_altitude_slider.connect("value_changed", Callable(self, "_on_fog_altitude_changed"))

	clouds_height_slider.connect("value_changed", Callable(self, "_on_clouds_height_changed"))
	clouds_thickness_slider.connect("value_changed", Callable(self, "_on_clouds_thickness_changed"))
	clouds_density_slider.connect("value_changed", Callable(self, "_on_clouds_density_changed"))

	wind_speed_slider.connect("value_changed", Callable(self, "_on_wind_speed_changed"))
	wind_direction_slider.connect("value_changed", Callable(self, "_on_wind_direction_changed"))

	sun_rotation_slider.connect("value_changed", Callable(self, "_on_sun_rotation_changed"))
	atmosphere_temperature_slider.connect("value_changed", Callable(self, "_on_atmosphere_temperature_changed"))

## Aggiorna tutte le label con i valori iniziali degli slider
func _init_labels():
	_on_fog_density_changed(fog_density_slider.value)
	_on_fog_decay_changed(fog_decay_slider.value)
	_on_fog_altitude_changed(fog_altitude_slider.value)

	_on_clouds_height_changed(clouds_height_slider.value)
	_on_clouds_thickness_changed(clouds_thickness_slider.value)
	_on_clouds_density_changed(clouds_density_slider.value)

	_on_wind_speed_changed(wind_speed_slider.value)
	_on_wind_direction_changed(wind_direction_slider.value)

	_on_sun_rotation_changed(sun_rotation_slider.value)
	_on_atmosphere_temperature_changed(atmosphere_temperature_slider.value)

# Metodi per aggiornare le label e il WeatherSystem
func _on_fog_density_changed(value: float):
	fog_density_value.text = str(value) + "%"
	if weather_system:
		weather_system.volumetric_fog_density = value

func _on_fog_decay_changed(value: float):
	fog_decay_value.text = str(value) + "%"
	if weather_system:
		weather_system.volumetric_fog_decay = value

func _on_fog_altitude_changed(value: float):
	fog_altitude_value.text = str(value) + "m"
	if weather_system:
		weather_system.volumetric_fog_altitude = value

func _on_clouds_height_changed(value: float):
	clouds_height_value.text = str(value) + "m"
	if weather_system:
		print(value)
		weather_system.clouds_height = value

func _on_clouds_thickness_changed(value: float):
	clouds_thickness_value.text = str(value) + "m"
	if weather_system:
		weather_system.clouds_thickness = value

func _on_clouds_density_changed(value: float):
	clouds_density_value.text = str(value) + "%"
	if weather_system:
		weather_system.clouds_density = value

func _on_wind_speed_changed(value: float):
	wind_speed_value.text = str(value) + " m/s"
	if weather_system:
		weather_system.wind_speed = value

func _on_wind_direction_changed(value: float):
	wind_direction_value.text = str(value) + "°"
	if weather_system:
		weather_system.wind_direction = value

func _on_sun_rotation_changed(value: float):
	sun_rotation_value.text = str(value) + "°"
	if weather_system:
		weather_system.sun_rotation = value

func _on_atmosphere_temperature_changed(value: float):
	atmosphere_temperature_value.text = str(value) + "°C"
	if weather_system:
		weather_system.atmosphere_temperature = value
