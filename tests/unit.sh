#!/usr/bin/env bash
# unit.sh — TatarOS берәмлек тестлары / self-contained unit tests.
set -uo pipefail
HERE="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
cd "$HERE" || exit 1
export AYDA_LANG=tt AYDA_ALIF=cyrl AYDA_PLAIN=1
# shellcheck source=/dev/null
for m in render alif catalog i18n faces complete dictionary phrases teatime; do . "lib/$m.sh"; done

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
eq "talos: get -n 10.0.0.5 ад<Tab>" "адреслар" "$(TOS_BACKEND=talos tc get -n 10.0.0.5 ад)"
eq "kuberoot: күрсәт сл<Tab>" "слот слотлар"  "$(tc күрсәт сл)"
eq "health <Tab> → nothing" ""                 "$(tc сәламәтлек "")"
bcomp() { ( complete() { :; }; . completion/tos.bash; COMP_WORDS=("$HERE/bin/tos" "$@"); COMP_CWORD=$#
            TOS_NO_TEA=1 _tos_complete; printf '%s ' "${COMPREPLY[@]}" | sed 's/ $//' ); }
eq "bash: tos яңад<Tab>"     "яңадан-кабыз"    "$(bcomp яңад)"
echo "── i18n ──"
eq "en tagline" "A national OS that provisions Tatarnetes" "$(AYDA_LANG=en t tos.version.tagline)"

echo "── faces (shared from tatarnetes) ──"
for mood in happy angry tea; do
  badw=""
  while IFS= read -r l; do w=$(tat_width "$l"); [ "$w" -eq "$TAT_FACE_W" ] || badw="$badw $w"; done <<EOF
$(tat_face_lines "$mood")
EOF
  eq "face $mood: all lines are $TAT_FACE_W cells wide" "" "$badw"
done
cap() { tat_face "$1" | sed -n 2p | sed 's/^.*  //'; }
eq "caption latin" "tübätäy" "$(AYDA_ALIF=latin cap happy)"
eq "caption arab"  "$(printf '%s' түбәтәй | cyrl_to_arab)" "$(AYDA_ALIF=arab cap tea)"
eq "caption en"    "skullcap" "$(AYDA_LANG=en cap angry)"
eq "tea tomorrow latin" "irtägä" "$(AYDA_ALIF=latin t tea.tomorrow)"

echo "── kuberoot backend: tables ──"
kr() ( . lib/kuberoot.sh; "$@" )
eq "сәламәтлек→health"      "health"       "$(kr resolve_verb сәламәтлек)"
eq "kire-kaytar→rollback"   "rollback"     "$(kr resolve_verb kire-kaytar)"
eq "дисклар→disks"          "disks"        "$(kr resolve_noun дисклар)"
eq "слотлар→bootentries"    "bootentries"  "$(kr resolve_noun слотлар)"
eq "төен→osconfigs"         "osconfigs"    "$(kr resolve_noun төен)"
eq "arab хезмәтләр→nodeservices" "nodeservices" "$(kr resolve_noun "$(printf '%s' хезмәтләр | cyrl_to_arab)")"
eq "Talos table kept"       "dmesg"        "$(kr talos_translate_verb системлог)"
eq "dmesg is Talos-only"    "yes"          "$(kr kr_talos_only dmesg && echo yes)"
eq "sistemlog is Talos-only" "yes"         "$(kr kr_talos_only sistemlog && echo yes)"
badv=""; for w in $(kr dict_verbs); do [ -n "$(kr translate_verb "$w")" ] || badv="$badv $w"; done
eq "kuberoot: every dict_verbs word is a verb" "" "$badv"
badn=""; for w in $(kr dict_nouns); do [ "$(kr translate_noun "$w")" != "$w" ] || badn="$badn $w"; done
eq "kuberoot: every dict_nouns word is a noun" "" "$badn"

echo "── kuberoot backend: kubectl calls (fake kubectl) ──"
FK="$(mktemp -d)"; trap 'rm -rf "$FK"' EXIT
cat > "$FK/kubectl" <<'FAKE'
#!/usr/bin/env bash
echo "$*" >> "$FAKE_LOG"
case "$*" in
  *"get osconfigs -o jsonpath"*) printf '%b' "${FAKE_OSCONFIGS:-}" ;;
  *"get bootentries"*"jsonpath"*) printf '%b' "${FAKE_SLOTS:-}" ;;
  *"create -f -"*) cat >> "$FAKE_LOG" ;;
esac
FAKE
chmod +x "$FK/kubectl"
export FAKE_LOG="$FK/log"
# ktos ARGS… — run tos on the fake kubectl; prints the kubectl calls, one per line.
ktos() { : > "$FAKE_LOG"; TOS_KUBECTL="$FK/kubectl" TOS_NO_TEA=1 TOS_PLAIN=1 bash bin/tos "$@" >/dev/null 2>&1
         sed 's/[0-9]\{4\}-[0-9-]*T[0-9:]*Z/NOW/; s/tos-[0-9]\{14\}/tos-TS/' "$FAKE_LOG"; }
eq "health -n" "get osconfigs,nodeservices,bootentries -l kuberoot.dev/node=t1" "$(ktos сәламәтлек -n t1)"
eq "logs -n"   "get --raw /apis/node.kuberoot.dev/v1alpha1/nodeservices/t1.kubelet/log" \
   "$(FAKE_OSCONFIGS='t1 t1\n' ktos көндәлек kubelet -n t1)"
eq "get with name -n" "get disks t1.sda" "$(ktos күрсәт диск sda -n t1)"
eq "kubeconfig" "get kubeconfigs admin -o jsonpath={.kubeconfig}" "$(ktos татарнетес-конфиг)"
eq "reboot via one node's API" "patch osconfigs n1 --type merge -p {\"spec\":{\"rebootRequestedAt\":\"NOW\"}}" \
   "$(FAKE_OSCONFIGS='n1 \n' ktos яңадан-кабыз | tail -1)"
eq "reboot, many nodes, no -n" "1" "$(FAKE_OSCONFIGS='a a\nb b\n' ktos reboot | wc -l | tr -d ' ')"
eq "restart a service, flags kept" "--context c patch nodeservices t1.kubelet --type merge -p {\"spec\":{\"restartedAt\":\"NOW\"}}" \
   "$(ktos хезмәтләр kubelet restart -n t1 --context c)"
eq "upgrade through the cluster names <node>.<name>" "  name: n1.tos-TS" \
   "$(FAKE_OSCONFIGS='n1 n1\n' ktos яңарт --url https://r/x.tar | grep '  name:')"
eq "upgrade --no-reboot" "  reboot: false" "$(ktos upgrade --url u --no-reboot -n n1 | grep reboot:)"
eq "upgrade without --url calls nothing" "" "$(ktos яңарт -n n1)"
eq "rollback prefers the other slot of that node" "patch bootentries t1.slot-b --type merge -p {\"spec\":{\"preferred\":true}}" \
   "$(FAKE_SLOTS='t1.slot-a true\nt1.slot-b false\nt2.slot-a false\n' ktos кире-кайтар -n t1 | sed -n 2p)"
eq "Talos-only verb exits 64" "64" "$(TOS_KUBECTL="$FK/kubectl" TOS_NO_TEA=1 TOS_PLAIN=1 bash bin/tos системлог >/dev/null 2>&1; echo $?)"
eq "unknown backend exits 64" "64" "$(TOS_BACKEND=zz TOS_NO_TEA=1 bash bin/tos версия >/dev/null 2>&1; echo $?)"

echo; echo "result: PASS=$PASS FAIL=$FAIL"
[ "$FAIL" -eq 0 ]
