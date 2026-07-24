# 《星火信使：黎明线》角色故事页 UI 切图集

**版本**：1.0  
**生成日期**：2026-07-23  
**适用范围**：Elsa、Rook 等角色故事页面

---

## 📦 切图清单

所有切图均为 **PNG 格式**，**RGBA 颜色模式**，**透明背景**，可直接用于 Web/移动应用开发。

### 导航组件

| 切图名称 | 尺寸 | 用途 | 说明 |
|---|---|---|---|
| `header_bg.png` | 854×80 px | 顶部导航栏背景 | 深黑色 #0F1520，包含状态栏与角色信息区 |
| `header_divider.png` | 854×2 px | 顶部分割线 | 金色 #D4A574，分隔顶部栏与内容区 |
| `footer_bg.png` | 854×160 px | 底部导航栏背景 | 深黑色 #0F1520，包含四栏 Tab |
| `footer_divider.png` | 854×2 px | 底部分割线 | 金色 #D4A574，分隔内容区与底部栏 |

### 角色信息组件

| 切图名称 | 尺寸 | 用途 | 说明 |
|---|---|---|---|
| `character_badge_bg.png` | 80×80 px | 角色徽章背景 | 棕色 #8B6F43，圆形（需在 CSS 中设置 border-radius: 50%） |

### 内容装饰组件

| 切图名称 | 尺寸 | 用途 | 说明 |
|---|---|---|---|
| `section_title_line.png` | 600×2 px | 章节标题装饰线 | 金色 #D4A574，用于分隔「WHY SHE RUNS」等章节 |
| `comic_frame_corner_tl.png` | 40×40 px | 漫画边框左上角 | 金色 #D4A574，L 形装饰角 |
| `comic_frame_corner_br.png` | 40×40 px | 漫画边框右下角 | 金色 #D4A574，L 形装饰角 |

### 故事面板组件

| 切图名称 | 尺寸 | 用途 | 说明 |
|---|---|---|---|
| `story_panel_bg.png` | 800×400 px | 故事文本面板背景 | 深灰色 #161E20，透明度 78%（alpha 200/255） |
| `story_panel_border.png` | 800×2 px | 故事面板上边框 | 棕色 #8E6F43，分隔漫画与文字区 |

---

## 🎨 色彩规范

所有切图遵循以下色彩体系：

| 色彩名称 | 十六进制 | RGB | 用途 |
|---|---|---|---|
| 深黑色 | #0F1520 | (15, 21, 32) | 背景色，导航栏 |
| 深灰色 | #161E20 | (22, 30, 32) | 面板背景 |
| 棕色 | #8B6F43 | (139, 111, 67) | 徽章、边框 |
| 金色 | #D4A574 | (212, 165, 116) | 强调、分割线、激活态 |

---

## 💻 技术接入指南

### HTML 结构示例

```html
<!-- 顶部导航栏 -->
<header class="story-header">
  <img src="header_bg.png" class="header-bg" alt="">
  <img src="header_divider.png" class="header-divider" alt="">
  
  <div class="character-info">
    <img src="character_badge_bg.png" class="badge" alt="Elsa">
    <h1>ELSA</h1>
    <span>Lv.6</span>
  </div>
</header>

<!-- 章节标题 -->
<section class="story-section">
  <div class="section-title">
    <span>WHY SHE RUNS</span>
    <img src="section_title_line.png" class="title-line" alt="">
  </div>
</section>

<!-- 漫画区域 -->
<div class="comic-container">
  <img src="comic_frame_corner_tl.png" class="corner-tl" alt="">
  <img src="comic_frame_corner_br.png" class="corner-br" alt="">
  <!-- 漫画内容 -->
</div>

<!-- 故事文本面板 -->
<div class="story-panel">
  <img src="story_panel_bg.png" class="panel-bg" alt="">
  <img src="story_panel_border.png" class="panel-border" alt="">
  <p>故事文本内容...</p>
</div>

<!-- 底部导航栏 -->
<footer class="story-footer">
  <img src="footer_divider.png" class="footer-divider" alt="">
  <img src="footer_bg.png" class="footer-bg" alt="">
  <!-- Tab 内容 -->
</footer>
```

