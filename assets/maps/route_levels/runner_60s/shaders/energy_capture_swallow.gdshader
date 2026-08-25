shader_type canvas_item;

uniform float swallow : hint_range(0.0, 1.0) = 0.0;
uniform vec4 core_color : source_color = vec4(0.08, 0.02, 0.16, 1.0);
uniform vec4 edge_color : source_color = vec4(0.55, 0.18, 0.95, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float s = clamp(swallow, 0.0, 1.0);
	float edge = length(uv - vec2(0.5));
	// 从四周向内吞没：边缘先黑紫，再吞噬中心
	float ring = smoothstep(0.72 - s * 0.75, 0.15 - s * 0.2, edge);
	float n = hash(uv * 36.0 + vec2(TIME * 1.4, TIME * 0.9));
	float tendril = smoothstep(0.35, 0.95, n) * s * (1.0 - ring * 0.35);
	float cover = clamp(s * 0.55 + (1.0 - ring) * s * 1.15 + tendril * 0.35, 0.0, 1.0);
	vec3 col = mix(edge_color.rgb, core_color.rgb, cover);
	COLOR = vec4(col, cover);
}
