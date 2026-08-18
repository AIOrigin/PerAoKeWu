shader_type spatial;
// 玻璃沙漠环境地面：贴图 + 暖色校正 +  procedural 起伏 + 条带内缘羽化
render_mode cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D ground_tex : source_color, filter_linear_mipmap, repeat_enable;
uniform vec3 sand_tint : source_color = vec3(0.94, 0.72, 0.46);
uniform vec3 warm_tint : source_color = vec3(0.88, 0.54, 0.28);
uniform vec3 cool_shadow : source_color = vec3(0.52, 0.34, 0.22);
uniform vec3 dust_veil : source_color = vec3(0.78, 0.58, 0.36);
uniform float tex_scale = 0.018;
uniform float detail_scale = 0.24;
uniform float roughness_val : hint_range(0.0, 1.0) = 0.96;
uniform float inner_feather : hint_range(0.0, 1.0) = 0.52;
uniform float tone_warmth : hint_range(0.0, 1.0) = 0.62;

varying vec3 world_pos;
varying vec4 v_color;

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
		p = p * 2.03 + vec2(3.1, 1.7);
		a *= 0.5;
	}
	return v;
}

void vertex() {
	world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	v_color = COLOR;
}

void fragment() {
	vec2 wuv = world_pos.xz * tex_scale;
	vec2 det = world_pos.xz * detail_scale;

	// 世界空间采样，避免条带 UV 接缝
	vec3 tex = texture(ground_tex, wuv).rgb;
	float dunes = fbm(det * vec2(0.48, 1.35));
	float ripples = fbm(det * vec2(3.6, 8.2) + dunes * 1.1);
	float grain = fbm(det * vec2(11.0, 15.0));

	vec3 albedo = tex * sand_tint;
	albedo = mix(albedo, albedo * warm_tint, tone_warmth);
	albedo = mix(albedo, dust_veil, ripples * 0.18 + dunes * 0.1);
	albedo *= 0.92 + grain * 0.14 + dunes * 0.08;

	// COLOR.r：0=条带靠跑道一侧，1=外侧；内缘做暖影过渡
	float edge_mask = smoothstep(0.0, inner_feather, v_color.r);
	float center_mask = (v_color.b <= 0.001) ? 1.0 : smoothstep(0.0, 0.62, v_color.b);
	albedo = mix(cool_shadow, albedo, edge_mask * center_mask);

	// 极弱横向风纹，打破贴图方块感
	float wind = pow(0.5 + 0.5 * sin(world_pos.z * 0.19 + dunes * 5.5), 3.0);
	albedo = mix(albedo, dust_veil * 0.95, wind * 0.05);

	ALBEDO = albedo;
	ROUGHNESS = mix(roughness_val, 0.82, grain * 0.2);
	METALLIC = 0.0;
	SPECULAR = 0.04;
}
