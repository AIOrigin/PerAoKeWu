shader_type spatial;
render_mode blend_add, cull_disabled, depth_draw_never, unshaded, shadows_disabled, fog_disabled;

uniform vec4 core_tint : source_color = vec4(0.16, 0.58, 0.98, 0.06);
uniform vec4 rim_tint : source_color = vec4(0.38, 0.82, 1.0, 0.44);
uniform vec4 spark_tint : source_color = vec4(0.94, 0.98, 1.0, 1.0);
uniform float energy_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float pulse : hint_range(0.5, 1.5) = 1.0;
uniform float storm_boost : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float ndv = clamp(dot(n, v), 0.0, 1.0);
	float fresnel = pow(1.0 - ndv, 2.15);
	float rim = smoothstep(0.10, 0.90, fresnel);

	float lat = asin(clamp(n.y, -1.0, 1.0));
	float lon = atan(n.z, n.x);
	float hex_a = sin(lon * 20.0 + lat * 12.0) * sin(lon * 10.0 - lat * 14.0);
	float hex = smoothstep(0.58, 0.86, hex_a * 0.5 + 0.5);
	hex *= mix(0.42, 0.88, rim);

	float sweep = sin(lon * 3.0 + lat * 2.0 + TIME * 1.2) * 0.5 + 0.5;
	sweep = pow(sweep, 5.0) * rim * 0.10;

	float ring_eq = smoothstep(0.028, 0.0, abs(n.y));
	float ring_vert = smoothstep(0.028, 0.0, abs(n.x));
	float gimbal = max(ring_eq, ring_vert) * (0.62 + energy_ratio * 0.28);

	vec3 col = mix(core_tint.rgb, rim_tint.rgb, rim);
	col += spark_tint.rgb * (hex * 0.72 + sweep * 0.22 + gimbal * 0.95);
	col += vec3(0.92, 0.98, 1.0) * gimbal * 0.38;

	float alpha = core_tint.a + rim_tint.a * rim * 0.92;
	alpha += hex * 0.14 + gimbal * 0.12;
	alpha *= (0.78 + 0.22 * energy_ratio) * pulse;
	alpha = clamp(alpha, 0.0, 0.42);

	float glow = 0.58 + rim * 1.22 + hex * 0.48 + gimbal * 0.95 + storm_boost * 0.18;
	ALBEDO = col;
	EMISSION = col * glow * energy_ratio * pulse;
	ALPHA = alpha;
}
