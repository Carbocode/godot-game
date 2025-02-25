class_name Sun extends DirectionalLight3D

# Costanti
const MIN_ELEVATION: float = deg_to_rad(-6) # Crepuscolo civile
const MAX_ELEVATION: float = deg_to_rad(40) # Pieno giorno
const E: float = deg_to_rad(23.4397)

# Variabili esportate
@export var sky_material: ShaderMaterial

# Funzioni base
func _ready() -> void:
	EventBus.subscribe("time_updated", Callable(self, "_on_time_updated"))
	_on_time_updated(DateTime.enlapsed_seconds)

func _on_time_updated(timestamp: int) -> void:
	var solar_position: Dictionary = get_sun_position(timestamp, Geolocation.latitude, Geolocation.longitude)
	var sun_direction: Vector3 = _calculate_sun_direction(solar_position)
	_update_sun_and_sky(sun_direction, solar_position.altitude)
	#_debug_print(solar_position)

func _calculate_sun_direction(solar_position: Dictionary) -> Vector3:
	var el: float = solar_position.altitude
	var az: float = solar_position.azimuth
	return Vector3(
		sin(az) * cos(el),
		sin(el),
		cos(az) * cos(el)
	)

func right_ascension(l: float, b: float) -> float:
	return atan2(sin(l) * cos(E) - tan(b) * sin(E), cos(l))

func declination(l: float, b: float) -> float:
	return asin(sin(b) * cos(E) + cos(b) * sin(E) * sin(l))

func azimuth(H: float, phi: float, dec: float) -> float:
	return atan2(sin(H), cos(H) * sin(phi) - tan(dec) * cos(phi))

func altitude(H: float, phi: float, dec: float) -> float:
	return asin(sin(phi) * sin(dec) + cos(phi) * cos(dec) * cos(H))

func sidereal_time(d: float, lw: float) -> float:
	return deg_to_rad(280.16 + 360.9856235 * d) - lw

func solar_mean_anomaly(d: float) -> float:
	return deg_to_rad(357.5291 + 0.98560028 * d)

func ecliptic_longitude(M: float) -> float:
	var C: float = deg_to_rad(1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M))
	var P: float =  deg_to_rad(102.9372)
	return M + C + P + PI

func sun_coords(d: float) -> Dictionary:
	var M: float = solar_mean_anomaly(d)
	var L: float = ecliptic_longitude(M)
	return {
		"dec": declination(L, 0),
		"ra": right_ascension(L, 0)
	}

func astro_refraction(h: float) -> float:
	if h < 0:
		h = 0
	return 0.0002967 / tan(h + 0.00312536 / (h + 0.08901179))

func get_sun_position(date: int, lat: float, lng: float) -> Dictionary:
	var lw: float = deg_to_rad(-lng)
	var phi: float = deg_to_rad(lat)
	var d: float = DateTime.to_days(date)
	
	var c: Dictionary = sun_coords(d)
	var H: float = sidereal_time(d, lw) - c.ra
	
	return {
		"azimuth": azimuth(H, phi, c.dec),
		"altitude": altitude(H, phi, c.dec)
	}

func _update_sun_and_sky(sun_direction: Vector3, elevation: float) -> void:
	# Aggiorna posizione sole
	global_transform = global_transform.looking_at(global_position - sun_direction, Vector3.UP)
	
	# Aggiorna materiale cielo
	if sky_material:
		sky_material.set_shader_parameter("sun_direction", sun_direction)
		var day_factor: float = clampf(inverse_lerp(MIN_ELEVATION, MAX_ELEVATION, elevation),0.0, 1.0)
		sky_material.set_shader_parameter("day_factor", day_factor)

func _debug_print(solar_position: Dictionary) -> void:
	print("Solar Position - Altitude: %f, Azimuth: %f" % [
		rad_to_deg(solar_position.altitude),
		rad_to_deg(solar_position.azimuth)
	])
