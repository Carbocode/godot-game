shader_type spatial;
render_mode unshaded;

//#define USE_FBM
//#define CIRCULAR_WAVES

// Core Properties
group_uniforms FBM.Number;
uniform int vertex_wave_count = 5;
uniform int fragment_wave_count = 5;
group_uniforms;

group_uniforms FBM.Vertex;
/** Starting seed for the vertex noiQse pattern - changes the base wave pattern */
uniform float vertex_seed = 0.0;

/** How much to change the seed between octaves - affects pattern variation */
uniform float vertex_seed_iter = 1253.2131;

/** Base frequency of vertex waves - controls how close waves are together */
uniform float vertex_frequency = 1.0;

/** How frequency changes between octaves - higher values create more detailed waves */
uniform float vertex_frequency_mult = 1.18;

/** Base height of vertex waves - controls overall wave height */
uniform float vertex_amplitude = 1.0;

/** How amplitude changes between octaves - affects wave detail visibility */
uniform float vertex_amplitude_mult = 0.82;

/** Base speed of vertex waves - controls how fast waves move */
uniform float vertex_initial_speed = 2.0;

/** How speed changes between octaves - affects motion of different sized waves */
uniform float vertex_speed_ramp = 1.07;

/** How much waves affect neighboring areas - controls wave interaction */
uniform float vertex_drag = 1.0;

/** Overall height multiplier for vertex displacement */
uniform float vertex_height = 1.0;

/** Controls how sharp wave peaks can be - higher values create pointier waves */
uniform float vertex_max_peak = 1.0;

/** Adjusts the threshold for peak formation - affects wave shape */
uniform float vertex_peak_offset = 1.0;
group_uniforms;

group_uniforms FBM.Fragment;
/** Starting seed for the fragment noise pattern - changes surface detail pattern */
uniform float fragment_seed = 0.0;

/** How much to change the seed between octaves - affects detail variation */
uniform float fragment_seed_iter = 1253.2131;

/** Base frequency of surface details - controls density of surface ripples */
uniform float fragment_frequency = 1.0;

/** How frequency changes between octaves - affects detail complexity */
uniform float fragment_frequency_mult = 1.18;

/** Base strength of surface details - controls how visible details are */
uniform float fragment_amplitude = 1.0;

/** How amplitude changes between octaves - affects detail prominence */
uniform float fragment_amplitude_mult = 0.82;

/** Base speed of surface details - controls how fast details move */
uniform float fragment_initial_speed = 2.0;

/** How speed changes between octaves - affects motion of different sized details */
uniform float fragment_speed_ramp = 1.07;

/** How much details affect neighboring pixels - controls detail spreading */
uniform float fragment_drag = 1.0;

/** Overall height multiplier for surface details */
uniform float fragment_height = 1.0;

/** Controls how sharp detail peaks can be - higher values create sharper details */
uniform float fragment_max_peak = 1.0;

/** Adjusts the threshold for detail peak formation - affects detail shape */
uniform float fragment_peak_offset = 1.0;
group_uniforms;

group_uniforms Normal;
/** Strengthens or weakens the effect of normals on lighting */
uniform float normal_strength = 1.0;

/** Controls how much normals affect fresnel calculations */
uniform float fresnel_normal_strength = 1.0;

/** Controls how much normals affect specular highlights */
uniform float specular_normal_strength = 1.0;
group_uniforms;

group_uniforms Colors;
/** Base color when not directly lit */
uniform vec3 ambient: source_color = vec3(1.0);

/** Base color of the water and how it reacts to direct light */
uniform vec3 diffuse_reflectance: source_color = vec3(1.0);

/** Controls the color and intensity of specular highlights */
uniform vec3 specular_reflectance: source_color = vec3(1.0);

/** Color of fresnel effect (edge highlighting) */
uniform vec3 fresnel_color: source_color = vec3(1.0);

/** Color added to wave peaks */
uniform vec3 tip_color: source_color = vec3(0.0);
group_uniforms;

group_uniforms Light;
/** Controls how sharp specular highlights are */
uniform float shininess = 0.0;

