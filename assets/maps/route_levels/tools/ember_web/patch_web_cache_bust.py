#!/usr/bin/env python3
"""Read ASSET_VERSION from ember_web_config.gd and cache-bust the Ember Runner Web HTML."""
from __future__ import annotations

import argparse
import re
from pathlib import Path

CONFIG_REL = "assets/maps/route_levels/ember_web/ember_web_config.gd"
VERSION_RE = re.compile(r'const\s+ASSET_VERSION\s*:=\s*"([^"]*)"')

WASM_TEMPLATE_RE = re.compile(r"godot\.web\.template[^\"']*\.wasm")
WASM_CANONICAL = "index.wasm"

FETCH_PATCH = """
		<meta http-equiv="Cache-Control" content="no-cache, no-store, must-revalidate">
		<meta http-equiv="Pragma" content="no-cache">
		<link rel="icon" href="index.png">
		<script>
window.__EMBER_ASSET_VER = {ver_js};
(function () {{
	const VER = window.__EMBER_ASSET_VER;
	const bust = function (u) {{
		if (typeof u !== 'string') {{
			return u;
		}}
		if (/godot\\.web\\.template[^/?#]*\\.wasm(\\?|$)/.test(u)) {{
			return u.replace(/[^/?#]*godot\\.web\\.template[^/?#]*\\.wasm/, 'index.wasm');
		}}
		// 只给 pck/js 加 ?v=。wasm 约 42MB，换 query 会让 CloudFront 回源。
		if (!/(^|\\/)index\\.(js|pck)(\\?|$)/.test(u)) {{
			return u;
		}}
		if (/[?&]v=/.test(u)) {{
			return u;
		}}
		return u + (u.indexOf('?') >= 0 ? '&' : '?') + 'v=' + encodeURIComponent(VER);
	}};
	const origFetch = window.fetch;
	window.fetch = function (input, init) {{
		if (typeof input === 'string') {{
			return origFetch.call(this, bust(input), init);
		}}
		if (typeof Request !== 'undefined' && input instanceof Request) {{
			const nu = bust(input.url);
			if (nu !== input.url) {{
				return origFetch.call(this, nu, init || {{
					method: input.method,
					headers: input.headers,
					credentials: input.credentials,
					mode: input.mode,
					redirect: input.redirect,
					referrer: input.referrer,
					signal: input.signal,
				}});
			}}
		}}
		return origFetch.call(this, input, init);
	}};
	if (typeof XMLHttpRequest !== 'undefined') {{
		const origOpen = XMLHttpRequest.prototype.open;
		XMLHttpRequest.prototype.open = function (method, url) {{
			const args = Array.prototype.slice.call(arguments);
			if (typeof url === 'string') {{
				args[1] = bust(url);
			}}
			return origOpen.apply(this, args);
		}};
	}}
}})();
		</script>
"""

PRELOADER_LOAD_FETCH_OLD = """\t\treturn fetch(file).then(function (response) {
\t\t\tif (!response.ok) {
\t\t\t\treturn Promise.reject(new Error(`Failed loading file '${file}'`));
\t\t\t}
\t\t\tconst tr = getTrackedResponse(response, tracker[file]);
\t\t\tif (raw) {
\t\t\t\treturn Promise.resolve(tr);
\t\t\t}
\t\t\treturn tr.arrayBuffer();
\t\t});"""

PRELOADER_LOAD_FETCH_NEW = """\t\treturn fetch(file).then(function (response) {
\t\t\tif (!response.ok) {
\t\t\t\treturn Promise.reject(new Error(`Failed loading file '${file}'`));
\t\t\t}
\t\t\t// wasm 直接读成 ArrayBuffer，避免 Response.clone / instantiateStreaming 卡死
\t\t\tif (raw && /\\.wasm(\\?|$)/.test(file)) {
\t\t\t\treturn response.arrayBuffer().then(function (buf) {
\t\t\t\t\ttracker[file].loaded = buf.byteLength;
\t\t\t\t\ttracker[file].done = true;
\t\t\t\t\treturn buf;
\t\t\t\t});
\t\t\t}
\t\t\tconst tr = getTrackedResponse(response, tracker[file]);
\t\t\tif (raw) {
\t\t\t\treturn Promise.resolve(tr);
\t\t\t}
\t\t\treturn tr.arrayBuffer();
\t\t});"""

