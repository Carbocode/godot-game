extends Node

@export var strength: float = 0.0  # Intensità del vento (0 = nessun vento)
@export var direction: Vector3 = Vector3(1, 0, 0)  # Direzione del vento (es. verso est)

func get_force():
	# Restituisce la forza totale del vento come vettore
	return direction.normalized() * strength