/** Base fresnel reflection amount */
uniform float fresnel_bias = 0.0;

/** Overall strength of fresnel effect */
uniform float fresnel_strength = 0.0;

/** Controls how quickly fresnel effect falls off */
uniform float fresnel_shininess = 0.0;

/** Controls how color fades at wave peaks */
uniform float tip_attenuation = 0.0;
group_uniforms;

// Wave properties
struct Wave {
    vec2 direction;
    vec2 origin;
    float frequency;
    float amplitude;
    float phase;
    float steepness;
};

const Wave[5] WAVES = Wave[5](
    // Wave 1 - Main large wave
    Wave(
        vec2(1.0, 0.6),  // direction
        vec2(0.0, 0.0),  // origin
        0.1,             // frequency
        5.0,             // amplitude
        1.0,             // phase
        1.8             // steepness
    ),
    // Wave 2 - Medium crossing wave
    Wave(
        vec2(-0.7, 0.3),
        vec2(0.0, 0.0),
        0.4,
        1.0,
        1.2,
        1.5
    ),
    // Wave 3 - Small detail wave
    Wave(
        vec2(0.3, -0.8),
        vec2(0.0, 0.0),
        0.6,
        0.2,
        0.8,
        1.3
    ),
    // Wave 4 - Ripple detail
    Wave(
        vec2(-0.4, -0.4),
        vec2(0.0, 0.0),
        0.8,
        0.1,
        1.5,
        1.0
    ),
    // Wave 5 - Micro detail
    Wave(
        vec2(0.2, 0.5),
        vec2(0.0, 0.0),
        1.0,
        0.05,
        2.0,
        0.8
    )
);

const int wave_count = 2;

vec2 get_direction(vec3 v, Wave w) {
    #ifdef CIRCULAR_WAVES
        vec2 p = vec2(v.x, v.z);
        return normalize(p - w.origin);
    #else
        return w.direction;
    #endif
}

float get_wave_coord(vec3 v, vec2 d, Wave w) {
    #ifdef CIRCULAR_WAVES
        vec2 p = vec2(v.x, v.z);
        return length(p - w.origin);
    #endif
    return v.x * d.x + v.z * d.y;
}

float get_time(Wave w) {
    #ifdef CIRCULAR_WAVES
        return -TIME * w.phase;
    #else
        return TIME * w.phase;
    #endif
}

vec3 steep_sine_wave(vec3 v, Wave w) {
    vec2 d = get_direction(v, w);
	float xz = get_wave_coord(v, d, w);
	float t = get_time(w);

	float h = 2.0f * w.amplitude * pow((sin(xz * w.frequency + t) + 1.0f) / 2.0f, w.steepness);

	return vec3(0.0f, h, 0.0f);
}

vec3 steep_sine_normal(vec3 v, Wave w) {
	vec2 d = get_direction(v, w);
	float xz = get_wave_coord(v, d, w);
	float t = get_time(w);


	float h = pow((sin(xz * w.frequency + t) + 1.0) / 2.0f, max(1.0f, w.steepness - 1.0));
	/*vec2 n = d * w.steepness * w.frequency * w.amplitude * h * cos(xz * w.frequency + t);

	return vec3(n.x, n.y, 0.0f);*/
	float epsilon = 0.1;

    // Calcola le derivate finite rispetto a x e z
    float h_x = pow((sin(get_wave_coord(v + vec3(epsilon, 0.0, 0.0), d, w) * w.frequency + t) + 1.0) / 2.0, max(1.0, w.steepness - 1.0));
    float h_z = pow((sin(get_wave_coord(v + vec3(0.0, 0.0, epsilon), d, w) * w.frequency + t) + 1.0) / 2.0, max(1.0, w.steepness - 1.0));

    // Calcolo delle derivate parziali (gradiente)
    float dhdx = (h_x - h) / epsilon;
    float dhdz = (h_z - h) / epsilon;

    // Vettori tangenti alla superficie
    vec3 tangentX = vec3(1.0, dhdx, 0.0);
    vec3 tangentZ = vec3(0.0, dhdz, 1.0);

    // Calcolo della normale come prodotto vettoriale dei tangenti
    vec3 normal = normalize(cross(tangentZ, tangentX));

    return normal;
}

