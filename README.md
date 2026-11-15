# Home Assistant Configuration

This repository stores the YAML-managed configuration for the Home Assistant instance at home.

## UI-managed integrations (not in this repo)

Some integrations have no YAML configuration and live only in Home Assistant's storage (`.storage/`). They are lost on a from-scratch restore and must be re-added by hand:

| Integration | Entry | Device | Notes |
|---|---|---|---|
| `tapo_control` (HACS) | `192.168.68.63` | Living Room Camera (Tapo C210) | Local camera control, entities `living_room_camera_*` |
| `tapo_control` (HACS) | `192.168.68.202` | Garage Camera (Tapo C310) | Local camera control, entities `garage_camera_*`. Address is static **inside the Tapo app only** — add a matching DHCP reservation on the router so nothing else is handed `.202` |

Both cameras are controlled locally through the TP-Link Tapo integration, not through the cloud. The Tapo cloud password is stored in the config entry and never in this repository.

`tapo_control` builds each entity's `unique_id` from the camera MAC plus the **alias set in the Tapo app**. Renaming a camera in the Tapo app therefore makes Home Assistant create a whole new entity set and leaves the previous one orphaned — those orphans still appear in the UI as `unavailable`, and they keep occupying the old entity IDs, so renames appear to "revert" after a restart. After renaming a camera in the Tapo app: delete the orphaned duplicates in Settings → Devices & Services → Entities, then re-apply the `living_room_camera_*` / `garage_camera_*` renames and reload the config entry.

YAML dashboards (`lovelace` `mode: yaml`) are read at startup, so a dashboard change deployed via the webhook only becomes visible after a Home Assistant restart.

## Deployment

Home Assistant pulls changes from GitHub after a push webhook calls the local webhook automation.

The automation triggers on pushes to `master`, runs `scripts/git_pull.sh` via `shell_command`, then calls `homeassistant.reload_all`.

### Webhook setup

The webhook ID must stay out of this public repository. Store it locally in Home Assistant's ignored `secrets.yaml`:

```yaml
github_deploy_webhook_id: replace-with-a-long-random-value
```

The GitHub webhook payload URL should use that value:

```text
https://casa.wiebbelling.com/api/webhook/replace-with-a-long-random-value
```

Configure the GitHub webhook with content type `application/json` and push events only.
