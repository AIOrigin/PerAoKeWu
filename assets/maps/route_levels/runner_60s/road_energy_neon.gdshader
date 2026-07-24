shader_type spatial;
// 参考：黑亮能量轨道。关闭环境光，避免沙漠橙雾把路面染成「熔岩水」。
render_mode cull_back, diffuse_burley, specular_schlick_ggx, ambient_light_disabled;

uniform vec3 base_color : source_color = vec3(0.01, 0.015, 0.03);
uniform vec3 vein_color : source_color = vec3(0.2, 0.95, 1.0);
uniform vec3 seam_color : source_color = vec3(1.0, 0.55, 0.2);
uniform float roughness_val : hint_range(0.0, 1.0) = 0.22;
uniform float metallic_val : hint_range(0.0, 1.0) = 0.08;
uniform float vein_energy : hint_range(0.0, 12.0) = 4.5;
uniform float seam_energy : hint_range(0.0, 8.0) = 2.2;
uniform float scroll_speed = 0.08;
uniform float crack_scale = 0.12;

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
		p = p * 2.13 + vec2(1.7, 9.2);
		a *= 0.5;
	}
	return v;
}

// 细裂纹：噪声脊线
float crack_mask(vec2 p) {
	float n = fbm(p);
	float ridge = 1.0 - abs(n * 2.0 - 1.0);
	float thin = pow(smoothstep(0.55, 0.92, ridge), 3.5);
	float branch = pow(smoothstep(0.6, 0.95, 1.0 - abs(fbm(p.yx * 1.4 + 3.1) * 2.0 - 1.0)), 4.0);
	return clamp(thin * 0.85 + branch * 0.55, 0.0, 1.0);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
}

void fragment() {
	// 用世界 XZ，但裂纹以「细丝」为主，避免大块横波
	vec2 uv = world_pos.xz * crack_scale;
	uv += vec2(0.0, TIME * scroll_speed);

	float cracks = crack_mask(uv * vec2(1.0, 2.6));
	cracks = max(cracks, crack_mask(uv * vec2(2.2, 0.7) + 12.0) * 0.65);

	// 板块横缝（细、亮、偏青）
	float tile = abs(fract(world_pos.z * 0.09) - 0.5);
	float seam = smoothstep(0.028, 0.0, tile - 0.452);

	// 中心微弱纵向高光条，增加轨道感
	float center_line = smoothstep(0.55, 0.0, abs(local_pos.x) * 0.35);

	vec3 albedo = base_color;
	albedo += vein_color * cracks * 0.04;
	albedo += vein_color * seam * 0.06;

	ALBEDO = albedo;
	METALLIC = metallic_val;
	ROUGHNESS = mix(roughness_val, 0.45, cracks);
	SPECULAR = 0.35;

	EMISSION = vein_color * cracks * vein_energy
		+ vein_color * seam * seam_energy
		+ seam_color * seam * step(0.7, fract(world_pos.z * 0.045 + 0.1)) * 1.8
		+ vein_color * center_line * 0.15;
}
