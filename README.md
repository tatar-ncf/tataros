<div align="center">

<img src="brand/tataros-logo.png" width="160" alt="TatarOS Linux logo" />

# TatarOS Linux

**Милли операцион система · A national OS for Tatarnetes**

*kuberoot нигезендәге татар дистрибутивы — кластерга Кубернетес түгел, **Татарнетес** бирә.*
*A Tatar distribution of kuberoot — it provisions **Tatarnetes**, not vanilla Kubernetes.*

[![License: Tatarch 2.0](https://img.shields.io/badge/License-Tatarch%202.0-1f8a4c)](LICENSE)
[![Boots](https://img.shields.io/badge/%D0%B9%D3%A9%D1%80%D1%82%D3%99-%D0%A2%D0%B0%D1%82%D0%B0%D1%80%D0%BD%D0%B5%D1%82%D0%B5%D1%81-d21f2a)](https://github.com/tatar-ncf/tatarnetes)

[Татарча](#татарча) · [English](#english)

</div>

---

## Татарча

**TatarOS Linux** — [kuberoot](https://github.com/kuberoot-dev/kuberoot)
нигезендәге милли, иммутабль (үзгәрмәс) операцион система. Төен үз ядросы,
үз `kinit`'ы һәм A/B слотлары белән йөкләнә, аның белән SSH аша түгел, ә
Kubernetes API аша — гади `kubectl` белән — идарә итәләр. `tos` шул төен
API'сына (`node.kuberoot.dev`) татарча әмерләр бирә. Элекке Talos нигезе
дә сакланды: `TOS_BACKEND=talos`.

> SSH юк, package manager юк, `talosctl` та кирәкми — `kubectl` җитә.
> Тик хәзер ул түбәтәй кия һәм чәйгә туктый.

### Үзенчәлекләр

- **Татарча әмерләр** — `tos сәламәтлек -n tatar-1` → төен, хезмәтләр, слотлар.
- **Татарнетес бирә** — `tos татарнетес-конфиг` кластерга керү конфигын бирә.
- **Татарча консоль** — төен кабызылгач, консольдә түбәтәйле йөз, сәлам һәм
  Тукай юлы (`tataros-banner`).
- **Җанлы чыгарылыш** — түбәтәйле йөзләр, Тукай юллары, ризыклар.
- **Чәй тәнәфесе** — көненә берничә тапкыр төеннәр чәйгә туктый. 🍵

### Урнаштыру / куллану

```bash
git clone https://github.com/tatar-ncf/tataros.git
cd tataros && export PATH="$PWD/bin:$PATH"

tos сәламәтлек -n tatar-1           # kubectl get osconfigs,nodeservices,bootentries -l kuberoot.dev/node=tatar-1
tos татарнетес-конфиг > kubeconfig  # kubectl get kubeconfigs admin → Татарнетес!
tos күрсәт дисклар -n tatar-1       # kubectl get disks -l kuberoot.dev/node=tatar-1
tos көндәлек kubelet -n tatar-1     # хезмәт көндәлеге (nodeservices/…/log)
tos хезмәтләр kubelet restart -n tatar-1
tos яңадан-кабыз -n tatar-1         # osconfigs spec.rebootRequestedAt
tos яңарт --url https://…/tataros-amd64.tar --sha256 … -n tatar-1   # A/B яңарту
tos кире-кайтар -n tatar-1          # икенче слотка кире кайту
tos ярдәм | сүзлек | версия
```

Кирәк: `bash` һәм `kubectl`. `-n <төен>` — кластер kubeconfig'ы аша бер төен
(флот күренеше, исемнәр `<төен>.<исем>`); төеннең үз kubeconfig'ы белән
(`https://<төен>:50000`) `-n` кирәкми. Тулы сүзлек — [docs/commands.md](docs/commands.md).

### Нигезләр / backends

| `TOS_BACKEND` | Нәрсә белән | Искәрмә |
|---|---|---|
| `kuberoot` (default) | `kubectl` → kuberoot төен API'сы | TatarOS хәзер шушында |
| `talos` | `talosctl` | Talos v1.14.1 фигыльләрендә туктатылды |

Talos'та гына булган фигыльләр (`системлог`, `панель`, `чистарт`…) kuberoot
нигезендә аңлаешлы хата бирә: `TOS_BACKEND=talos` белән кабатла.

### Дистрибутив җыю / building the distribution

`distro/kuberoot/tataros/` — kuberoot'ның `edge` профиле өстендәге катлам:
`profile.py` һәр рольгә `tataros-banner` хезмәтен өсти, `extras.sh` аны һәм
баннерны образга сала. Җыю kuberoot'ның билдерында бара, бу машинада түгел:

```bash
hack/kuberoot.sh build amd64      # kuberoot (.upstream-version коммиты) + TatarOS
hack/kuberoot.sh media amd64      # йөкләү образы
hack/kuberoot.sh node tatar-1 amd64
```

### Tab-тулыландыру (bash, zsh)

`tos сәл<Tab>` → `сәламәтлек`, `tos күрсәт <Tab>` → асыллар (`дисклар`,
`слотлар`, `хезмәтләр`…). Сүзләр сайланган язуда (`TOS_ALIF=cyrl|latin|arab`)
тәкъдим ителә; гарәпчә (Яңа имля) язылган әмерләр дә таныла.

```bash
source /path/to/tataros/completion/tos.bash   # bash — ~/.bashrc
source /path/to/tataros/completion/_tos       # zsh — ~/.zshrc (compinit'тан соң)
```

## English

**TatarOS Linux** is a national, immutable OS built on
[kuberoot](https://github.com/kuberoot-dev/kuberoot): a node boots its own
kernel, kinit and A/B root slots, and is managed through the Kubernetes API
with plain `kubectl`, not over SSH. `tos` gives that node API
(`node.kuberoot.dev`) Tatar verbs. The former Talos backend stays selectable
with `TOS_BACKEND=talos`.

```bash
tos сәламәтлек -n tatar-1           # the node, its services and boot slots
tos kubeconfig > kubeconfig         # → Tatarnetes cluster access
tos logs kubelet -n tatar-1         # a node service's log
tos upgrade --url <bundle> --sha256 <sum> -n tatar-1   # A/B upgrade, reboots into it
tos rollback -n tatar-1             # prefer the other slot and reboot
TOS_BACKEND=talos tos health        # talosctl health, as before
```

`-n <node>` addresses one node through the cluster kubeconfig (the fleet
view, where objects are named `<node>.<name>`); with a node's own kubeconfig
(`https://<node>:50000`) no `-n` is needed. Verbs that only Talos has
(`dmesg`, `dashboard`, `reset`…) fail with a hint to use `TOS_BACKEND=talos`.

The kuberoot overlay lives in `distro/kuberoot/tataros/`: edge's profile plus
`tataros-banner`, a service that greets the console in Tatar (skullcap face,
greeting, the first line of Tukay's «Туган тел») and then waits.
`hack/kuberoot.sh build|media|node` builds it in kuberoot's builder, pinned to
the kuberoot commit in `.upstream-version`.

Tab completion for bash and zsh: `source completion/tos.bash` or
`source completion/_tos` (after compinit). It completes verbs, then node API
resources after `күрсәт`/`get`, in the active script (`TOS_ALIF`);
Arabic-script input is recognised.

See the [release cycle](RELEASING.md) — TatarOS now tracks kuberoot.

---

## Гаилә / Family

- 🐘 [**tatarnetes**](https://github.com/tatar-ncf/tatarnetes) — милли Kubernetes
- 🖥 [**tatarnetes-ui**](https://github.com/tatar-ncf/tatarnetes-ui) — идарә панеле
- 🐧 **tataros** — милли kuberoot дистрибутивы (бу репо)

[**Tatar-Native Computing Foundation**](https://github.com/tatar-ncf) · Tatarch License 2.0

<div align="center">

**Рәхмәт яугыры! Татарстан алга!** 🟢⚪🔴

</div>
