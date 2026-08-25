shader_type canvas_item;

uniform float chase_strength : hint_range(0.0, 1.0) = 0.0;
uniform float chase_state = 0.0;
uniform vec4 tint_color : source_color = vec4(0.42, 0.12, 0.72, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float s = clamp(chase_strength, 0.0, 1.0);
	float edge = length(uv - vec2(0.5));
	float vignette = smoothstep(0.28, 0.78, edge) * s;
	float n = hash(uv * 48.0 + vec2(TIME * 0.35, TIME * 0.21));
	float warp = (n - 0.5) * 0.012 * s * (1.0 + chase_state * 0.08);
	vec2 warped = uv + vec2(warp, -warp * 0.65);
	float fringe = smoothstep(0.42, 0.92, length(warped - vec2(0.5))) * s;
	vec3 purple = tint_color.rgb;
	float alpha = vignette * 0.42 + fringe * 0.22;
	COLOR = vec4(purple, alpha);
}
