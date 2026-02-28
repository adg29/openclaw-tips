#!/bin/bash
# Context Usage Report — ASCII visualization of workspace file sizes
# Posts to #asyncvc-security

PER_FILE_CAP=20000
TOTAL_CAP=150000
BAR_WIDTH=30

FILES=(
  "/root/clawd/AGENTS.md"
  "/root/clawd/MEMORY.md"
  "/root/clawd/TOOLS.md"
  "/root/clawd/SOUL.md"
  "/root/clawd/IDENTITY.md"
  "/root/clawd/USER.md"
  "/root/clawd/HEARTBEAT.md"
)

total=0
declare -A sizes

for f in "${FILES[@]}"; do
  if [ -f "$f" ]; then
    sz=$(wc -c < "$f")
  else
    sz=0
  fi
  name=$(basename "$f")
  sizes["$name"]=$sz
  total=$((total + sz))
done

# Build the report
report="📊 *Context Usage Report* — $(date -u '+%Y-%m-%d %H:%M UTC')\n"
report+="\n"

# Per-file bars
report+="*Per-File Usage* (cap: $(printf "%'d" $PER_FILE_CAP) chars)\n"
report+="\`\`\`\n"

# Sort by size descending
for name in $(for k in "${!sizes[@]}"; do echo "$k ${sizes[$k]}"; done | sort -k2 -rn | awk '{print $1}'); do
  sz=${sizes[$name]}
  pct=$((sz * 100 / PER_FILE_CAP))
  filled=$((sz * BAR_WIDTH / PER_FILE_CAP))
  [ $filled -gt $BAR_WIDTH ] && filled=$BAR_WIDTH
  empty=$((BAR_WIDTH - filled))
  bar=$(printf '%0.s█' $(seq 1 $filled 2>/dev/null))
  [ $empty -gt 0 ] && bar+=$(printf '%0.s░' $(seq 1 $empty))
  [ $filled -eq 0 ] && bar=$(printf '%0.s░' $(seq 1 $BAR_WIDTH))
  
  # Warning marker
  marker=" "
  [ $pct -ge 80 ] && marker="⚠"
  [ $pct -ge 95 ] && marker="🔴"
  
  printf -v line "%-14s %s %5d / %5d  %3d%% %s" "$name" "$bar" "$sz" "$PER_FILE_CAP" "$pct" "$marker"
  report+="$line\n"
done
report+="\`\`\`\n"

# Total bar
total_pct=$((total * 100 / TOTAL_CAP))
total_filled=$((total * BAR_WIDTH / TOTAL_CAP))
[ $total_filled -gt $BAR_WIDTH ] && total_filled=$BAR_WIDTH
total_empty=$((BAR_WIDTH - total_filled))
total_bar=$(printf '%0.s█' $(seq 1 $total_filled 2>/dev/null))
[ $total_empty -gt 0 ] && total_bar+=$(printf '%0.s░' $(seq 1 $total_empty))
[ $total_filled -eq 0 ] && total_bar=$(printf '%0.s░' $(seq 1 $BAR_WIDTH))

total_marker=" "
[ $total_pct -ge 70 ] && total_marker="⚠"
[ $total_pct -ge 90 ] && total_marker="🔴"

report+="*Combined Usage* (cap: $(printf "%'d" $TOTAL_CAP) chars)\n"
report+="\`\`\`\n"
printf -v tline "TOTAL          %s %s / %s  %3d%% %s" "$total_bar" "$(printf "%'d" $total)" "$(printf "%'d" $TOTAL_CAP)" "$total_pct" "$total_marker"
report+="$tline\n"
report+="\`\`\`\n"

# Headroom summary
headroom=$((TOTAL_CAP - total))
report+="\n💡 *Headroom:* $(printf "%'d" $headroom) chars remaining (${total_pct}% used)"

if [ $total_pct -ge 80 ]; then
  report+="\n⚠️ *Action needed:* Consider trimming MEMORY.md or consolidating files."
fi

echo -e "$report"
