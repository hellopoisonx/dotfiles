#!/bin/bash
# Waybar custom module: mako notification center status
# Outputs JSON with text (icon + count), tooltip, class, alt.

set -e

# Notification count via makoctl list JSON
COUNT=$(makoctl list -j 2>/dev/null | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    print(len(data))
except:
    print(0)
")

# Do-not-disturb mode detection
DND=0
if makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; then
    DND=1
fi

# Build tooltip from pending notifications
if [ "$COUNT" -gt 0 ]; then
    TOOLTIP=$(makoctl list -j 2>/dev/null | python3 -c "
import sys, json
try:
    notifications = json.load(sys.stdin)
    lines = []
    for n in notifications:
        app = n.get('app_name', 'Unknown')
        summary = n.get('summary', '')
        body = n.get('body', '')
        actions = n.get('actions', {})
        id_ = n.get('id', 0)
        lines.append(f'<b>{app}</b>  <i>#{id_}</i>')
        lines.append(f'  {summary}')
        if body:
            truncated = (body[:117] + '…') if len(body) > 120 else body
            lines.append(f'  {truncated}')
        if actions:
            action_str = ', '.join(actions.keys())
            lines.append(f'  <small>actions: {action_str}</small>')
        lines.append('')
    print('\n'.join(lines).strip())
except Exception as e:
    print(f'Error parsing notifications: {e}')
")
else
    TOOLTIP="No notifications"
fi

if [ "$DND" -eq 1 ]; then
    TOOLTIP="Do Not Disturb — notifications hidden\n\n${TOOLTIP}"
fi

# Determine class and display text
if [ "$DND" -eq 1 ]; then
    CLASS="dnd"
    TEXT=""
    ALT="dnd"
elif [ "$COUNT" -gt 0 ]; then
    CLASS="has-notifications"
    TEXT="  ${COUNT}"
    ALT="${COUNT}"
else
    CLASS="none"
    TEXT=""
    ALT="0"
fi

# Escape for JSON
escape_json() {
    python3 -c "import sys,json; print(json.dumps(sys.stdin.read()[:-1]))" <<< "$1"
}

TEXT_JSON=$(escape_json "$TEXT")
TOOLTIP_JSON=$(escape_json "$TOOLTIP")

printf '{"text":%s,"tooltip":%s,"class":"%s","alt":"%s"}\n' \
    "$TEXT_JSON" "$TOOLTIP_JSON" "$CLASS" "$ALT"
