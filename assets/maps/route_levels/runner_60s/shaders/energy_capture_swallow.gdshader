shader_type canvas_item;

uniform float swallow : hint_range(0.0, 1.0) = 0.0;
uniform vec4 core_color : source_color = vec4(0.12, 0.03, 0.22, 1.0);
uniform vec4 mid_color : source_color = vec4(0.52, 0.14, 0.88, 1.0);
uniform vec4 edge_color : source_color = vec4(0.95, 0.42, 1.0, 1.0);
uniform vec4 spark_color : source_color = vec4(0.55, 0.82, 1.0, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	vec2 u = f * f * (3.0 - 2.0 * f);
	return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

void fragment() {
	vec2 uv = UV;
	float s = clamp(swallow, 0.0, 1.0);
	if (s <= 0.001) {
		COLOR = vec4(0.0);
		return;
	}

	// 四边向内吞没（可见紫粉能量前沿），末段才盖成深紫
	float edge_dist = min(min(uv.x, 1.0 - uv.x), min(uv.y, 1.0 - uv.y));
	float n1 = noise(uv * 9.0 + vec2(TIME * 0.55, -TIME * 0.35));
	float n2 = noise(uv * 22.0 + vec2(-TIME * 0.8, TIME * 0.6));
	float jagged = (n1 - 0.5) * 0.04 * s + (n2 - 0.5) * 0.025 * s;

	float frontier = mix(0.48, -0.04, pow(s, 0.78)) + jagged;
	float fill = 1.0 - smoothstep(frontier - 0.05, frontier + 0.14, edge_dist);
	fill = clamp(fill, 0.0, 1.0);

	float rim = smoothstep(frontier + 0.14, frontier, edge_dist)
		* smoothstep(frontier - 0.22, frontier - 0.04, edge_dist)
		* s;

	float tendril = smoothstep(0.5, 0.92, n2) * (1.0 - fill) * s * 0.55;

	vec3 col = mix(mid_color.rgb, core_color.rgb, fill * fill);
	col = mix(col, edge_color.rgb, rim * 0.75);
	col = mix(col, spark_color.rgb, (rim + tendril) * 0.35);

	float alpha = fill * mix(0.45, 0.92, s) + rim * 0.42 + tendril * 0.28;
	// 末段才整块盖实，且必须是深紫而非灰白
	float end_cover = smoothstep(0.9, 1.0, s);
	col = mix(col, core_color.rgb, end_cover);
	alpha = max(alpha, end_cover * 0.98);

	COLOR = vec4(col, clamp(alpha, 0.0, 1.0));
}
