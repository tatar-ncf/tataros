# shellcheck shell=bash
# teawindows.sh — чәй тәнәфесләре kuberoot флотының хезмәт күрсәтү тәрәзәләре
# булып китә: FleetRollout яңа релизны төеннәргә чәй вакытында гына бирә.
#
# Tea breaks as real maintenance windows: the deterministic tea schedule
# (teatime.sh, the same formula as ayda and tatarnetes-ui) rendered into a
# kuberoot FleetRollout's spec.maintenanceWindows for the days ahead, so a
# fleet takes new releases only while its people drink tea. The schedule is
# kept in Kazan time (Europe/Moscow) by default, whoever runs the generator.
# Requires: teatime.sh, i18n.sh. Bash 3.2; GNU or BSD date.

TEAWIN_TZ_DEFAULT="Europe/Moscow"

# _tw_gnu — GNU date (Linux) or BSD date (macOS).
_tw_gnu() { date --version >/dev/null 2>&1; }

# _tw_epoch TZ "YYYY-MM-DD HH:MM:SS" — the wall time in TZ as seconds since
# the epoch. Seconds are spelled out: BSD date keeps the current ones otherwise.
_tw_epoch() {
  if _tw_gnu; then TZ="$1" date -d "$2" +%s
  else TZ="$1" date -j -f "%Y-%m-%d %H:%M:%S" "$2" +%s; fi
}
# _tw_fmt TZ EPOCH FORMAT
_tw_fmt() {
  if _tw_gnu; then TZ="$1" date -d "@$2" +"$3"
  else TZ="$1" date -r "$2" +"$3"; fi
}

# teawin_list DAYS TZ [YYYY-MM-DD] — one "START_RFC3339 MINUTES" line per tea
# break of the first day (today in TZ by default) and the DAYS-1 days after
# it, oldest first.
# Each day's windows come from tea_windows YYYYMMDD, in that day's wall time
# in TZ, so a change of daylight saving time moves nothing.
teawin_list() {
  local days="$1" tz="$2" first="${3:-}" noon k day d s len e
  [ -n "$first" ] || first="$(TZ="$tz" date +%Y-%m-%d)"
  # Noon of the first day in TZ: whole days from it never cross into another date.
  noon="$(_tw_epoch "$tz" "$first 12:00:00")" || return 1
  k=0
  while [ "$k" -lt "$days" ]; do
    day="$(_tw_fmt "$tz" $((noon + k * 86400)) %Y%m%d)"
    d="${day%????}-${day#????}"; d="${d%??}-${d#???????}"
    while read -r s len; do
      [ -z "$s" ] && continue
      e="$(_tw_epoch "$tz" "$(printf '%s %02d:%02d:00' "$d" $((s / 60)) $((s % 60)))")" || return 1
      printf '%s %s\n' "$(_tw_fmt UTC "$e" %Y-%m-%dT%H:%M:%SZ)" "$len"
    done <<EOF
$(tea_windows "$day")
EOF
    k=$((k + 1))
  done | sort
}

# teawin_render DAYS TZ FORMAT — the windows as a merge patch of a
# FleetRollout: FORMAT json (one line, for kubectl patch) or yaml.
teawin_render() {
  local fmt="$3" start len sep=""
  case "$fmt" in
    json) printf '{"spec":{"maintenanceWindows":[' ;;
    *)    printf 'spec:\n  maintenanceWindows:\n' ;;
  esac
  while read -r start len; do
    [ -z "$start" ] && continue
    case "$fmt" in
      json) printf '%s{"start":"%s","duration":"%sm"}' "$sep" "$start" "$len"; sep="," ;;
      *)    printf '  - {start: "%s", duration: %sm}\n' "$start" "$len" ;;
    esac
  done <<EOF
$(teawin_list "$1" "$2")
EOF
  [ "$fmt" = json ] && printf ']}}\n'
  return 0
}

# tos чәй-тәрәзәләре [--days N] [--tz ZONE] [-o yaml|json] [--rollout NAME] [kubectl flags]
# Prints the patch, or with --rollout applies it to that FleetRollout.
teawin_main() {
  local days=7 tz="${TOS_TEA_TZ:-$TEAWIN_TZ_DEFAULT}" fmt=yaml rollout=""
  local -a kflags=()
  while [ "$#" -gt 0 ]; do
    case "$1" in
      --days|--көннәр) days="${2:-}"; shift 2 || shift ;;
      --days=*|--көннәр=*) days="${1#*=}"; shift ;;
      --tz) tz="${2:-}"; shift 2 || shift ;;
      --tz=*) tz="${1#*=}"; shift ;;
      -o|--output) fmt="${2:-}"; shift 2 || shift ;;
      -o=*|--output=*) fmt="${1#*=}"; shift ;;
      --rollout) rollout="${2:-}"; shift 2 || shift ;;
      --rollout=*) rollout="${1#*=}"; shift ;;
      --context|--kubeconfig) kflags+=("$1" "${2:-}"); shift 2 || shift ;;
      *) kflags+=("$1"); shift ;;
    esac
  done
  case "$days" in ''|*[!0-9]*) days=x ;; esac
  if [ "$days" = x ] || [ "$days" -lt 1 ] || [ "$days" -gt 60 ]; then
    printf '%s\n' "  $(t tos.teawin.bad_days "$days")" >&2; return 64
  fi
  if [ ! -f "/usr/share/zoneinfo/$tz" ] && [ "$tz" != UTC ]; then
    printf '%s\n' "  $(t tos.teawin.bad_tz "$tz")" >&2; return 64
  fi
  if [ -z "$rollout" ]; then
    teawin_render "$days" "$tz" "$fmt"; return $?
  fi
  local patch n kubectl="${TOS_KUBECTL:-kubectl}"
  patch="$(teawin_render "$days" "$tz" json)" || return 1
  n="$(printf '%s' "$patch" | grep -o '"start"' | grep -c .)"
  tat_dim "🐧 → $kubectl ${kflags[*]:-} patch fleetrollouts $rollout --type merge -p …"
  "$kubectl" ${kflags[@]+"${kflags[@]}"} patch fleetrollouts "$rollout" --type merge -p "$patch" >/dev/null || return $?
  printf '%b\n' "  ${TAT_GREEN}$(t tos.teawin.applied "$rollout" "$n" "$days")${TAT_RESET}" >&2
}
