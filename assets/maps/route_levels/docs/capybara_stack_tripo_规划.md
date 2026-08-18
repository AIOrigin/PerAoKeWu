# Capybara Rush · Stack 模式 — Tripo 资源规划

> **状态（2026-08-06）**：Batch A + Batch B 障碍已生成并入库 `capybara_rush/`（不进星火信使 `models/` / `runner_60s`）。  
> - 概念图：Elser → `_inbox/concepts/capybara_stack/`  
> - Tripo 原料：`_inbox/tripo_raw/capybara_stack/`  
> - 正式入库：`capybara_rush/models/`  
> - 复跑脚本：`GENERATE_WITH_TRIPO.sh` / `GENERATE_BATCH_B_OBSTACLES.sh` / `GENERATE_BATCH_B_REMAINING.sh`  
> Batch B（6 个）约耗 350 credits；2026-08-06 生成后余额约 299。

**禁止**把本模式障碍/角色写进 `models/obstacles/`、星球 JSON 或 `runner_60s` 关卡。
---

## 1. 模式一句话

| 项 | 内容 |
|----|------|
| 玩法 | 沿赛道前进，拾取水豚叠成塔；避障保塔不倒，冲刺终点 |
| 镜头 | 第三人称跟拍，略高，看向跑道前方 |
| 核心资产 | **可堆叠的水豚**（同一底座尺寸）+ **窄道障碍** + **粉彩环境** |

本仓库当前是「星火信使」跑酷；Stack 建议作为**独立小模式/原型**目录，避免和 Elsa/Rook 混目录。

**正式目录（已创建）**

```
assets/maps/route_levels/
├── _inbox/tripo_raw/capybara_stack/     # Tripo 原始输出
├── _inbox/concepts/capybara_stack/      # 概念图 / Prompt 备份
└── capybara_rush/                       # ★ 独立地图（对标 runner_60s）
    ├── model_paths.gd                   # CapybaraRushPaths
    ├── models/
    │   ├── characters/
    │   ├── obstacles/
    │   ├── environment/
    │   └── props/
    └── levels/                          # 本模式关卡（勿用 planets/）
```

---

## 2. 统一美术 Prompt 前缀（所有 Tripo 任务共用）

英文前缀（推荐直接给 Tripo）：

```text
Low-poly stylized 3D game asset, soft pastel colors, rounded forms,
minimal detail, clean silhouette, mobile game style like Capybara Rush,
no realism, no PBR metal, no text, no UI, isolated object, centered,
uniform scale reference, solid colors, soft lighting
```

技术参数建议（与现有 `GENERATE_WITH_TRIPO.sh` 类似）：

| 参数 | 建议 |
|------|------|
| 模型 | 优先 `tripo` / 当前 CLI 默认高质量档 |
| 面数 | 先 3k–8k，游戏内再 decimate |
| 格式 | `.glb` |
| 贴图 | 尽量 **vertex color / 简单 albedo**；避免复杂 UV 碎贴图 |
| 朝向 | 角色面朝 +Z 或统一约定「背对相机为默认奔跑朝向」 |

---

## 3. 生成清单（按优先级分批）

### Batch A — MVP 必做（先做这一批）

| ID | 资产 | 入库名（验收后） | Tripo Prompt 要点（接在前缀后） | 用途 |
|----|------|------------------|--------------------------------|------|
| A1 | 水豚本体（标准） | `characters/capybara_base.glb` | `cute chubby capybara, warm brown, tiny ears, short legs, oblong body, single mesh, T-pose or idle standing, flat bottom for stacking` | 塔的每一层；可实例化多次 |
| A2 | 木栅栏障碍 | `obstacles/fence_picket.glb` | `simple wooden picket fence segment, dark brown vertical slats, two horizontal rails, about 1.5m wide, low-poly` | 挡道 / 需换道 |
| A3 | 小路岩石 | `environment/rock_edge.glb` | `small angular low-poly rock, purple-grey pastel, trail side prop` | 路边装饰 |
| A4 | 棒棒糖树 | `environment/tree_lollipop.glb` | `stylized lollipop tree, thin trunk, one round foliage ball, soft green or muted pink` | 远中景 |
| A5 | 终点门/拱门 | `props/finish_arch.glb` | `simple finish line arch or gate, pastel colors, no text, low-poly` | 关卡终点 |

**A1 关键要求（堆叠）**

- 底部近似平整，竖直堆叠时不歪。  
- 包围盒宽高比稳定；建议逻辑尺寸：**宽 ≈ 1.0、长 ≈ 1.4、高 ≈ 0.7**（入库后统一缩放到该比例）。  
- 不要做张开的四肢大姿态，否则叠塔会穿模。

### Batch B — 玩法丰富

