extends Node

# Roma Coordinates
const LONGITUDE: float = 12.4964
const LATITUDE: float = 41.9028

const EARTH_RADIUS_KM: float = 6371.0 # Raggio medio della Terra in km

@export var _position: Vector3 = Vector3(LONGITUDE, LATITUDE, 0.0)

# Proprietà per la longitudine
@export var longitude: float:
    get:
        return _position.x
    set(value):
        _position.x = value

# Proprietà per la latitudine
@export var latitude: float:
    get:
        return _position.y
    set(value):
        _position.y = value

# Proprietà per l'altitudine
@export var altitude: float:
    get:
        return _position.z
    set(value):
        _position.z = value

# Imposta una nuova posizione completa
func set_position(new_longitude: float, new_latitude: float, new_altitude: float = 0.0) -> void:
    longitude = new_longitude
    latitude = new_latitude
    altitude = new_altitude

func set_position_as_vector3(new_position: Vector3) -> void:
    _position = new_position

func set_position_as_vector2(new_position: Vector3) -> void:
    set_position(new_position.x, new_position.y, 0.0)
    
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

# Resetta la posizione alle coordinate zero
func reset_position() -> void:
    set_position(LONGITUDE, LATITUDE, 0.0)

# Stampa la posizione in formato leggibile
func _to_string() -> String:
    return "Latitudine: %s, Longitudine: %s, Altitudine: %s" % [latitude, longitude, altitude]

func calculate_geodesic_distance(position1: Vector3, position2: Vector3) -> float:
    # Converti latitudine e longitudine da gradi a radianti
    var lat1: float = deg_to_rad(position1.y)
    var lon1: float = deg_to_rad(position1.x)
    var lat2: float = deg_to_rad(position2.y)
    var lon2: float = deg_to_rad(position2.x)

    # Differenze tra le coordinate
    var delta_lat: float = lat2 - lat1
    var delta_lon: float = lon2 - lon1

    # Formula dell'haversine
    var a: float = pow(sin(delta_lat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(delta_lon / 2), 2)
    var c: float = 2 * atan2(sqrt(a), sqrt(1 - a))

    # Distanza in km
    var distance: float = EARTH_RADIUS_KM * c

    # Aggiungi differenza altimetrica (se necessario)
    var delta_alt: float = position2.z - position1.z
    return sqrt(pow(distance, 2) + pow(delta_alt / 1000.0, 2)) # Converti altitudine da metri a km