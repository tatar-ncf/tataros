#!/usr/bin/env bash
# render-banner.sh — TatarOS төененең консоль сәламе / the console banner of a
# TatarOS node: a carpet, the skullcap face, the greeting in Tatar and English
# and the first line of Tukay's «Туган тел» (data/VERIFICATION.tt.md).
# No colours: the banner goes to whatever console the node has.
# Usage: scripts/render-banner.sh > banner.txt   (AYDA_ALIF=cyrl|latin|arab)
set -euo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export AYDA_FORCE_FUN=1 NO_COLOR=1 AYDA_LANG=tt
unset AYDA_PLAIN AYDA_QUIET
for m in render alif catalog i18n faces; do
  # shellcheck source=/dev/null
  . "$HERE/lib/$m.sh"
done
tukay="$(sed -n '/^И туган тел, и матур тел/{p;q;}' "$HERE/data/poetry.tt")"
[ -n "$tukay" ] || { echo "data/poetry.tt: Tukay's line is missing" >&2; exit 1; }
{
  tat_carpet
  tat_face_happy
  printf '  TatarOS Linux — kuberoot\n'
  printf '  %s\n' "$(t tos.greet.hello)"
  printf '  %s\n' "$(AYDA_LANG=en t tos.greet.hello)"
  printf '  «%s» — %s\n' "$(printf '%s' "$tukay" | alif_render)" "$(printf '%s' 'Г. Тукай' | alif_render)"
  printf '  %s\n' "$(t tos.greet.sub)"
  tat_carpet
} 2>&1
