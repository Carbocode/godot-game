class_name UISlider extends HBoxContainer

# Segnale emesso quando il valore cambia
signal value_changed(value: float)

# Nodo target e proprietà
@export var target_node: NodePath
@export var target_property: String = ""

# Parametri configurabili nell'editor
@export var label_text: String = "Default Label":
	set(value):
		label_text = value
		if $Label: 
			$Label.text = value
@export var min_value: float = 0.0: 
	set(value):
		min_value = value
		if $HSlider: 
			$HSlider.min_value = value
@export var max_value: float = 100.0: 
	set(value):
		max_value = value
		if $HSlider: 
			$HSlider.max_value = value
@export var step: float = 0.01: 
	set(value):
		step = value
		if $HSlider: 
			$HSlider.step = value
@export var slider_value: float = 0.0: 
	set(value):
		slider_value = value
		if $HSlider: 
			$HSlider.value = value
		if $Value: 
			update_label(value)
@export var unit: String = ""

func _ready() -> void:
	# Connetti il segnale dello slider al metodo interno
	$HSlider.value_changed.connect(_on_slider_value_changed)
	
	# Verifica se abbiamo un nodo target
	if target_node:
		var node = get_node(target_node)
		# Connetti il segnale al nodo target
		value_changed.connect(func(value): node.set(target_property, value))
		# Inizializza il valore dello slider con il valore corrente della proprietà target
		if target_property:
			slider_value = node.get(target_property)

func _on_slider_value_changed(value: float) -> void:
	update_label(value)
	print(value)
	value_changed.emit(value)

## Aggiorna l'etichetta con il valore corrente	
func update_label(value: float):
	$Value.text = ("%.2f%s" % [value, unit])
