# Godot Web 导出：卡皮巴拉跑酷踩坑与优化记录

> 项目：Capybara Rush（Godot 4.4，单线程 Web 导出）  
> 线上入口：`https://assets.elseland.elser.ai/games/capybara-rush/index.html`  
> 相关脚本：`tools/export_capybara_rush_web.sh` → `patch_web_cache_bust.py` → `upload_game_to_s3.sh`

---

## 一、为什么首次加载需要这么久？

Web 版 Godot 游戏**不是**打开一个 HTML 就完事，浏览器要完成一整条「下载引擎 → 编译 → 启动游戏 → 按需拉资源」的链路。首次访问（无痕 / 清缓存）尤其慢，原因如下。

### 1. 必须下载的核心包（最大头）

| 文件 | 磁盘原大小 | Brotli 传输 | 作用 |
|------|-----------|-------------|------|
| `index.wasm` | ~42 MB | ~6 MB | **整个 Godot 引擎**编译成 WebAssembly |
| `index.pck` | ~22 MB | ~7 MB | 游戏脚本、UI 字体、关卡 JSON、音效等 |
| `index.js` | ~300 KB | 很小 | 启动器、进度条、fetch 逻辑 |

**合计首次必下约 13 MB（Brotli）**，优化前未压缩约 **63 MB**。  
3D 模型（GLB）**不在 pck 里**，走 CDN 按需下载，进选角/进关时才拉。

### 2. 浏览器还要做 CPU 密集型工作

下载完成后并不等于能玩：

1. **WebAssembly 编译/实例化**（`wasm-instantiate`）—— 几十 MB 的 wasm 在主线程编译，中低端手机/电脑可能要 **数秒到十几秒**。
2. **解压 pck、初始化 Godot 运行时**—— 解析脚本、注册类、建渲染上下文。
3. **WebGL 首帧**—— GPU 管线、shader 就绪。

Network 面板显示 wasm/pck「下完了」，画面仍可能卡在加载封面，多半是在做 **编译 + 引擎初始化**，不是网络还在传。

### 3. 网络与 CDN 地理距离

资源托管在 **AWS us-east-1 + CloudFront**（边缘如东京 NRT）。国内用户跨境带宽常见 **100–500 KB/s**，即使 13 MB 也要 **30 秒～2 分钟**；优化前 63 MB 原文件出现 **5～15 分钟** 并不罕见。

### 4. 进游戏后的第二次下载（GLB）

首屏进 **选角菜单** 时，不再预载整关 GLB（见下文优化）。  
**选角预览、进关** 才从 CDN 拉角色/场景模型；并发限制为 2，避免浏览器连接池被占满。  
因此：**首包加载完 ≠ 所有 3D 资源已就绪**。

### 5. 第二次打开为什么快很多？

- `index.wasm` / `index.pck` / `index.js` 使用 `Cache-Control: immutable, max-age=31536000`，浏览器**本地磁盘缓存**。
- GLB 缓存在 `user://capybara_cdn/<版本>/`（IndexedDB / Origin Private FS）。
- 仅 `index.html` 为 `no-cache`，用于拿到带新 `?v=` 的入口。

---

## 二、我们踩过的坑

### 导出与打包

| 坑 | 现象 | 原因 | 处理 |
|----|------|------|------|
| **选场景导出漏脚本** | 网页白屏 / 解析 Global.gd 失败 | Godot「选场景导出」不会自动包含 `preload()` 链上的 `.gd` | `export_capybara_rush_web.sh` 自动把 capybara 全部 `.gd` + Autoload 依赖写入 `export_files` |
| **Web 无系统中文字体** | UI 方块字 | 系统字体在浏览器不可用 | 显式把 SmileSans、LiberationMono 等字体打进 pck |
| **主场景不对** | 导出成 App 首页而非跑酷 | `project.godot` 默认 `mobile_home.tscn` | 导出前临时改 `run/main_scene` 为 `capybara_rush.tscn`，脚本结束 restore |
| **模型已上 S3，pck 仍很大** | 误以为 GLB 还在包里 | pck ≈ wasm 引擎 + 脚本字体音效；GLB 在 `exclude_filter` 外置 CDN | 正常；体积主要看 wasm（引擎本体） |
| **编辑器 Web 预览 ≠ 线上包** | `localhost:8060/tmp_js_export.html` 黑屏/灰条、无封面 | 编辑器临时调试页，**未经过 patch** | 测线上用 `build/capybara_rush_web/index.html` 或 CDN 地址 |

### 加载与缓存

