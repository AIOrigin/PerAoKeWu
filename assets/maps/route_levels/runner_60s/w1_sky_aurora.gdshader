shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded, depth_draw_never, fog_disabled;

uniform vec4 color_a : source_color = vec4(0.72, 0.48, 0.98, 0.38);
uniform vec4 color_b : source_color = vec4(0.35, 0.82, 1.0, 0.28);
uniform float scroll_speed : hint_range(0.0, 0.2) = 0.042;
uniform float band_seed : hint_range(0.0, 8.0) = 0.0;
uniform float horizon_glow : hint_range(0.0, 3.0) = 1.0;
uniform float float_strength : hint_range(0.0, 1.0) = 0.42;

float _band(vec2 uv, float seed) {
	vec2 p = uv * vec2(2.6, 4.2) + vec2(seed * 1.3, seed * 0.7);
	p.x += TIME * scroll_speed * (0.8 + seed * 0.12);
	float wave = sin(p.x * 3.1 + p.y * 1.8) * 0.5
		+ sin(p.x * 6.4 - p.y * 2.6 + seed) * 0.28
		+ sin(p.x * 11.0 + p.y * 4.8 - TIME * 0.35) * 0.14;
	wave = wave * 0.5 + 0.5;
	return smoothstep(0.32, 0.78, wave);
}

void fragment() {
	float h = clamp(UV.y, 0.0, 1.0);
	float side = 1.0 - smoothstep(0.62, 1.0, abs(UV.x - 0.5) * 2.0);
	float rise = smoothstep(0.0, 0.08, h);
	float fall = 1.0 - smoothstep(0.78, 1.0, h);

	// 天边带：幕布底部更亮，模拟地平线极光
	float horizon = pow(1.0 - smoothstep(0.0, 0.52, h), 2.1) * horizon_glow;
	// 缓慢上下浮动 + 帘幕轻摆
	float drift_y = sin(TIME * 0.38 + UV.x * 5.2 + band_seed * 1.6) * float_strength * 0.14;
	float sway_x = sin(TIME * 0.22 + h * 4.0 + band_seed) * float_strength * 0.06;
	vec2 anim_uv = UV + vec2(sway_x, drift_y);

	float b1 = _band(anim_uv, band_seed);
	float b2 = _band(anim_uv + vec2(0.31, -0.18), band_seed + 1.7);
	float b3 = _band(anim_uv * 1.18 + vec2(-0.12, 0.24), band_seed + 3.1);
	float bands = clamp(b1 * 0.48 + b2 * 0.36 + b3 * 0.28, 0.0, 1.0);

	vec3 col = mix(color_a.rgb, color_b.rgb, pow(h, 0.55));
	col += color_b.rgb * bands * 0.72;
	col += mix(color_a.rgb, color_b.rgb, 0.5) * horizon * 0.85;

	float alpha = bands * rise * fall * side;
	alpha += horizon * side * rise * 0.55;
	alpha *= mix(color_a.a, color_b.a, h);
	alpha = clamp(alpha, 0.0, mix(0.42, 0.62, horizon * 0.35));

	ALBEDO = col;
	EMISSION = col * (0.38 + bands * 0.95 + horizon * 1.65);
	ALPHA = alpha;
}
