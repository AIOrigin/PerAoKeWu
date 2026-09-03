shader_type sky;

// 第二关：水源全景云层打底，再叠青蓝色系和竖向极光。不要开 REALTIME cubemap。
uniform sampler2D source_pano : source_color, filter_linear, repeat_enable;
uniform float energy = 1.42;
uniform float cool_mix : hint_range(0.0, 1.0) = 0.46;
uniform float aurora_amount : hint_range(0.0, 1.5) = 0.82;

void sky() {
	vec3 dir = normalize(EYEDIR);
	float lon = atan(dir.x, dir.z);
	float lat = asin(clamp(dir.y, -1.0, 1.0));
	vec2 uv = vec2(fract(lon / TAU + 0.5), clamp(0.5 - lat / PI, 0.001, 0.999));
	vec3 col = texture(source_pano, uv).rgb * energy;

	float luma = dot(col, vec3(0.299, 0.587, 0.114));
	vec3 cool = vec3(col.r * 0.58, col.g * 0.84, max(col.b, luma) * 1.22);
	col = mix(col, cool, cool_mix);

	// 镜头大约看 v=0.34–0.54，极光必须落在这一带
	float h = uv.y;
	float band = smoothstep(0.27, 0.35, h) * (1.0 - smoothstep(0.51, 0.57, h));
	float t = TIME * 0.16;
	float c1 = pow(max(sin(uv.x * 17.5 + t) * 0.5 + 0.5, 0.0), 3.4);
	float c2 = pow(max(sin(uv.x * 10.2 - t * 0.72 + 1.6) * 0.5 + 0.5, 0.0), 4.2);
	float c3 = pow(max(sin(uv.x * 26.0 + t * 1.25 + 0.8) * 0.5 + 0.5, 0.0), 6.2);
	float curtain = clamp(c1 * 0.72 + c2 * 0.48 + c3 * 0.28, 0.0, 1.0);
	float pillars = smoothstep(0.22, 0.62, curtain);
	vec3 aurora_lo = vec3(0.32, 0.96, 0.40);
	vec3 aurora_hi = vec3(0.84, 0.40, 0.92);
	vec3 aurora = mix(aurora_lo, aurora_hi, smoothstep(0.48, 0.32, h));
	col += aurora * pillars * band * aurora_amount;

	COLOR = col;
}
