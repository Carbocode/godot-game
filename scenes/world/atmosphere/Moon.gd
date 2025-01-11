extends DirectionalLight3D
class_name Moon

@export var sky_material: ShaderMaterial

# Funzione di callback per l'evento "time_updated"
func _on_time_updated(timestamp: int) -> void:
	# Ottieni la posizione attuale dal Geolocation
	var latitude = Geolocation.latitude
	var longitude = Geolocation.longitude

	# Ottieni la data e ora corrente in UTC
	var date = DateTime.get_datetime(timestamp)

	# Calcola la posizione della Luna
	var moon_position = get_moon_position(date, latitude, longitude)

	# Calcola la direzione della Luna
	var moon_direction = _calculate_moon_direction(moon_position)

	# Aggiorna la posizione della Luna e il materiale del cielo
	_update_moon_and_sky(moon_direction)

	# Stampa la posizione della Luna per debug
	_debug_print(moon_position)

# Funzione chiamata al readiness del nodo
func _ready() -> void:
	EventBus.subscribe("time_updated", Callable(self, "_on_time_updated"))
	_on_time_updated(DateTime.enlapsed_seconds)

# Funzione per calcolare i parametri principali della Luna
func calculate_lunar_parameters(jd: float, T: float) -> Dictionary:
	var L = fposmod(218.316 + 13.176396 * (jd - 2451545.0), 360.0)
	var M = fposmod(134.963 + 13.064993 * (jd - 2451545.0), 360.0)
	var M_prime = fposmod(93.272 + 13.229350 * (jd - 2451545.0), 360.0)
	var e = 1.0 - 0.002516 * T - 0.0000074 * T * T
	return {"L": L, "M": M, "M_prime": M_prime, "e": e}

# Funzione per calcolare le coordinate eclittiche della Luna
func calculate_ecliptic_coordinates(params: Dictionary, jd: float) -> float:
	var C = (6.289 * sin(deg_to_rad(params["M_prime"]))) + (1.274 * sin(deg_to_rad(2 * (jd - 2451545.0) + params["M_prime"]))) + (0.658 * sin(deg_to_rad(2 * (jd - 2451545.0) - params["M_prime"]))) + (0.214 * sin(deg_to_rad(2 * params["M"]))) + (0.11 * sin(deg_to_rad(jd - 2451545.0)))

	var true_long = params["L"] + C
	var omega = 125.04 - 0.052954 * (jd - 2451545.0)
	var lambda_ = true_long - 0.00569 - 0.00478 * sin(deg_to_rad(omega))

	return lambda_

# Funzione per calcolare le coordinate equatoriali della Luna
func calculate_equatorial_coordinates(lambda_: float, epsilon: float) -> Dictionary:
	var decl = asin(sin(deg_to_rad(epsilon)) * sin(deg_to_rad(lambda_)))
	decl = rad_to_deg(decl)

	var RA = atan2(cos(deg_to_rad(epsilon)) * sin(deg_to_rad(lambda_)), cos(deg_to_rad(lambda_)))
	RA = rad_to_deg(RA)
	RA = fposmod(RA, 360.0)
	return {"declination": decl, "RA": RA}

# Funzione per calcolare l'angolo orario (Hour Angle)
func calculate_hour_angle(LST: float, longitude: float, RA: float) -> float:
	return fposmod(LST - RA, 360.0)

# Funzione per calcolare l'altitudine e l'azimut
func calculate_alt_az(latitude: float, decl: float, H: float) -> Dictionary:
	var lat_rad = deg_to_rad(latitude)
	var decl_rad = deg_to_rad(decl)
	var H_rad = deg_to_rad(H)

	var sin_alt = sin(lat_rad) * sin(decl_rad) + cos(lat_rad) * cos(decl_rad) * cos(H_rad)
	var alt = asin(sin_alt)
	alt = rad_to_deg(alt)

	var cos_az = (sin(decl_rad) - sin(lat_rad) * sin(deg_to_rad(alt))) / (cos(lat_rad) * cos(deg_to_rad(alt)))
	cos_az = clamp(cos_az, -1.0, 1.0)  # Evita errori numerici
	var az = acos(cos_az)
	az = rad_to_deg(az)

	if sin(H_rad) > 0:
		az = 360.0 - az

	return {"elevation": alt, "azimuth": az}

# Funzione per calcolare la distanza della Luna
func calculate_moon_distance(d: float) -> float:
	var M = deg_to_rad(134.963 + 13.064993 * d)     # Anomalia media Luna
	var D = deg_to_rad(297.850 + 12.19074912 * d)   # Elongazione media

	# Distanza media della Luna (in km)
	var distance = 385000.56 

	# Correzioni principali
	distance += -20905.355 * cos(M)                 # Variazione ellittica
	distance += -3699.111 * cos(2 * D - M)          # Variazione evection
	distance += -2955.968 * cos(2 * D)              # Variazione annuale
	distance += -569.925 * cos(2 * M)               # Prima variazione
	distance += -48.888 * cos(2 * D + M)
	
	return distance  # in chilometri

# Funzione principale per ottenere la posizione della Luna
func get_moon_position(date: Dictionary, latitude: float, longitude: float) -> Dictionary:
	var jd = DateTime.get_julian_date(date)
	var T = (jd - 2451545.0) / 36525.0

	var params = calculate_lunar_parameters(jd, T)
	var lambda_ = calculate_ecliptic_coordinates(params, jd)

	var epsilon = 23.439292 - (0.0130042 * T) - (0.0130042 * pow(T, 2)) + (0.000000504 * pow(T, 3))
	var equatorial = calculate_equatorial_coordinates(lambda_, epsilon)

	# Utilizza la funzione migliorata per ottenere LST
	var lst = DateTime.get_sidereal_time(jd, date.hour, date.minute, longitude)
	var H = calculate_hour_angle(lst, longitude, equatorial["RA"])

	var alt_az = calculate_alt_az(latitude, equatorial["declination"], H)

	# Calcola la distanza della Luna
	var distance = calculate_moon_distance(jd - 2451545.0)

	return {
		"elevation": deg_to_rad(alt_az["elevation"]),
		"azimuth": deg_to_rad(alt_az["azimuth"]),
		"distance": distance  # Distanza in chilometri
	}

# Funzione per calcolare la direzione della Luna in base all'elevazione e azimut
func _calculate_moon_direction(moon_position: Dictionary) -> Vector3:
	var elevation: float = moon_position["elevation"]
	var azimuth: float = moon_position["azimuth"]
	return Vector3(
		sin(azimuth) * cos(elevation),
		sin(elevation),
		cos(azimuth) * cos(elevation)
	)

# Funzione per aggiornare la posizione della Luna e il materiale del cielo
func _update_moon_and_sky(moon_direction: Vector3) -> void:
	# Aggiorna la direzione della luce direzionale usando look_at
	global_transform = global_transform.looking_at(global_position - moon_direction, Vector3.UP)

	# Aggiorna materiale cielo
	if sky_material:
		sky_material.set_shader_parameter("moon_direction", moon_direction)

# Funzione di debug per stampare la posizione della Luna
func _debug_print(moon_position: Dictionary) -> void:
	print("Moon Position - Elevation: %f°, Azimuth: %f°, Distance: %f km" % [
		rad_to_deg(moon_position["elevation"]),
		rad_to_deg(moon_position["azimuth"]),
		moon_position["distance"]
	])
