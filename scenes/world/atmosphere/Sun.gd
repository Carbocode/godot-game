class_name Sun extends DirectionalLight3D

const EARTH_ANGLE: float = deg_to_rad(23.44)
const FULL_CIRCLE: float = 2 * PI

@export var time_node_path: NodePath # Percorso al nodo Time

var time_node: DateTime

var _cached_day: int = -1
var _cached_equation_of_time: float = 0.0

func _ready() -> void:
	# Trova il nodo Time
	if time_node_path:
		time_node = get_node(time_node_path)
		# Collegati al segnale time_updated
		time_node.time_updated.connect(_on_time_updated)
		# Imposta la rotazione iniziale
		_on_time_updated()

func _on_time_updated() -> void:
	# Ottieni la posizione solare
	var solar_position: Dictionary = get_solar_position(latitude, longitude)
	var elevation: float = solar_position["elevation"] # In radianti
	var azimuth: float = solar_position["azimuth"] # In radianti
	
	
	# Calcola il vettore direzionale del sole
	var direction: Vector3 = Vector3(
		sin(azimuth) * cos(elevation),
		sin(elevation),
		cos(azimuth) * cos(elevation)
	)
	
	# Usa look_at() invece della rotazione diretta
	global_transform = global_transform.looking_at(global_position - direction, Vector3.UP)
	
	print("Solar Position - Elevation: %f, Azimuth: %f" % [
		rad_to_deg(elevation),
		rad_to_deg(azimuth)
	])

# Funzione per calcolare la declinazione del Sole
func get_declination(day_of_year_from_equinox: float) -> float:
	return EARTH_ANGLE * sin(FULL_CIRCLE / DateTime.DAYS_IN_YEAR * day_of_year_from_equinox)

func get_solar_position(latitude: float, longitude: float) -> Dictionary:
	latitude = clampf(latitude, -90.0, 90.0)
	longitude = fmod(longitude + 180.0, 360.0) - 180.0
	
	# Ottieni data e ora
	var date: Dictionary = time_node.get_current_datetime()
	var year: int = date.year
	var month: int = date.month
	var day: int = date.day
	
	# Calcolo del giorno giuliano
	var julian_day: float = time_node.get_julian_day(year, month, day)
	var day_of_year_from_equinox: float = time_node.get_day_of_year_from_equinox(julian_day)
	
	# Cache dei calcoli giornalieri
	if day != _cached_day:
		_cached_equation_of_time = time_node.get_equation_of_time(day_of_year_from_equinox)
		_cached_day = day
	
	var declination: float = get_declination(day_of_year_from_equinox) # Converti in radianti
	
	var time: float = date.hour + date.minute / 60.0 + date.second / 3600.0
	
	# Calcolo del tempo solare
	var solar_time: float = time + longitude / 15.0 + _cached_equation_of_time / 60.0
	
	# Calcolo dell'angolo orario
	var hour_angle: float = deg_to_rad(15.0 * (solar_time - 12.0)) # Converti in radianti
	
	# Calcolo dell'elevazione
	var lat_rad: float = deg_to_rad(latitude)
	var elevation: float = asin(sin(lat_rad) * sin(declination) + cos(lat_rad) * cos(declination) * cos(hour_angle))
	
	# Calcolo dell'azimut
	# Calcolo dell'azimut con gestione speciale per i poli
	var azimuth: float
	
	# Gestione speciale per i poli (o quasi-poli)
	if abs(latitude) > 89.9: # Siamo molto vicini ai poli
		# Al polo sud, il sole si muove in senso orario
		if latitude < 0:
			azimuth = -hour_angle
		# Al polo nord, il sole si muove in senso antiorario
		else:
			azimuth = hour_angle
	else:
		# Calcolo standard dell'azimut per altre latitudini
		var sin_azimuth: float = cos(declination) * sin(hour_angle) / cos(elevation)
		var cos_azimuth: float = (sin(elevation) * sin(lat_rad) - sin(declination)) / (cos(elevation) * cos(lat_rad))
		azimuth = atan2(sin_azimuth, cos_azimuth)
		
		# Correzione più semplice: assicuriamoci che l'azimut sia relativo al nord
		azimuth = PI + azimuth
		
	# Normalizzazione base tra 0 e 2π
	if azimuth < 0:
		azimuth += DateTime.FULL_CIRCLE
	else:
		while azimuth >= DateTime.FULL_CIRCLE:
			azimuth = fmod(azimuth, DateTime.FULL_CIRCLE)
	
	return {"elevation": elevation, "azimuth": azimuth}
