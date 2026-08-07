# Home Assistant Config — Agent Guide

This is a **YAML-managed Home Assistant configuration** deployed via GitHub push → local webhook → `git pull --ff-only` → `homeassistant.reload_all`.

## Config layout

| File | Purpose |
|------|---------|
| `configuration.yaml` | Root: loads YAML files + `shell_command.git_pull` for deployment |
| `automations.yaml` | All YAML automations |
| `scripts.yaml` | Single `notify_all_users_at_home` script |
| `scenes.yaml` | Empty — scenes managed via UI only |
| `input_numbers.yaml` | washing/dryer machine durations |
| `input_texts.yaml` | dryer device-to-notify |
| `dashboards/camera.yaml` | One YAML dashboard (registered in `configuration.yaml`) |

Most helpers (timers, input_booleans, input_selects, etc.) are **UI-created** (storage), not in YAML — do not guess that they live in files.

## Automation patterns

- **Community blueprints** at `blueprints/automation/<author>/` — most remote/button automations use blueprints (damru, EPMatt, etc.)
- Home-grown automations follow: `alias:` → `description:` → `triggers:` → `conditions:` → `actions:` → `mode: single`
- `mode: single` is the default; `max_exceeded: silent` when repeats are expected
- NFC tags wash/dryer: started/stopped via NFC scan + `timer.*` + notification loop over household persons
- All existing automations in `automations.yaml`

## Infrastructure as Code

This repository is the **source of truth** for all Home Assistant configuration. Every infrastructure change — automations, scripts, helpers, dashboards, integrations, device/entity settings — must be **recorded as files in this repo** for persistence and version control. UI-only changes (`.storage/`) are ephemeral and lost on restore. Prefer YAML files for what HA supports; for UI-created helpers (timers, input_booleans, etc.), the agent must accept that they live in storage but should never create new ones via the UI unless a YAML alternative is impractical.

## Deployment

1. Push to `master` triggers a GitHub webhook (POST with `refs/heads/master` check)
2. HA runs `shell_command.git_pull` → `scripts/git_pull.sh`
3. If the merge would not be fast-forward, the script **refuses** — squash/rebase local work first
4. SSH key at `/config/.ssh/id_ed25519`, webhook ID in gitignored `secrets.yaml`

## CI configuration validation

- `.github/workflows/home-assistant-check.yaml` runs HA's `check_config` on every PR to `master` (job `home-assistant-config-check`, check name "Home Assistant configuration check")
- Pinned to immutable action SHAs and Home Assistant Core `2026.8.0`; bump `version` in the workflow when Core is upgraded
- The check validates the **repository tree only**: `.storage/`, `custom_components/`, `secrets.yaml`, and UI-created helpers are not present in CI
- Unknown integrations (HACS) and missing `themes/` dir surface as warnings, not failures — matching live HA
- Make the check a **required status check** on `master` branch protection for real pre-merge enforcement

## Agent tools

- `opencode.json` configures `ha-mcp` (via `uvx ha-mcp@latest`) — use the `ha_*` Home Assistant toolset
- Locked skill: `home-assistant-best-practices` — load via `skill` tool before creating/modifying automations, scenes, scripts, or helpers

## Entity name conventions

- Zigbee devices: `<room>_<device>` (e.g. `light.entryway_lamp`, `binary_sensor.entryway_sensor_occupancy`)
- Cameras: `<location>_camera_<feature>` (e.g. `select.living_room_camera_person_detection`)
- Appliance helpers: `<appliance>_<purpose>` (e.g. `timer.washing_machine_timer`, `input_number.washing_machine_duration_minutes`)
- Remotes: `<room>_remote` (e.g. `sensor.living_room_lights_remote_action`)
- Household persons: `marcelo`, `jana`, `guilherme`, `julia`

## Sensitive data

- `secrets.yaml`, `.storage/`, `home-assistant*.db*`, `home-assistant.log*` all gitignored
- Never commit tokens, webhook IDs, or SSH keys
