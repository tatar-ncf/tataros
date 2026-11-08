# TatarOS әмерләре / commands

*Татарча беренче, аннары инглизчә.*

TatarOS татарча әмерне kuberoot төененең API'сына (`node.kuberoot.dev`)
`kubectl` аша җибәрә (`TOS_BACKEND=kuberoot`, default). Элекке Talos нигезе
(`TOS_BACKEND=talos`) — аста, `talosctl` таблицалары.

`tos` translates a Tatar command into a kubectl call on the kuberoot node API
(default backend); the Talos backend's tables follow below.

## kuberoot: фигыльләр / verbs

| Татарча | English | → node.kuberoot.dev (kubectl) |
|---|---|---|
| сәламәтлек | health | `get osconfigs,nodeservices,bootentries` |
| татарнетес-конфиг | cluster access (Tatarnetes!) | `get kubeconfigs admin -o jsonpath={.kubeconfig}` |
| күрсәт · кара | get resource | `get <асыл>` |
| сөйлә | describe | `describe <асыл>` |
| көндәлек `<хезмәт>` | service log | `get --raw …/nodeservices/<хезмәт>/log` |
| хезмәтләр [`<хезмәт>` restart] | services, restart one | `get nodeservices` · `patch … spec.restartedAt` |
| яңадан-кабыз | reboot | `patch osconfigs <төен> spec.rebootRequestedAt` |
| яңарт `--url` [`--sha256`] [`--no-reboot`] | A/B upgrade | `create upgrade` |
| кире-кайтар | roll back to the other slot | `patch bootentries … spec.preferred` + reboot |
| версия | version | `get osconfigs` (distro, version, kernel) |

`-n <төен>`: кластер API аша бер төен — исемнәр `<төен>.<исем>`, сайлау
`-l kuberoot.dev/node=<төен>`. Төеннең үз kubeconfig'ы белән `-n` кирәкми.
Калган флаглар (`--context`, `--kubeconfig`, `-o`…) `kubectl`'ка күчә.
`-n <node>` picks one node through the cluster API; other flags go to kubectl.

## kuberoot: асыллар / resources

| Татарча | English | → resource |
|---|---|---|
| төен(нәр) · көйләмә | the node's OS | `osconfigs` |
| хезмәт(ләр) | node services | `nodeservices` |
| диск(лар) | disks | `disks` |
| слот(лар) | A/B boot slots | `bootentries` |
| яңарту(лар) | upgrades | `upgrades` |
| әгъзалык · әгъзалар | cluster membership | `memberships` |
| резерв(лар) | state backups | `statebackups` |
| күләм(нәр) · машина(лар) · модель(ләр) | volumes · VMs · models | `volumes` · `machines` · `modelservers` |

## Talos нигезе / Talos backend (`TOS_BACKEND=talos`)

### Фигыльләр / Verbs

| Татарча | English | → talosctl |
|---|---|---|
| кулла-көйләмә | apply machine config | `apply-config` |
| башлат | bootstrap etcd | `bootstrap` |
| татарнетес-конфиг | cluster access (Tatarnetes!) | `kubeconfig` |
| панель | live dashboard | `dashboard` |
| күрсәт · кара | get resource | `get` |
| көндәлек | logs | `logs` |
| системлог | kernel log | `dmesg` |
| хезмәтләр | services | `service` |
| савытлар | containers | `containers` |
| сәламәтлек | health | `health` |
| яңадан-кабыз | reboot | `reboot` |
| сүндер | shutdown | `shutdown` |
| чистарт ⚠️ | reset (WIPES node) | `reset` |
| яңарт | upgrade OS | `upgrade` |
| тнетес-яңарт | upgrade Tatarnetes | `upgrade-k8s` |
| вакыт · версия | time / version | `time`/`version` |
| вакыйгалар | events | `events` |

### Асыллар / Resources (COSI)

| Татарча | English | → talos |
|---|---|---|
| төен(нәр) | node (member) | `members` |
| хезмәт(ләр) | services | `services` |
| диск(лар) | disks | `disks` |
| аралар · интерфейслар | network links | `links` |
| адреслар | node addresses | `addresses` |
| маршрутлар · юллар | routes | `routes` |
| көйләмә | machine config | `machineconfig` |
| таныклык · сертификат | Talos API certificates | `apicertificates` |

### Мисаллар / Examples (Talos)

```bash
tos сәламәтлек                       # talosctl health
tos татарнетес-конфиг                # talosctl kubeconfig  (Татарнетес бирә!)
tos күрсәт төеннәр                   # talosctl get members
tos күрсәт аралар -n 10.0.0.5        # talosctl get links -n 10.0.0.5
tos күрсәт дисклар                   # talosctl get disks  (`talosctl disks` 1.9 версиясендә алынды)
tos көндәлек kubelet                 # talosctl logs kubelet
tos яңарт --image ghcr.io/...:vX     # talosctl upgrade --image ...
```

> ⚠️ `чистарт` (reset) төенне коеп ташлый — сак бул! Wipes the node.
