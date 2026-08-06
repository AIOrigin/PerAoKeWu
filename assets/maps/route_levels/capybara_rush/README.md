# Capybara Rush（独立地图）

与星火信使跑酷（`runner_60s` / `models/`）**完全隔离**。本目录只放 Capybara Rush / Stack 相关资源与关卡。

## 怎么跑起来看

1. 在 Godot 文件树打开：`capybara_rush/capybara_rush.tscn`
2. 按 **F6**（运行当前场景），不要按 F5（F5 仍是主页 `mobile_home`）
3. **A / D** 或方向键换道；自动前进；到终点按 **R** 重开

```
capybara_rush/
├── capybara_rush.tscn   # ★ 可玩原型场景
├── capybara_rush.gd
├── model_paths.gd
├── models/              # 正式 3D
│   ├── characters/
│   ├── obstacles/
│   ├── environment/
│   └── props/
└── levels/
```

## 当前模型（Batch A）

| 资产 | 路径 |
|------|------|
| 水豚 | `res://assets/maps/route_levels/capybara_rush/models/characters/capybara_base.glb` |
| 栅栏 | `…/obstacles/fence_picket.glb` |
| 岩石 | `…/environment/rock_edge.glb` |
| 棒棒糖树 | `…/environment/tree_lollipop.glb` |
| 终点拱门 | `…/props/finish_arch.glb` |

路径常量：`model_paths.gd`（`CapybaraRushPaths`）  
生成原料：`../_inbox/concepts/capybara_stack/`、`../_inbox/tripo_raw/capybara_stack/`  
规划：`../docs/capybara_stack_tripo_规划.md`
