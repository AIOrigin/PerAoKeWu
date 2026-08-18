shader_type spatial;
render_mode blend_add, cull_disabled, unshaded, depth_draw_never, fog_disabled;

uniform vec4 core_color : source_color = vec4(0.68, 0.52, 0.92, 0.45);
uniform vec4 rim_color : source_color = vec4(0.48, 0.72, 0.92, 0.35);
uniform float pulse_speed : hint_range(0.0, 4.0) = 0.85;
uniform float pillar_seed : hint_range(0.0, 8.0) = 0.0;
uniform float intensity : hint_range(0.0, 1.0) = 0.42;

void fragment() {
	float h = clamp(UV.y, 0.0, 1.0);
	float w = abs(UV.x - 0.5) * 2.0;
	float core = 1.0 - smoothstep(0.0, 0.46, w);
	float base = smoothstep(0.0, 0.10, h);
	float tip = 1.0 - smoothstep(0.80, 1.0, h);

	float flicker = sin(TIME * pulse_speed * 7.0 + h * 20.0 + pillar_seed) * 0.10 + 0.90;
	float streak = sin(h * 36.0 - TIME * 1.8 + pillar_seed * 3.0) * 0.5 + 0.5;
	streak = smoothstep(0.58, 1.0, streak);

	vec3 col = mix(rim_color.rgb, core_color.rgb, core);
	col += core_color.rgb * streak * core * 0.22;

	float alpha = core * base * tip * flicker * 0.58 * intensity;
	ALBEDO = col;
	EMISSION = col * (0.95 + streak * 0.35) * intensity;
	ALPHA = alpha;
}
