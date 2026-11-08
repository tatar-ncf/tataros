# shellcheck shell=bash
# kuberoot.sh — TatarOS'ның kuberoot нигезе: tos фигыльләре kuberoot төененең
# API'сына (node.kuberoot.dev) kubectl аша бара. Talos нигезе дә кала
# (TOS_BACKEND=talos), бу файл аны алыштырмый.
#
# The kuberoot backend of tos: Tatar verbs act on the kuberoot node API
# (node.kuberoot.dev) through kubectl. Sourced after dictionary.sh when
# TOS_BACKEND=kuberoot: the Talos tables stay as talos_translate_verb /
# talos_translate_noun, and the kuberoot ones take their names, so
# resolve_verb, resolve_noun and tos_complete (Latin and Arabic input
# included) work unchanged. Bash 3.2.
#
# Two ways to reach a node, both plain kubectl:
#   * a node kubeconfig (node-admin certificate, https://<node>:50000): the
#     node API of that node alone, objects under their own names;
#   * the cluster kubeconfig: the fleet view of every node, objects named
#     "<node>.<name>" (OSConfig keeps the node's name) and labelled
#     kuberoot.dev/node=<node>. `-n <node>` picks one, as with talosctl.

KR_NODE_LABEL="kuberoot.dev/node"
KR_API="/apis/node.kuberoot.dev/v1alpha1"
KR_KUBECTL="${TOS_KUBECTL:-kubectl}"

# Talos'ныкылар исеме белән саклана / keep the Talos tables under talos_*.
eval "talos_$(declare -f translate_verb)"
eval "talos_$(declare -f translate_noun)"

# --- Фигыльләр / verbs → tos actions on the node API --------------------
translate_verb() {
  case "$1" in
    сәламәтлек|сихәт)                              echo health ;;
    татарнетес-конфиг|тнетес-конфиг|кластер-керү) echo kubeconfig ;;
    күрсәт|кара|ал)                                echo get ;;
    сөйлә)                                         echo describe ;;
    көндәлек|язма)                                 echo logs ;;
    хезмәтләр|хезмәт)                              echo services ;;
    яңадан-кабыз|кабыз|перезагрузка)              echo reboot ;;
    яңарт|яңарту)                                  echo upgrade ;;
    кире-кайтар)                                   echo rollback ;;
    версия)                                        echo version ;;
    health|kubeconfig|get|describe|logs|services|reboot|upgrade|rollback|version)
                                                   echo "$1" ;;
    service)                                       echo services ;;
    *)                                             echo "" ;;
  esac
}

# --- Асыллар / node API resources ---------------------------------------
translate_noun() {
  case "$1" in
    төен|төеннәр|көйләмә|конфиг) echo osconfigs ;;    # the node's own OS: one per node
    хезмәт|хезмәтләр)          echo nodeservices ;;
    диск|дисклар)              echo disks ;;
    слот|слотлар)              echo bootentries ;;   # A/B root slots
    яңарту|яңартулар)          echo upgrades ;;
    әгъзалык|әгъзалар)         echo memberships ;;
    резерв|резервлар)          echo statebackups ;;
    күләм|күләмнәр)            echo volumes ;;
    машина|машиналар)          echo machines ;;
    модель|модельләр)          echo modelservers ;;
    *)                         echo "$1" ;;
  esac
}

dict_verbs() {
  printf '%s\n' сәламәтлек татарнетес-конфиг күрсәт кара сөйлә көндәлек хезмәтләр \
    яңадан-кабыз яңарт кире-кайтар версия
}
dict_nouns() {
  printf '%s\n' төен төеннәр көйләмә хезмәт хезмәтләр диск дисклар слот слотлар \
    яңарту яңартулар әгъзалык әгъзалар резерв резервлар күләм күләмнәр машина \
    машиналар модель модельләр
}

# kr_talos_only WORD — Talos фигыле, ләкин kuberoot'та юк / a Talos-only verb?
kr_talos_only() {
  [ -n "$(talos_translate_verb "$1")" ] && return 0
  [ -n "$(talos_translate_verb "$(printf '%s' "$1" | latin_to_cyrl)")" ]
}

# --- kubectl чакыру / running kubectl -----------------------------------
# KR_FLAGS: kubectl flags the user gave (--context, --kubeconfig, -o …).
# KR_NODE: the node -n named; KR_MODE: cluster (fleet view) or direct.
KR_FLAGS=()
KR_NODE=""
KR_MODE=""

kr_kubectl() {
  tat_dim "🐧 → $KR_KUBECTL ${KR_FLAGS[*]:-} $*"
  "$KR_KUBECTL" ${KR_FLAGS[@]+"${KR_FLAGS[@]}"} "$@"
}
# Quiet lookups: no echo line, stderr kept for kubectl's own errors.
kr_query() { "$KR_KUBECTL" ${KR_FLAGS[@]+"${KR_FLAGS[@]}"} "$@"; }

kr_fail() { printf '%b\n' "  ${TAT_RED}$*${TAT_RESET}" >&2; }
kr_ok()   { printf '%b\n' "  ${TAT_GREEN}$*${TAT_RESET}" >&2; }

