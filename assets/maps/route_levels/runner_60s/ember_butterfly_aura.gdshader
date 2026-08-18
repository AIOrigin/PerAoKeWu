shader_type spatial;
render_mode blend_add, cull_disabled, depth_draw_never, unshaded, shadows_disabled, fog_disabled;

uniform vec4 core_color : source_color = vec4(1.0, 0.96, 0.98, 1.0);
uniform vec4 flame_color : source_color = vec4(1.0, 0.48, 0.58, 0.72);
uniform vec4 tip_color : source_color = vec4(0.95, 0.25, 0.38, 0.0);
uniform float intensity : hint_range(0.0, 3.0) = 1.15;
uniform float pulse : hint_range(0.4, 1.8) = 1.0;
uniform float flow_speed = 2.2;
uniform float wing_spread : hint_range(0.6, 1.4) = 1.0;
uniform float flap : hint_range(0.0, 1.0) = 0.32;
uniform float soft_edge : hint_range(0.05, 0.45) = 0.16;

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

float sd_circle(vec2 p, float r) {
	return length(p) - r;
}

float butterfly_sdf(vec2 p) {
	vec2 q = vec2(abs(p.x), p.y);
	float flap_amt = 1.0 + flap * 0.1 * sin(TIME * 5.0);
	q.x *= flap_amt / max(wing_spread, 0.01);

	float upper = sd_circle(q - vec2(0.36, 0.30), 0.34);
	upper = min(upper, sd_circle(q - vec2(0.58, 0.16), 0.24));
	float lower = sd_circle(q - vec2(0.26, -0.24), 0.24);
	lower = min(lower, sd_circle(q - vec2(0.44, -0.36), 0.15));
	float wings = min(upper, lower);

	float body = max(abs(p.x) * 12.5 - 0.28, abs(p.y) * 1.2 - 0.7);
	float d = min(wings, body);

	vec2 ant = vec2(abs(p.x) - 0.07, p.y - 0.66);
	d = min(d, length(ant) - 0.028);

	float cleft = abs(p.x) - 0.035;
	d = max(d, -cleft * 0.45 * step(0.02, abs(p.y)));

	return d;
}

void fragment() {
	vec2 uv = UV * 2.0 - 1.0;
	uv.x *= 0.9;
	uv.y *= 1.06;

	float d = butterfly_sdf(uv);
	float soft = max(soft_edge, 0.06);
	float core_mask = 1.0 - smoothstep(-soft * 0.35, soft * 0.55, d);
	float halo_mask = 1.0 - smoothstep(-soft * 0.2, soft * 1.55, d);
	float mask = max(core_mask * 0.95, halo_mask * 0.5);
	mask = pow(max(mask, 0.0), 1.02);

	float r = length(uv);
	float ang = atan(uv.y, uv.x);
	float swirl = noise21(vec2(uv.x * 3.0 + TIME * 0.9, uv.y * 3.0 - TIME * 1.3));
	float flicker = 0.78 + 0.28 * noise21(vec2(ang * 2.0, TIME * 4.2));

	float glow = mask * (0.68 + swirl * 0.42) * flicker;
	float falloff = 1.0 - smoothstep(0.32, 1.12, r);
	glow *= mix(0.8, 1.0, falloff);

	float vein = abs(sin(ang * 4.0 + uv.y * 3.0));
	vein = smoothstep(0.7, 0.95, vein) * core_mask;
	glow += vein * 0.24;

	float flow = sin(uv.x * 8.0 + uv.y * 5.0 + TIME * flow_speed) * 0.5 + 0.5;
	glow *= 0.8 + flow * 0.3;

	vec3 col = mix(core_color.rgb, flame_color.rgb, smoothstep(0.05, 0.52, r));
	col = mix(col, tip_color.rgb, smoothstep(0.45, 1.0, r) * halo_mask * 0.5);
	col += core_color.rgb * (swirl * 0.22 + vein * 0.28);
	col = mix(col, vec3(1.0, 0.92, 0.95), 0.18);

	float alpha = glow * intensity * pulse * flame_color.a * 0.62;
	ALBEDO = col;
	EMISSION = col * (1.15 + swirl * 0.55 + vein * 0.35) * intensity * pulse;
	ALPHA = clamp(alpha, 0.0, 0.48);
}
