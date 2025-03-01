@tool
extends MeshInstance3D

# --- Costanti e preload ---
const WATER_MAT := preload("res://assets/shaders/ocean/mat_water.tres")
const SPRAY_MAT := preload("res://assets/shaders/ocean/mat_spray.tres")
const WATER_MESH_HIGH := preload("res://assets/models/ocean/clipmap_high.obj")
const WATER_MESH_LOW := preload("res://assets/models/ocean/clipmap_low.obj")

enum MeshQuality { LOW, HIGH }

# Nomi dei parametri shader
const WATER_COLOR_PARAM := &"water_color"
const FOAM_COLOR_PARAM := &"foam_color"
const NUM_CASCADES_PARAM := &"num_cascades"
const DISPLACEMENTS_PARAM := &"displacements"
const NORMALS_PARAM := &"normals"
const MAP_SCALES_PARAM := &"map_scales"

# --- Proprietà Esportate ---
@export_group("Wave Parameters")
@export_color_no_alpha var water_color: Color = Color(0.1, 0.15, 0.18): set = _set_water_color
@export_color_no_alpha var foam_color: Color = Color(0.73, 0.67, 0.62): set = _set_foam_color
@export var parameters: Array[WaveCascadeParameters] = []: set = _set_parameters

@export_group('Performance Parameters')
@export_enum("128x128:128", "256x256:256", "512x512:512", "1024x1024:1024") var map_size: int = 1024: set = _set_map_size
@export var mesh_quality: int = MeshQuality.HIGH: set = _set_mesh_quality
@export_range(0, 60) var updates_per_second: float = 50.0: set = _set_updates_per_second

# --- Variabili Membro ---
var wave_generator: WaveGenerator = null: set = _set_wave_generator
var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var time: float = 0.0
var next_update_time: float = 0.0

var displacement_maps: Texture2DArrayRD = Texture2DArrayRD.new()
var normal_maps: Texture2DArrayRD = Texture2DArrayRD.new()

# --- Ciclo di Vita ---
func _init() -> void:
	rng.set_seed(1234) # This seed gives big waves!

func _ready() -> void:
	_set_water_color(water_color)
	_set_foam_color(foam_color)
	_setup_wave_generator()

func _process(delta : float) -> void:
	# Update waves once every 1.0/updates_per_second.
	if updates_per_second == 0 or time >= next_update_time:
		var target_update_delta := 1.0 / (updates_per_second + 1e-10)
		var update_delta := delta if updates_per_second == 0 else target_update_delta + (time - next_update_time)
		next_update_time = time + target_update_delta
		_update_water(update_delta)
	time += delta

# --- Funzioni Helper ---
func _setup_wave_generator() -> void:
	if parameters.size() <= 0: return
	for param in parameters:
		param.should_generate_spectrum = true

	wave_generator = WaveGenerator.new()
	wave_generator.map_size = map_size
	wave_generator.init_gpu(maxi(2, parameters.size())) # FIXME: This is needed because my RenderContext API sucks...

	displacement_maps.texture_rd_rid = RID()
	normal_maps.texture_rd_rid = RID()
	displacement_maps.texture_rd_rid = wave_generator.descriptors[&'displacement_map'].rid
	normal_maps.texture_rd_rid = wave_generator.descriptors[&'normal_map'].rid

	RenderingServer.global_shader_parameter_set(NUM_CASCADES_PARAM, parameters.size())
	RenderingServer.global_shader_parameter_set(DISPLACEMENTS_PARAM, displacement_maps)
	RenderingServer.global_shader_parameter_set(NORMALS_PARAM, normal_maps)

func _update_scales_uniform() -> void:
	var map_scales : PackedVector4Array; map_scales.resize(len(parameters))
	for i in len(parameters):
		var params := parameters[i]
		var uv_scale := Vector2.ONE / params.tile_length
		map_scales[i] = Vector4(uv_scale.x, uv_scale.y, params.displacement_scale, params.normal_scale)
	# No global shader parameter for arrays :(
	WATER_MAT.set_shader_parameter(MAP_SCALES_PARAM, map_scales)
	SPRAY_MAT.set_shader_parameter(MAP_SCALES_PARAM, map_scales)

func _update_water(delta : float) -> void:
	#if wave_generator == null: _setup_wave_generator()
	wave_generator.update(delta, parameters)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		displacement_maps.texture_rd_rid = RID()
		normal_maps.texture_rd_rid = RID()

# --- Setter ---
func _set_water_color(value: Color) -> void:
	water_color = value
	RenderingServer.global_shader_parameter_set(WATER_COLOR_PARAM, water_color.srgb_to_linear())

func _set_foam_color(value: Color) -> void:
	foam_color = value
	RenderingServer.global_shader_parameter_set(FOAM_COLOR_PARAM, foam_color.srgb_to_linear())

func _set_parameters(value: Array) -> void:
	parameters = []
	for i in range(value.size()):
		var cascade = value[i] if value[i] != null else WaveCascadeParameters.new()
		# Connetti il segnale se non già collegato
		if not cascade.is_connected(&"scale_changed", _update_scales_uniform):
			cascade.scale_changed.connect(_update_scales_uniform)
		cascade.spectrum_seed = Vector2i(rng.randi_range(-10000, 10000), rng.randi_range(-10000, 10000))
		cascade.time = 120.0 + PI * i  # Offset per evitare interferenze tra cascade
		parameters.append(cascade)
	_setup_wave_generator()
	_update_scales_uniform()

func _set_map_size(value: int) -> void:
	map_size = value
	_setup_wave_generator()

func _set_mesh_quality(value: int) -> void:
	mesh_quality = value
	mesh = WATER_MESH_HIGH if mesh_quality == MeshQuality.HIGH else WATER_MESH_LOW

func _set_updates_per_second(value: float) -> void:
	# Calcola il nuovo tempo di aggiornamento mantenendo la coerenza temporale
	next_update_time = next_update_time - (1.0 / (updates_per_second + 1e-10) - 1.0 / (value + 1e-10))
	updates_per_second = value

func _set_wave_generator(new_generator: WaveGenerator) -> void:
	if wave_generator:
		wave_generator.queue_free()
	wave_generator = new_generator
	add_child(wave_generator)
