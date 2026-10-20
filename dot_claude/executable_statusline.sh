#!/usr/bin/env bash
# Powerline-style status line mirroring pi-powerline-footer's "default" preset:
# model, thinking, path, git, context %, cache read, cost (+ subscription usage like pi-usage).
in=$(cat)
j() { jq -r "$1 // empty" <<<"$in" 2>/dev/null; }

model=$(j '.model.display_name')
think=$(j '.effort.level // .thinking.level')
dir=$(j '.workspace.current_dir // .cwd')
ctx=$(j '.context_window.used_percentage')
cache=$(j '.context_window.current_usage.cache_read_input_tokens')
cost=$(j '.cost.total_cost_usd')
u5=$(j '.rate_limits.five_hour.used_percentage')
u7=$(j '.rate_limits.seven_day.used_percentage')

R=$'\e[0m'; D=$'\e[2m'; C=$'\e[36m'; G=$'\e[32m'; Y=$'\e[33m'; RD=$'\e[31m'; M=$'\e[35m'; B=$'\e[34m'
sep=" ${D}│${R} "
parts=()

[ -n "$model" ] && parts+=("${C}${model}${R}")
[ -n "$think" ] && parts+=("${M}think:${think}${R}")
[ -n "$dir" ] && parts+=("${B}$(basename "$dir")${R}")

if [ -n "$dir" ] && br=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null); then
  st=$(git -C "$dir" status --porcelain 2>/dev/null)
  s=$(grep -c '^[MADRC]' <<<"$st"); u=$(grep -c '^.[MD]' <<<"$st"); n=$(grep -c '^??' <<<"$st")
  g="${G}${br}${R}"
  [ "$s" -gt 0 ] && g+=" ${G}+${s}${R}"
  [ "$u" -gt 0 ] && g+=" ${Y}*${u}${R}"
  [ "$n" -gt 0 ] && g+=" ${D}?${n}${R}"
  parts+=("$g")
fi

pctcolor() { local p=${1%.*}; if [ "$p" -ge 90 ]; then echo "$RD"; elif [ "$p" -ge 70 ]; then echo "$Y"; else echo "$G"; fi; }
fmt() { awk -v n="$1" 'BEGIN{ if(n>=1e6) printf "%.1fM",n/1e6; else if(n>=1e3) printf "%.1fk",n/1e3; else printf "%d",n }'; }

[ -n "$ctx" ] && parts+=("ctx $(pctcolor "$ctx")${ctx%.*}%${R}")
[ -n "$cache" ] && [ "$cache" != 0 ] && parts+=("${D}cache $(fmt "$cache")${R}")
[ -n "$cost" ] && parts+=("${Y}\$$(printf '%.2f' "$cost")${R}")
[ -n "$u5" ] && parts+=("5h $(pctcolor "$u5")${u5%.*}%${R}")
[ -n "$u7" ] && parts+=("7d $(pctcolor "$u7")${u7%.*}%${R}")

out=""; for p in "${parts[@]}"; do out+="${out:+$sep}$p"; done
printf '%s' "$out"
