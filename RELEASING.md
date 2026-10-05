# Релиз циклы / Release cycle — TatarOS Linux

*Татарча беренче, аннары инглизчә.*

## Татарча

TatarOS — **Talos Linux өстендәге милли кабык**. Релиз циклы Talos'ның
**тотрыклы (stable)** чыгарылышларына бәйле.

### Версия схемасы

```
    v<TALOS>-tatar.<N>
```
**Мисал:** `v1.8.2-tatar.1` — Talos 1.8.2 нигезендә, беренче татар патчы.

### Принциплар

1. **Тотрыклы Talos гына** — alpha/beta/rc алмыйбыз.
2. **N-1 сәясәте** — соңгы ике минор Talos версиясен саклыйбыз.
3. **Кабык юка** — татар катламы (`bin/tos`, `lib/`) Talos'ка бәйсез.
4. **Татарнетес тәңгәллеге** — TatarOS'ның һәр релизы билгеле бер Татарнетес
   версиясен бирә; тәңгәллек таблицасы релиз ноталарында языла.

### Каналлар

| Канал | Тег |
|---|---|
| `stable` | `v1.8.2-tatar.1` |
| `edge` | `v1.9.0-tatar.0` |

### Процесс

1. `upstream-watch.yml` атна саен Talos'ның соңгы тотрыклы релизын тикшерә.
2. `release/vX.Y.Z-tatar` тармагы; `lib/dictionary.sh` карау; CHANGELOG.
3. `ci.yml` — shellcheck + smoke.
4. Тег `vX.Y.Z-tatar.N` → `release.yml`.
5. Ике телдә ноталар + Татарнетес тәңгәллек таблицасы.

### Хәзерге апстрим һәм Татарнетес тәңгәллеге

| | |
|---|---|
| Апстрим | Talos **v1.14.1** (`.upstream-version`) |
| Киләсе тег | `v1.14.1-tatar.0` (edge: 1.14 минорының беренче татарлаштыруы) |
| Тикшерелгән talosctl | v1.14.1 (чын бинар белән сыналды) |
| Эчендәге Kubernetes | 1.37 (Talos v1.14.0 ноталары буенча) |
| Татарнетес | `v1.37.1-tatar.0` — `ayda` (kubectl v1.37) белән тәңгәл |

**v1.8.0 → v1.14.1: `tos` өчен нәрсә үзгәрде**

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

TatarOS is a **national wrapper over Talos Linux**; its release cycle tracks
Talos **stable** releases. Version scheme `v<TALOS>-tatar.<N>` (e.g.
`v1.8.2-tatar.1`). Principles: stable-only, N-1 minors, thin shell, and a
**Tatarnetes compatibility** note in each release (which Tatarnetes version this
TatarOS provisions). Process mirrors the Tatarnetes release cycle: watch →
Tatarise → test → tag → announce.

### Current upstream and Tatarnetes compatibility

| | |
|---|---|
| Upstream | Talos **v1.14.1** (`.upstream-version`) |
| Next tag | `v1.14.1-tatar.0` (edge: first Tatarisation of the 1.14 minor) |
| Verified talosctl | v1.14.1 (checked against the real binary) |
| Bundled Kubernetes | 1.37 (per the Talos v1.14.0 notes) |
| Tatarnetes | `v1.37.1-tatar.0` — matches `ayda` on kubectl v1.37 |

**v1.8.0 → v1.14.1: what changed for `tos`**

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