| ID | 资产 | 入库名 | Prompt 要点 | 用途 |
|----|------|--------|-------------|------|
| B1 | 水豚（小） | `characters/capybara_small.glb` | 同 A1，`smaller scale variant` | 视觉层次 / 分数差 |
| B2 | 水豚（大） | `characters/capybara_large.glb` | 同 A1，`slightly larger` | Boss 层 / 奖励 |
| B3 | 半边栅栏 | `obstacles/fence_half.glb` | 半宽栅栏，只挡一道 | 单侧挡道 |
| B4 | 矮墙/雪沿 | `obstacles/low_wall.glb` | `low pastel wall curb` | 矮障、需跳（若做跳跃） |
| B5 | 可拾取水豚标记 | `props/pickup_glow_pad.glb` | `flat circular pastel pad, soft glow shape, no text` | 地上可叠单位的生成点 |
| B6 | 断桥缺口边 | `obstacles/gap_edge.glb` | `broken path edge piece` | 掉落威胁（可选） |

### Batch C — 场景氛围（可程序化替代则可不生成）

| ID | 资产 | 入库名 | Prompt 要点 | 备注 |
|----|------|--------|-------------|------|
| C1 | 远山丘 | `environment/hill_soft.glb` | `large rounded pastel purple hill, very low poly` | 也可用 CSG/Mesh 代替 |
| C2 | 水面片 | — | **不建议 Tripo** | 用 Plane + 水色材质即可 |
| C3 | 路段块 | — | **不建议 Tripo** | 用挤出/Plane 白lavender 路面 |
| C4 | 天空盒 | — | **不建议 Tripo** | 渐变 Environment |

### Batch D — 皮肤变体（后期）

海盗帽水豚、墨镜水豚等（App 有大量皮肤）。**Stack 原型不要先做**，等 A/B 跑通再开。

---

## 4. 不建议用 Tripo 做的

| 内容 | 原因 | 替代 |
|------|------|------|
| 整条赛道 | 弯曲/拼接难控 | `RoadMeshBuilder` 或简单 Plane |
| 水面 / 天空 | 平面即可 | 材质 + Environment |
| UI（LEVEL、进度条） | 2D | Control / Texture |
| 物理碰撞体 | Tripo mesh 不适合直接当精确碰撞 | 简化 Box/Capsule |
| 带动画的奔跑序列 | 成本高、Stack 可用「整体平移 + 轻微 bob」 | 单 idle mesh + 动画曲线 |

---

## 5. 概念图 → Tripo 流程（可选）

若要用「图生 3D」（与全息障碍一样）：

1. 先用 AI 出 **纯白底、单物体、三视图或正交侧视** 概念图。  
2. 放入：`_inbox/concepts/capybara_stack/`  
3. 脚本参考：`_inbox/concepts/holographic/GENERATE_WITH_TRIPO.sh`  
4. 输出：`_inbox/tripo_raw/capybara_stack/<id>/`  
5. 验收、重命名、缩放到统一单位后 → `capybara_rush/models/`

纯文生 3D 也可，Batch A 优先文生，省一步画图。

---

## 6. Godot 原型侧（资源齐了再做）

最小可玩：

1. 自动向前跑；左右换道（2–3 道）。  
2. 碰到 `pickup` → 塔顶再挂一只 `capybara_base`（本地 Y 叠高）。  
3. 碰到 `fence` → 掉 1 只或整塔晃动；塔空则失败。  
4. 到 `finish_arch` → 按高度计分。  
5. 环境：两侧水色 Plane + 实例化 `tree_lollipop` / `rock_edge`。

**不必**一上来做真实刚体平衡；可用「换道时塔倾斜角、撞障掉层」假平衡，手感接近 Stack。

---

## 7. 费用与数量预估

| 批次 | 模型数 | 说明 |
|------|--------|------|
| A | 5 | MVP |
| B | 6 | 玩法加料 |
| C | 0–1 | 多数程序化 |
| **合计建议首发** | **5（仅 A）** | 你确认后再调 API |

每模型按 Tripo 当前计价扣费；生成前会再跑一次 `tripo balance` 给你看余额。

---

## 8. 待你确认的事项

请直接回复勾选/修改：

1. **首发只做 Batch A（5 个）**，还是 A+B 一起？  
2. 风格是否锁定：**粉彩低模 + 棕色水豚**（如截图），还是更 Q 版/更写实？  
3. 生成方式：**纯文生** 或 **先概念图再图生**？  
4. 水豚是否需要 **多皮肤**（第一期不要 / 要 1–2 个）？  
5. ~~目录~~ → 已定为 `capybara_rush/`（独立地图）。

---

*文档版本：2026-08-06 · Batch A + Batch B 已入库 capybara_rush*
