extends Node

# Date/time constants
const DAY: float = 60 * 60 * 24.0
const J1970: float = 2440588.0
const J2000: float = 2451545.0

@export var pause: bool = false: # Controlla se il tempo è in pausa
	set(value):
		pause = value
		set_physics_process(!value)
		EventBus.emit("pause_toggled", [!value])

var enlapsed_seconds: int = 1712585000
var seconds_per_game_second: float = 1 #0.00025
var time_accumulator: float = 0.0

func _ready() -> void:
	print("DateTime initialized with time starting from: ", _to_string())
	EventBus.register("time_updated")
	EventBus.register("pause_toggled")
	set_physics_process(true) # Abilita il processo fisico per gestire il tempo

func _physics_process(delta: float) -> void:
	# Accumula il tempo
	time_accumulator += delta
	
	# Calcola quanti secondi di gioco sono passati
	var game_seconds_elapsed = int(time_accumulator * (1.0 / seconds_per_game_second))
	
	if game_seconds_elapsed > 0:
		# Aggiorna il tempo di gioco
		enlapsed_seconds += game_seconds_elapsed
		# Sottrai il tempo processato dall'accumulatore
		time_accumulator -= game_seconds_elapsed * seconds_per_game_second
		# Emetti l'evento
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

func to_julian(date: int) -> float:
	return float(date) / DAY - 0.5 + J1970

func from_julian(j: float) -> int:
	return int((j + 0.5 - J1970) * DAY)

func to_days(date: int) -> float:
	return to_julian(date) - J2000

func _to_string() -> String:
	var date: Dictionary = get_datetime(enlapsed_seconds)
	return "%04d-%02d-%02dT%02d:%02d:%02dZ" % [date.year, date.month, date.day, date.hour, date.minute, date.second]
