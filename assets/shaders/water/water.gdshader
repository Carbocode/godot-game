shader_type spatial;

#define CIRCULAR_WAVES

// Wave properties
struct Wave {
    vec2 direction;
    vec2 origin;
    float frequency;
    float amplitude;
    float phase;
    float steepness;
};

const Wave[2] WAVES = Wave[2](
    // Wave 1 - Main large wave
    Wave(
        vec2(1.0, 0.6),  // direction
        vec2(-100.0, -100.0),  // origin
        0.4,
        1.0,
        1.2,
        1.5
    ),
    // Wave 2 - Medium crossing wave
    Wave(
        vec2(-0.7, 0.3),
        vec2(100.0, 100.0),
        0.4,
        1.0,
        1.2,
        1.5
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
	//ALBEDO = NORMAL;

	ALBEDO=vec3(0.0,0.0,1.0);
}