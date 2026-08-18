shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded, depth_draw_never, fog_disabled;

uniform vec4 horizon_color : source_color = vec4(0.72, 0.58, 0.92, 0.18);
uniform vec4 zenith_color : source_color = vec4(0.55, 0.42, 0.78, 0.04);
uniform float approach_boost : hint_range(0.0, 1.0) = 0.0;
uniform float grid_strength : hint_range(0.0, 1.0) = 0.0;
uniform float interior_glow : hint_range(0.0, 1.0) = 0.0;

// 淡紫色祥云：贴地软雾，向上自然消散，避免硬水平切边
float _cloud(vec2 uv, float seed) {
	vec2 p = uv * vec2(3.4, 2.8) + vec2(seed * 1.7, seed * 0.9);
	p.x += TIME * 0.016 * (0.6 + seed);
	float n = sin(p.x * 2.1 + p.y * 1.3) * 0.5
		+ sin(p.x * 4.7 - p.y * 2.2 + seed) * 0.28
		+ sin(p.x * 8.3 + p.y * 5.1 - TIME * 0.12) * 0.14;
	n = n * 0.5 + 0.5;
	float lobe = smoothstep(0.42, 0.78, n);
	float soft = smoothstep(0.18, 0.55, n) * (1.0 - smoothstep(0.72, 0.98, n));
	return max(lobe * 0.55, soft * 0.85);
}

void fragment() {
	float h = clamp(UV.y, 0.0, 1.0);
	// 贴地雾带：底部极软起雾，很快向上消散，不形成腰线硬边
	float ground_fade = smoothstep(0.0, 0.05, h); // 贴地微透明，避免硬切地缝
	float height_falloff = 1.0 - smoothstep(0.08, 0.42, h);
	float band = ground_fade * height_falloff;
	float c1 = _cloud(UV, 0.2);
	float c2 = _cloud(UV + vec2(0.37, -0.18), 1.1);
	float c3 = _cloud(UV * 1.35 + vec2(-0.22, 0.31), 2.4);
	float clouds = clamp(c1 * 0.5 + c2 * 0.38 + c3 * 0.32, 0.0, 1.0) * band;

	// 底层薄雾：贴地更实、向上指数变淡，和跑道自然衔接
	float ground_haze = pow(1.0 - smoothstep(0.0, 0.34, h), 1.65) * ground_fade;

	vec3 col = mix(horizon_color.rgb, zenith_color.rgb, pow(h, 0.55));
	col = mix(col, vec3(0.84, 0.72, 0.98), clouds * 0.45 + ground_haze * 0.35);
	col += vec3(0.28, 0.18, 0.4) * interior_glow * 0.05;

	float alpha = ground_haze * mix(0.14, 0.22, approach_boost * 0.4);
	alpha += clouds * mix(0.1, 0.18, approach_boost * 0.35 + interior_glow * 0.15);
	alpha *= mix(horizon_color.a, zenith_color.a, h);
	// 左右柔边，避免整面矩形遮罩感
	float side = 1.0 - smoothstep(0.72, 1.0, abs(UV.x - 0.5) * 2.0);
	alpha *= mix(0.55, 1.0, side);
	alpha = clamp(alpha, 0.0, 0.28);

	ALBEDO = col;
	EMISSION = col * (0.18 + clouds * 0.35 + ground_haze * 0.25 + approach_boost * 0.1);
	ALPHA = alpha;
}
