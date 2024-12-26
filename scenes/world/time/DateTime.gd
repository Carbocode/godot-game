class_name DateTime extends Node

signal pause_toggled  # Segnale per notificare il cambiamento
signal time_updated  # Emette quando il tempo cambia

const VERNAL_EQUINOX: int = 81
const DAYS_IN_YEAR: int = 365
const EARTH_ANGLE: float = deg_to_rad(23.44)
const FULL_CIRCLE: float = 2 * PI

@export var pause: bool = false:  # Controlla se il tempo è in pausa
	set(value):
		pause=value
		set_physics_process(!value)
		emit_signal("pause_toggled", !value)

var enlapsed_seconds: float = 1735102800#946728000  # 2000-1-1T12:00:00Z
var seconds_per_game_second: float = 0.00025  # Velocità di simulazione del tempo

func _ready():
	set_physics_process(true)  # Abilita il processo fisico per gestire il tempo

func _physics_process(delta):
	# Incrementa il tempo di gioco
	enlapsed_seconds += delta / seconds_per_game_second
	emit_signal("time_updated", enlapsed_seconds)
	print(_to_string())

# Funzioni per manipolare il tempo
func add_seconds(seconds: int):
	enlapsed_seconds += seconds
	emit_signal("time_updated", enlapsed_seconds)

func set_timestamp(timestamp: int):
	enlapsed_seconds = timestamp
	emit_signal("time_updated", enlapsed_seconds)

func get_timestamp() -> int:
	return enlapsed_seconds

# Conversione del timestamp in data leggibile
func get_datetime(timestamp: int) -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(timestamp)

# Conversione del timestamp interno in data leggibile
func get_current_datetime() -> Dictionary:
	return Time.get_datetime_dict_from_unix_time(enlapsed_seconds)

# Funzione per calcolare il giorno giuliano
func get_julian_day(year: int, month: int, day: int) -> float:
	var a = int((14 - month) / 12)
	var y = year + 4800 - a
	var m = month + 12 * a - 3
	return day + int((153 * m + 2) / 5) + 365 * y + int(y / 4) - int(y / 100) + int(y / 400) - 32045

# Funzione per calcolare il giorno dell'anno dall'equinozio di primavera
func get_day_of_year_from_equinox(julian_day: float) -> float:
	const equinox_jde = 2451623.80984 # Valore fisso per equinozio di primavera vicino a J2000
	return julian_day - equinox_jde

# Funzione per calcolare la declinazione del Sole
func get_declination(day_of_year_from_equinox: float) -> float:
	return EARTH_ANGLE * sin(FULL_CIRCLE / DAYS_IN_YEAR * day_of_year_from_equinox)

func get_equation_of_time(day_of_year_from_equinox: float) -> float:
	var b = FULL_CIRCLE * day_of_year_from_equinox / DAYS_IN_YEAR
	return 229.18 * (0.000075 + 0.001868 * cos(b) - 0.032077 * sin(b) - 0.014615 * cos(2*b) - 0.040849 * sin(2*b))

func _to_string() -> String:
	var date = get_datetime(enlapsed_seconds)
	return "%04d-%02d-%02d %02d:%02d:%02d" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
