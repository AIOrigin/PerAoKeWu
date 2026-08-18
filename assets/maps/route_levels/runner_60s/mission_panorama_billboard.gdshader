shader_type spatial;
render_mode blend_mix, cull_disabled, unshaded, depth_draw_never, fog_disabled;

uniform sampler2D panorama_tex : filter_linear_mipmap;
uniform vec4 uv_rect = vec4(0.4, 0.05, 0.2, 0.35);
uniform float alpha_mul : hint_range(0.0, 1.0) = 0.82;

void fragment() {
	vec2 uv = uv_rect.xy + UV * uv_rect.zw;
	vec4 tex = texture(panorama_tex, uv);
	float side = 1.0 - smoothstep(0.72, 1.0, abs(UV.x - 0.5) * 2.0);
	float top = smoothstep(0.0, 0.06, UV.y);
	float bot = 1.0 - smoothstep(0.9, 1.0, UV.y);
	float alpha = tex.a * alpha_mul * side * top * bot;
	ALBEDO = tex.rgb;
	EMISSION = tex.rgb * 0.12;
	ALPHA = alpha;
}
