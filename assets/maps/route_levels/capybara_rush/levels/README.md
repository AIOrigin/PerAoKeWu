# levels/

Capybara Rush 关卡数据（与 `runner_60s` / `planets` 隔离）。

## 规划

- **[LEVEL_PLAN_30.md](./LEVEL_PLAN_30.md)** — 30 关 × 5 基调、速度难度、Tripo 批次

## 已落地

```
levels/
├── LEVEL_PLAN_30.md
├── level_catalog.gd          # 在上级目录：capybara_rush/level_catalog.gd
├── themes/
│   ├── lake_clear.json
│   ├── honey_pasture.json
│   ├── sakura_cloud.json
│   ├── dusk_neon.json
│   └── onsen_volcano.json
└── level_01.json … level_30.json
```

## 游玩

1. F6 运行 `capybara_rush.tscn`
2. 选角色 → **选关卡**（未解锁的会锁住；通关解锁下一关）
3. 每关 `run_speed` / 断崖数 / 主题色 / 风景路径来自 JSON

主题缺模型时自动回退程序方块 / 棒棒糖树。Tripo 脚本：

`_inbox/concepts/capybara_stack/GENERATE_THEME_ASSETS.sh`
