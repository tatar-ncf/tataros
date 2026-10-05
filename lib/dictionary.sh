# shellcheck shell=bash
# dictionary.sh — TatarOS: татарча әмерләрне talosctl теленә тәрҗемә итү.
# Translate Tatar verbs into talosctl. Bash 3.2 (case-based, no assoc arrays).

# --- Фигыльләр / verbs --------------------------------------------------
translate_verb() {
  case "$1" in
    кулла-көйләмә|көйләмә-кулла|конфиг-кулла)         echo apply-config ;;
    башлат|этакы|этед-башлат)                          echo bootstrap ;;
    татарнетес-конфиг|тнетес-конфиг|кластер-керү)     echo kubeconfig ;;
    панель|күзәтү)                                     echo dashboard ;;
    күрсәт|кара|ал)                                    echo get ;;
    көндәлек|язма)                                     echo logs ;;
    системлог|дмесг)                                   echo dmesg ;;
    хезмәтләр|хезмәт)                                  echo service ;;
    савытлар|савыт)                                    echo containers ;;
    сәламәтлек|сихәт)                                  echo health ;;
    яңадан-кабыз|кабыз|перезагрузка)                  echo reboot ;;
    сүндер|тукта)                                      echo shutdown ;;
    чистарт|коеп-таза)                                 echo reset ;;
    яңарт|яңарту)                                      echo upgrade ;;
    kubernetes-яңарт|тнетес-яңарт)                     echo upgrade-k8s ;;
    вакыт)                                             echo time ;;
    версия)                                            echo version ;;
    процесслар|процесс)                                echo processes ;;
    хәтер|память)                                      echo memory ;;
    статистика|стат)                                   echo stats ;;
    вакыйгалар|вакыйга)                                echo events ;;
    күчер|копия)                                       echo copy ;;
    # --- инглизчә talosctl фигыльләре (passthrough), talosctl v1.14 буенча ---
    # talosctl v1.14 top-level commands + aliases (checked against the real binary).
    # `disks` 1.9'да алынды (→ get disks); `members`, `shell` беркайчан да булмаган.
    apply-config|bootstrap|kubeconfig|dashboard|get|g|logs|dmesg|service|services|\
    containers|c|health|reboot|shutdown|reset|upgrade|upgrade-k8s|time|\
    version|processes|ps|memory|free|stats|copy|cp|config|gen|cluster|\
    etcd|list|ls|read|mounts|netstat|restart|rollback|support|usage|validate|\
    cgroups|conformance|debug|edit|events|image|inject|inspect|machineconfig|\
    meta|patch|pcap|rotate-ca|wipe|completion)
                                                       echo "$1" ;;
    *)                                                 echo "" ;;
  esac
}

# --- Асыллар / talos resources (COSI) -----------------------------------
translate_noun() {
  case "$1" in
    төен|төеннәр)              echo members ;;   # talosctl'да COSI 'nodes' юк → cluster.Member
    хезмәт|хезмәтләр)          echo services ;;
    диск|дисклар)             echo disks ;;
    аралар|интерфейслар)      echo links ;;         # network links
    адреслар|ип)              echo addresses ;;     # node addresses
    маршрутлар|юллар)         echo routes ;;
    көйләмә|конфиг)           echo machineconfig ;;
    сертификат|таныклык)      echo apicertificates ;; # COSI'да 'certificates' юк → ApiCertificates
    әгъзалар|үлән)            echo members ;;
    *)                        echo "$1" ;;
  esac
}

# Гарәп язуы (Яңа имля) белән кертелгән сүз dict_verbs/dict_nouns аша таныла.
# Arabic-script input is recognised through the dict_verbs / dict_nouns lists.
resolve_verb() {
  local v="$1" r
  r="$(translate_verb "$v")"; [ -n "$r" ] && { printf '%s' "$r"; return 0; }
  if alif_has_arab "$v"; then
    # shellcheck disable=SC2046  # word lists are single words by construction
    r="$(alif_arab_pick "$v" $(dict_verbs))" && translate_verb "$r"
    return 0
  fi
  translate_verb "$(printf '%s' "$v" | latin_to_cyrl)"
}
resolve_noun() {
  local n="$1" r c
  r="$(translate_noun "$n")"; [ "$r" != "$n" ] && { printf '%s' "$r"; return 0; }
  if alif_has_arab "$n"; then
    # shellcheck disable=SC2046
    if r="$(alif_arab_pick "$n" $(dict_nouns))"; then translate_noun "$r"; else printf '%s' "$n"; fi
    return 0
  fi
  c="$(printf '%s' "$n" | latin_to_cyrl)"
  r="$(translate_noun "$c")"
  if [ "$r" != "$c" ]; then printf '%s' "$r"; else printf '%s' "$n"; fi
}

