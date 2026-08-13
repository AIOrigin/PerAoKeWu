shader_type spatial;
// 参考: https://gameidea.org/2026/02/01/creating-a-stylized-3d-water-shader/
// 兼容性优先：float hash + const 迭代；开阔水面也能看出波纹
render_mode blend_mix, depth_draw_opaque, cull_disabled, diffuse_burley, specular_schlick_ggx;

uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float max_depth : hint_range(0.1, 50.0) = 8.0;
uniform float fade_start_depth : hint_range(0.0, 50.0) = 0.4;
uniform vec3 underwater_fog_color : source_color = vec3(0.08, 0.22, 0.34);
uniform vec3 base_tint_color : source_color = vec3(0.50, 0.88, 0.98);
uniform vec3 deep_color : source_color = vec3(0.10, 0.38, 0.52);
uniform vec3 water_absorption : source_color = vec3(0.28, 0.08, 0.04);

uniform float sea_height : hint_range(0.0, 5.0) = 0.45;
uniform float sea_choppy : hint_range(0.0, 10.0) = 3.5;
uniform float sea_speed : hint_range(0.0, 5.0) = 1.5;
uniform float sea_freq : hint_range(0.0, 0.5) = 0.14;

uniform float refraction_strength : hint_range(0.0, 2.0) = 0.7;
uniform float normal_epsilon : hint_range(0.001, 1.0) = 0.025;
uniform float normal_smoothness_dist : hint_range(0.0, 1000.0) = 45.0;

uniform float roughness : hint_range(0.0, 1.0) = 0.1;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;
uniform float specular : hint_range(0.0, 1.0) = 0.65;

uniform vec3 foam_color : source_color = vec3(1.0, 1.0, 1.0);
uniform float foam_crest_amount : hint_range(0.0, 10.0) = 2.4;

const int ITER_GEOMETRY = 3;
const int ITER_FRAGMENT = 5;
const mat2 octave_m = mat2(vec2(1.6, 1.2), vec2(-1.2, 1.6));

varying vec3 world_vert;
varying float wave_height_v;
varying vec3 vertex_normal_world;

// float hash（避免部分后端 uint 哈希异常）
float hash12(vec2 p) {
	vec3 p3 = fract(vec3(p.xyx) * 0.1031);
	p3 += dot(p3, p3.yzx + 33.33);
	return fract((p3.x + p3.y) * p3.z);
}

float noise(in vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	vec2 u = f * f * (3.0 - 2.0 * f);
	return -1.0 + 2.0 * mix(
		mix(hash12(i + vec2(0.0, 0.0)), hash12(i + vec2(1.0, 0.0)), u.x),
		mix(hash12(i + vec2(0.0, 1.0)), hash12(i + vec2(1.0, 1.0)), u.x),
		u.y);
}

// 教程 sea_octave：尖峰状风格化波浪
float sea_octave(vec2 uv, float choppy) {
	uv += noise(uv);
	vec2 wv = 1.0 - abs(sin(uv));
	vec2 swv = abs(cos(uv));
	wv = mix(wv, swv, wv);
	return pow(1.0 - pow(max(wv.x * wv.y, 1e-5), 0.65), choppy);
}

float map_height(vec2 xz, float time, int iters) {
	float freq = sea_freq;
	float amp = sea_height;
	float choppy = sea_choppy;
	vec2 uv = xz;
	uv.x *= 0.75;
	float h = 0.0;
	for (int i = 0; i < 5; i++) {
		if (i >= iters) {
			break;
		}
		float d = sea_octave((uv + time * sea_speed) * freq, choppy);
		d += sea_octave((uv - time * sea_speed) * freq, choppy);
		h += d * amp;
		uv = octave_m * uv;
		freq *= 1.9;
		amp *= 0.22;
		choppy = mix(choppy, 1.0, 0.2);
	}
	return h;
}

vec3 get_normal_detailed(vec3 p, float eps, float time) {
	float h0 = map_height(p.xz, time, ITER_FRAGMENT);
	float hx = map_height(p.xz + vec2(eps, 0.0), time, ITER_FRAGMENT);
	float hz = map_height(p.xz + vec2(0.0, eps), time, ITER_FRAGMENT);
	return normalize(vec3(h0 - hx, eps, h0 - hz));
}

float get_linear_depth(sampler2D d_tex, vec2 uv, mat4 inv_proj) {
	float depth = texture(d_tex, uv).x;
	vec3 ndc = vec3(uv * 2.0 - 1.0, depth);
#if CURRENT_RENDERER == RENDERER_COMPATIBILITY
	ndc.z = depth * 2.0 - 1.0;
#endif
	vec4 view = inv_proj * vec4(ndc, 1.0);
	return -(view.z / max(view.w, 1e-5));
}