DO_INIT_OLD = """\t\t\t\t\treturn new Promise(function (resolve, reject) {
\t\t\t\t\t\tpromise.then(function (response) {
\t\t\t\t\t\t\tconst cloned = new Response(response.clone().body, { 'headers': [['content-type', 'application/wasm']] });
\t\t\t\t\t\t\tGodot(me.config.getModuleConfig(loadPath, cloned)).then(function (module) {
\t\t\t\t\t\t\t\tconst paths = me.config.persistentPaths;
\t\t\t\t\t\t\t\tmodule['initFS'](paths).then(function (err) {
\t\t\t\t\t\t\t\t\tme.rtenv = module;
\t\t\t\t\t\t\t\t\tif (me.config.unloadAfterInit) {
\t\t\t\t\t\t\t\t\t\tEngine.unload();
\t\t\t\t\t\t\t\t\t}
\t\t\t\t\t\t\t\t\tresolve();
\t\t\t\t\t\t\t\t});
\t\t\t\t\t\t\t});
\t\t\t\t\t\t});
\t\t\t\t\t});"""

DO_INIT_NEW = """\t\t\t\t\treturn new Promise(function (resolve, reject) {
\t\t\t\t\t\tpromise.then(function (wasmSource) {
\t\t\t\t\t\t\tGodot(me.config.getModuleConfig(loadPath, wasmSource)).then(function (module) {
\t\t\t\t\t\t\t\tconst paths = me.config.persistentPaths;
\t\t\t\t\t\t\t\tmodule['initFS'](paths).then(function (err) {
\t\t\t\t\t\t\t\t\tme.rtenv = module;
\t\t\t\t\t\t\t\t\tif (me.config.unloadAfterInit) {
\t\t\t\t\t\t\t\t\t\tEngine.unload();
\t\t\t\t\t\t\t\t\t}
\t\t\t\t\t\t\t\t\tresolve();
\t\t\t\t\t\t\t\t}).catch(reject);
\t\t\t\t\t\t\t}).catch(reject);
\t\t\t\t\t\t}).catch(reject);
\t\t\t\t\t});"""

INSTANTIATE_WASM_OLD = """\t\t\t'instantiateWasm': function (imports, onSuccess) {
\t\t\t\tfunction done(result) {
\t\t\t\t\tonSuccess(result['instance'], result['module']);
\t\t\t\t}
\t\t\t\tif (typeof (WebAssembly.instantiateStreaming) !== 'undefined') {
\t\t\t\t\tWebAssembly.instantiateStreaming(Promise.resolve(r), imports).then(done);
\t\t\t\t} else {
\t\t\t\t\tr.arrayBuffer().then(function (buffer) {
\t\t\t\t\t\tWebAssembly.instantiate(buffer, imports).then(done);
\t\t\t\t\t});
\t\t\t\t}
\t\t\t\tr = null;
\t\t\t\treturn {};
\t\t\t},"""

INSTANTIATE_WASM_NEW = """\t\t\t'instantiateWasm': function (imports, onSuccess) {
\t\t\t\tfunction done(result) {
\t\t\t\t\tonSuccess(result['instance'], result['module']);
\t\t\t\t}
\t\t\t\tvar src = r;
\t\t\t\tr = null;
\t\t\t\tPromise.resolve(src).then(function (input) {
\t\t\t\t\tif (input && typeof input.arrayBuffer === 'function') {
\t\t\t\t\t\treturn input.arrayBuffer();
\t\t\t\t\t}
\t\t\t\t\treturn input;
\t\t\t\t}).then(function (buffer) {
\t\t\t\t\treturn WebAssembly.instantiate(buffer, imports);
\t\t\t\t}).then(done).catch(function (err) {
\t\t\t\t\tconsole.error('Godot wasm instantiate failed:', err);
\t\t\t\t\tthrow err;
\t\t\t\t});
\t\t\t\treturn {};
\t\t\t},"""


def repo_root() -> Path:
    here = Path(__file__).resolve()
    for parent in here.parents:
        if (parent / "project.godot").exists():
            return parent
    raise SystemExit("找不到 project.godot")


def read_asset_version(root: Path | None = None) -> str:
    root = root or repo_root()
    text = (root / CONFIG_REL).read_text(encoding="utf-8")
    m = VERSION_RE.search(text)
    if not m or not m.group(1).strip():
        raise SystemExit(f"未找到 ASSET_VERSION：{root / CONFIG_REL}")
    return m.group(1).strip()


# Godot 导出会生成默认 index.png（引擎 Logo）；封面必须用独立文件名，否则 CDN immutable 会一直命中旧图
COVER_REL = "assets/maps/route_levels/mobile_home/ui_home/background.png"
COVER_OUT_NAME = "cover.png"

