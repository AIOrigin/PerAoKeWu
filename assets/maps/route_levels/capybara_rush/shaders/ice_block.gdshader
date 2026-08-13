// Adapted from nekotogd/Godot_Parallax_Ice_3D (CC0)
// https://github.com/nekotogd/Godot_Parallax_Ice_3D
// DepthIce_v2 → Godot 4.x；切线空间视差，适配立方体面
shader_type spatial;
render_mode blend_mix, depth_draw_opaque, cull_back, diffuse_burley, specular_schlick_ggx;

uniform sampler2D over_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D under_texture : source_color, filter_linear_mipmap, repeat_enable;
uniform sampler2D surface_normalmap : hint_normal, filter_linear_mipmap, repeat_enable;

uniform vec4 top_color : source_color = vec4(0.6764, 0.980092, 1.0, 1.0);
uniform vec4 deep_tint : source_color = vec4(0.25, 0.55, 0.85, 1.0);
uniform float depth = 0.12;
uniform float normal_depth = 1.15;
uniform float roughness : hint_range(0.0, 1.0) = 0.08;
uniform float metallic : hint_range(0.0, 1.0) = 0.35;
uniform float refractive_index = 0.14;
uniform float fresnel_power : hint_range(0.5, 5.0) = 2.6;
uniform float alpha_base : hint_range(0.2, 1.0) = 0.82;
uniform float emission_mul : hint_range(0.0, 2.0) = 0.28;
uniform float uv_scale = 1.35;

float blendOverlay_f(float base, float blend) {
	float branchless = step(base, 0.5);
	return (2.0 * base * blend) * branchless
		+ (1.0 - 2.0 * (1.0 - base) * (1.0 - blend)) * (1.0 - branchless);
}

vec3 blendOverlay(vec3 base, vec3 blend) {
	return vec3(
		blendOverlay_f(base.r, blend.r),
		blendOverlay_f(base.g, blend.g),
		blendOverlay_f(base.b, blend.b)
	);
}

void fragment() {
	vec2 uv = UV * uv_scale;
	vec3 ntex = texture(surface_normalmap, uv).xyz * 2.0 - 1.0;
	NORMAL_MAP = texture(surface_normalmap, uv).xyz;
	NORMAL_MAP_DEPTH = normal_depth;

	// VIEW / TBN 均在视图空间 → 切线空间视线，立方体六面可用
	vec3 view_t = normalize(vec3(
		dot(VIEW, TANGENT),
		dot(VIEW, BINORMAL),
		dot(VIEW, NORMAL)
	));
	view_t = normalize(view_t - ntex * refractive_index);
	vec2 offset = (view_t.xy / max(view_t.z, 0.15)) * max(depth, 0.001);

	vec3 over_color = texture(over_texture, uv).rgb;
	vec3 color = blendOverlay(over_color, top_color.rgb);
	vec3 under_color = texture(under_texture, uv + offset + ntex.xy * 0.35).rgb;
	vec3 ice = blendOverlay(color, under_color);
	ice = mix(ice, deep_tint.rgb, 0.18);

	float fres = pow(1.0 - clamp(dot(NORMAL, VIEW), 0.0, 1.0), fresnel_power);
	ice = mix(ice, top_color.rgb, fres * 0.35);

	ALBEDO = ice;
	ALPHA = clamp(alpha_base + fres * 0.12, 0.45, 0.95);
	ROUGHNESS = mix(roughness, 0.35, fres * 0.25);
	METALLIC = metallic;
	SPECULAR = 0.85;
	EMISSION = top_color.rgb * fres * emission_mul;
}
