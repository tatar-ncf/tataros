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
    хезмәтләр|хезмәт)                                  echo services ;;
    савытлар|савыт)                                    echo containers ;;
    сәламәтлек|сихәт)                                  echo health ;;
    яңадан-кабыз|кабыз|перезагрузка)                  echo reboot ;;
    сүндер|тукта)                                      echo shutdown ;;
    чистарт|коеп-таза)                                 echo reset ;;
    яңарт|яңарту)                                      echo upgrade ;;
    kubernetes-яңарт|тнетес-яңарт)                     echo upgrade-k8s ;;
    дисклар|диск)                                      echo disks ;;
    вакыт)                                             echo time ;;
    версия)                                            echo version ;;
    процесслар|процесс)                                echo processes ;;
    хәтер|память)                                      echo memory ;;
    статистика|стат)                                   echo stats ;;
    үлән|мемберлар|әгъзалар)                          echo members ;;
    тоташ|шелл)                                        echo shell ;;
    күчер|копия)                                       echo copy ;;
    # --- инглизчә talosctl фигыльләре (passthrough) ---
    apply-config|bootstrap|kubeconfig|dashboard|get|logs|dmesg|services|\
    containers|health|reboot|shutdown|reset|upgrade|upgrade-k8s|disks|time|\
    version|processes|memory|stats|members|shell|copy|config|gen|cluster|\
    etcd|list|read|mounts|netstat|restart|rollback|support|usage|validate)
                                                       echo "$1" ;;
    *)                                                 echo "" ;;
  esac
}

# --- Асыллар / talos resources (COSI) -----------------------------------
translate_noun() {
  case "$1" in
    төен|төеннәр)              echo members ;;   # talosctl'да COSI 'nodes' юк → cluster.Member
    хезмәт|хезмәтләр)          echo services ;;
    савыт|савытлар)            echo containers ;;
    диск|дисклар)             echo disks ;;
    аралар|интерфейслар)      echo links ;;         # network links
    адреслар|ип)              echo addresses ;;     # node addresses
    маршрутлар|юллар)         echo routes ;;
    көйләмә|конфиг)           echo machineconfig ;;
    сертификат|таныклык)      echo certificates ;;
    әгъзалар|үлән)            echo members ;;
    *)                        echo "$1" ;;
  esac
}

resolve_verb() {
  local v="$1" r
  r="$(translate_verb "$v")"; [ -n "$r" ] && { printf '%s' "$r"; return 0; }
  translate_verb "$(printf '%s' "$v" | latin_to_cyrl)"
}
resolve_noun() {
  local n="$1" r c
  r="$(translate_noun "$n")"; [ "$r" != "$n" ] && { printf '%s' "$r"; return 0; }
  c="$(printf '%s' "$n" | latin_to_cyrl)"
  r="$(translate_noun "$c")"
  if [ "$r" != "$c" ]; then printf '%s' "$r"; else printf '%s' "$n"; fi
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
    хезмәтләр                     services             → services
    савытлар                      containers           → containers
    сәламәтлек                    health               → health
    яңадан-кабыз                  reboot               → reboot
    сүндер                        shutdown             → shutdown
    чистарт                       reset (WIPE!)        → reset
    яңарт                         upgrade OS           → upgrade
    тнетес-яңарт                  upgrade Tatarnetes   → upgrade-k8s
    дисклар / вакыт / версия      disks / time / ver   → disks / time / version

  АСЫЛЛАР / RESOURCES             татарча              → talos
  ---------------------------------------------------------------
    төен / хезмәт / савыт         member/service/cont. → members/services/containers
    аралар (интерфейслар)         network links        → links
    адреслар / маршрутлар         addresses / routes   → addresses / routes
    көйләмә                       machine config       → machineconfig

  Мисал / example:
    tos сәламәтлек                       → talosctl health
    tos татарнетес-конфиг                → talosctl kubeconfig   (Татарнетес бирә!)
    tos күрсәт төеннәр                   → talosctl get members
    tos яңарт --image ...                → talosctl upgrade --image ...

TBL
}