void vertex() {
	vec3 world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
	float h = map_height(world_pos.xz, TIME, ITER_GEOMETRY);
	VERTEX.y += h;
	wave_height_v = h;
	world_vert = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;

	float vertex_eps = 0.15;
	float h_x = map_height(world_pos.xz + vec2(vertex_eps, 0.0), TIME, ITER_GEOMETRY);
	float h_z = map_height(world_pos.xz + vec2(0.0, vertex_eps), TIME, ITER_GEOMETRY);
	vertex_normal_world = normalize(vec3(h - h_x, vertex_eps, h - h_z));
	NORMAL = vertex_normal_world;
}

void fragment() {
	float dist_to_cam = length(VERTEX);
	float lod_epsilon = max(normal_epsilon, dist_to_cam * 0.004);
	vec3 detailed_normal = get_normal_detailed(world_vert, lod_epsilon, TIME);
	float smooth_factor = clamp((dist_to_cam - normal_smoothness_dist) / 180.0, 0.0, 1.0);
	vec3 final_normal = mix(detailed_normal, vertex_normal_world, smooth_factor);
	NORMAL = (VIEW_MATRIX * vec4(final_normal, 0.0)).xyz;

	// 教程式海浪细节（片元，保证远距离也有纹理感）
	float d1 = sea_octave((world_vert.xz + TIME * sea_speed) * sea_freq * 2.2, sea_choppy);
	float d2 = sea_octave((world_vert.xz - TIME * sea_speed) * sea_freq * 3.0 + 12.0, sea_choppy * 0.9);
	float ripple = clamp(d1 * 0.55 + d2 * 0.45, 0.0, 1.0);
	float crest = smoothstep(0.15, 0.9, wave_height_v / max(sea_height, 0.001));
	crest = max(crest, smoothstep(0.62, 0.2, final_normal.y) * 0.85);

	vec3 surface_col = mix(deep_color, base_tint_color, ripple * 0.7 + 0.15);
	surface_col = mix(surface_col, base_tint_color * 1.2 + vec3(0.06, 0.1, 0.12), crest * 0.5);
	float fres = pow(1.0 - clamp(dot(normalize(NORMAL), normalize(VIEW)), 0.0, 1.0), 2.5);
	surface_col = mix(surface_col, vec3(0.82, 0.92, 1.0), fres * 0.55);

	// 深度折射（近岸有几何时增强；开阔水面仍以 surface_col 为主）
	float water_linear_depth = -VERTEX.z;
	float bg_linear_depth = get_linear_depth(DEPTH_TEXTURE, SCREEN_UV, INV_PROJECTION_MATRIX);
	float thickness = max(0.0, bg_linear_depth - water_linear_depth);

	vec3 view_vertex_normal = (VIEW_MATRIX * vec4(vertex_normal_world, 0.0)).xyz;
	vec2 normal_offset = NORMAL.xy - view_vertex_normal.xy;
	float near_bed = smoothstep(0.04, 2.0, thickness) * (1.0 - smoothstep(max_depth * 0.4, max_depth, thickness));
	vec2 distorted_uv = SCREEN_UV + normal_offset * refraction_strength * near_bed * 0.045;
	float dist_bg = get_linear_depth(DEPTH_TEXTURE, distorted_uv, INV_PROJECTION_MATRIX);
	if (dist_bg < water_linear_depth - 0.001) {
		distorted_uv = SCREEN_UV;
		dist_bg = bg_linear_depth;
	}
	thickness = max(0.0, dist_bg - water_linear_depth);
	near_bed = smoothstep(0.04, 2.0, thickness) * (1.0 - smoothstep(max_depth * 0.4, max_depth, thickness));

	vec3 screen_color = texture(SCREEN_TEXTURE, distorted_uv).rgb;
	float depth_ratio = clamp((thickness - fade_start_depth) / max(0.001, max_depth - fade_start_depth), 0.0, 1.0);
	vec3 transmittance = exp(-thickness * water_absorption);
	vec3 underwater = mix(underwater_fog_color, screen_color * mix(base_tint_color, deep_color, depth_ratio), transmittance);

	ALBEDO = mix(surface_col, underwater, near_bed * 0.5);

	// 波峰白沫
	float foam = crest * foam_crest_amount * 0.22;
	foam *= smoothstep(0.35, 0.85, ripple);
	ALBEDO = mix(ALBEDO, foam_color, clamp(foam, 0.0, 0.65));

	ROUGHNESS = mix(roughness, 0.45, clamp(foam, 0.0, 1.0));
	METALLIC = metallic;
	SPECULAR = mix(specular, 0.9, fres);
	ALPHA = 1.0;
}
