shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_prepass_alpha;

uniform vec4 wave_color : source_color = vec4(0.48, 0.96, 1.0, 0.72);
uniform vec4 accent_color : source_color = vec4(1.0, 0.78, 0.28, 1.0);
uniform float approach_boost : hint_range(0.0, 1.0) = 0.0;
uniform float pulse : hint_range(0.5, 1.5) = 1.0;

void fragment() {
	float ripple = sin(UV.x * 34.0 - TIME * 3.2) * sin(UV.y * 12.0 + TIME * 2.2);
	ripple = ripple * 0.5 + 0.5;
	float scan = fract(UV.y * 0.72 - TIME * 1.35);
	scan = smoothstep(0.08, 0.0, abs(scan - 0.5) * 2.0);
	float edge = smoothstep(0.88, 0.98, max(abs(UV.x - 0.5) * 2.0, abs(UV.y - 0.5) * 2.0));
	float sparkle = sin(UV.x * 80.0 + TIME * 6.0) * sin(UV.y * 40.0 - TIME * 4.5);
	sparkle = smoothstep(0.92, 1.0, sparkle * 0.5 + 0.5);
	vec3 col = mix(wave_color.rgb, accent_color.rgb, scan * 0.55 + edge * 0.35 + sparkle * 0.25);
	float alpha = (ripple * 0.32 + scan * 0.78 + edge * 0.42 + sparkle * 0.35);
	alpha *= wave_color.a * (0.55 + approach_boost * 0.45) * pulse;
	ALBEDO = col;
	EMISSION = col * (1.8 + scan * 3.2 + approach_boost * 2.8 + sparkle * 2.0) * pulse;
	ALPHA = clamp(alpha, 0.0, 0.98);
}