# Elseland App WebView（PR #58）注入 --app-sat/sab/sal/sar；游戏侧统一映射为 --sat/sab/sal/sar
SAFE_AREA_CSS = """
/* EMBER_SAFE_AREA */
:root {
	--sat: max(env(safe-area-inset-top, 0px), var(--app-sat, 0px));
	--sab: max(env(safe-area-inset-bottom, 0px), var(--app-sab, 0px));
	--sal: max(env(safe-area-inset-left, 0px), var(--app-sal, 0px));
	--sar: max(env(safe-area-inset-right, 0px), var(--app-sar, 0px));
}
html {
	height: 100%;
}
body {
	box-sizing: border-box;
	padding: var(--sat) var(--sar) var(--sab) var(--sal);
	min-height: 100%;
	height: 100%;
}
#canvas {
	width: 100%;
	height: 100%;
}
"""

# 加载期封面样式：粉紫底 + 居中方形封面 + 底部进度条
SPLASH_CSS = """
body, #status {
	background: linear-gradient(180deg, #0a1220 0%, #1a1018 55%, #120810 100%) !important;
	color: #f2d7b6;
}
#status {
	visibility: visible;
}
#status-splash {
	display: block !important;
	position: relative !important;
	top: auto !important;
	bottom: auto !important;
	left: auto !important;
	right: auto !important;
	width: min(88vw, 520px) !important;
	height: auto !important;
	max-height: 72vh !important;
	object-fit: contain !important;
	margin: 0 auto 1.25rem auto !important;
	border-radius: 0 !important;
	box-shadow: none !important;
}
#status-splash.show-image--false,
#status-splash.fullsize--true {
	display: block !important;
	width: min(88vw, 520px) !important;
	height: auto !important;
	max-height: 72vh !important;
	object-fit: contain !important;
	border-radius: 0 !important;
	box-shadow: none !important;
}
#status-progress {
	display: block !important;
	position: relative !important;
	bottom: auto !important;
	left: auto !important;
	right: auto !important;
	width: min(56vw, 280px);
	height: 10px;
	margin: 0 auto;
	appearance: none;
	border: none;
	border-radius: 999px;
	overflow: hidden;
	background: rgba(255, 255, 255, 0.85);
}
#status-progress::-webkit-progress-bar {
	background: rgba(255, 255, 255, 0.85);
	border-radius: 999px;
}
#status-progress::-webkit-progress-value {
	background: linear-gradient(90deg, #ff9a3c, #ff5a2a);
	border-radius: 999px;
}
#status-progress::-moz-progress-bar {
	background: linear-gradient(90deg, #ff9a3c, #ff5a2a);
	border-radius: 999px;
}
#status-notice {
	display: block !important;
	position: relative !important;
	margin: 0.75rem auto 0 auto !important;
	padding: 0.45rem 0.85rem !important;
	max-width: min(88vw, 420px) !important;
	background: rgba(255, 255, 255, 0.72) !important;
	color: #d7b48a !important;
	border-radius: 999px !important;
	font: 600 13px/1.35 system-ui, -apple-system, sans-serif !important;
	text-align: center !important;
}
"""


def patch_js(js_path: Path) -> str | None:
    text = js_path.read_text(encoding="utf-8")
    m = WASM_TEMPLATE_RE.search(text)
    template_name: str | None = None
    if not m:
        if f'"{WASM_CANONICAL}"' not in text:
            raise SystemExit(f"{js_path} 未找到 Godot wasm 模板文件名")
    else:
        template_name = m.group(0)
        if template_name != WASM_CANONICAL:
            text2 = text.replace(f'"{template_name}"', f'"{WASM_CANONICAL}"')
            if text2 == text:
                raise SystemExit(f"{js_path} 未能把 {template_name} 改写为 {WASM_CANONICAL}")
            text = text2
            print(f"index.js wasm 路径 {template_name} -> {WASM_CANONICAL}")
    if PRELOADER_LOAD_FETCH_OLD in text:
        text = text.replace(PRELOADER_LOAD_FETCH_OLD, PRELOADER_LOAD_FETCH_NEW, 1)
    elif "wasm 直接读成 ArrayBuffer" not in text:
        raise SystemExit(f"{js_path} 未找到 Preloader.loadFetch，无法修复 wasm-instantiate")
    if DO_INIT_OLD in text:
        text = text.replace(DO_INIT_OLD, DO_INIT_NEW, 1)
    elif "wasmSource" not in text:
        raise SystemExit(f"{js_path} 未找到 Engine.doInit clone 逻辑")
    if INSTANTIATE_WASM_OLD in text:
        text = text.replace(INSTANTIATE_WASM_OLD, INSTANTIATE_WASM_NEW, 1)
    elif "Godot wasm instantiate failed" not in text:
        raise SystemExit(f"{js_path} 未找到 instantiateWasm")
    js_path.write_text(text, encoding="utf-8")
    print("index.js：wasm ArrayBuffer 实例化 + doInit 去 clone")
    return template_name


