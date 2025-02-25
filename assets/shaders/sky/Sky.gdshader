shader_type sky;

group_uniforms Sky;
uniform float day_factor : hint_range(0.0, 1.0) = 1.0;
uniform vec3 sun_direction = vec3(0.0, 1.0, 0.0);
uniform vec3 moon_direction = vec3(0.0, -1.0, 0.0);

group_uniforms Sun;
// Parametri di controllo per sole e luna
uniform float sun_disk_size : hint_range(0.01, 0.1) = 0.0008;
uniform float sun_glow_size : hint_range(0.0, 10.0) = 5.0;
uniform float sun_glow_intensity : hint_range(0.0, 100.0) = 48.0;

group_uniforms Moon;
uniform float moon_disk_size : hint_range(0.01, 0.1) = 0.0004;
uniform float moon_glow_size : hint_range(0.0, 2.0) = 0.5;
uniform float moon_glow_intensity : hint_range(0.0, 50.0) = 32.0;

group_uniforms Colors;
// Colori e parametri visivi
uniform vec3 day_sky_color : source_color = vec3(0.4, 0.6, 1.0);
uniform vec3 night_sky_color : source_color = vec3(0.05, 0.05, 0.1);
uniform vec3 horizon_day_color : source_color = vec3(0.8, 0.6, 0.4);
uniform vec3 horizon_night_color : source_color = vec3(0.1, 0.1, 0.15);
uniform vec3 sun_color : source_color = vec3(50.0, 40.0, 30.0);
uniform vec3 moon_color : source_color = vec3(1.5, 1.5, 1.8); // Ridotta drasticamente l'intensità HDR
uniform float scatter_strength = 0.5;

// Calcola l'intensità dello scattering atmosferico
float atmospheric_scatter(vec3 dir, vec3 light_dir) {
    float scatter = max(dot(dir, light_dir), 0.0);
    scatter = pow(scatter, 8.0) * scatter_strength;
    return scatter;
}

// Funzione per creare il disco celeste
float celestial_disc(float cos_angle, float size) {
    return smoothstep(cos(size), cos(size * 0.9), cos_angle);
}

// Funzione per il glow celeste
float celestial_glow(float cos_angle, float intensity, float concentration) {
    return pow(max(cos_angle, 0.0), concentration) * intensity;
}

void sky() {
    vec3 dir = EYEDIR;

    // Colore base del cielo
    vec3 sky_color = mix(night_sky_color, day_sky_color, day_factor);

    // Calcola il colore dell'orizzonte
    vec3 current_horizon_color = mix(horizon_night_color, horizon_day_color, day_factor);

    // Aggiungi l'orizzonte
    float horizon = 1.0 - abs(dir.y);
    horizon = pow(horizon, 4.0);
    sky_color = mix(sky_color, current_horizon_color, horizon * 0.5);

    // Calcola angoli per sole e luna
    float sun_cos_angle = dot(dir, sun_direction);
    float moon_cos_angle = dot(dir, moon_direction);

    // Calcola il sole
    float sun_disc = celestial_disc(sun_cos_angle, sun_disk_size);
    float sun_glow = celestial_glow(sun_cos_angle, sun_glow_size, sun_glow_intensity);
    vec3 visible_sun_color = sun_color * mix(0.1, 1.0, day_factor);

    // Calcola la luna
    float moon_disc = celestial_disc(moon_cos_angle, moon_disk_size);
    float moon_glow = celestial_glow(moon_cos_angle, moon_glow_size, moon_glow_intensity);
    vec3 visible_moon_color = moon_color * mix(1.0, 0.1, day_factor);

    // Aggiungi scattering atmosferico (rimosso per la luna)
    float sun_scatter = atmospheric_scatter(dir, sun_direction) * day_factor;
	float moon_scatter = atmospheric_scatter(dir, moon_direction) * day_factor;
    sky_color += visible_sun_color * sun_scatter * 0.1;

    // Combina sole e luna
    sky_color = mix(sky_color, visible_sun_color, (sun_disc + sun_glow));
    sky_color = mix(sky_color, visible_moon_color, ( moon_disc + moon_glow)); // Rimosso il glow dalla miscelazione principale

    // Aggiungi solo un leggero glow alla luna
    sky_color += visible_moon_color * celestial_glow(moon_cos_angle, 0.01, 12.0);

    // Output finale
    COLOR = sky_color;
}