class_name UIToggle extends HBoxContainer

# Segnale emesso quando il valore cambia
signal value_changed(value: bool)

# Esporta il nodo a cui ci vogliamo collegare
@export var target_node: NodePath
@export var target_property: String = ""

# Parametri configurabili nell'editor
@export var label_text: String = "Default Label":
	set(value):
		label_text = value
		if $Label: 
			$Label.text = value
@export var toggle_value: bool = false: 
	set(value):
		toggle_value = value
		if $CheckButton: 
			$CheckButton.button_pressed = value

func _ready() -> void:
	# Connetti il segnale dello slider al metodo interno
	$CheckButton.toggled.connect(_on_toggle_value_changed)
	
	# Verifica se abbiamo un nodo target
	if target_node:
		var node = get_node(target_node)
		# Connetti il segnale al nodo target
		value_changed.connect(func(value) -> void: node.set(target_property, value))

func _on_toggle_value_changed(value: bool) -> void:
	print(value)
	value_changed.emit(value)
