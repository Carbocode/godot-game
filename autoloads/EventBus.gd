extends Node

# Dizionario per mappare eventi a una lista di callback
var listeners: Dictionary = {}

func _ready() -> void:
	print("Event Bus Ready")

# Registra un nuovo evento
func register(event_name: String):
	listeners[event_name] = []
	print("New event registered ", event_name)

# Cancella un evento esistente
func unregister(event_name: String):
	listeners.erase(event_name)
	print("Event removed ", event_name)

# Registra un listener per un evento
func subscribe(event_name: String, callback: Callable) -> void:
	if not listeners.has(event_name):
		listeners[event_name] = []
	listeners[event_name].append(callback)
	print("Node subscribed to ", event_name)

# Rimuove un listener per un evento
func unsubscribe(event_name: String, callback: Callable) -> void:
	listeners[event_name].erase(callback)
	print("Node unsubscribed from ", event_name)

# Emette un evento, invocando tutti i listener registrati
func emit(event_name: String, args: Array = []) -> void:
	for callback: Callable in listeners[event_name]:
		callback.callv(args)
