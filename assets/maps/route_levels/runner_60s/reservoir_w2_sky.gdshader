shader_type sky;

// 全景结构固定，云层在其上明暗流动——不要整张天漂移。
uniform sampler2D source_pano : source_color, filter_linear, repeat_enable;
uniform vec3 zenith_color : source_color = vec3(0.12, 0.16, 0.38);
uniform vec3 mid_color : source_color = vec3(0.50, 0.38, 0.70);
uniform vec3 horizon_color : source_color = vec3(0.56, 0.62, 0.90);
uniform vec3 highlight_color : source_color = vec3(0.90, 0.86, 1.0);
uniform vec3 shadow_color : source_color = vec3(0.07, 0.08, 0.18);
uniform vec3 ground_color : source_color = vec3(0.22, 0.16, 0.18);
uniform float energy = 1.12;
uniform float contrast = 1.45;
uniform float silhouette_strength : hint_range(0.0, 1.0) = 0.88;
uniform float cloud_amount : hint_range(0.0, 1.0) = 0.72;
uniform float cloud_speed = 0.016;
uniform vec3 aurora_color : source_color = vec3(0.38, 0.86, 1.0);
uniform float aurora_amount : hint_range(0.0, 1.0) = 0.0;
uniform float source_keep : hint_range(0.0, 1.0) = 0.0;
uniform float cloud_low = 0.02;
uniform float cloud_high = 0.48;
uniform float paint_sky : hint_range(0.0, 1.0) = 0.0;
uniform float sky_style = 0.0; // 0=第二关  1=第三关分层暮色  2=第四关清透星空
uniform vec3 cloud_dark_color : source_color = vec3(0.20, 0.34, 0.58);
uniform vec3 cloud_bright_color : source_color = vec3(0.90, 0.94, 1.0);

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	float a = hash(i);
	float b = hash(i + vec2(1.0, 0.0));
	float c = hash(i + vec2(0.0, 1.0));
	float d = hash(i + vec2(1.0, 1.0));
	return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
}

float fbm(vec2 p) {
	float v = 0.0;
	float a = 0.5;
	v += a * noise(p); p *= 2.05; a *= 0.5;
	v += a * noise(p); p *= 2.03; a *= 0.5;
	v += a * noise(p); p *= 2.07; a *= 0.5;
	v += a * noise(p);
	return v;
}

