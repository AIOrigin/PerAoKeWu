shader_type spatial;
// 全息能量轨：贴图（提示词生成）+ 流动光波 / 电路叠加。贴地、不透明。
render_mode cull_back, diffuse_burley, specular_schlick_ggx, ambient_light_disabled;

uniform sampler2D road_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 base_color : source_color = vec3(0.02, 0.1, 0.18);
uniform vec3 plasma_color : source_color = vec3(0.3, 0.96, 1.0);
uniform vec3 circuit_color : source_color = vec3(0.5, 1.0, 1.0);
uniform vec3 edge_color : source_color = vec3(0.9, 0.35, 1.0);
uniform float roughness_val : hint_range(0.0, 1.0) = 0.16;
uniform float metallic_val : hint_range(0.0, 1.0) = 0.04;
uniform float tex_blend : hint_range(0.0, 1.0) = 0.85;
uniform float plasma_energy : hint_range(0.0, 10.0) = 2.8;
uniform float flow_energy : hint_range(0.0, 6.0) = 1.8;
uniform float wave_speed = 1.15;
uniform float scroll_speed = 0.22;
uniform float road_half_width = 6.0;
uniform float tex_length_scale = 0.085;

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

float circuit_mask(vec2 p) {
	float gx = abs(fract(p.x * 4.0) - 0.5);
	float gz = abs(fract(p.y * 10.0) - 0.5);
	float lines = smoothstep(0.04, 0.0, gx) + smoothstep(0.035, 0.0, gz);
	float nodes = smoothstep(0.1, 0.0, length(fract(p * vec2(6.0, 14.0)) - 0.5));
	return clamp(lines * 0.45 + nodes * 0.8, 0.0, 1.0);
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	local_pos = VERTEX;
}

void fragment() {
	// 横向跨路宽映射贴图 U；纵向沿世界前进方向滚动
	float u = clamp(local_pos.x / max(road_half_width, 0.001) * 0.5 + 0.5, 0.0, 1.0);
	float v = world_pos.z * tex_length_scale - TIME * scroll_speed;
	vec2 tex_uv = vec2(u, v);
	vec4 tex = texture(road_tex, tex_uv);

	float wave = pow(0.5 + 0.5 * sin(world_pos.z * 0.5 - TIME * wave_speed), 2.6);
	float wave2 = pow(0.5 + 0.5 * sin(world_pos.z * 1.05 - TIME * wave_speed * 1.4 + 1.3), 3.2);
	float circuit = circuit_mask(vec2(u, v));
	float core = pow(smoothstep(1.15, 0.0, abs(local_pos.x)), 2.4);
	float edge = smoothstep(road_half_width * 0.78, road_half_width * 0.98, abs(local_pos.x));
	float nav = smoothstep(0.07, 0.0, abs(fract(world_pos.z * 0.16 - TIME * 0.3) - 0.5) - 0.36);
	nav *= smoothstep(2.4, 0.0, abs(local_pos.x));

	vec3 procedural = mix(base_color, plasma_color * 0.4, core * 0.7 + wave * 0.25);
	procedural = mix(procedural, circuit_color * 0.3, circuit * 0.55);
	procedural = mix(procedural, edge_color * 0.35, edge);

	// 贴图主导，程序化补流动与边缘能量
	vec3 albedo = mix(procedural, tex.rgb, tex_blend * tex.a);
	albedo = mix(albedo, plasma_color * 0.55, wave * 0.12);
	albedo = mix(albedo, edge_color * 0.45, edge * 0.35);

	ALBEDO = albedo;
	ALPHA = 1.0;
	METALLIC = metallic_val;
	ROUGHNESS = mix(roughness_val, 0.32, circuit * 0.35);
	SPECULAR = 0.42;

	vec3 tex_emit = tex.rgb * (0.55 + wave * 0.65);
	EMISSION = tex_emit * plasma_energy * tex_blend
		+ plasma_color * (core * 1.2 + wave * 0.8 + wave2 * 0.5) * flow_energy * 0.45
		+ circuit_color * circuit * 1.4
		+ plasma_color * nav * 2.0
		+ edge_color * edge * 4.2;
}
