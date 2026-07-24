shader_type spatial;
// 异星固态能量轨：不透明、低发光、内嵌青白静脉与内部微粒流动。无玻璃/透明。
render_mode cull_back, diffuse_burley, specular_schlick_ggx, ambient_light_disabled;

uniform vec3 base_color : source_color = vec3(0.04, 0.09, 0.14);
uniform vec3 vein_color : source_color = vec3(0.55, 0.88, 1.0);
uniform vec3 particle_color : source_color = vec3(0.35, 0.95, 1.0);
uniform float roughness_val : hint_range(0.0, 1.0) = 0.38;
uniform float metallic_val : hint_range(0.0, 1.0) = 0.12;
uniform float vein_energy : hint_range(0.0, 4.0) = 1.15;
uniform float particle_energy : hint_range(0.0, 3.0) = 0.85;
uniform float flow_speed = 0.55;
uniform float detail_scale = 0.14;

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
	return pow(smoothstep(0.42, 0.88, ridge), 2.2);
}

float micro_particles(vec2 p) {
	// 表面下细小光点，沿路径缓慢流动
	vec2 cell = floor(p);
	vec2 f = fract(p) - 0.5;
	float h = hash(cell);
	vec2 drift = vec2(h - 0.5, fract(h * 7.13) - 0.5) * 0.35;
	float d = length(f - drift);
	float spark = smoothstep(0.12, 0.02, d);
	return spark * step(0.72, h);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
}

void fragment() {
	vec2 flow_uv = world_pos.xz * detail_scale;
	flow_uv.y -= TIME * flow_speed * 0.08;

	float veins = soft_vein(flow_uv * vec2(1.1, 2.4));
	veins = max(veins * 0.75, soft_vein(flow_uv * vec2(2.3, 0.9) + 5.5) * 0.55);

	float particles = micro_particles(flow_uv * vec2(18.0, 42.0) + vec2(0.0, TIME * flow_speed));
	particles += micro_particles(flow_uv * vec2(28.0, 16.0) - vec2(TIME * flow_speed * 0.4, 0.0)) * 0.65;

	// 极弱的模块接缝，保持连续一体感
	float seam = smoothstep(0.02, 0.0, abs(fract(world_pos.z * 0.05) - 0.5) - 0.478);

	// 边缘轻微能量收束（不做成强霓虹条）
	float edge = smoothstep(5.2, 6.1, abs(local_pos.x));

	// 不透明固态能量体：偏青灰，略提亮静脉处
	vec3 albedo = base_color;
	albedo = mix(albedo, vein_color * 0.22, veins * 0.55);
	albedo = mix(albedo, vein_color * 0.18, seam * 0.35);
	albedo += particle_color * particles * 0.08;

	ALBEDO = albedo;
	ALPHA = 1.0;
	METALLIC = metallic_val;
	ROUGHNESS = mix(roughness_val, 0.28, veins * 0.4);
	SPECULAR = 0.22;

	// 低强度内嵌发光：静脉在表层下，粒子更细
	EMISSION = vein_color * veins * vein_energy
		+ particle_color * particles * particle_energy
		+ vein_color * seam * 0.35
		+ particle_color * edge * 0.25;
}
