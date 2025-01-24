extends DirectionalLight3D
class_name Moon

const E = deg_to_rad(23.4397)

@export var sky_material: ShaderMaterial

# Funzione chiamata al readiness del nodo
func _ready() -> void:
	EventBus.subscribe("time_updated", Callable(self, "_on_time_updated"))
	_on_time_updated(DateTime.enlapsed_seconds)

# Funzione di callback per l'evento "time_updated"
func _on_time_updated(timestamp: int) -> void:
	var moon_position = get_moon_position(timestamp, Geolocation.latitude, Geolocation.longitude)
	var moon_direction = _calculate_moon_direction(moon_position)
	_update_moon_and_sky(moon_direction)
	_debug_print(moon_position)

# Position calculations
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

func astro_refraction(h: float) -> float:
	if h < 0:
		h = 0
	return 0.0002967 / tan(h + 0.00312536 / (h + 0.08901179))

func moon_coords(d: float) -> Dictionary:
	var L = deg_to_rad(218.316 + 13.176396 * d)
	var M = deg_to_rad(134.963 + 13.064993 * d)
	var F = deg_to_rad(93.272 + 13.229350 * d)
	
	var l = L + deg_to_rad(6.289) * sin(M)
	var b = deg_to_rad(5.128) * sin(F)
	var dt = 385001 - 20905 * cos(M)
	
	return {
		"ra": right_ascension(l, b),
		"dec": declination(l, b),
		"dist": dt
	}

func get_moon_position(date: int, lat: float, lng: float) -> Dictionary:
	var lw = deg_to_rad(-lng)
	var phi = deg_to_rad(lat)
	var d = DateTime.to_days(date)
	
	var c = moon_coords(d)
	var H = sidereal_time(d, lw) - c.ra
	var h = altitude(H, phi, c.dec)
	var pa = atan2(sin(H), tan(phi) * cos(c.dec) - sin(c.dec) * cos(H))
	
	h = h + astro_refraction(h)
	
	return {
		"azimuth": azimuth(H, phi, c.dec),
		"altitude": h,
		"distance": c.dist,
		"parallacticAngle": pa
	}

# Funzione per calcolare la direzione della Luna in base all'elevazione e azimut
func _calculate_moon_direction(moon_position: Dictionary) -> Vector3:
	var altitude: float = moon_position.altitude
	var azimuth: float = moon_position.azimuth
	return Vector3(
		sin(azimuth) * cos(altitude),
		sin(altitude),
		cos(azimuth) * cos(altitude)
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
	print("Moon Position - Altitude: %f°, Azimuth: %f°, Distance: %f km" % [
		rad_to_deg(moon_position.altitude),
		rad_to_deg(moon_position.azimuth),
		moon_position.distance
	])
