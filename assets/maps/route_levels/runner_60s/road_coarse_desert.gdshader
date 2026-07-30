shader_type spatial;
// 粗粝沙漠跑道：压实沙面 + 砾石颗粒 + 路缘碎石，无能量发光。
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform vec3 sand_color : source_color = vec3(0.74, 0.52, 0.28);
uniform vec3 gravel_color : source_color = vec3(0.4, 0.26, 0.14);
uniform vec3 dust_color : source_color = vec3(0.58, 0.38, 0.2);
uniform float roughness_val : hint_range(0.0, 1.0) = 0.94;
uniform float metallic_val : hint_range(0.0, 1.0) = 0.02;
uniform float detail_scale = 0.32;
uniform float pebble_scale = 3.2;

varying vec3 world_pos;
varying vec3 local_pos;

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 5; i++) {
		v += a * noise(p);
		p = p * 2.07 + vec2(4.3, 1.9);
		a *= 0.5;
	}
	return v;
}

float pebble_field(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p) - 0.5;
	float h = hash(cell);
	if (h < 0.42) {
		return 0.0;
	}
	vec2 off = vec2(hash(cell + 13.7) - 0.5, hash(cell + 29.1) - 0.5) * 0.38;
	float r = 0.12 + hash(cell + 5.3) * 0.16;
	float d = length(f - off);
	return smoothstep(r, r * 0.35, d) * smoothstep(0.42, 0.88, h);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
}

void fragment() {
	vec2 uv = world_pos.xz * detail_scale;
	float dunes = fbm(uv * vec2(0.55, 1.8));
	float ripples = fbm(uv * vec2(4.2, 9.5) + dunes * 1.4);
	float pebbles = pebble_field(uv * pebble_scale + ripples * 0.6);
	pebbles = max(pebbles, pebble_field(uv * pebble_scale * 1.7 + 8.2) * 0.55);

	float track = pow(smoothstep(2.8, 0.0, abs(local_pos.x)), 1.6);
	float edge_gravel = smoothstep(4.8, 6.2, abs(local_pos.x));

	vec3 albedo = mix(sand_color, gravel_color, pebbles * 0.72);
	albedo = mix(albedo, dust_color, ripples * 0.28 + dunes * 0.12);
	albedo *= 1.0 - track * 0.14;
	albedo = mix(albedo, gravel_color * 1.08, edge_gravel * 0.35);

	// 极弱横向风纹
	float wind = pow(0.5 + 0.5 * sin(world_pos.z * 0.22 + dunes * 6.0), 4.0);
	albedo = mix(albedo, dust_color * 0.92, wind * 0.06);

	ALBEDO = albedo;
	METALLIC = metallic_val;
	ROUGHNESS = mix(roughness_val, 0.78, pebbles * 0.25 + track * 0.08);
	SPECULAR = 0.08;
	EMISSION = dust_color * wind * 0.015;
}
