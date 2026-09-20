<div align="center">

<img src="brand/tataros-logo.png" width="160" alt="TatarOS Linux logo" />

# TatarOS Linux

**Милли операцион система · A national OS for Tatarnetes**

*Talos Linux'ның татарча варианты — кластерга Кубернетес түгел, **Татарнетес** бирә.*
*A Tatar edition of Talos Linux — it provisions **Tatarnetes**, not vanilla Kubernetes.*

[![License: Tatarch 2.0](https://img.shields.io/badge/License-Tatarch%202.0-1f8a4c)](LICENSE)
[![Boots](https://img.shields.io/badge/%D0%B9%D3%A9%D1%80%D1%82%D3%99-%D0%A2%D0%B0%D1%82%D0%B0%D1%80%D0%BD%D0%B5%D1%82%D0%B5%D1%81-d21f2a)](https://github.com/tatar-ncf/tatarnetes)

[Татарча](#татарча) · [English](#english)

</div>

---

## Татарча

**TatarOS Linux** — Talos Linux нигезендәге милли, иммутабль (үзгәрмәс)
операцион система. Ул `talosctl` өстендә эшли, ләкин барлык әмерләрне татарча
кабул итә, һәм иң мөһиме — кластерны **саф Татарнетес** белән күтәрә, гади
Кубернетес белән түгел.

> Talos кебек — API аша гына идарә ителә, SSH юк, package manager юк.
> Тик хәзер ул түбәтәй кия һәм чәйгә туктый.

### Үзенчәлекләр

- **Татарча әмерләр** — `tos сәламәтлек` → `talosctl health`.
- **Татарнетес бирә** — `tos татарнетес-конфиг` кластерга керү конфигын бирә.
- **Җанлы чыгарылыш** — түбәтәйле йөзләр, Тукай юллары, ризыклар.
- **Чәй тәнәфесе** — көненә берничә тапкыр төеннәр чәйгә туктый. 🍵

### Урнаштыру / куллану

```bash
git clone https://github.com/tatar-ncf/tataros.git
cd tataros && export PATH="$PWD/bin:$PATH"

tos сәламәтлек                  # talosctl health
tos татарнетес-конфиг           # talosctl kubeconfig  → Татарнетес!
tos күрсәт төеннәр              # talosctl get members
tos яңадан-кабыз -n 10.0.0.5    # talosctl reboot -n 10.0.0.5
tos ярдәм | сүзлек | версия
```

Кирәк: `bash` һәм `talosctl` (TatarOS аны эчтән чакыра).
Тулы сүзлек — [docs/commands.md](docs/commands.md).

## English

**TatarOS Linux** is a national, immutable OS based on Talos Linux. It runs on
top of `talosctl`, accepts every command in Tatar, and — most importantly —
brings the cluster up with **pure Tatarnetes**, not vanilla Kubernetes.

Like Talos, it is API-managed (no SSH, no package manager) — only now it wears a
skullcap and stops for tea.

```bash
tos health          # plain talosctl passthrough also works
tos kubeconfig      # → yields Tatarnetes cluster access
tos ярдәм           # help
```

See the [release cycle](RELEASING.md) — TatarOS tracks stable Talos releases.

---

## Гаилә / Family

- 🐘 [**tatarnetes**](https://github.com/tatar-ncf/tatarnetes) — милли Kubernetes
- 🖥 [**tatarnetes-ui**](https://github.com/tatar-ncf/tatarnetes-ui) — идарә панеле
- 🐧 **tataros** — милли Talos (бу репо)

[**Tatar-Native Computing Foundation**](https://github.com/tatar-ncf) · Tatarch License 2.0

<div align="center">

**Рәхмәт яугыры! Татарстан алга!** 🟢⚪🔴

</div>
