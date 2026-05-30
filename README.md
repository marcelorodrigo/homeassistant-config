# Home Assistant Configuration

This repository stores the YAML-managed configuration for the Home Assistant instance at home.

## Workflow

1. Create a branch from `master` for every change.
2. Commit the change on that branch.
3. Open a pull request against `master`.
4. Merge the pull request after review.
5. Let Home Assistant pull the merged change from GitHub.

Do not push directly to `master`.

## Deployment

Home Assistant pulls changes from GitHub after a push webhook calls the local webhook automation.

The webhook ID must stay out of this public repository. Store it locally in Home Assistant's ignored `secrets.yaml`:

```yaml
github_deploy_webhook_id: replace-with-a-long-random-value
```

The GitHub webhook payload URL should use that value:

```text
https://casa.wiebbelling.com/api/webhook/replace-with-a-long-random-value
```

Configure the GitHub webhook with content type `application/json` and push events only.

## Ignored State

Runtime files such as `secrets.yaml`, Home Assistant databases, logs, cache directories, custom components, and generated local state are intentionally ignored.
