shader_type sky;

// 按像素采样朝阳全景。不要走 cubemap 实时辐照度，否则会平均成一片粉。
uniform sampler2D source_pano : source_color, filter_linear, repeat_enable;
uniform float energy = 1.18;

void sky() {
	vec3 dir = normalize(EYEDIR);
	float lon = atan(dir.x, dir.z);
	float lat = asin(clamp(dir.y, -1.0, 1.0));
	vec2 uv = vec2(fract(lon / TAU + 0.5), clamp(0.5 - lat / PI, 0.001, 0.999));
	COLOR = texture(source_pano, uv).rgb * energy;
}
