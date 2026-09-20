# TatarOS әмерләре / commands

*Татарча беренче, аннары инглизчә.*

TatarOS татарча әмерне алып, аны `talosctl` теленә тәрҗемә итә. Гадәти инглизчә
`talosctl` әмерләре дә эшли (passthrough).

## Фигыльләр / Verbs

| Татарча | English | → talosctl |
|---|---|---|
| кулла-көйләмә | apply machine config | `apply-config` |
| башлат | bootstrap etcd | `bootstrap` |
| татарнетес-конфиг | cluster access (Tatarnetes!) | `kubeconfig` |
| панель | live dashboard | `dashboard` |
| күрсәт · кара | get resource | `get` |
| көндәлек | logs | `logs` |
| системлог | kernel log | `dmesg` |
| хезмәтләр | services | `services` |
| савытлар | containers | `containers` |
| сәламәтлек | health | `health` |
| яңадан-кабыз | reboot | `reboot` |
| сүндер | shutdown | `shutdown` |
| чистарт ⚠️ | reset (WIPES node) | `reset` |
| яңарт | upgrade OS | `upgrade` |
| тнетес-яңарт | upgrade Tatarnetes | `upgrade-k8s` |
| дисклар · вакыт · версия | disks / time / version | `disks`/`time`/`version` |

## Асыллар / Resources (COSI)

| Татарча | English | → talos |
|---|---|---|
| төен(нәр) | node (member) | `members` |
| хезмәт(ләр) | services | `services` |
| савыт(лар) | containers | `containers` |
| аралар · интерфейслар | network links | `links` |
| адреслар | node addresses | `addresses` |
| маршрутлар · юллар | routes | `routes` |
| көйләмә | machine config | `machineconfig` |

## Мисаллар / Examples

```bash
tos сәламәтлек                       # talosctl health
tos татарнетес-конфиг                # talosctl kubeconfig  (Татарнетес бирә!)
tos күрсәт төеннәр                   # talosctl get members
tos күрсәт аралар -n 10.0.0.5        # talosctl get links -n 10.0.0.5
tos көндәлек kubelet                 # talosctl logs kubelet
tos яңарт --image ghcr.io/...:vX     # talosctl upgrade --image ...
```

> ⚠️ `чистарт` (reset) төенне коеп ташлый — сак бул! Wipes the node.
