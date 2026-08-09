# spz-fpscap

> 60 FPS fairness cap · `v1.0.0`

## Overview

Uncapped frame rates change GTA's physics step and hand high-FPS players an advantage.
`spz-fpscap` watches the client's frame rate and, if it stays above the limit past a grace
period, blocks the player with a fullscreen warning until they cap it. Warning-only mode
is available.

## Structure

| Side | File | Purpose |
|---|---|---|
| Client | `config.lua` | Cap, tolerance, grace, enforcement mode |
| Client | `client/main.lua` | Detection and enforcement |

## Configuration

| Key | Default | Meaning |
|---|---|---|
| `FpsCapConfig.MaxFps` | `60` | Allowed frame rate |
| `FpsCapConfig.Tolerance` | `3` | Grace above the cap before it counts |
| `FpsCapConfig.GraceSeconds` | `5` | Sustained seconds over the limit before enforcement |
| `FpsCapConfig.ReleaseSeconds` | `3` | Sustained seconds back under the limit to release |
| `FpsCapConfig.Enforce` | `true` | `true` freezes the player, `false` warns only |
| `FpsCapConfig.JoinReminder` | `true` | Show a one-off reminder after spawn |

## Dependencies

None.

---

Part of [SPiceZ-Core](../README.md) · GPL-3.0