# kr_target — which node, and whether names carry its prefix. With -n the
# fleet view is meant. Without it, the one OSConfig there is decides: with
# the node label it came through the cluster, without it from the node.
kr_target() {
  if [ -n "$KR_NODE" ]; then KR_MODE=cluster; return 0; fi
  local out name label count=0
  out="$(kr_query get osconfigs -o "jsonpath={range .items[*]}{.metadata.name}{\" \"}{.metadata.labels.kuberoot\\.dev/node}{\"\\n\"}{end}")" || return 1
  while read -r name label; do
    [ -z "$name" ] && continue
    count=$((count + 1)); KR_NODE="$name"
    if [ -n "$label" ]; then KR_MODE=cluster; else KR_MODE=direct; fi
  done <<EOF
$out
EOF
  if [ "$count" -ne 1 ]; then KR_NODE=""; kr_fail "$(t tos.kr.need_node)"; return 2; fi
  return 0
}

# kr_name LOCAL — the object's name as the API in use spells it.
kr_name() {
  if [ "$KR_MODE" = cluster ]; then printf '%s.%s' "$KR_NODE" "$1"; else printf '%s' "$1"; fi
}

# kr_sel — a label selector for -n, as words for kubectl.
kr_sel() { [ -n "$KR_NODE" ] && printf '%s\n' -l "$KR_NODE_LABEL=$KR_NODE"; return 0; }

kr_now() { date -u +%Y-%m-%dT%H:%M:%SZ; }

# --- Гамәлләр / actions -------------------------------------------------
# kr_main ACTION ARGS… — parses talosctl-style -n and the upgrade flags,
# passes every other flag to kubectl, and acts.
kr_main() {
  local action="$1"; shift
  local -a pos=() sel=()
  local url="" sha="" reboot=1 tok
  KR_FLAGS=(); KR_NODE=""; KR_MODE=""
  while [ "$#" -gt 0 ]; do
    tok="$1"
    case "$tok" in
      -n|--nodes|--node) KR_NODE="${2:-}"; shift 2 || shift ;;
      --nodes=*|--node=*) KR_NODE="${tok#*=}"; shift ;;
      --url) url="${2:-}"; shift 2 || shift ;;
      --url=*) url="${tok#*=}"; shift ;;
      --sha256) sha="${2:-}"; shift 2 || shift ;;
      --sha256=*) sha="${tok#*=}"; shift ;;
      --no-reboot|--кабызмыйча) reboot=0; shift ;;
      --) shift; while [ "$#" -gt 0 ]; do pos+=("$1"); shift; done ;;
      --context|--kubeconfig|--cluster|--user|--server|-s|--request-timeout|-o|--output|-l|--selector)
          KR_FLAGS+=("$tok" "${2:-}"); shift 2 || shift ;;
      -*) KR_FLAGS+=("$tok"); shift ;;
      *)  pos+=("$tok"); shift ;;
    esac
  done
  if ! command -v "$KR_KUBECTL" >/dev/null 2>&1; then
    tat_dim "🐧 → $KR_KUBECTL ($action)"
    kr_fail "$(t kubectl.notfound "$KR_KUBECTL")"
    printf '%s\n' "  $(t kubectl.notfound.hint)" >&2
    return 127
  fi
  while IFS= read -r tok; do [ -n "$tok" ] && sel+=("$tok"); done <<EOF
$(kr_sel)
EOF

  case "$action" in
    health)
      kr_kubectl get osconfigs,nodeservices,bootentries ${sel[@]+"${sel[@]}"} ;;
    kubeconfig)
      kr_kubectl get kubeconfigs "${pos[0]:-admin}" -o 'jsonpath={.kubeconfig}' ;;
    get|describe)
      local res="osconfigs" i
      [ "${#pos[@]}" -gt 0 ] && res="$(resolve_noun "${pos[0]}")"
      local -a names=()
      i=1
      while [ "$i" -lt "${#pos[@]}" ]; do
        if [ -n "$KR_NODE" ] && [ "$res" != osconfigs ]; then names+=("$KR_NODE.${pos[$i]}"); else names+=("${pos[$i]}"); fi
        i=$((i + 1))
      done
      if [ "${#names[@]}" -gt 0 ]; then
        kr_kubectl "$action" "$res" "${names[@]}"
      else
        kr_kubectl "$action" "$res" ${sel[@]+"${sel[@]}"}
      fi ;;
    logs)
      [ "${#pos[@]}" -gt 0 ] || { kr_fail "$(t tos.kr.need_service)"; return 64; }
      kr_target || return $?
      kr_kubectl get --raw "$KR_API/nodeservices/$(kr_name "${pos[0]}")/log" ;;
    services)
      if [ "${#pos[@]}" -eq 0 ]; then
        kr_kubectl get nodeservices ${sel[@]+"${sel[@]}"}; return $?
      fi
      kr_target || return $?
      case "${pos[1]:-}" in
        restart|яңадан-башлат|яңадан-кабыз)
          kr_kubectl patch nodeservices "$(kr_name "${pos[0]}")" --type merge \
            -p "{\"spec\":{\"restartedAt\":\"$(kr_now)\"}}" >/dev/null || return $?
          kr_ok "$(t tos.kr.restart "${pos[0]}")" ;;
        *) kr_kubectl get nodeservices "$(kr_name "${pos[0]}")" ;;
      esac ;;
    reboot)
      kr_target || return $?
      kr_reboot ;;
    upgrade)
      [ -n "$url" ] || { kr_fail "$(t tos.kr.need_url)"; return 64; }
      kr_target || return $?
      local name rb=false
      name="$(kr_name "tos-$(date -u +%Y%m%d%H%M%S)")"
      [ "$reboot" -eq 1 ] && rb=true
      kr_kubectl create -f - <<YAML || return $?
