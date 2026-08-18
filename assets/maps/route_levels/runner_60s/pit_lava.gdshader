shader_type spatial;
render_mode unshaded, cull_disabled, specular_disabled;

uniform vec3 lava_deep : source_color = vec3(0.06, 0.01, 0.0);
uniform vec3 lava_hot : source_color = vec3(0.78, 0.18, 0.02);
uniform vec3 lava_bright : source_color = vec3(0.95, 0.62, 0.12);
uniform float scroll_speed : hint_range(0.05, 1.5) = 0.42;
uniform float crack_scale : hint_range(4.0, 40.0) = 16.0;
uniform float bubble_strength : hint_range(0.0, 1.5) = 0.85;
uniform float emission_boost : hint_range(0.2, 3.0) = 0.85;

float _hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float _noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = _hash(i);
	float b = _hash(i + vec2(1.0, 0.0));
	float c = _hash(i + vec2(0.0, 1.0));
	float d = _hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float _bubble_field(vec2 uv, float t) {
	float acc = 0.0;
	for (int i = 0; i < 4; i++) {
		float fi = float(i);
		vec2 cell = uv * (2.4 + fi * 0.85) + vec2(fi * 1.7, -t * (0.55 + fi * 0.18));
		vec2 id = floor(cell);
		vec2 f = fract(cell) - 0.5;
		float rnd = _hash(id + fi * 17.0);
		vec2 center = (vec2(rnd, fract(rnd * 7.13)) - 0.5) * 0.55;
		float life = fract(rnd + t * (0.35 + fi * 0.08));
		float rad = mix(0.08, 0.22, rnd) * (0.55 + life);
		float d = length(f - center);
		float ring = smoothstep(rad, rad * 0.55, d) * smoothstep(rad * 0.15, rad * 0.55, d);
		float pop = smoothstep(0.92, 0.72, life) * smoothstep(0.05, 0.2, life);
		acc += ring * pop * (0.55 + rnd * 0.45);
	}
	return clamp(acc, 0.0, 1.4);
}

void fragment() {
	vec2 uv = UV * crack_scale;
	uv += vec2(TIME * scroll_speed * 0.18, TIME * scroll_speed * -0.11);
	float n1 = _noise(uv);
	float n2 = _noise(uv * 2.3 + vec2(3.1, TIME * 0.25));
	float n3 = _noise(uv * 0.55 - vec2(TIME * 0.08, 1.7));
	float heat = clamp(n1 * 0.55 + n2 * 0.35 + n3 * 0.25, 0.0, 1.0);
	float vein = smoothstep(0.42, 0.78, heat);
	float bubbles = _bubble_field(UV * 7.5, TIME * scroll_speed) * bubble_strength;
	vec3 col = mix(lava_deep, lava_hot, heat);
	col = mix(col, lava_bright, vein * vein * 0.85);
	col = mix(col, lava_bright * 1.05, clamp(bubbles * 0.55, 0.0, 0.65));
	ALBEDO = col;
	EMISSION = col * (0.95 + vein * 1.65 + bubbles * 1.1) * emission_boost;
}
