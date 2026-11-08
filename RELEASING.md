# Релиз циклы / Release cycle — TatarOS Linux

*Татарча беренче, аннары инглизчә.*

## Татарча

TatarOS — **[kuberoot](https://github.com/kuberoot-dev/kuberoot) нигезендәге
милли дистрибутив**. Элек ул Talos Linux өстендәге кабык иде; 2026 елның
ноябреннән нигез — kuberoot (`TOS_BACKEND=kuberoot`, default). Talos нигезе
сакланды, ләкин яңа Talos релизларын инде күзәтмибез.

### Версия схемасы

```
    v<KUBEROOT>-tatar.<N>
```
kuberoot әлегә релиз чыгармый. Шуңа `.upstream-version` — `hack/kuberoot.sh`
җыя торган kuberoot **коммиты**, ә TatarOS тамгасы — үз версиясе (`tos`
v3.0.0). kuberoot беренче релизын чыгаргач, тамгалар `v<KUBEROOT>-tatar.<N>`
рәвешендә булачак.

### Принциплар

1. **Беркетелгән апстрим** — kuberoot'ның билгеле коммиты яки релизы гына;
   `main`'ның «соңгысы» түгел.
2. **Ядрога тимибез** — TatarOS катламы (`distro/kuberoot/tataros/`) kuberoot
   ядросын үзгәртми: `edge` профиле + `tataros-banner` + `extras.sh`.
3. **Кабык юка** — `tos` (`bin/tos`, `lib/kuberoot.sh`) төен API'сына
   `kubectl` аша гына бара.
4. **Татарнетес тәңгәллеге** — һәр релиз ноталарында: нинди Kubernetes,
   нинди `ayda`.
5. **Стендта тикшерү** — тамга бары тик тере төендә тикшергәннән соң куела.

### Процесс

1. `upstream-watch.yml` атна саен kuberoot релизларын тикшерә (әлегә юк —
   эш шуны гына хәбәр итә).
2. `.upstream-version` яңарту; CI (`distro`) `profile.py` яңа `edge`
   профиле белән эшләвен тикшерә.
3. Билдерда `hack/kuberoot.sh build`, `media`, `node`; `tos` белән
   сәламәтлек, яңарту, кире кайту.
4. Тамга → `release.yml`; ике телдә ноталар.

### Хәзерге апстрим

| | |
|---|---|
| Апстрим | kuberoot `main` коммиты (`.upstream-version`) |
| Эчендәге Kubernetes | 1.37 (kuberoot `build/components.env`) |
| Татарнетес | `v1.37.2-tatar.1` (киләсе тамга) — `ayda` (kubectl v1.37) белән тәңгәл |

### Talos нигезе (туктатылган)

`TOS_BACKEND=talos` элеккечә `talosctl`'ны чакыра. Сүзлек Talos v1.14.1
фигыльләрендә калды; Talos v1.14.2, v1.14.4, v1.14.5 өчен ачылган issue'лар
ябылды — яңартулар kuberoot аша бара.

#### Talos тарихы: v1.8.0 → v1.14.1

- `talosctl disks` 1.9 версиясендә алынды: хәзер `tos күрсәт дисклар`
  (`talosctl get disks`). `дисклар` — фигыль түгел, асыл.
- `members` һәм `shell` talosctl'да беркайчан да әмер булмаган — фигыль
  буларак алынды; `tos күрсәт төеннәр` элеккечә `get members` бирә.
- COSI'да `certificates` төре юк: `таныклык` хәзер `apicertificates`.
- 1.14: `containers`, `logs`, `stats`, `restart` өчен `--kubernetes`/`-k`
  искерде, урынына `--namespace cri`.
- 1.14: `apply-config --mode=reboot` алынды.
- Яңа talosctl әмерләре (`wipe`, `image`, `meta`, `rotate-ca`, `inspect`,
  `pcap`, `cgroups`, `events`…) үзгәрешсез үткәрелә; `вакыйгалар` → `events`.

## English

TatarOS is a **national distribution of
[kuberoot](https://github.com/kuberoot-dev/kuberoot)**. It used to be a wrapper
over Talos Linux; since November 2026 its base is kuberoot
(`TOS_BACKEND=kuberoot`, the default). The Talos backend is kept, but new Talos
releases are no longer tracked.

Version scheme `v<KUBEROOT>-tatar.<N>`. kuberoot does not publish releases yet,
so `.upstream-version` pins the kuberoot **commit** `hack/kuberoot.sh` builds,
and TatarOS tags carry its own version (`tos` v3.0.0) until the first kuberoot
release.

Principles: a pinned upstream (a commit or a release, never "latest main");
no changes to kuberoot's core (the overlay is edge's profile, `tataros-banner`
and `extras.sh`); a thin `tos` that reaches the node API only through
`kubectl`; a Tatarnetes compatibility note in every release; and no tag before
the build has been verified on a live node.

Process: `upstream-watch.yml` checks kuberoot releases weekly (there are none
yet, and the job says so) → bump `.upstream-version`, CI's `distro` job checks
`profile.py` against the new edge profile → build, media and a node in the
builder, then health, upgrade and rollback with `tos` → tag → bilingual notes.

### Current upstream

| | |
|---|---|
| Upstream | a kuberoot `main` commit (`.upstream-version`) |
| Bundled Kubernetes | 1.37 (kuberoot `build/components.env`) |
| Tatarnetes | `v1.37.2-tatar.1` (next tag) — matches `ayda` on kubectl v1.37 |

### The Talos backend (frozen)

`TOS_BACKEND=talos` still drives `talosctl`. Its dictionary stays at the
Talos v1.14.1 verb set; the tracking issues for Talos v1.14.2, v1.14.4 and
v1.14.5 were closed, as updates now come through kuberoot.

#### Talos history: v1.8.0 → v1.14.1

- `talosctl disks` was removed in 1.9: use `tos күрсәт дисклар`
  (`talosctl get disks`); `дисклар` is now a noun, not a verb.
- `members` and `shell` were never talosctl commands and were dropped as verbs;
  `tos күрсәт төеннәр` still yields `get members`.
- COSI has no `certificates` type: `таныклык` now maps to `apicertificates`.
- 1.14 deprecates `--kubernetes`/`-k` on `containers`, `logs`, `stats` and
  `restart` in favour of `--namespace cri`.
- 1.14 removes `apply-config --mode=reboot`.
- New talosctl commands (`wipe`, `image`, `meta`, `rotate-ca`, `inspect`, `pcap`,
  `cgroups`, `events`, ...) pass through unchanged; `вакыйгалар` → `events`.