def install_wasm_alias(out_dir: Path, template_name: str | None) -> None:
    if not template_name:
        return
    src = out_dir / WASM_CANONICAL
    dst = out_dir / template_name
    if (not src.is_file() or src.stat().st_size < 1024) and dst.is_file() and dst.stat().st_size > 1024:
        src.write_bytes(dst.read_bytes())
        print(f"index.wasm 为空，已从 {dst.name} 恢复 ({src.stat().st_size} bytes)")
    if not src.is_file() or src.stat().st_size < 1024:
        raise SystemExit(f"找不到有效的 {src}，无法写入 wasm 别名")
    if not dst.exists() or dst.stat().st_size != src.stat().st_size:
        dst.write_bytes(src.read_bytes())
        print(f"wasm 别名 -> {dst.name}")


def install_loading_cover(out_dir: Path, root: Path | None = None) -> tuple[Path, str]:
    import hashlib

    root = root or repo_root()
    src = root / COVER_REL
    fallback = out_dir / "cover.png"
    if not src.is_file() and fallback.is_file():
        src = fallback
        print(f"加载封面缺失，改用已有 {fallback}")
    if not src.is_file():
        src = out_dir / "index.png"
        print(f"加载封面缺失，改用 {src}")
    if not src.is_file():
        raise SystemExit(f"找不到加载封面：{root / COVER_REL}")
    data = src.read_bytes()
    digest = hashlib.md5(data).hexdigest()[:8]
    dst = out_dir / COVER_OUT_NAME
    dst.write_bytes(data)
    # 顺带覆盖 index.png，给 manifest / favicon 用；真正显示走 cover.png
    (out_dir / "index.png").write_bytes(data)
    print(f"加载封面 -> {dst} (md5={digest})")
    return dst, digest


def _strip_wake_lock_block(text: str) -> str:
    text = re.sub(
        r"\t/\* EMBER_WAKE_LOCK \*/[\s\S]*?\t/\* /EMBER_WAKE_LOCK \*/\n?",
        "",
        text,
        count=1,
    )
    # 兼容旧版无标记重复注入
    while "_emberWakeLock" in text:
        new_text = re.sub(
            r"\n\tlet _emberWakeLock = null;[\s\S]*?"
            r"document\.addEventListener\('visibilitychange', function \(\) \{[\s\S]*?\}\);\n",
            "\n",
            text,
            count=1,
        )
        if new_text == text:
            break
        text = new_text
    text = text.replace("\t\t_emberReleaseWakeLock();\n\t\t_emberReleaseWakeLock();\n", "\t\t_emberReleaseWakeLock();\n")
    text = text.replace(
        "\t\tsetStatusNotice(_emberLoadNotice);\n\t\t_emberRequestWakeLock();\n\t\tsetStatusNotice(_emberLoadNotice);\n\t\t_emberRequestWakeLock();\n",
        "\t\tsetStatusNotice(_emberLoadNotice);\n\t\t_emberRequestWakeLock();\n",
    )
    return text