apiVersion: node.kuberoot.dev/v1alpha1
kind: Upgrade
metadata:
  name: $name
spec:
  url: "$url"
  sha256: "$sha"
  reboot: $rb
YAML
      kr_ok "$(t tos.kr.upgrade "$KR_NODE")" ;;
    rollback)
      kr_target || return $?
      local entries slot="" n booted
      entries="$(kr_query get bootentries ${sel[@]+"${sel[@]}"} -o 'jsonpath={range .items[*]}{.metadata.name}{" "}{.status.booted}{"\n"}{end}')" || return $?
      while read -r n booted; do
        [ -z "$n" ] && continue
        [ "$KR_MODE" = cluster ] && case "$n" in "$KR_NODE".*) ;; *) continue ;; esac
        [ "$booted" = true ] || slot="$n"
      done <<EOF
$entries
EOF
      [ -n "$slot" ] || { kr_fail "$(t tos.kr.no_spare_slot "$KR_NODE")"; return 1; }
      kr_kubectl patch bootentries "$slot" --type merge -p '{"spec":{"preferred":true}}' >/dev/null || return $?
      kr_ok "$(t tos.kr.rollback "$KR_NODE" "${slot##*slot-}")"
      kr_reboot ;;
    version)
      kr_query version --client 2>/dev/null | sed 's/^/    /' >&2
      kr_kubectl get osconfigs ${sel[@]+"${sel[@]}"} \
        -o 'custom-columns=NODE:.metadata.name,DISTRO:.status.distro,VERSION:.status.version,KERNEL:.status.kernelVersion' ;;
    *)
      kr_fail "$(t err.unknown_verb "$action")"; return 64 ;;
  esac
}

kr_reboot() {
  kr_kubectl patch osconfigs "$KR_NODE" --type merge \
    -p "{\"spec\":{\"rebootRequestedAt\":\"$(kr_now)\"}}" >/dev/null || return $?
  kr_ok "$(t tos.kr.reboot "$KR_NODE")"
}

show_dictionary() {
  cat <<'TBL'

  TATAROS СҮЗЛЕГЕ / TATAROS DICTIONARY  (kuberoot node API, kubectl)
  ═══════════════════════════════════════════════════════════════

  ФИГЫЛЬЛӘР / VERBS               татарча              → node.kuberoot.dev
  ---------------------------------------------------------------
    сәламәтлек                    health               → get osconfigs,nodeservices,bootentries
    татарнетес-конфиг             cluster access       → get kubeconfigs admin
    күрсәт / кара                 get resource         → get <асыл>
    сөйлә                         describe             → describe <асыл>
    көндәлек <хезмәт>             service log          → nodeservices/<хезмәт>/log
    хезмәтләр [<хезмәт> restart]  services             → nodeservices (spec.restartedAt)
    яңадан-кабыз                  reboot               → osconfigs spec.rebootRequestedAt
    яңарт --url <URL>             upgrade OS (A/B)     → create upgrade
    кире-кайтар                   roll back a slot     → bootentries spec.preferred + reboot
    версия                        version              → osconfigs status.version

  АСЫЛЛАР / RESOURCES             татарча              → node.kuberoot.dev
  ---------------------------------------------------------------
    төен / көйләмә                the node's OS        → osconfigs
    хезмәт                        service              → nodeservices
    диск(лар)                     disks                → disks
    слот(лар)                     A/B boot slots       → bootentries
    яңарту(лар)                   upgrades             → upgrades
    әгъзалык                      cluster membership   → memberships
    резерв(лар)                   state backups        → statebackups
    күләм / машина / модель       volumes / VMs / LLMs → volumes / machines / modelservers

  -n <төен> — кластер аша бер төен / one node through the cluster API.
  TOS_BACKEND=talos — элекке Talos нигезе / the Talos backend.

  Мисал / example:
    tos сәламәтлек -n tatar-1            → kubectl get osconfigs,… -l kuberoot.dev/node=tatar-1
    tos көндәлек kubelet -n tatar-1      → kubectl get --raw …/nodeservices/tatar-1.kubelet/log
    tos яңарт --url https://…/tataros.tar --sha256 … -n tatar-1

TBL
}
