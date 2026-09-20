#!/bin/bash
# 读取内建屏幕亮度，输出 Waybar custom 模块 JSON
CURRENT=$(brightnessctl --class=backlight get 2>/dev/null || echo 0)
MAX=$(brightnessctl --class=backlight max 2>/dev/null || echo 1)
PCT=$(( CURRENT * 100 / MAX ))

# 根据亮度百分比选择图标（与原来 format-icons 顺序一致）
if   [ "$PCT" -ge 90 ]; then ICON=""
elif [ "$PCT" -ge 80 ]; then ICON=""
elif [ "$PCT" -ge 70 ]; then ICON=""
elif [ "$PCT" -ge 60 ]; then ICON=""
elif [ "$PCT" -ge 50 ]; then ICON=""
elif [ "$PCT" -ge 40 ]; then ICON=""
elif [ "$PCT" -ge 30 ]; then ICON=""
elif [ "$PCT" -ge 20 ]; then ICON=""
else ICON=""
fi

echo "{\"text\": \"${ICON} ${PCT}%\", \"tooltip\": \"亮度: ${PCT}%\", \"percentage\": ${PCT}}"
