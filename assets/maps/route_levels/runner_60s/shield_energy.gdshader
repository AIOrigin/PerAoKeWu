shader_type spatial;
render_mode blend_add, cull_disabled, depth_draw_never, unshaded, shadows_disabled, fog_disabled;

uniform vec4 core_tint : source_color = vec4(1.0, 0.42, 0.58, 0.04);
uniform vec4 rim_tint : source_color = vec4(1.0, 0.58, 0.74, 0.36);
uniform vec4 spark_tint : source_color = vec4(1.0, 0.92, 0.96, 1.0);
uniform float energy_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float pulse : hint_range(0.5, 1.5) = 1.0;
uniform float storm_boost : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec3 n = normalize(NORMAL);
	vec3 v = normalize(VIEW);
	float ndv = clamp(dot(n, v), 0.0, 1.0);
	float fresnel = pow(1.0 - ndv, 2.35);
	float rim = smoothstep(0.14, 0.88, fresnel);

	float lat = asin(clamp(n.y, -1.0, 1.0));
	float lon = atan(n.z, n.x);
	float hex_a = sin(lon * 18.0 + lat * 11.0) * sin(lon * 9.0 - lat * 13.0);
	float hex = smoothstep(0.78, 0.94, hex_a * 0.5 + 0.5) * rim * 0.30;

	float sweep = sin(lon * 3.0 + lat * 2.0 + TIME * 1.2) * 0.5 + 0.5;
	sweep = pow(sweep, 5.0) * rim * 0.08;

	vec3 col = mix(core_tint.rgb, rim_tint.rgb, rim);
	col += spark_tint.rgb * (sweep + hex) * (0.38 + storm_boost * 0.16);

	float alpha = core_tint.a + rim_tint.a * rim * 0.95;
	alpha += (sweep + hex) * 0.08;
	alpha *= (0.76 + 0.24 * energy_ratio) * pulse;
	alpha = clamp(alpha, 0.0, 0.34);

	float glow = 0.52 + rim * 1.18 + (sweep + hex) * 0.36 + storm_boost * 0.18;
	ALBEDO = col;
	EMISSION = col * glow * energy_ratio * pulse;
	ALPHA = alpha;
}