void sky() {
	vec3 dir = normalize(EYEDIR);
	float lon = atan(dir.x, dir.z);
	float lat = asin(clamp(dir.y, -1.0, 1.0));
	vec2 uv = vec2(lon / TAU + 0.5, 0.5 - lat / PI);
	vec3 src = texture(source_pano, uv).rgb;
	float src_luma = dot(src, vec3(0.299, 0.587, 0.114));
	float luma = clamp((src_luma - 0.08) * 1.28, 0.0, 1.0);
	luma = clamp(pow(luma, contrast), 0.0, 1.0);

	float h = dir.y;
	vec3 grade = mix(horizon_color, mid_color, smoothstep(-0.04, 0.22, max(h, 0.0)));
	grade = mix(grade, zenith_color, smoothstep(0.16, 0.62, max(h, 0.0)));
	if (h < 0.0) {
		grade = mix(ground_color, horizon_color, smoothstep(-0.38, 0.0, h));
	}

	if (sky_style > 0.5 && sky_style < 1.5) {
		// 第三关：镜头朝前是靛蓝/品红，暖橙只在贴地平线一条细带
		vec3 col = mix(mid_color, zenith_color, smoothstep(0.04, 0.36, max(h, 0.0)));
		float warm = (1.0 - smoothstep(0.0, 0.07, h)) * smoothstep(-0.06, 0.01, h);
		col = mix(col, horizon_color, warm * 0.80);
		if (h < 0.0) {
			col = mix(ground_color, horizon_color, smoothstep(-0.36, 0.0, h));
		}
		col *= mix(0.82, 1.18, luma);
		vec2 cuv = vec2(lon * 0.72, h * 1.35) + vec2(TIME * cloud_speed, 0.0);
		float cover = fbm(cuv * vec2(1.15, 1.45));
		float clouds = smoothstep(0.40, 0.64, cover);
		float lit = smoothstep(0.48, 0.76, cover);
		float band = smoothstep(-0.02, 0.08, h) * (1.0 - smoothstep(0.40, 0.72, h));
		float amt = clouds * cloud_amount * band;
		col = mix(col, col * vec3(0.55, 0.48, 0.70), amt * (1.0 - lit) * 0.55);
		col = mix(col, mix(col, highlight_color, 0.45), amt * lit * 0.50);
		COLOR = col * energy;
		return;
	}

	if (sky_style > 1.5) {
		// 第四关：清透深蓝底，不要整屏品红厚涂；银河是一条亮带，星星要够大
		vec3 col = mix(mid_color, zenith_color, smoothstep(0.06, 0.42, max(h, 0.0)));
		col = mix(horizon_color, col, smoothstep(-0.02, 0.10, h));
		if (h < 0.0) {
			col = mix(ground_color, horizon_color, smoothstep(-0.34, 0.0, h));
		}
		col *= mix(0.90, 1.12, luma);
		float mw = exp(-pow((h - 0.26) / 0.18, 2.0));
		mw *= 0.40 + 0.60 * pow(0.5 + 0.5 * sin(lon * 0.85 + 0.35), 2.2);
		vec3 dust_a = vec3(0.16, 0.32, 0.62);
		vec3 dust_b = vec3(0.22, 0.14, 0.40);
		col += mix(dust_a, dust_b, 0.35) * mw * 0.42;
		vec2 cell = floor(uv * vec2(52.0, 26.0));
		float hs = hash(cell);
		vec2 f = fract(uv * vec2(52.0, 26.0)) - 0.5;
		float tw = 0.62 + 0.38 * sin(TIME * (1.6 + hash(cell + 2.1) * 3.4) + hs * 6.2832);
		float spark = smoothstep(0.46, 0.0, length(f)) * step(0.86, hs) * tw;
		col += vec3(0.78, 0.88, 1.0) * spark * 1.55;
		vec2 cell2 = floor(uv * vec2(18.0, 9.0));
		float hs2 = hash(cell2 + 8.3);
		vec2 f2 = fract(uv * vec2(18.0, 9.0)) - 0.5;
		float big = smoothstep(0.38, 0.0, length(f2)) * step(0.93, hs2);
		col += vec3(0.85, 0.92, 1.0) * big * 1.8;
		COLOR = col * energy;
		return;
	}

	if (paint_sky > 0.5) {
		vec3 col = mix(horizon_color, mid_color, smoothstep(-0.06, 0.16, h));
		col = mix(col, zenith_color, smoothstep(0.08, 0.48, max(h, 0.0)));
		if (h < 0.0) {
			col = mix(ground_color, horizon_color, smoothstep(-0.40, 0.0, h));
		}
		col *= mix(0.78, 1.16, luma);

		vec2 cuv = vec2(lon * 0.82, h * 1.55) + vec2(TIME * cloud_speed, TIME * cloud_speed * 0.18);
		float n1 = fbm(cuv * vec2(1.25, 1.65));
		float n2 = fbm(cuv * vec2(2.85, 2.40) + vec2(3.1, -1.6));
		float n3 = fbm(cuv * vec2(5.40, 4.20) + vec2(-2.2, 2.4));
		float cover = n1 * 0.52 + n2 * 0.32 + n3 * 0.16;
		float clouds = smoothstep(0.38, 0.56, cover);
		float lit = smoothstep(0.48, 0.78, n2);
		float cloud_band = smoothstep(-0.10, 0.04, h) * (1.0 - smoothstep(0.46, 0.82, h));
		float amt = clouds * cloud_amount * cloud_band;
		col = mix(col, cloud_dark_color, amt * (1.0 - lit) * 0.88);
		col = mix(col, cloud_bright_color, amt * lit * 0.92);

		float sil_low = 1.0 - smoothstep(0.08, 0.34, luma);
		float band_low = smoothstep(-0.18, 0.0, h) * (1.0 - smoothstep(0.04, 0.16, h));
		col = mix(col, shadow_color * 0.28, sil_low * band_low * silhouette_strength);

		COLOR = col * energy;
		return;
	}

	vec3 col = mix(shadow_color, grade, smoothstep(0.02, 0.48, luma));
	col = mix(col, highlight_color, smoothstep(0.52, 0.90, luma));

	if (source_keep > 0.001) {
		vec3 structured = mix(shadow_color, grade, luma);
		structured = mix(structured, highlight_color, smoothstep(0.42, 0.88, luma));
		col = mix(col, structured, source_keep);
	}

	float sil_low = 1.0 - smoothstep(0.08, 0.34, luma);
	float sil_tall = 1.0 - smoothstep(0.03, 0.16, luma);
	float band_low = smoothstep(-0.18, 0.0, h) * (1.0 - smoothstep(0.04, 0.16, h));
	float band_tall = smoothstep(-0.02, 0.10, h) * (1.0 - smoothstep(0.32, 0.58, h));
	col = mix(col, shadow_color * 0.22, sil_low * band_low * silhouette_strength);
	col = mix(col, shadow_color * 0.12, sil_tall * band_tall * silhouette_strength);

	// 云自己在动：独立成团，不带动整张全景
	vec2 cuv = vec2(lon * 1.05, h * 2.2) + vec2(TIME * cloud_speed, TIME * cloud_speed * 0.22);
	float n1 = fbm(cuv * vec2(1.7, 2.0));
	float n2 = fbm(cuv * vec2(3.4, 2.8) + vec2(2.7, -1.4));
	float n3 = fbm(cuv * vec2(6.2, 4.6) + vec2(-1.8, 3.1));
	float cover = n1 * 0.50 + n2 * 0.34 + n3 * 0.16;
	float clouds = smoothstep(0.34, 0.62, cover);
	float lit = smoothstep(0.46, 0.80, n2);
	float cloud_band = smoothstep(cloud_low - 0.08, cloud_low + 0.10, h)
		* (1.0 - smoothstep(cloud_high, cloud_high + 0.28, h));
	float amt = clouds * cloud_amount * cloud_band;
	vec3 cloud_dark = mix(shadow_color * 1.6, col * 0.42, 0.35);
	vec3 cloud_bright = mix(highlight_color, col, 0.18);
	col = mix(col, cloud_dark, amt * (1.0 - lit));
	col = mix(col, cloud_bright, amt * lit);

	if (aurora_amount > 0.001) {
		float curtain = sin(lon * 2.6 + TIME * 0.28 + h * 3.2) * 0.5
			+ sin(lon * 5.4 - TIME * 0.19 + 1.1) * 0.34
			+ sin(lon * 9.2 + TIME * 0.13 + h * 6.0) * 0.18;
		curtain = smoothstep(0.28, 0.72, curtain * 0.5 + 0.5);
		float veil = 0.55 + 0.45 * sin(lon * 1.35 + TIME * 0.11);
		float aurora_band = smoothstep(0.06, 0.18, h) * (1.0 - smoothstep(0.42, 0.78, h));
		col += aurora_color * curtain * veil * aurora_band * aurora_amount * 0.55;
	}

	COLOR = col * energy;
}
