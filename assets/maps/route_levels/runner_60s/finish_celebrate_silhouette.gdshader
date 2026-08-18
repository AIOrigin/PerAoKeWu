shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded, depth_prepass_alpha;

uniform vec4 body_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform vec4 glow_color : source_color = vec4(0.98, 0.98, 1.0, 1.0);
uniform float approach_boost : hint_range(0.0, 1.0) = 0.0;
uniform float celebrate : hint_range(0.0, 1.0) = 0.0;
uniform float pulse : hint_range(0.5, 1.5) = 1.0;

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float fresnel = pow(1.0 - clamp(dot(n, v), 0.0, 1.0), 2.4);
	vec3 col = body_color.rgb;
	col = mix(col, glow_color.rgb, fresnel * (0.55 + approach_boost * 0.35 + celebrate * 0.45));
	float glow = fresnel * (2.2 + approach_boost * 2.0 + celebrate * 3.5) * pulse;
	ALBEDO = col;
	EMISSION = glow_color.rgb * glow;
	ALPHA = 1.0;
}
