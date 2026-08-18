shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_prepass_alpha;

uniform vec4 base_color : source_color = vec4(0.32, 0.42, 0.92, 0.78);
uniform vec4 scan_color : source_color = vec4(0.72, 0.9, 1.0, 0.98);
uniform vec4 accent_color : source_color = vec4(0.62, 0.48, 0.98, 1.0);
uniform float scan_speed = 1.85;
uniform float band_width = 0.08;
uniform float gate_open : hint_range(0.0, 1.0) = 0.0;
uniform float pulse = 1.0;

void fragment() {
	float scan = fract(UV.y * 0.72 - TIME * scan_speed);
	scan = smoothstep(band_width, 0.0, abs(scan - 0.5) * 2.0);
	float ripple = sin(UV.x * 28.0 + TIME * 2.4) * 0.5 + 0.5;
	float wave2 = sin(UV.y * 18.0 - TIME * 1.6 + UV.x * 6.0) * 0.5 + 0.5;
	float rim = smoothstep(0.78, 0.98, max(abs(UV.x - 0.5) * 2.0, abs(UV.y - 0.5) * 2.0));
	float grid = step(0.92, fract(UV.x * 18.0)) + step(0.92, fract(UV.y * 10.0));
	vec3 col = mix(base_color.rgb, scan_color.rgb, scan * 0.7 + ripple * 0.18);
	col = mix(col, accent_color.rgb, wave2 * 0.22 + rim * 0.28);
	col += accent_color.rgb * grid * 0.18;
	float band = 1.0 - smoothstep(0.42, 0.98, abs(UV.y - 0.5) * 2.0);
	float side = 1.0 - smoothstep(0.82, 1.0, abs(UV.x - 0.5) * 2.0);
	float alpha = (0.42 + scan * 0.38 + rim * 0.22 + wave2 * 0.10) * base_color.a * band * side;
	alpha *= mix(0.72, 1.12, gate_open);
	alpha *= pulse;
	ALBEDO = col;
	EMISSION = col * (1.55 + scan * 3.0 + rim * 1.8) * pulse;
	ALPHA = clamp(alpha, 0.0, 0.96);
}
