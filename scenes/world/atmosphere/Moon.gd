class_name Moon extends DirectionalLight3D

@export var time_node_path: NodePath # Percorso al nodo Time

var time_node: DateTime

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
	var moon_position: Dictionary = get_moon_position(latitude, longitude)
	var elevation: float = moon_position["elevation"] # In radianti
	var azimuth: float = moon_position["azimuth"] # In radianti
	
	
	# Calcola il vettore direzionale del sole
	var direction: Vector3 = Vector3(
		sin(azimuth) * cos(elevation),
		sin(elevation),
		cos(azimuth) * cos(elevation)
	)
	
	# Usa look_at() invece della rotazione diretta
	global_transform = global_transform.looking_at(global_position - direction, Vector3.UP)
	
	print("Moon Position - Elevation: %f, Azimuth: %f" % [
		rad_to_deg(elevation),
		rad_to_deg(azimuth)
	])

# Funzione per calcolare elevazione e azimut della Luna
func get_moon_position(latitude: float, longitude: float) -> Dictionary:
	var lat: float = clampf(latitude, -90.0, 90.0)
	var long: float = fmod(longitude + 180.0, 360.0) - 180.0

	# Ottieni data e ora
	var date: Dictionary = time_node.get_current_datetime()
	var year: int = date.year
	var month: int = date.month
	var day: int = date.day

	# Calcolo del Giorno Giuliano
	var jd: float = time_node.get_julian_day(year, month, day)
	var T: float = (jd - 2451545.0) / 36525 # Secolo giuliano

	# Coordinate lunari geocentriche approssimate
	var L: float = deg_to_rad(218.316 + 13.176396 * (jd - 2451545.0)) # Longitudine media
	var M: float = deg_to_rad(134.963 + 13.064993 * (jd - 2451545.0)) # Anomalia media
	var F: float = deg_to_rad(93.272 + 13.229350 * (jd - 2451545.0)) # Argomento della latitudine
	
	# Longitudine eclittica
	var lambda: float = L + deg_to_rad(6.289 * sin(M)) # Perturbazioni principali
	var beta: float = deg_to_rad(5.128 * sin(F)) # Latitudine eclittica

	# Obliquità dell'eclittica
	var epsilon: float = deg_to_rad(23.439 - 0.0000004 * T)

	# Coordinate equatoriali
	var sin_delta: float = sin(beta) * cos(epsilon) + cos(beta) * sin(epsilon) * sin(lambda)
	var delta: float = asin(sin_delta) # Declinazione
	var y: float = sin(lambda) * cos(epsilon) - tan(beta) * sin(epsilon)
	var x: float = cos(lambda)
	var alpha: float = atan2(y, x) # Ascensione retta

	# Tempo siderale locale
	var GST: float = 280.46061837 + 360.98564736629 * (jd - 2451545.0)
	var LST: float = fmod(deg_to_rad(GST + long), TAU)

	# Coordinate orizzontali
	var H: float = fmod((LST - alpha), TAU) # Angolo orario
	var sin_alt: float = sin(deg_to_rad(lat)) * sin(delta) + cos(deg_to_rad(lat)) * cos(delta) * cos(H)
	var alt: float = asin(sin_alt) # Elevazione
	var y_az: float = sin(H)
	var x_az: float = cos(H) * sin(deg_to_rad(lat)) - tan(delta) * cos(deg_to_rad(lat))
	var az: float = atan2(y_az, x_az) + PI # Azimut (da nord verso est)
	return {
		"elevation": rad_to_deg(alt),
		"azimuth": fmod(rad_to_deg(az), 360)
	}