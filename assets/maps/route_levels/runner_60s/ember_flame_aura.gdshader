shader_type spatial;
render_mode blend_add, cull_disabled, depth_draw_never, unshaded, shadows_disabled, fog_disabled;

uniform vec4 core_color : source_color = vec4(1.0, 0.96, 0.88, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.45, 0.18, 0.95);
uniform vec4 tip_color : source_color = vec4(0.35, 0.7, 1.0, 0.0);
uniform float intensity : hint_range(0.0, 3.0) = 1.35;
uniform float pulse : hint_range(0.4, 1.8) = 1.0;
uniform float flow_speed = 4.2;
uniform float ring_inner : hint_range(0.0, 0.9) = 0.14;
uniform float ring_outer : hint_range(0.2, 1.4) = 1.02;
uniform float tongue_strength : hint_range(0.0, 1.0) = 0.92;
uniform float vertical_soft : hint_range(0.0, 1.0) = 0.0;

float hash21(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise21(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash21(i);
	float b = hash21(i + vec2(1.0, 0.0));
	float c = hash21(i + vec2(0.0, 1.0));
	float d = hash21(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	for (int i = 0; i < 2; i++) {
		v += a * noise21(p);
		p *= 2.05;
		a *= 0.5;
	}
	return v;
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	float r = length(uv);
	float ang = atan(uv.y, uv.x);

	// 多频火舌：跳动、扭曲、参差不齐
	float jump = sin(TIME * flow_speed * 1.7) * 0.5 + 0.5;
	float tongue = sin(ang * 9.0 + TIME * flow_speed) * 0.5 + 0.5;
	tongue *= sin(ang * 4.0 - TIME * flow_speed * 1.55 + jump) * 0.5 + 0.5;
	tongue = mix(0.42, 1.0, pow(tongue, 1.2) * tongue_strength);

	float flame_noise = fbm(vec2(ang * 2.4 + TIME * 1.8, r * 5.5 - TIME * 5.5));
	float flicker = 0.55 + 0.55 * fbm(vec2(ang * 3.2, TIME * 7.2));
	float lick = pow(max(flame_noise, 0.001), 1.15);

	float outer = mix(ring_outer * 0.62, ring_outer, tongue);
	outer += (lick - 0.5) * 0.22;
	float band = smoothstep(ring_inner, ring_inner + 0.1, r);
	band *= 1.0 - smoothstep(outer - 0.22, outer, r);
	band *= flicker * (0.45 + lick * 0.85);

	// 径向上升感：内圈更亮，外圈火舌跳动
	float rise = smoothstep(ring_inner, 0.7, r);
	band *= mix(1.15, 0.85 + jump * 0.35, rise);

	if (vertical_soft > 0.001) {
		float vfade = 1.0 - abs(UV.y * 2.0 - 1.0);
		band *= mix(1.0, smoothstep(0.05, 0.55, vfade), vertical_soft);
	}

	vec3 col = mix(core_color.rgb, flame_color.rgb, smoothstep(ring_inner, 0.52, r));
	col = mix(col, tip_color.rgb, smoothstep(0.5, ring_outer, r) * 0.65);
	col += vec3(1.0, 0.75, 0.35) * lick * 0.45;
	col += core_color.rgb * flicker * 0.2;

	float alpha = band * intensity * pulse * flame_color.a;
	ALBEDO = col;
	EMISSION = col * (2.8 + lick * 4.2 + jump * 1.2) * intensity * pulse;
	ALPHA = clamp(alpha, 0.0, 1.0);
}
