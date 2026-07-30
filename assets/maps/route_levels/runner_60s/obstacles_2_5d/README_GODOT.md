# 2.5D 跑酷障碍物精灵：Godot 直接使用包

本目录包含四张已经完成背景透明清理的 **RGBA PNG** 精灵。每张均为一件完整障碍物，而非需要手动组合的分层零件。将整个 `final` 文件夹复制到 Godot 项目的 `res://assets/obstacles/` 后，Godot 会自动将 PNG 作为 `CompressedTexture2D` 导入，可直接赋给 `Sprite2D.texture` 或 `AnimatedSprite2D.sprite_frames`。

| 文件 | 画布 | 对应玩法 | 推荐节点 |
|---|---:|---|---|
| `obstacle_energy_orb_grumpy_2_5d.png` | 1920 × 1920 | 漂浮躲避障碍物：烦躁表情 | `Area2D > Sprite2D` |
| `obstacle_energy_orb_angry_2_5d.png` | 1920 × 1920 | 漂浮躲避障碍物：愤怒表情 | `Area2D > Sprite2D` |
| `obstacle_energy_sprigs_2_5d.png` | 1920 × 1920 | 跳跃躲避的低矮能量棱芽 | `Area2D > Sprite2D` |
| `obstacle_phase_curtain_2_5d.png` | 2560 × 1440 | 滑铲穿越的上方相位光幕 | `Area2D > Sprite2D` |

## 最小使用步骤

1. 将四张 PNG 放入 Godot 项目的 `res://assets/obstacles/`。
2. 新建一个 `Area2D`，添加一个 `Sprite2D` 子节点，并把对应 PNG 拖入 `Texture` 属性。
3. 添加 `CollisionShape2D`，使用简易形状而非逐像素碰撞。
4. 依据项目世界单位调整 `Sprite2D.scale`；从 `Vector2(0.35, 0.35)` 开始试验即可。

> 所有 PNG 都具有真实 Alpha 通道和四角透明留白。不要在 Godot 中启用“背景去除”或色键；直接导入即可。

## 推荐碰撞体

| 障碍物 | 碰撞体 | 位置建议 |
|---|---|---|
| 两个能量球 | `CircleShape2D` | 覆盖核心球体约 70%–75% 直径；忽略闪电与悬浮环。 |
| 能量棱芽 | 1 个低矮 `RectangleShape2D` 或 2 个窄矩形 | 放在晶体基部至中段；不要把碰撞体覆盖至最高尖端。 |
| 相位光幕 | 一个宽矩形 `RectangleShape2D` | 仅覆盖上方光幕区域；下方滑铲空隙必须不设碰撞。 |

## 透明与渲染建议

| 项目 | 建议 |
|---|---|
| 混合模式 | 默认 Alpha 混合可直接使用。若需要更强光感，可复制一个 Sprite2D，顶层使用 Add 混合材质。 |
| 过滤 | 保持默认线性过滤；如果采用像素风项目，再改用 Nearest。 |
| 颜色 | 保持原始 `modulate = Color.WHITE`。可通过轻微的蓝紫色 `modulate` 做关卡变体。 |
| 移动端缩放 | 若需要降低显存占用，可在 Godot Import 面板中将 `Size Limit` 或最大纹理尺寸下调至 1024；不要改变透明通道。 |

## 可选的 Godot 节点结构

```text
Area2D (Obstacle)
├── Sprite2D
└── CollisionShape2D
```

该结构已经足够让四件资产作为跑酷障碍物使用；能量球的悬浮、棱芽的微光、光幕的扫描线等动态效果可以在后续通过 `Tween`、Shader 或粒子系统增强，但并不是导入与使用的前置条件。
