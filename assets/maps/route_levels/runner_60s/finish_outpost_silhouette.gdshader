shader_type spatial;
render_mode blend_mix, cull_disabled, depth_draw_opaque, unshaded;

uniform vec4 body_color : source_color = vec4(0.04, 0.055, 0.09, 1.0);
uniform vec4 rim_color : source_color = vec4(0.3, 0.45, 0.6, 1.0);
uniform vec4 window_glow : source_color = vec4(0.12, 0.2, 0.3, 1.0);
uniform float approach_boost : hint_range(0.0, 1.0) = 0.0;
uniform float pulse : hint_range(0.6, 1.4) = 1.0;

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float ndv = clamp(dot(n, v), 0.0, 1.0);
	float fresnel = pow(1.0 - ndv, 3.2);

	vec3 col = body_color.rgb;
	col = mix(col, rim_color.rgb, fresnel * (0.12 + approach_boost * 0.18));

	ALBEDO = col;
	EMISSION = col * fresnel * (0.15 + approach_boost * 0.25) * pulse;
	ALPHA = 1.0;
}
