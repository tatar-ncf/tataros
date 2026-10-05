# shellcheck shell=bash
# tos.bash — Tab-тулыландыру (bash) / bash completion for `tos`.
# Урнаштыру / install:   source /path/to/tataros/completion/tos.bash
# Бөтен логика `tos __complete` эчендә / all logic lives in `tos __complete`.
_tos_complete() {
  local line
  COMPREPLY=()
  while IFS= read -r line; do
    [ -n "$line" ] && COMPREPLY+=("$line")
  done <<EOF_TOS
$("${COMP_WORDS[0]}" __complete "${COMP_WORDS[@]:1:COMP_CWORD}" 2>/dev/null)
EOF_TOS
}
complete -F _tos_complete tos
