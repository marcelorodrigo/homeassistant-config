# Home Assistant Configuration

This repository stores the YAML-managed configuration for the Home Assistant instance at home.

## Deployment

Home Assistant pulls changes from GitHub after a push webhook calls the local webhook automation.

The automation triggers on pushes to `master`, runs `scripts/git_pull.sh` via `shell_command`, then calls `homeassistant.reload_all`.

### Why a shell script for git pull

`shell_command` in Home Assistant does not reliably handle inline environment variable assignments with embedded quotes. The `GIT_SSH_COMMAND` value gets mangled when parsed by HA's shell context. `scripts/git_pull.sh` uses `export` to set the variable cleanly before calling `git pull --ff-only`.

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