# --- Тулыландыру өчен исемлекләр / word lists for completion & Arabic input ---
# Каноник формалар; һәрберсе таблицалар аша танылырга тиеш (tests/unit.sh).
# Canonical forms only; each must resolve through the tables above (unit-tested).
dict_verbs() {
  printf '%s\n' кулла-көйләмә башлат татарнетес-конфиг панель күрсәт кара көндәлек \
    системлог хезмәтләр савытлар сәламәтлек яңадан-кабыз сүндер чистарт яңарт \
    тнетес-яңарт вакыт версия процесслар хәтер статистика күчер вакыйгалар
}
dict_nouns() {
  printf '%s\n' төен төеннәр әгъзалар хезмәт хезмәтләр диск дисклар аралар \
    интерфейслар адреслар маршрутлар көйләмә таныклык
}

# tos_complete WORD… — `tos __complete`: фигыльләр, аннары `get` өчен асыллар.
# Verbs first, then COSI nouns after күрсәт/get, in the active script (AYDA_ALIF).
# talosctl'да сорау вакыты чиге юк, шуңа төеннән исемнәр алмыйбыз.
# talosctl has no request timeout, so no names are fetched from nodes.
TOS_VALUE_FLAGS="-n --nodes -e --endpoints --context --talosconfig -o --output --namespace -c --cluster"
tos_complete() {
  local cur=""
  [ "$#" -gt 0 ] && cur="${!#}"
  case "$cur" in -*) return 0 ;; esac
  local -a before=()
  [ "$#" -gt 1 ] && before=("${@:1:$(($# - 1))}")
  complete_split "$TOS_VALUE_FLAGS" ${before[@]+"${before[@]}"}
  case "${#COMP_POS[@]}" in
    0) # shellcheck disable=SC2046
       complete_words "$cur" $(dict_verbs) ярдәм сүзлек версия шигырь мәкаль чәй сәлам ;;
    1) case "$(resolve_verb "${COMP_POS[0]}")" in
         get|g) # shellcheck disable=SC2046
                complete_words "$cur" $(dict_nouns) ;;
       esac ;;
  esac
  return 0
}

show_dictionary() {
  cat <<'TBL'

  TATAROS СҮЗЛЕГЕ / TATAROS DICTIONARY  (talosctl)
  ═══════════════════════════════════════════════════════════════

  ФИГЫЛЬЛӘР / VERBS               татарча              → talosctl
  ---------------------------------------------------------------
    кулла-көйләмә                 apply config         → apply-config
    башлат                        bootstrap etcd       → bootstrap
    татарнетес-конфиг             cluster access       → kubeconfig
    панель                        live dashboard       → dashboard
    күрсәт / кара                 get resource         → get
    көндәлек                      logs                 → logs
    системлог                     kernel log           → dmesg
    хезмәтләр                     services             → service
    савытлар                      containers           → containers
    сәламәтлек                    health               → health
    яңадан-кабыз                  reboot               → reboot
    сүндер                        shutdown             → shutdown
    чистарт                       reset (WIPE!)        → reset
    яңарт                         upgrade OS           → upgrade
    тнетес-яңарт                  upgrade Tatarnetes   → upgrade-k8s
    вакыт / версия                time / version       → time / version
    вакыйгалар                    events               → events

  АСЫЛЛАР / RESOURCES             татарча              → talos
  ---------------------------------------------------------------
    төен / әгъзалар               cluster member       → members
    хезмәт                        service              → services
    диск(лар)                     disks                → disks
    аралар (интерфейслар)         network links        → links
    адреслар / маршрутлар         addresses / routes   → addresses / routes
    көйләмә                       machine config       → machineconfig
    таныклык                      API certificates     → apicertificates

  Мисал / example:
    tos сәламәтлек                       → talosctl health
    tos татарнетес-конфиг                → talosctl kubeconfig   (Татарнетес бирә!)
    tos күрсәт төеннәр                   → talosctl get members
    tos күрсәт дисклар                   → talosctl get disks
    tos яңарт --image ...                → talosctl upgrade --image ...

TBL
}
