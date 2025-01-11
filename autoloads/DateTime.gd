extends Node

const VERNAL_EQUINOX: int = 81
const DAYS_IN_YEAR: int = 365

@export var pause: bool = false: # Controlla se il tempo è in pausa
	set(value):
		pause = value
		set_physics_process(!value)
		EventBus.emit("pause_toggled", [!value])

var enlapsed_seconds: int = 1712599200
var seconds_per_game_second: float = 0.0025 #0.00025 # Velocità di simulazione del tempo

func _ready() -> void:
	print("DateTime initialized with time starting from: ", _to_string())
	EventBus.register("time_updated")
	EventBus.register("pause_toggled")
	set_physics_process(true) # Abilita il processo fisico per gestire il tempo

func _physics_process(delta: float) -> void:
	# Incrementa il tempo di gioco
	enlapsed_seconds += int(delta / seconds_per_game_second)
	EventBus.emit("time_updated", [enlapsed_seconds])
	print(_to_string())

# Funzioni per manipolare il tempo
func add_seconds(seconds: int) -> void:
	enlapsed_seconds += seconds
	EventBus.emit("time_updated", [enlapsed_seconds])

func set_timestamp(timestamp: int) -> void:
	enlapsed_seconds = timestamp
	EventBus.emit("time_updated", [enlapsed_seconds])

func get_timestamp() -> int:
	return enlapsed_seconds

# Conversione del timestamp in data leggibile
func get_datetime(timestamp: int) -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(timestamp)

# Conversione del timestamp interno in data leggibile
func get_current_datetime() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(enlapsed_seconds)

# Funzione per calcolare il giorno giuliano
func get_julian_date(date) -> float:
	var year: int = date.year
	var month: int = date.month
	var day: float = date.day + date.hour / 24.0 + date.minute / 1440.0 + date.second / 86400.0
	
	# Correzione per gennaio e febbraio
	if month <= 2:
		year -= 1
		month += 12
	
	# Correzione gregoriana
	
	var B: float;
	if year < 1582 or (year == 1582 and month < 10) or (year == 1582 and month == 10 and day < 15):
		B = 0
	else:
		var A: float = floor(year / 100)
		B = 2 - A + floor(A / 4)
	
	# Calcolo del giorno giuliano (JDN)
	return floor(365.25 * (year + 4716)) + floor(30.6001 * (month + 1)) + day + B - 1524.5

func get_sidereal_time(jd: float, hour: float, minute: float, longitude: float) -> float:
	# Calcola il tempo frazionario
	var UT = hour + (minute / 60.0)
	
	# Calcola T (secolo giuliano)
	var T = (jd - 2451545.0) / 36525.0
	
	# Calcola GMST (Greenwich Mean Sidereal Time)
	var GMST = 280.46061837 + 360.98564736629 * (jd - 2451545.0) + 0.000387933 * pow(T, 2) - pow(T, 3) / 38710000.0
	GMST += UT * 15.0  # Correzione per l'ora UT
	GMST = fmod(GMST, 360.0)
	if GMST < 0.0:
		GMST += 360.0

	# Calcola LST (Local Sidereal Time)
	var lst = GMST + longitude
	lst = fmod(lst, 360.0)
	if lst < 0.0:
		lst += 360.0

	return lst

# Funzione per calcolare il giorno dell'anno dall'equinozio di primavera
func get_day_of_year_from_equinox(julian_day: float) -> float:
	const equinox_jde: float = 2451623.80984 # Valore fisso per equinozio di primavera vicino a J2000
	return julian_day - equinox_jde

func get_equation_of_time(day_of_year_from_equinox: float) -> float:
	var M: float = deg_to_rad(357.5291 + 0.98560028 * day_of_year_from_equinox) # Anomalia media
	var C: float = deg_to_rad(1.9148 * sin(M) + 0.02 * sin(2 * M) + 0.0003 * sin(3 * M)) # Equazione del centro
	var L: float = fmod(deg_to_rad(280.46646 + 0.98564736 * day_of_year_from_equinox + C), TAU) # Longitudine solare apparente
	
	return 4 * (deg_to_rad(0.0057183) - L + C) / TAU * 60.0 # Equazione del tempo in minuti

func _to_string() -> String:
	var date: Dictionary = get_datetime(enlapsed_seconds)
	return "%04d-%02d-%02dT%02d:%02d:%02dZ" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
