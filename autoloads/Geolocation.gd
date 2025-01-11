extends Node
# Roma Coordinates
const LONGITUDE: float = -79.1914788
const LATITUDE: float = 43.0399019
const EARTH_RADIUS_KM: float = 6371.0 # Raggio medio della Terra in km

@export var _position: Vector3 = Vector3(LONGITUDE, LATITUDE, 0.0)
var timezone: String 

# Proprietà per la longitudine
@export var longitude: float:
	get:
		return _position.x
	set(value):
		_position.x = value
		EventBus.emit("position_changed", [_position])

# Proprietà per la latitudine
@export var latitude: float:
	get:
		return _position.y
	set(value):
		_position.y = value
		EventBus.emit("position_changed", [_position])

# Proprietà per l'altitudine
@export var altitude: float:
	get:
		return _position.z
	set(value):
		_position.z = value
		EventBus.emit("position_changed", [_position])

# Inizializzazione del Singleton
func _ready() -> void:
	EventBus.register("position_changed")
	print("GeoLocation initialized with position: ", _to_string())

func set_position(new_position: Vector3) -> void:
	_position = new_position
	EventBus.emit("position_changed", [_position])

func set_position_as_vector2(new_position: Vector3) -> void:
	set_position(Vector3(new_position.x, new_position.y, 0.0))
	
# Ottieni la posizione come dizionario (leggibilità migliorata)
func get_position_as_dict() -> Dictionary:
	return {
		"longitude": longitude,
		"latitude": latitude,
		"altitude": altitude
	}

# Calcola la distanza tra la posizione corrente e un'altra
func calculate_distance(target_position: Vector3) -> float:
	return _position.distance_squared_to(target_position)

func calculate_geodesic_distance(position: Vector3) -> float:
	# Converti latitudine e longitudine da gradi a radianti
	var lat1: float = deg_to_rad(_position.y)
	var lon1: float = deg_to_rad(_position.x)
	var lat2: float = deg_to_rad(position.y)
	var lon2: float = deg_to_rad(position.x)

	# Differenze tra le coordinate
	var delta_lat: float = lat2 - lat1
	var delta_lon: float = lon2 - lon1

	# Formula dell'haversine
	var a: float = pow(sin(delta_lat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(delta_lon / 2), 2)
	var c: float = 2 * atan2(sqrt(a), sqrt(1 - a))

	# Distanza in km
	var distance: float = EARTH_RADIUS_KM * c

	# Aggiungi differenza altimetrica (se necessario)
	var delta_alt: float = position.z - _position.z
	return sqrt(pow(distance, 2) + pow(delta_alt / 1000.0, 2)) # Converti altitudine da metri a km

# Resetta la posizione alle coordinate zero
func reset_position() -> void:
	set_position(Vector3(LONGITUDE, LATITUDE, 0.0))

# Stampa la posizione in formato leggibile
func _to_string() -> String:
	return "Latitudine: %s, Longitudine: %s, Altitudine: %s" % [latitude, longitude, altitude]
