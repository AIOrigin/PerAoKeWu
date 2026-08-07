# Capybara Rush（独立地图）

与星火信使跑酷（`runner_60s` / `models/`）**完全隔离**。本目录只放 Capybara Rush / Stack 相关资源与关卡。

## 怎么跑起来看

1. 在 Godot 文件树打开：`capybara_rush/capybara_rush.tscn`
2. 按 **F6**（运行当前场景），不要按 F5（F5 仍是主页 `mobile_home`）
3. 选角色 → 选模式（**叠塔 Stack** / **竞速 Rush**）
4. **A / D** 换道；**空格 / W** 跳跃；自动前进；**R** 重开；**Esc** 回选角

### 通用机制

- **跳跃**：躲开障碍；可跳上**台阶**
- **黄星加速道具**：拾取后短时加速
- **橙色加速赛道**：踩上去持续加速
- **弯道**：赛道会左右拐弯

### 竞速模式

- 碰到**飞船** → 冲锋 **5s**（开飞船造型 + 加速）
- 冲锋中撞**障碍** → 冲锋 **-1s**
- 冲锋中**加速包** → 冲锋 **+0.5s**（上限 12s）

```
capybara_rush/
├── capybara_rush.tscn
├── capybara_rush.gd
├── capybara_track_path.gd   # 弯道 Curve3D
├── model_paths.gd
├── models/
└── levels/
```

路径常量：`model_paths.gd`（`CapybaraRushPaths`）  
生成原料：`../_inbox/concepts/capybara_stack/`、`../_inbox/tripo_raw/capybara_stack/`  
规划：`../docs/capybara_stack_tripo_规划.md`