def _patch_html_loader_shell(text: str, total_mb: int) -> str:
    notice = f"First download ~{total_mb} MB. Please keep this page in the foreground…"
    text = _strip_wake_lock_block(text)
    wake_block = f"""
\t/* EMBER_WAKE_LOCK */
\tlet _emberWakeLock = null;
\tconst _emberLoadNotice = {notice!r};
\tasync function _emberRequestWakeLock() {{
\t\ttry {{
\t\t\tif ('wakeLock' in navigator) {{
\t\t\t\t_emberWakeLock = await navigator.wakeLock.request('screen');
\t\t\t}}
\t\t}} catch (e) {{}}
\t}}
\tfunction _emberReleaseWakeLock() {{
\t\tif (_emberWakeLock) {{
\t\t\t_emberWakeLock.release().catch(function () {{}});
\t\t\t_emberWakeLock = null;
\t\t}}
\t}}
\tdocument.addEventListener('visibilitychange', function () {{
\t\tif (!initializing) {{
\t\t\treturn;
\t\t}}
\t\tif (document.hidden) {{
\t\t\tsetStatusNotice('下载中请保持本页在前台，切后台可能暂停');
\t\t}} else {{
\t\t\tsetStatusNotice(_emberLoadNotice);
\t\t\t_emberRequestWakeLock();
\t\t}}
\t}});
\t/* /EMBER_WAKE_LOCK */
"""
    anchor = "\tfunction displayFailureNotice(err) {"
    if anchor not in text:
        raise SystemExit("index.html 未找到 displayFailureNotice，无法注入加载器补丁")
    text = text.replace(anchor, wake_block + anchor, 1)
    if "_emberLoadNotice" not in text.split("setStatusMode('progress')")[0]:
        pass
    progress_line = "\t\tsetStatusMode('progress');"
    progress_patch = "\t\tsetStatusNotice(_emberLoadNotice);\n\t\t_emberRequestWakeLock();\n\t\tsetStatusMode('progress');"
    if progress_patch not in text:
        text = text.replace(progress_line, progress_patch, 1)
    hidden_patch = "\t\t}).then(() => {\n\t\t\t_emberReleaseWakeLock();\n\t\t\tsetStatusMode('hidden');"
    if hidden_patch not in text:
        text = text.replace(
            "\t\t}).then(() => {\n\t\t\tsetStatusMode('hidden');",
            hidden_patch,
            1,
        )
    notice_patch = "\t\t_emberReleaseWakeLock();\n\t\tsetStatusMode('notice');\n\t\tinitializing = false;"
    if notice_patch not in text:
        text = text.replace(
            "\t\tsetStatusMode('notice');\n\t\tinitializing = false;",
            notice_patch,
            1,
        )
    return text


