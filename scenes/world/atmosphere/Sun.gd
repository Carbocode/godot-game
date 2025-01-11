class_name Sun extends DirectionalLight3D

# Costanti
const MIN_ELEVATION: float = deg_to_rad(-6) # Crepuscolo civile
const MAX_ELEVATION: float = deg_to_rad(40) # Pieno giorno
const EARTH_ANGLE: float = deg_to_rad(23.44) # Obliquità dell'eclittica
const ECCENTRICITY: float = 0.0167 # Eccentricità orbitale
const JULIAN_BASE: float = 2451545.0 # JD di riferimento (1 gennaio 2000 12:00 UTC)

# Variabili esportate
@export var sky_material: ShaderMaterial

# Cache
var _cached_day: int = -1
var _cached_equation_of_time: float = 0.0

# Funzioni base
func _ready() -> void:
	EventBus.subscribe("time_updated", Callable(self, "_on_time_updated"))
	_on_time_updated(DateTime.enlapsed_seconds)

func _on_time_updated(timestamp: int) -> void:
	var solar_position: Dictionary = get_solar_position(Geolocation.latitude, Geolocation.longitude)
	var sun_direction: Vector3 = _calculate_sun_direction(solar_position)
	_update_sun_and_sky(sun_direction, solar_position["elevation"])
	_debug_print(solar_position)

func _calculate_sun_direction(solar_position: Dictionary) -> Vector3:
	var elevation: float = solar_position["elevation"]
	var azimuth: float = solar_position["azimuth"]
	return Vector3(
		sin(azimuth) * cos(elevation),
		sin(elevation),
		cos(azimuth) * cos(elevation)
	)

func get_solar_position(latitude: float, longitude: float) -> Dictionary:
	latitude = clampf(latitude, -90.0, 90.0)
	longitude = fmod(longitude + 180.0, 360.0) - 180.0

	var date: Dictionary = DateTime.get_current_datetime()
	var julian_day: float = DateTime.get_julian_date(date)
	var day_of_year_from_equinox: float = _get_day_of_year_from_equinox(julian_day)

	_update_daily_cache(date.day, day_of_year_from_equinox)

	return _calculate_solar_coordinates(latitude, longitude, date, julian_day)

func _update_daily_cache(current_day: int, day_of_year_from_equinox: float) -> void:
	if current_day != _cached_day:
		_cached_equation_of_time = DateTime.get_equation_of_time(day_of_year_from_equinox)
		_cached_day = current_day

func _calculate_solar_coordinates(latitude: float, longitude: float, date: Dictionary, julian_day: float) -> Dictionary:
	var declination: float = _get_declination(julian_day)
	var solar_time: float = _calculate_solar_time(date, longitude)
	var hour_angle: float = deg_to_rad(15.0 * (solar_time - 12.0))

	var elevation: float = _calculate_elevation(latitude, declination, hour_angle)
	var azimuth: float = _calculate_azimuth(latitude, declination, hour_angle, elevation)

	return {"elevation": elevation, "azimuth": azimuth}

func _get_day_of_year_from_equinox(julian_day: float) -> float:
	return fmod(julian_day - JULIAN_BASE, 365.25)

func _get_declination(julian_day: float) -> float:
	var day_of_year: float = _get_day_of_year_from_equinox(julian_day)
	return EARTH_ANGLE * sin(TAU * day_of_year / 365.25)

func _calculate_solar_time(date: Dictionary, longitude: float) -> float:
	var time: float = date.hour + date.minute / 60.0 + date.second / 3600.0
	return time + longitude / 15.0 + _cached_equation_of_time / 60.0

func _calculate_elevation(latitude: float, declination: float, hour_angle: float) -> float:
	var lat_rad: float = deg_to_rad(latitude)
	return asin(sin(lat_rad) * sin(declination) + cos(lat_rad) * cos(declination) * cos(hour_angle))

func _calculate_azimuth(latitude: float, declination: float, hour_angle: float, elevation: float) -> float:
	var lat_rad: float = deg_to_rad(latitude)
	var sin_azimuth: float = cos(declination) * sin(hour_angle) / cos(elevation)
	var cos_azimuth: float = (sin(elevation) * sin(lat_rad) - sin(declination)) / (cos(elevation) * cos(lat_rad))
	return _normalize_azimuth(atan2(sin_azimuth, cos_azimuth))

func _normalize_azimuth(azimuth: float) -> float:
	if azimuth < 0:
		azimuth += TAU
	return azimuth

func _update_sun_and_sky(sun_direction: Vector3, elevation: float) -> void:
	# Aggiorna posizione sole
	global_transform = global_transform.looking_at(global_position - sun_direction, Vector3.UP)
	
	# Aggiorna materiale cielo
	if sky_material:
		sky_material.set_shader_parameter("sun_direction", sun_direction)
		var day_factor: float = clampf(inverse_lerp(MIN_ELEVATION, MAX_ELEVATION, elevation),0.0, 1.0)
		sky_material.set_shader_parameter("day_factor", day_factor)

func _debug_print(solar_position: Dictionary) -> void:
	print("Solar Position - Elevation: %f, Azimuth: %f" % [
		rad_to_deg(solar_position["elevation"]),
		rad_to_deg(solar_position["azimuth"])
	])
