class_name ModelPaths
extends RefCounted

## 星火信使跑酷正式 3D 资源根路径（见 docs/3D资源目录规划.md）
## Capybara Rush 请用 capybara_rush/model_paths.gd（CapybaraRushPaths），勿混入本树。

const ROOT := "res://assets/maps/route_levels/models/"

const CHARACTERS := ROOT + "characters/"
const ELSA := CHARACTERS + "elsa/"
const ROOK := CHARACTERS + "rook/"

const OBSTACLES := ROOT + "obstacles/"
const OBS_JUMP := OBSTACLES + "jump/"
const OBS_SLIDE := OBSTACLES + "slide/"
const OBS_DODGE := OBSTACLES + "dodge/"
const OBS_HOLO := OBSTACLES + "styles/holographic/"

const TRACK_TEX := ROOT + "track/textures/"
const ENV_MID := ROOT + "environment/midground/"
const ENV_FAR := ROOT + "environment/distant/"
const ENV_BUILDINGS := ROOT + "environment/buildings/"
const ENV_PLANETS := ROOT + "environment/planets/"
const ENV_STARS := ROOT + "environment/stars/"
const ENV_SHIPS := ROOT + "environment/ships/"
const BG_PANORAMA := ROOT + "backgrounds/panoramas/"

# 运输包等 2D 仍暂放旧批目录（未迁 models）
const CARGO_2D := "res://mvp素材第二批/运输包2d/"