vec3 vertexFBM(vec3 v) {
    float f = vertex_frequency;
    float a = vertex_amplitude;
    float speed = vertex_initial_speed;
    float seed = vertex_seed;
    vec3 p = v;
    float amplitude_sum = 0.0f;

    float h = 0.0f;
    vec2 n = vec2(0.0f);

    for (int wi = 0; wi < vertex_wave_count; ++wi) {
        vec2 d = normalize(vec2(cos(seed), sin(seed)));

        float x = dot(d, p.xz) * f + TIME * speed;
        float wave = a * exp(vertex_max_peak * sin(x) - vertex_peak_offset);
        float dx = vertex_max_peak * wave * cos(x);

        h += wave;

		n += d * dx * f;

        p.xz += d * -dx * a * vertex_drag;

        amplitude_sum += a;
        f *= vertex_frequency_mult;
        a *= vertex_amplitude_mult;
        speed *= vertex_speed_ramp;
        seed += vertex_seed_iter;
    }

    vec3 output = vec3(h, n.x, n.y) / amplitude_sum;
    output.x *= vertex_height;

    return output;
}

vec3 fragmentFBM(vec3 v) {
    float f = fragment_frequency;
    float a = fragment_amplitude;
    float speed = fragment_initial_speed;
    float seed = fragment_seed;
    vec3 p = v;
    float amplitude_sum = 0.0;

    float h = 0.0f;
    vec2 n = vec2(0.0f);

    for (int wi = 0; wi < fragment_wave_count; ++wi) {
        vec2 d = normalize(vec2(cos(seed), sin(seed)));

        float x = dot(d, p.xz) * f + TIME * speed;
        float wave = a * exp(fragment_max_peak * sin(x) - fragment_peak_offset);
        vec2 dw = f * d * (fragment_max_peak * wave * cos(x));

        h += wave;
        p.xz += -dw * a * fragment_drag;

        n += dw;

        amplitude_sum += a;
        f *= fragment_frequency_mult;
        a *= fragment_amplitude_mult;
        speed *= fragment_speed_ramp;
        seed += fragment_seed_iter;
    }

    vec3 output = vec3(h, n.x, n.y) / amplitude_sum;
    output.x *= fragment_height;

    return output;
}

varying vec3 world_pos;
varying vec3 world_normal;
varying float height;
varying vec3 fresnel;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
    vec3 h = vec3(0.0f);
    vec3 n = vec3(0.0f);

    #ifdef USE_FBM
    vec3 fbm = vertexFBM(world_pos);
    h.y = fbm.x;
    n.xy = fbm.yz;
    #else
    // Apply wave displacement
    for(int wi = 0; wi < wave_count; wi++) {
        h += steep_sine_wave(world_pos, WAVES[wi]);
		n += steep_sine_normal(world_pos, WAVES[wi]);
    }
    #endif

    VERTEX += h;

    NORMAL = normalize(n);
}

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform vec2 SCREEN_PIXEL_SIZE;

void fragment() {
    #ifdef USE_FBM
		height = 0.0;

        vec3 fbm = fragmentFBM(world_pos);
        height = fbm.x;
        world_normal.xy = fbm.yz;
		world_normal = normalize(vec3(-world_normal.x, 1.0, -world_normal.y));

		// Apply normal strength
		world_normal.xz *= normal_strength;
		world_normal = normalize(world_normal);

		NORMAL += world_normal;
    #endif

	ALBEDO = NORMAL;

	//ALBEDO=vec3(0.0,0.0,1.0);
}

/*
void light() {
	float diffuse = max(dot(normalize(NORMAL), normalize(LIGHT)), 0.0);
	vec3 diffuse_color = diffuse * LIGHT_COLOR.rgb;

    DIFFUSE_LIGHT = diffuse_color;
}*/