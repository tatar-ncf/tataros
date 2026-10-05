#!/usr/bin/env bash
# unit.sh — TatarOS берәмлек тестлары / self-contained unit tests.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$HERE" || exit 1
export AYDA_LANG=tt AYDA_ALIF=cyrl AYDA_PLAIN=1
# shellcheck source=/dev/null
for m in render alif catalog i18n complete dictionary phrases teatime; do . "lib/$m.sh"; done

PASS=0; FAIL=0
eq() { if [ "$2" = "$3" ]; then PASS=$((PASS+1)); printf '  ✓ %s\n' "$1";
       else FAIL=$((FAIL+1)); printf '  ✗ %s köt=[%s] alд=[%s]\n' "$1" "$2" "$3"; fi; }

echo "── alif ──"
eq "kürsät→күрсәт" "күрсәт" "$(printf '%s' 'kürsät' | latin_to_cyrl)"
echo "── plural ──"
eq "төен→төеннәр" "төеннәр" "$(tn төен)"
echo "── resolve_verb (talos) ──"
eq "health→health"           "health"    "$(resolve_verb health)"
eq "сәламәтлек→health"        "health"    "$(resolve_verb сәламәтлек)"
eq "татарнетес-конфиг→kubeconfig" "kubeconfig" "$(resolve_verb татарнетес-конфиг)"
eq "kürsät→get"              "get"       "$(resolve_verb kürsät)"
eq "zzz→(empty)"            ""          "$(resolve_verb zzz)"
eq "хезмәтләр→service"        "service"   "$(resolve_verb хезмәтләр)"
eq "вакыйгалар→events"        "events"    "$(resolve_verb вакыйгалар)"
eq "wipe passthrough (1.14)"  "wipe"      "$(resolve_verb wipe)"
eq "disks removed in 1.9"     ""          "$(resolve_verb disks)"
eq "дисклар is no verb now"   ""          "$(resolve_verb дисклар)"
eq "shell never existed"      ""          "$(resolve_verb shell)"
eq "members is no verb"       ""          "$(resolve_verb members)"
echo "── resolve_noun (talos) ──"
eq "төен→members" "members" "$(resolve_noun төен)"
eq "аралар→links"  "links"  "$(resolve_noun аралар)"
eq "дисклар→disks" "disks"  "$(resolve_noun дисклар)"
eq "таныклык→apicertificates" "apicertificates" "$(resolve_noun таныклык)"
eq "көйләмә→machineconfig" "machineconfig" "$(resolve_noun көйләмә)"
eq "kubelet→kubelet" "kubelet" "$(resolve_noun kubelet)"
echo "── word lists & Arabic input ──"
badv=""; for w in $(dict_verbs); do [ -n "$(translate_verb "$w")" ] || badv="$badv $w"; done
eq "every dict_verbs word is a verb" "" "$badv"
badn=""; for w in $(dict_nouns); do [ "$(translate_noun "$w")" != "$w" ] || badn="$badn $w"; done
eq "every dict_nouns word is a noun" "" "$badn"
eq "arab сәламәтлек → health" "health" "$(resolve_verb "$(printf '%s' сәламәтлек | cyrl_to_arab)")"
eq "arab төеннәр → members"   "members" "$(resolve_noun "$(printf '%s' төеннәр | cyrl_to_arab)")"
echo "── completion (tos __complete) ──"
tc() { TOS_NO_TEA=1 bash bin/tos __complete "$@" | tr '\n' ' ' | sed 's/ $//'; }
eq "сәл<Tab>"               "сәламәтлек сәлам" "$(tc сәл)"
eq "күрсәт ди<Tab>"         "диск дисклар"     "$(tc күрсәт ди)"
eq "latin kürsät tö<Tab>"   "töen töennär"     "$(AYDA_ALIF=latin tc kürsät tö)"
eq "get -n 10.0.0.5 ад<Tab>" "адреслар"        "$(tc get -n 10.0.0.5 ад)"
eq "health <Tab> → nothing" ""                 "$(tc сәламәтлек "")"
bcomp() { ( complete() { :; }; . completion/tos.bash; COMP_WORDS=("$HERE/bin/tos" "$@"); COMP_CWORD=$#
            TOS_NO_TEA=1 _tos_complete; printf '%s ' "${COMPREPLY[@]}" | sed 's/ $//' ); }
eq "bash: tos яңад<Tab>"     "яңадан-кабыз"    "$(bcomp яңад)"
echo "── i18n ──"
eq "en tagline" "A national OS that provisions Tatarnetes" "$(AYDA_LANG=en t tos.version.tagline)"

echo; echo "result: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
