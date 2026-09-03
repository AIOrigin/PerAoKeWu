# 星火信使 · H5（HTML5）移交说明

面向：把游戏嵌进 **已有 iOS 游戏壳 App（WebView）** 的技术人员。

> 本交付物是 **Godot 4.4 导出的 Web 包**（`index.html` + `.wasm` + `.pck` 等），**不是**独立上架用的 IPA，也**不是**未编译源码 ZIP。

---

## 1. 游戏概况

| 项 | 值 |
|---|---|
| 产品名 | 星火信使 / Ember Runner |
| 引擎 | Godot **4.4** → Export → **Web** |
| 主场景 | `mobile_home.tscn`（竖屏手机 UI） |
| 分辨率 | 1080×1920，竖屏 |
| 操作（跑酷） | 左右滑换道 · **上滑跳跃** · 下滑滑铲（点按不作普通跳跃，防误触） |

---

## 2. 目录里有什么

| 文件 | 说明 |
|---|---|
| `HANDOFF_H5.md` | 本文 |
| `CHECKLIST_H5.md` | 接收方勾选 |
| `export_presets.web.example.cfg` | Web 导出预设示例 |
| `export_h5.ps1` | Windows 一键导出脚本（需本机 Godot 4.4.1 + templates） |
| `build/` | 导出产物（`index.html` 等） |
| `EmberRunner_H5_YYYYMMDD.zip` | 可直接给壳工程挂载的静态资源包 |

---

## 3. 接入方式（WebView）

1. 解压 ZIP，得到以 `index.html` 为入口的静态目录。  
2. 用 **https**（或 App 内本地/桥接加载）打开该目录；纯 `file://` 在部分 WebView 不可用。  
3. 建议全屏、允许触控、锁定竖屏。  
4. 当前导出默认 **关闭多线程**（`thread_support=false`），降低对 COOP/COEP 的依赖，便于嵌壳。  
5. 若壳已配置跨源隔离且希望开线程提性能，可再出一版开启 `variant/thread_support`。

官方说明：[Exporting for the Web](https://docs.godotengine.org/en/4.4/tutorials/export/exporting_for_web.html)

---

## 4. 体积说明（给产品/技术）

| 交付物 | 体积（本版） |
|---|---|
| `EmberRunner_H5_20260902.zip` | **约 336.5 MB** |
| 解压后 `index.pck` | **约 530.2 MB** |
| `index.wasm` | 约 41.7 MB |

- 这是 **真 3D 跑酷**，H5 包会明显大于普通 2D 小游戏。  
- 已排除：备份、视频帧、编辑器、`capybara_rush`、参考全景、未引用 sidecar 贴图等。  
- 嵌壳后建议由壳侧做 **CDN / 首包分包 / 进游戏再下载**，不宜当几十 MB 的轻量 H5 预期。  
- 本版为角色/UI 压缩后、近景环境已从备份还原的可玩交付版（非历史 351/554 包）。

---

## 5. 本机重新导出（可选）

1. 安装 Godot **4.4.x** 标准版 + 同版本 Export Templates（含 `web_*`）。  
2. 将 `export_presets.web.example.cfg` 配进工程 `export_presets.cfg`。  
3. 或在仓库根执行：

```powershell
powershell -ExecutionPolicy Bypass -File .\release\h5_handoff\export_h5.ps1
```

---

## 6. 验收建议

- 冷启动进入手机主页（HOME / MAP / TASKS / RUNNER）  
- 触控：左右滑 / 上滑跳 / 下滑铲  
- 一局跑酷可结算返回  
- iOS WebView 真机：音频、竖屏、前后台切换不白屏
