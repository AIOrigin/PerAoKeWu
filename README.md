<div align="center">

# HYPERLUNATIC

[![English](https://img.shields.io/badge/English-blue)](README_en.md) [![简体中文](https://img.shields.io/badge/简体中文-red)](README.md)
单独

![Godot v4.4](https://img.shields.io/badge/Godot-v4.4-478cbf?logo=godot-engine&logoColor=white) [![GitHub license](https://img.shields.io/github/license/317gw/HYPERLUNATIC)](LICENSE) [![GitHub stars](https://img.shields.io/github/stars/317gw/HYPERLUNATIC)](https://github.com/317gw/HYPERLUNATIC/stargazers) [![GitHub issues](https://img.shields.io/github/issues/317gw/HYPERLUNATIC)](https://github.com/317gw/HYPERLUNATIC/issues) [![GitHub forks](https://img.shields.io/github/forks/317gw/HYPERLUNATIC)](https://github.com/317gw/HYPERLUNATIC/network)

HYPERLUNATIC 游戏项目备份存档开源学习文件和文件夹，由 白色蜂鸟(AlbedoHummingbird / 317gw) 制作，使用 Godot Engine 开发

早期项目Wiki可见 [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/317gw/HYPERLUNATIC) 此Wiki由语言模型生成，生成来源主要来自项目内文档，因未依据代码所以多数内容不准确，请以项目代码为准。此外网站可以直接对项目咨询语言模型。

**注意** 英文版本页（README）由语言模型翻译，不能保证准确性，且容易更新不及时导致陈旧。

**NOTE** The English version page (README) is translated by the Language Model, which does not guarantee accuracy and is prone to being outdated.

</div>


![高塔](/forREADME/godot.windows.opt.tools.64_iuGFJwCi3z.jpg)
![50m](/forREADME/godot.windows.opt.tools.64_7GSDSlLmNj.jpg)
![太阳景色](/forREADME/godot.windows.opt.tools.64_GtXq4hUzeo.jpg)
![弹幕](/forREADME/godot.windows.opt.tools.64_bKXhlvlfwd.jpg)
![水下](/forREADME/godot.windows.opt.tools.64_WjNpwygEvz.jpg)


## 🚀开始
引擎版本会激进跟随最新稳定版 —— Godot_4.4-stable  
主要使用GDScript进行开发  

版本构建区分dev、alpha、beta、stable。  
分发命名如 "HYPERLUNATIC v0.1.0-dev.1.20250708"。  
内部application/config/version如 "v0.1.0-dev.1"  

目前发布版都是dev开发版，所以说现阶段导出游戏意义不大。从"HYPERLUNATIC.exe"打开游戏。  

需要编辑项目的，请从上面<font color = green> <>Code▽</font>下载源码ZIP压缩包，或克隆，自行下载安装 [Godot Engine](https://godotengine.org/)，并导入项目文件，然后自由发挥:)  
极个别情况，你要是碰见什么安装错误、没有依赖，那我也不知道 摆手✋  

嘿！你现在就可以参与进来！地图设计 彩蛋 小游戏 ARG 之类……  
所有设计都在施工中，看看概率论与统计，保不齐后续会发生什么  

 * 后续计划见 [TodoPlan](TodoPlan.md)


## 🪪介绍：
这是一款开源的\*头部视角\*3D游戏，包含 平台跳跃、冒险解谜、动作射击、弹幕躲避 等元素，你可以去地图中找找有什么是需要完成的。

> 或者去看看你身处的世界……

 * #### 📜剧情
    2077年，Karole Kate休假回到了老家。在整理老电脑的过程中，她发现以前玩的一款\*超级老\*的游戏的其中一个服务器还在线上。于是在一通硬件、软件、升级、整理、打MOD之后，她进入了这个——2000年便在计划的服务器。  
    还有她在玩游戏不是穿越了😡。

 * #### 🗺地图设计&游戏流程
    地球🌏 向 太阳☀️ 的宇宙之旅！或是 但丁的神曲？  
    使用区域来进行场景风格和玩法上的区分，如天空、月球、水星。  

    你会在游戏服务器（实际离线）中游玩，内部采用线路关卡制。明确化 如空气墙、游玩区域、判定盒等场景构件。  
    场景的背景模型是完整而且可以到达的。  

    游戏服务器之间有不明显的连接，可以使用诸如掉出地图、寻找刻意的传送点等方式来完成切换。  
    兼容主菜单列表选关，被包装成游戏服务器列表。  

    除了完成主线流程外，还包含带有明确的规则限制的挑战任务。成就进度就是流程进度。与关卡、服务器、挑战、成就交织在一起的解密。不必要的ARG(未施工)。  

 * #### 🖼画面
    老游戏服务器的房间，打mod后的氛围。不是赛博朋克风格。  
    采用低分辨率贴图和低面数模型，根据物体性质的选择性使用PBR材质，简约的光照效果，尽可能酷炫的着色器后处理。  

    你可以看到你的身子！(未施工抱歉)  

 * #### 玩法主要参考(推荐去试一下)
    ULTRAKILL、Celeste、Mirror's Edge、Garry's Mod、Half-Life 2、Neon White、VOIN、Touhou Project、Minecraft、Touhou Luna Nights、沙雕之路、Deadlock、DEATH STRANDING DIRECTOR'S CUT、Antimatter Dimensions、NGU IDLE  
    …… 等好玩的游戏。

    风格灵感来自起源引擎(主要是gmod)和mc的服务器

    还有，以上构想均在制作中


## 🛠️核心机制
HYPERLUNATIC的核心机制，可以基本了解游戏设计。

* #### 玩家移动
    虽然参考了起源引擎，但玩家基本的被动受力和移动并不完全仿照刚体，代码上没有使用简洁的物理模拟。  
    玩家的运动系统设计的很复杂，代码上是根据玩家所处环境和玩家状态分别处理的。  
    冰面等表面会计算摩擦系数  
    斜坡会滑下来，制作此系统后玩家走出地面边缘容易加速飞出  
    上斜坡时，由于楼梯检测有误，会导致玩家表观速度持续增加，但实际上没有  

* #### 物理交互
    只对于各类物体，尽可能还原物理效果，不涉及过多物理视觉效果，如风、水波纹、树叶/草。

* #### 弹幕地狱
    参考Touhou Project弹幕作重新设计的，2d弹幕游戏的弹幕设计不适用于3d游戏。

* #### 选关界面
    使用游戏服务器界面包装选关界面。

* #### 流程控制
    区域 Area                 样式定义 # 对相关内容进行分组的主题和视觉样式划分，不是实际游玩场景的区分，多数游戏服务器只属于一个区域  
    游戏服务器 Game Server     场景容器 # 具有单条或多条路线的完整关卡场景  
    线路 Route                游戏路径 # 从头到尾的特定路径，由起点、检查点、终点标识，开始后会切换场景。通常就是一个关卡  
    场景组件 Scene Components  互动元素 # 环境对象、交互式元素和游戏机制  

* #### 简述现状
    水物理性能差，且物体通常不易稳定到水面。打开res://assets/systems/water_physics/fluid_mechanics_manager.tscn场景的use_rigid_bodys_fluid_mechanic启用主场景level_001_test_sandbox的水测试场景的物理  
由于项目施工中，优化差，如过于卡顿请减少刚体数量或者场景内其他物件  
    弹幕系统框架施工中，还不能正常编写行为脚本，而且性能差，推荐场景限制子弹1000以下。之后会尝试使用2d空间物理制作相对弹幕平面进行优化。  
    还没有使用对象池，上次试用对象池优化弹幕反而变卡了  
    偶尔会出现bug现象的回滚现象？  


## Q&A：
* 为什么选择使用Godot开发3D游戏？
    * Godot本身足够轻量级，磁盘、内存占用低，软件开关迅速，电脑负担小，开发方便。其他引擎的高新技术尚不考虑。

* 参与开发可以干什么？
    * 很多方式，比如提交代码、报告Bug、提供建议、翻译文档等。

* 我想提供帮助？
    * 你可以使用这个Github仓库，或在下方↓的联系方式留言讨论。

* 多语言支持？
    * 简体中文、繁体中文、英文。目前没有实力支持其他语言。如你想制作其他语言翻译，我非常乐意，直接联系我。

* 登录平台？
    * 仅目前，PC端，Steam、itch.io

* 要开发多久？
    * 我想要全职开发，但是会有困难，总之comeing s∞n in 2077

* 为什么是2077？
    * 因为好多赛博朋克或者未来风格作品都有出现这个年份。

* 游戏玩法是啥啊？缝合这么多游戏？
    * 主要玩法参考Celeste的平台跳跃，ULTRAKILL的快节奏操作，地图设计参考Celeste、Neon White。感觉和印象是更重要的，实际上并没有搭配毫不相干的游戏机制。
    * 四处逛逛。

* 我好像没看到有什么角色？
    * 游戏流程以玩家为中心，故事性较弱，大概会有我小说、车卡、RimWorld中的角色，且大概都是女，因为Touhou Project。

* 中文译名是啥啊？
    * ~~亢奋的疯子~~ ~~超月狂~~ ~~超级月亮人~~ 没有合适的中文译名，HYPERLUNATIC作为唯一名称就很合适，如果你有合适的中文译名，欢迎告诉我。

* Antimatter Dimensions和NGU IDLE是挂机、点击、idle游戏，和这游戏有啥关系？
    * 这俩游戏的流程设计非常好，其中的一些解谜部分非常有趣，所以偷了。

* ？：
    * 答应我，好好睡觉。


## 📌注意事项：
本项目为开源项目，采用 GPL-3.0 开源协议 - 查看 [LICENSE](LICENSE) 文件了解详情。对于GPL-3.0的传染性我很抱歉，我很高兴看到你去参考和使用我的代码。

欢迎参与贡献，但请遵守以下规定：  
1. 不要删除或修改文件中的版权声明。  
2. 不要在项目中使用任何未经授权的素材或代码。  
3. 用于商业用途时，仅代码可用，不要使用 美术/声效/模型/文本 等资源，不要使用 HYPERLUNATIC/FireKami/白色蜂鸟/AlbedoHummingbird/317gw 等字样用于宣传或主要内容(包括其大小写形式)。  

项目根目录下，目前只有assets文件夹能确保为项目作者制作的主要原创部分，assets文件夹为核心资产。  
assets文件夹下的部分代码和资源文件、图像、音频来自网络，对其进行了修改，遵守其协议，并尽可能的表明了出处，如发现问题请联系项目作者。  
目前并未整理非代码资源的许可，不要擅自使用。  

根目录下的其他并非由Godot Engine或其addon生成文件和文件夹，为临时的流动文件，其来源为其他开源项目或互联网，用于测试、开发等。

addons文件夹下存放着Godot Engine的插件。  
插件的原作者并非项目作者，部分代码已根据项目需求进行了修改，遵守其协议，因嫌麻烦并未列出许可证，如有问题请联系项目作者。  

如有对其他开源项目、addon、互联网资源的使用许可或许可证的异议，为项目作者的疏忽，请联系项目作者。  

> 作者邮箱：<wo3178216379@outlook.com>  
> INDIENOVA主页 -> [HYPERLUNATIC](https://indienova.com/g/hyperlunatic)  
> itch.io主页 -> [HYPERLUNATIC](https://albedohummingbird.itch.io/hyperlunatic)  
> bilibili -> [白色蜂鸟的个人空间](https://space.bilibili.com/32704272)  
> 爱发电赞助: -> [白色蜂鸟主页](https://ifdian.net/a/AlbedoHummingbird)  
> QQ讨论群 -> [白色蜂鸟&FireKami讨论](https://qm.qq.com/q/zh3svlXTBm) 705304831  
> Discord聊天室 -> [FireKami Game&Fiction](https://discord.gg/c9v67xuuQR)  
> /tp [github开源地址](https://github.com/317gw/HYPERLUNATIC)  

![Alt text](/forREADME/godot.windows.opt.tools.64_1721bm5eGd.jpg)
![Alt text](/forREADME/godot.windows.opt.tools.64_6GGmSkblFN.jpg)
![Alt text](/forREADME/godot.windows.opt.tools.64_OmOsZfQeu6.png)
![远景](/forREADME/godot.windows.opt.tools.64_vnLDbKccJK.jpg)
![水](/forREADME/godot.windows.opt.tools.64_8xybG45lHn.jpg)
![海泡沫1](/forREADME/godot.windows.opt.tools.64_PwjpRzcOVt.jpg)
![海泡沫2](/forREADME/godot.windows.opt.tools.64_d1uX4mJ7kA.jpg)
![弹幕发射器2](/forREADME/godot.windows.opt.tools.64_q3VD1p4X4Q.jpg)
![弹幕发射器4](/forREADME/godot.windows.opt.tools.64_KAdiUCbcte.jpg)
![弹幕发射器5](/forREADME/godot.windows.opt.tools.64_zS6zkwZ24w.jpg)
![制作组logo](/logo/logo暗处变亮.png)

> 现实的荒野

---