def _wire_bytes(path: Path, codec: str = "br") -> int:
    import importlib.util

    # 大 pck 做 brotli 探测会卡好几分钟；上传时再压。这里只估 splash 文案。
    size = path.stat().st_size
    if size > 80 * 1024 * 1024:
        return int(size * 0.45)
    helper = Path(__file__).resolve().parent / "wire_compress.py"
    spec = importlib.util.spec_from_file_location("wire_compress", helper)
    if spec is None or spec.loader is None:
        raise SystemExit(f"找不到 {helper}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod.wire_size(path, codec)


def patch_html(html_path: Path, version: str) -> None:
    import hashlib

    text = html_path.read_text(encoding="utf-8")
    out_dir = html_path.parent
    pck = out_dir / "index.pck"
    js_path = out_dir / "index.js"
    wasm_path = out_dir / "index.wasm"
    parts = [version]
    if wasm_path.is_file():
        parts.append(hashlib.md5(wasm_path.read_bytes()).hexdigest()[:8])
    if pck.is_file():
        parts.append(hashlib.md5(pck.read_bytes()).hexdigest()[:8])
    if js_path.is_file():
        parts.append(hashlib.md5(js_path.read_bytes()).hexdigest()[:8])
    shell_ver = "-".join(parts)
    _cover_path, cover_digest = install_loading_cover(html_path.parent)
    cover_ver = f"{shell_ver}-{cover_digest}"
    wire_bytes = 0
    if wasm_path.is_file():
        wire_bytes += _wire_bytes(wasm_path, "br")
    if pck.is_file():
        wire_bytes += _wire_bytes(pck, "br")
    total_mb = max(1, int(round(wire_bytes / 1024 / 1024)))
    patch = FETCH_PATCH.format(ver_js=f'"{shell_ver}"')
    if "__EMBER_ASSET_VER" in text:
        text, n = re.subn(
            r"\t\t<meta http-equiv=\"Cache-Control\"[\s\S]*?</script>\n",
            patch,
            text,
            count=1,
        )
        if n != 1:
            text = re.sub(
                r'<script>\s*window\.__EMBER_ASSET_VER[\s\S]*?</script>',
                patch.strip(),
                text,
                count=1,
            )
    else:
        if "</head>" not in text:
            raise SystemExit(f"{html_path} 没有 </head>，无法写入缓存破坏脚本")
        text = text.replace("</head>", patch + "\t</head>", 1)
    # favicon / splash 都指向独立 cover.png，彻底躲开 Godot 默认 index.png 的 CDN 缓存
    if 'rel="icon"' not in text:
        text = text.replace(
            "<head>",
            f'<head>\n\t\t<link rel="icon" href="{COVER_OUT_NAME}?v={cover_ver}">',
            1,
        )
    else:
        text = re.sub(
            r'<link rel="icon" href="[^"]*">',
            f'<link rel="icon" href="{COVER_OUT_NAME}?v={cover_ver}">',
            text,
            count=1,
        )
    text = re.sub(
        r'<script src="index\.js[^"]*"></script>',
        f'<script src="index.js?v={shell_ver}"></script>',
        text,
        count=1,
    )
    engine_expose = "const engine = new Engine(GODOT_CONFIG);\nwindow.__emberEngine = engine;"
    if "window.__emberEngine" not in text:
        if "const engine = new Engine(GODOT_CONFIG);" not in text:
            raise SystemExit(f"{html_path}: Engine init not found; cannot expose copyToFS")
        text = text.replace("const engine = new Engine(GODOT_CONFIG);", engine_expose, 1)
    text = re.sub(
        r'<img id="status-splash"([^>]*)\ssrc="[^"]*"([^>]*)>',
        rf'<img id="status-splash"\1 src="{COVER_OUT_NAME}?v={cover_ver}"\2>',
        text,
        count=1,
    )
    # 显示封面，并始终刷新加载期样式
    text = text.replace("show-image--false", "show-image--true")
    text = re.sub(
        r"\n#status-splash\s*\{\s*display:\s*none\s*!important;\s*\}\n?",
        "\n",
        text,
    )
    style_patch = SAFE_AREA_CSS + "\n/* EMBER_LOADING_COVER */\n" + SPLASH_CSS
    if "/* EMBER_SAFE_AREA */" in text:
        text = re.sub(
            r"\n/\* EMBER_SAFE_AREA \*/[\s\S]*?(?=\t\t</style>|</style>)",
            style_patch,
            text,
            count=1,
        )
    elif "/* EMBER_LOADING_COVER */" in text:
        text = re.sub(
            r"\n/\* EMBER_LOADING_COVER \*/[\s\S]*?(?=\t\t</style>|</style>)",
            style_patch,
            text,
            count=1,
        )
    else:
        text = text.replace("</style>", style_patch + "\t\t</style>", 1)
    text = re.sub(
        r'<meta name="viewport" content="[^"]*">',
        '<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1.0, viewport-fit=cover">',
        text,
        count=1,
    )
    text = re.sub(
        r"<title>[^<]*</title>",
        "<title>Ember Runners: Dawnline</title>",
        text,
        count=1,
    )
    text = text.replace(
        '"ensureCrossOriginIsolationHeaders":true',
        '"ensureCrossOriginIsolationHeaders":false',
    )
    if 'id="status-notice">' in text:
        text = re.sub(
            r'id="status-notice">[^<]*</div>',
            f'id="status-notice">First download ~{total_mb} MB, please wait…</div>',
            text,
            count=1,
        )
    # 不要 preload pck/wasm：会和下引擎请求重复，慢连接上会下两遍
    text = re.sub(
        r'\s*<link rel="preload" href="index\.(wasm|pck)[^"]*" [^>]*>\n?',
        "\n",
        text,
    )
    text = _patch_html_loader_shell(text, total_mb)
    html_path.write_text(text, encoding="utf-8")
    print(f"已写入资源版本 {version} 入口缓存 {shell_ver} 封面 {cover_ver} -> {html_path}")


def patch_web_dir(out_dir: Path, version: str) -> None:
    js_path = out_dir / "index.js"
    html_path = out_dir / "index.html"
    if not js_path.is_file():
        raise SystemExit(f"找不到 {js_path}")
    if not html_path.is_file():
        raise SystemExit(f"找不到 {html_path}")
    template_name = patch_js(js_path)
    install_wasm_alias(out_dir, template_name)
    patch_html(html_path, version)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("cmd", choices=["version", "html", "dir"])
    parser.add_argument("target", nargs="?", type=Path)
    args = parser.parse_args()
    version = read_asset_version()
    if args.cmd == "version":
        print(version)
        return
    if args.cmd == "dir":
        if args.target is None:
            raise SystemExit("dir 模式需要 Web 输出目录")
        patch_web_dir(args.target, version)
        return
    if args.target is None:
        raise SystemExit("html 模式需要 index.html 路径")
    js_path = args.target.parent / "index.js"
    template_name = patch_js(js_path) if js_path.is_file() else None
    install_wasm_alias(args.target.parent, template_name)
    patch_html(args.target, version)


if __name__ == "__main__":
    main()
