# Waybar + Catppuccin 配置项目

## 项目概述

本目录是 Waybar 状态栏的个性化配置，针对 **Niri** Wayland 合成器，使用 **Catppuccin Mocha** 主题。

## 文件结构

| 文件 | 用途 |
|------|------|
| `config.jsonc` | Waybar 主配置：模块布局、各模块参数（JSONC 格式，支持注释） |
| `style.css` | Waybar 样式表，`@import` 引入 Catppuccin 主题色 |
| `catppuccin/` | Catppuccin 主题子模块（Git 仓库），使用 Whiskers 模板生成 |

## 技术约束

### GTK3 CSS 限制
Waybar 使用 GTK3 CSS 渲染，以下 CSS 属性**无效**，会被静默拒绝：
- `max-width`、`overflow`、`text-overflow`、`white-space`
- 单位仅支持 `px` 和 `pt`，不支持 `ch`（`em` 可用但语义仅限于字体）
- 窗口标题截断无法通过纯 CSS 实现，需依赖 `custom` 模块的 `max-length` 属性或 pill 容器的自然宽度约束

### Catppuccin 颜色变量
主题 CSS 通过 `@define-color` 定义了 26 个颜色变量（rosewater ~ crust），在 `style.css` 中使用 `@变量名` 引用，例如：
```css
color: @text;
background: alpha(@surface0, 0.88);
```

可用 GTK3 CSS 颜色函数：`alpha()`、`shade()`、`mix()`、`lighter()`、`darker()`。

### Niri 模块
本配置使用 Niri 专属模块：
- `niri/workspaces` — 工作区切换
- `niri/window` — 当前窗口标题
- 普通 Waybar 模块（network、pulseaudio、clock 等）通用

## 修改指南

### 调整主题色
`style.css` 顶部 `@import` 指向 `catppuccin/themes/mocha.css`，切换风味改为 `latte.css` / `frappe.css` / `macchiato.css`。

### 调整布局
`config.jsonc` 中 `modules-left` / `modules-center` / `modules-right` 数组控制模块位置。模块参数写在同一 JSON 对象的同名 key 下。

### 生成/更新主题文件
`catppuccin/` 目录内使用 [Whiskers](https://github.com/catppuccin/whiskers) 模板引擎：
- `just all` — 生成所有四种风味的 CSS
- `just clean` — 清除生成文件
- `waybar.tera` — Tera 模板文件

不要手动编辑 `catppuccin/themes/*.css`，它们由模板生成。

## 重启 Waybar

`systemctl --user restart waybar.service`

## 依赖

- **Waybar**（含 `niri/workspaces` 和 `niri/window` 模块支持）
- **Niri** Wayland 合成器
- **Font Awesome 6 Free**（图标字体）
- **pavucontrol**（音频模块点击）
- **nmtui**（网络模块点击）
- **noto-fonts-emoji** 或其他 emoji 字体（蓝牙图标）
