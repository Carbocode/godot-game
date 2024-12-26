extends Node3D

# Parametri per il ciclo giorno/notte
var day_duration: float = 30.0  # Durata del giorno in secondi

func _process(delta: float) -> void:
	#update_sun_position(delta)
	pass
	
func update_sun_position(delta: float) -> void:
	# Incrementa la rotazione del sole in base al tempo
	var rotation_step: float = 360.0 / day_duration * delta
	sun_rotation += rotation_step

	# Applica la rotazione al sole
	if sun:
		sun.rotation_degrees.x = sun_rotation

	# Debug: Stampa la rotazione del sole
	print("Sun rotation:", sun_rotation)

	# Simula l'illuminazione in base alla posizione del sole
	#adjust_lighting()

func adjust_lighting() -> void:
	if sun:
		# Alba e tramonto: Colore rossastro
		if sun_rotation > 180:  # Tramonto
			sun.light_color = Color(1.0, 0.5, 0.3)
			sun.light_energy = 0.0
		elif sun_rotation < 30:  # Alba
			sun.light_energy = 1.0
			sun.light_color = Color(1.0, 0.8, 0.6)
		else:  # Mezzogiorno: Colore bianco
			sun.light_energy = 1.0
			sun.light_color = Color(1.0, 1.0, 1.0)

		# Intensità della luce diminuisce durante la notte
		if sun_rotation > 180 or sun_rotation < 30:
			sun.light_energy = 0.5  # Luce fioca
		else:
			sun.light_energy = 1.0  # Luce piena

# Fog
#@onready var fog_volume: FogVolume = $VolumetricFog  # Nodo FogVolume nella scena

var volumetric_fog_density: float = 0.0:
	get:
		return volumetric_fog_density
	set(value):
		volumetric_fog_density = value

var volumetric_fog_decay: float = 1.0:
	get:
		return volumetric_fog_decay
	set(value):
		volumetric_fog_decay = value

var volumetric_fog_altitude: float = 0.0:
	get:
		return volumetric_fog_altitude
	set(value):
		volumetric_fog_altitude = value

# Clouds settings
@onready var clouds: GPUParticles3D = $Clouds

var clouds_height: float = 1000.0:
	get:
		return clouds_height
	set(value):
		print(value)
		clouds_height = value
		
var clouds_thickness: float = 100.0:
	get:
		return clouds_thickness
	set(value):
		clouds_thickness = value
		
var clouds_density: float = 0.0:
	get:
		return clouds_density
	set(value):
		clouds_density = value

# Wind settings
@onready var wind: Node = $Wind

var wind_speed: float = 0.0:
	get:
		return wind_speed
	set(value):
		wind_speed = value
		
var wind_direction: float = 0.0:  # Angolo in gradi (0-360)
	get:
		return wind_direction
	set(value):
		wind_direction = value

# Sun settings
@onready var sun: DirectionalLight3D = $Sun

var sun_rotation: float = 0.1:  # 0 = fermo, 1 = giorno completo in un secondo
	get:
		return sun_rotation
	set(value):
		sun_rotation = wrapf(value, 0, 360)
		
var atmosphere_temperature: float = 20:  # Temperatura del sole (in Kelvin)
	get:
		return atmosphere_temperature
	set(value):
		atmosphere_temperature = value