| 坑 | 现象 | 原因 | 处理 |
|----|------|------|------|
| **`<link rel="preload">` wasm/pck** | 同一文件下两遍，首访更慢 | preload 与 Godot 引擎 fetch 重复 | patch 移除 preload |
| **`Response.clone()` + `instantiateStreaming`** | 控制台刷屏 `still waiting on run dependencies: wasm-instantiate`，永久卡死 | 部分浏览器对 wasm 流式实例化 + clone 有 bug | patch：`arrayBuffer()` + `WebAssembly.instantiate(buffer)` |
| **CDN `immutable` 命中旧 JS** | 修了 patch 但线上行为不变 | 仅改 JS 内容，URL 未变 | `?v=` 带 pck/js/wasm 的 hash：`5-<wasm8>-<pck8>-<js8>` |
| **`_capyWakeLock` 重复声明** | `SyntaxError: Identifier '_capyWakeLock' has already been declared` | patch 脚本多次运行重复注入 | 幂等标记块 `CAPYBARA_WAKE_LOCK`，注入前先 strip |
| **未压缩上传 wasm/pck** | Network 显示 43+22 MB，下载数分钟 | S3 原样存储，无 `Content-Encoding` | 上传前 Brotli 预压缩（见下文） |

### 运行时（CDN 模型）

| 坑 | 现象 | 原因 | 处理 |
|----|------|------|------|
| **启动即预载全部 GLB** | 与 wasm/pck 抢带宽，首屏极慢 | `_ready` 里 `_prepare_level_assets()` | 选角/选关菜单阶段不预载关卡 GLB，**进关再下** |
| **CDN 并发过高** | 大量 GLB `Pending`，黑屏 | 浏览器对同域连接数 ~6，超限排队假死 | `capybara_cdn.gd` 全局队列，`MAX_CONCURRENT_DOWNLOADS = 2` |
| **切后台下载暂停** | 切 Tab 后进度停住 | SceneTree pause | CDN 节点 `PROCESS_MODE_ALWAYS` + Wake Lock 提示 |
| **选角预览同时拉 10+ 模型** | 连接池打满 | 每个卡片 `_ready` 即下载 | 按卡片 index **错峰 0.45s** 再拉预览 |

### 部署与调试

| 坑 | 现象 | 原因 | 处理 |
|----|------|------|------|
| **用 Godot F5 测 Web** | 竖条灰屏 | 竖屏 1080×1920 letterbox + 未 patch 的调试壳 | F6 运行当前场景，或测正式 build |
| **重复上传 template wasm** | S3 多一份 42 MB | `godot.web.template_*.wasm` 与 `index.wasm` 重复 | upload 排除 `godot.web.template*.wasm` |

---

## 三、已实施的优化清单

### 传输层（CDN）

- **Brotli 预压缩上传**（`wire_compress.py` + `upload_game_to_s3.sh`）  
  - S3 存压缩体，响应头 `Content-Encoding: br`  
  - 浏览器透明解压，Godot 无感  
  - 首访 **~13 MB**（br） vs 原 **~63 MB**（未压缩）  
  - 备选：`COMPRESS_CODEC=gzip bash upload_game_to_s3.sh`
- **缓存策略**  
  - `index.html` / `manifest.json`：`no-cache`  
  - wasm / pck / js / 封面：`immutable, max-age=31536000`  
  - wasm / pck / js URL 带 `?v=` 版本戳
- **部署后预热** `index.wasm`（CloudFront 边缘缓存）

### HTML / JS 补丁（`patch_web_cache_bust.py`）

- 加载封面 `cover.png`（独立文件名，避开 Godot 默认 `index.png` 的旧 CDN 缓存）
- 粉紫加载 UI + 进度条 +「首次约 N MB」提示（N 按 Brotli _wire_ 体积估算）
- fetch / XHR URL bust（js、pck、**wasm**）
- wasm 加载路径修复（ArrayBuffer 实例化）
- Wake Lock + 切后台文案提示
- Elseland App WebView 安全区 CSS（`--app-sat/sab/sal/sar`）
- 关闭 `ensureCrossOriginIsolationHeaders`（单线程导出无需 COOP/COEP，兼容性更好）

### 游戏逻辑

- 启动只到选角/选关，**不预载关卡 GLB**
- CDN 下载队列 + 最多 2 并发 + 120s 超时
- 接受 HTTP 206（Range）
- 选角预览错峰下载

---

## 四、标准发布流程

