shader_type spatial;
render_mode unshaded, cull_back, depth_draw_opaque, specular_disabled;

// 备用：不要绑 sampler，不要写 ALPHA。游戏里实际走 StandardMaterial 顶点色。
void fragment() {
	ALBEDO = COLOR.rgb;
}
