shader_type spatial;
// 全息能量轨：连续挤出网格 + 克制青绿能量。UV.x=路宽，UV.y=沿路距离。
render_mode cull_back, diffuse_burley, specular_schlick_ggx, ambient_light_disabled;

uniform sampler2D road_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 base_color : source_color = vec3(0.04, 0.08, 0.1);
uniform vec3 plasma_color : source_color = vec3(0.25, 0.55, 0.6);
uniform vec3 circuit_color : source_color = vec3(0.32, 0.65, 0.68);
uniform vec3 edge_color : source_color = vec3(0.48, 0.24, 0.55);
uniform float roughness_val : hint_range(0.0, 1.0) = 0.46;
uniform float metallic_val : hint_range(0.0, 1.0) = 0.08;
uniform float tex_blend : hint_range(0.0, 1.0) = 0.42;
uniform float tex_darken : hint_range(0.0, 1.0) = 0.28;
uniform float plasma_energy : hint_range(0.0, 4.0) = 0.55;
uniform float flow_energy : hint_range(0.0, 3.0) = 0.4;
uniform float wave_speed = 0.55;
uniform float scroll_speed = 0.06;
uniform float road_half_width = 6.0;

varying vec3 world_pos;

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
	for (int i = 0; i < 4; i++) {
		v += a * noise(p);
		p = p * 2.05 + vec2(3.1, 7.4);
		a *= 0.5;
	}
	return v;
}

float soft_vein(vec2 p) {
	float n = fbm(p);
	float ridge = 1.0 - abs(n * 2.0 - 1.0);
	return pow(smoothstep(0.45, 0.9, ridge), 2.4);
}

float micro_particles(vec2 p) {
	vec2 cell = floor(p);
	vec2 f = fract(p) - 0.5;
	float h = hash(cell);
	vec2 drift = vec2(h - 0.5, fract(h * 7.13) - 0.5) * 0.32;
	float d = length(f - drift);
	return smoothstep(0.1, 0.018, d) * step(0.78, h);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	float u = UV.x;
	float v = UV.y - TIME * scroll_speed;
	float lateral_x = (u - 0.5) * road_half_width * 2.0;

	vec4 tex = texture(road_tex, vec2(u, v));
	vec3 tex_col = tex.rgb * tex_darken;
	float tex_luma = dot(tex_col, vec3(0.299, 0.587, 0.114));
	tex_col = mix(tex_col, plasma_color * 0.18, smoothstep(0.3, 0.7, tex_luma) * 0.7);
	tex_col = min(tex_col, vec3(0.32));

	vec2 flow_uv = vec2(u, v) * vec2(1.2, 2.6);
	float veins = soft_vein(flow_uv);
	veins = max(veins * 0.7, soft_vein(flow_uv * vec2(2.1, 0.85) + 4.2) * 0.5);

	float particles = micro_particles(flow_uv * vec2(22.0, 48.0) + vec2(0.0, TIME * wave_speed));
	particles += micro_particles(flow_uv * vec2(30.0, 18.0) - vec2(TIME * wave_speed * 0.35, 0.0)) * 0.6;

	float wave = pow(0.5 + 0.5 * sin(world_pos.z * 0.28 - TIME * wave_speed), 3.8);
	float core = pow(smoothstep(1.5, 0.0, abs(lateral_x)), 2.8) * 0.4;
	float edge = smoothstep(road_half_width * 0.9, road_half_width * 1.02, abs(lateral_x));
	float edge_soft = smoothstep(road_half_width * 0.75, road_half_width * 0.98, abs(lateral_x));

	vec3 solid = base_color;
	solid = mix(solid, plasma_color * 0.16, veins * 0.5 + core * 0.2);
	solid = mix(solid, edge_color * 0.08, edge_soft * 0.3);
	solid += circuit_color * particles * 0.05;

	vec3 albedo = mix(solid, tex_col, tex_blend * tex.a);
	albedo = mix(albedo, plasma_color * 0.1, wave * 0.06);
	albedo = min(albedo, vec3(0.34));

	ALBEDO = albedo;
	ALPHA = 1.0;
	METALLIC = metallic_val;
	ROUGHNESS = mix(roughness_val, 0.3, veins * 0.3);
	SPECULAR = 0.2;

	EMISSION = plasma_color * veins * plasma_energy
		+ circuit_color * particles * flow_energy
		+ plasma_color * core * 0.22
		+ plasma_color * wave * 0.08
		+ edge_color * edge * 0.28;
}
