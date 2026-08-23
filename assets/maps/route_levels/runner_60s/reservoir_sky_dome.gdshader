shader_type spatial;
render_mode unshaded, cull_disabled, depth_draw_never, fog_disabled, shadows_disabled;
render_priority -128;

// 相机周围天空球：按屏幕像素直接采样全景，不被 Sky Cubemap 平均成平涂。
uniform sampler2D source_pano : source_color, filter_linear, repeat_enable;
uniform float energy = 1.15;
uniform float sky_yaw = 0.0;

void fragment() {
	vec3 world_pos = (INV_VIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	vec3 cam_pos = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	vec3 dir = normalize(world_pos - cam_pos);
	float lon = atan(dir.x, dir.z) + sky_yaw;
	float lat = asin(clamp(dir.y, -1.0, 1.0));
	vec2 uv = vec2(lon / TAU + 0.5, 0.5 - lat / PI);
	vec3 col = textureLod(source_pano, uv, 0.0).rgb * energy;
	ALBEDO = col;
	EMISSION = col;
}
