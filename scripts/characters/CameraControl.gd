extends Camera3D

@export var zoom_speed: float = 1.0
@export var min_size: float = 5.0
@export var max_size: float = 50.0

func _ready():
	# Assicuriamoci che la telecamera sia in modalità ortogonale
	if projection != Camera3D.PROJECTION_ORTHOGONAL:
		projection = Camera3D.PROJECTION_ORTHOGONAL
	size = 20.0  # Imposta una dimensione iniziale per la telecamera

func _process(delta: float) -> void:
	# Controlla le azioni di input
	if Input.is_action_just_pressed("zoom_in"):
		size = clamp(size - zoom_speed, min_size, max_size)
	elif Input.is_action_just_pressed("zoom_out"):
		size = clamp(size + zoom_speed, min_size, max_size)