```bash
# 1. 导出 Web（改 export_files、临时 main_scene、Godot headless 导出、自动 patch）
bash assets/maps/route_levels/capybara_rush/tools/export_capybara_rush_web.sh

# 2. 本地预览（不要用 Godot 8060 调试页）
cd build/capybara_rush_web && python3 -m http.server 8765
# 打开 http://localhost:8765/index.html

# 3. 上传（需 AWS 凭证 + brotli）
python3 -m pip install brotli
bash assets/maps/route_levels/capybara_rush/tools/capybara_web/upload_game_to_s3.sh

# 4. 模型 CDN（改 ASSET_VERSION 后单独上传）
bash assets/maps/route_levels/capybara_rush/tools/capybara_web/upload_models_to_s3.sh
```

版本 bump 时改 `capybara_web_config.gd` 的 `ASSET_VERSION`。

---

## 五、验收清单（无痕窗口）

- [ ] 仅 **1 次** wasm + **1 次** pck 请求（无重复 preload）
- [ ] wasm / pck 响应头含 `content-encoding: br`（或 gzip）
- [ ] 传输体积 wasm ~6 MB、pck ~7 MB 量级
- [ ] 无 `wasm-instantiate` 无限刷屏
- [ ] 无 `_capyWakeLock` SyntaxError
- [ ] 加载封面 + 进度条 + 约 13 MB 提示
- [ ] 进选角不批量 Pending；进关 GLB 最多 2 路并发
- [ ] 二次打开 wasm/pck 走 disk cache，秒开

DevTools 快速检查：

```bash
curl -sI -H 'Accept-Encoding: br' \
  'https://assets.elseland.elser.ai/games/capybara-rush/index.wasm'
# 期望：content-encoding: br，content-length ≈ 6_000_000
```

---

## 六、Brotli 兼容性说明

| 环境 | 支持 Brotli | 能跑 Godot 4 Web |
|------|-------------|------------------|
| Chrome / Edge / Firefox 近年版本 | ✅ | ✅ |
| Safari 11+ / iOS 11+ | ✅ | ✅ |
| 微信等 Chromium WebView（较新） | ✅ | ✅ |
| IE 11 | ❌ | ❌（无 WebAssembly） |

**结论**：能运行 Godot 4 Web 的浏览器几乎都能解 Brotli；不支持 Brotli 的也跑不了 wasm。  
保守方案：`COMPRESS_CODEC=gzip bash upload_game_to_s3.sh`（约 17 MB）。

---

## 七、体积还能再减吗？

| 方向 | 预期收益 | 成本 |
|------|----------|------|
| 已做：Brotli | 63 MB → ~13 MB 传输 | 低 |
| 已做：GLB 外置 CDN | pck 不含模型 | 中 |
| 定制 Godot 导出模板（裁剪引擎功能） | wasm 可能再减 20–40% | 高 |
| 国内 CDN 镜像（阿里云等） | 降低延迟，非体积 | 运维 |
| 线程版 wasm + COOP/COEP | 性能↑，托管更麻烦 | 不推荐当前项目 |

wasm **~42 MB** 是 Godot 4 引擎本体，单线程 Web 导出很难压到几 MB；**首次加载下限**主要由引擎 wasm 决定。

---

## 八、相关文件索引

| 文件 | 作用 |
|------|------|
| `tools/export_capybara_rush_web.sh` | Headless 导出 + 写 export_files |
| `tools/capybara_web/patch_web_cache_bust.py` | HTML/JS 补丁、封面、缓存破坏 |
| `tools/capybara_web/upload_game_to_s3.sh` | S3/CloudFront 上传 + Brotli |
| `tools/capybara_web/wire_compress.py` | Brotli/gzip 预压缩 |
| `tools/capybara_web/upload_models_to_s3.sh` | GLB 模型 CDN |
| `capybara_web_config.gd` | `ASSET_VERSION`、CDN 根 URL |
| `capybara_cdn.gd` | 运行时 GLB 下载队列 |
| `capybara_rush.gd` | 启动流程（选角前不预载关卡） |

---

## 九、时间线参考（优化后，国内网络粗估）

| 阶段 | 耗时（粗估） |
|------|-------------|
| 下载 wasm + pck（~13 MB br，并行） | 30 s ~ 2 min |
| wasm 编译 + 引擎启动 | 5 ~ 15 s |
| 进入选角 UI | 可交互 |
| 首次进关 + GLB | 视模型数量 + 网络，额外 10 s ~ 数 min |
| **二次访问**（有缓存） | 通常 **< 5 s** 进游戏 |

实际耗时因设备、网络、CDN 命中情况差异很大；**首次慢是 WebAssembly 游戏的常态**，优化目标是控制必下体积、避免重复下载、把大模型延后到进关再拉。
