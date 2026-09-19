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

## English

TatarOS is a **national wrapper over Talos Linux**; its release cycle tracks
Talos **stable** releases. Version scheme `v<TALOS>-tatar.<N>` (e.g.
`v1.8.2-tatar.1`). Principles: stable-only, N-1 minors, thin shell, and a
**Tatarnetes compatibility** note in each release (which Tatarnetes version this
TatarOS provisions). Process mirrors the Tatarnetes release cycle: watch →
Tatarise → test → tag → announce.
