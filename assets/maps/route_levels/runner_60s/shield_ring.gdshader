shader_type spatial;
render_mode blend_add, cull_disabled, depth_draw_never, unshaded, fog_disabled;

uniform vec4 ring_color : source_color = vec4(0.55, 0.95, 1.0, 0.75);
uniform float energy_ratio : hint_range(0.0, 1.0) = 1.0;
uniform float pulse : hint_range(0.5, 1.5) = 1.0;
uniform float flow_speed = 1.6;

void fragment() {
	float u = UV.x;
	float streak = sin(u * 42.0 + TIME * flow_speed) * 0.5 + 0.5;
	streak = pow(streak, 4.0);
	float fade = smoothstep(0.0, 0.12, min(UV.y, 1.0 - UV.y));
	vec3 col = ring_color.rgb * (0.65 + streak * 0.85);
	float alpha = ring_color.a * fade * energy_ratio * pulse;
	ALBEDO = col;
	EMISSION = col * (1.6 + streak * 2.2);
	ALPHA = alpha;
}
