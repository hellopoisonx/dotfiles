# niri 配置规则

## 修改配置后的验证与重载

每次修改 `config.kdl`（或其引用的 theme 等文件）之后，必须按顺序执行：

1. **验证配置**：`niri validate`
   - 默认读取 `$XDG_CONFIG_HOME/niri/config.kdl`（即本目录下的 `config.kdl`）
   - 若验证失败，根据错误信息修正后再继续

2. **重载配置**：`niri msg action load-config-file`
   - 向运行中的 niri 实例发送重载指令
   - 无需重启 compositor，配置即时生效

## niri wiki

所有的配置改动一定要有[官方wiki](https://github.com/niri-wm/niri/wiki)的支撑

## 配置语言

- 配置文件使用 KDL 格式：https://kdl.dev
- `/` 开头的行是注释，`/-` 注释掉紧随其后的节点

## 多文件结构

- `config.kdl` — 主配置文件
- `theme-*.kdl` — 主题文件，由主配置引用
