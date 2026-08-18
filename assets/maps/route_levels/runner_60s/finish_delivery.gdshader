shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_prepass_alpha;

uniform vec4 base_color : source_color = vec4(0.18, 0.82, 1.0, 0.55);
uniform vec4 scan_color : source_color = vec4(0.92, 1.0, 1.0, 0.95);
uniform float scan_speed = 1.35;
uniform float band_width = 0.11;
uniform float grid_strength = 0.22;

void fragment() {
	float scan = fract(UV.y * 0.65 - TIME * scan_speed);
	scan = smoothstep(band_width, 0.0, abs(scan - 0.5) * 2.0);
	float grid_x = smoothstep(0.92, 1.0, abs(fract(UV.x * 14.0) - 0.5) * 2.0);
	float grid_y = smoothstep(0.92, 1.0, abs(fract(UV.y * 10.0 + TIME * 0.15) - 0.5) * 2.0);
	float grid = max(grid_x, grid_y) * grid_strength;
	float rim = smoothstep(0.78, 0.98, max(abs(UV.x - 0.5) * 2.0, abs(UV.y - 0.5) * 2.0));
	vec3 col = mix(base_color.rgb, scan_color.rgb, scan + grid);
	col += scan_color.rgb * rim * 0.65;
	float alpha = (0.12 + scan * 0.62 + grid + rim * 0.28) * base_color.a;
	ALBEDO = col;
	EMISSION = col * (1.15 + scan * 2.4 + rim);
	ALPHA = clamp(alpha, 0.0, 0.92);
}
