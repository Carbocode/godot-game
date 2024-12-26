extends CharacterBody3D

@export var speed: float = 5.0
@export var gravity: float = 9.8
@export var jump_speed: float = 5.0

func _physics_process(delta: float) -> void:
	var input_dir = Vector3.ZERO

	if Input.is_action_pressed("move_up"):
		input_dir.z -= 1
		input_dir.x -= 1
	if Input.is_action_pressed("move_down"):
		input_dir.z += 1
		input_dir.x += 1
	if Input.is_action_pressed("move_left"):
		input_dir.z += 1
		input_dir.x -= 1
	if Input.is_action_pressed("move_right"):
		input_dir.z -= 1
		input_dir.x += 1

	# Normalizziamo il vettore per evitare velocità maggiori in diagonale
	if input_dir != Vector3.ZERO:
		input_dir = input_dir.normalized()

	# Movimento sull'asse X/Z
	var direction = input_dir * speed
	
	# Applichiamo gravità se necessario (se il personaggio dovrà saltare o stare su un terreno)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Aggiorniamo la velocità orizzontale
	velocity.x = direction.x
	velocity.z = direction.z

	move_and_slide()