### CSS 样式建议

```css
/* 顶部导航栏 */
.story-header {
  position: relative;
  height: 80px;
  background: #0F1520;
}

.header-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.header-divider {
  position: absolute;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 2px;
}

/* 角色徽章 */
.badge {
  width: 80px;
  height: 80px;
  border-radius: 50%;
  object-fit: cover;
}

/* 章节标题装饰线 */
.title-line {
  width: 600px;
  height: 2px;
  display: inline-block;
  margin-left: 16px;
}

/* 漫画边框角 */
.corner-tl, .corner-br {
  position: absolute;
  width: 40px;
  height: 40px;
}

.corner-tl {
  top: 0;
  left: 0;
}

.corner-br {
  bottom: 0;
  right: 0;
}

/* 故事面板 */
.story-panel {
  position: relative;
  background: rgba(22, 30, 32, 0.78);
  border-top: 2px solid #8E6F43;
  padding: 24px;
}

.panel-bg {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0.78;
}

/* 底部导航栏 */
.story-footer {
  position: fixed;
  bottom: 0;
  left: 0;
  width: 100%;
  height: 160px;
  background: #0F1520;
}

.footer-divider {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 2px;
}
```

### 响应式适配

所有切图尺寸基于 **854px 宽度**（竖屏标准）。对于不同屏幕尺寸，建议采用以下缩放方案：

| 屏幕宽度 | 缩放比例 | 说明 |
|---|---|---|
| 360px（小屏手机） | 42% | `transform: scale(0.42)` |
| 480px（中屏手机） | 56% | `transform: scale(0.56)` |
| 720px（大屏手机） | 84% | `transform: scale(0.84)` |
| 854px（标准竖屏） | 100% | 原始尺寸 |
| 1024px（平板） | 120% | `transform: scale(1.2)` |

---

## 🔧 集成检查清单

- [ ] 所有 10 个 PNG 文件已复制到项目资源目录
- [ ] 图片路径在 HTML/CSS 中正确引用
- [ ] 透明背景在浏览器中正确显示（无白色或黑色背景）
- [ ] 色彩与设计稿一致（特别是金色 #D4A574 和深黑色 #0F1520）
- [ ] 响应式缩放在各屏幕尺寸上正常工作
- [ ] 导航栏、分割线、面板边框对齐无误
- [ ] 文字与切图的叠放顺序正确（z-index）
- [ ] 性能测试：图片加载时间 < 500ms

---

## 📝 文件命名规范

所有切图遵循以下命名规范，便于维护与扩展：

```
{component_type}_{element_name}_{variant}.png
```

**示例**：
- `header_bg.png`：导航类 + 背景
- `story_panel_border.png`：故事类 + 面板 + 边框
- `comic_frame_corner_tl.png`：漫画类 + 边框 + 左上角

**前缀含义**：
- `header_*`：顶部导航相关
- `footer_*`：底部导航相关
- `story_*`：故事内容相关
- `comic_*`：漫画区域相关
- `character_*`：角色信息相关
- `section_*`：章节标题相关

---

## 🚀 后续扩展

### 新增切图建议

如需为其他角色（如 Rook）添加故事页，建议新增以下切图：

- `character_badge_bg_rook.png`：Rook 的徽章背景（可调整色调）
- `story_panel_bg_variant.png`：不同故事面板背景变体
- `divider_horizontal_thick.png`：粗分割线变体

### 动画与交互

建议在以下元素上添加过渡动画：

- **淡入淡出**：章节标题、故事面板（duration: 300ms）
- **滑动**：导航栏、底部 Tab（duration: 200ms）
- **缩放**：角色徽章 hover 效果（scale: 1.05）

---

## 📞 技术支持

如有任何问题或需要调整切图规格，请联系设计团队。

**最后更新**：2026-07-23  
**维护者**：Manus AI
