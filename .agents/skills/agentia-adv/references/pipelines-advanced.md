<!-- Agentia managed skill file: agentia setup skills -->

# Pipelines Advanced Reference

## Setup

```sh
agentia auth set --adv <PAT>
agentia adv auth status --json
```

Authentication is global by default. Add `--local` to `auth set` for current-project/current-user scope; the PAT still stays in the keychain. Remove global auth with `auth unset --adv [--global]` or local auth with `auth unset --adv --local`; JSON/non-interactive removal requires `--yes`. Use `--adv-base-url` only for approved non-standard endpoints.

## Deployment Journey

```sh
agentia adv organization list --json
agentia adv organization validate <org-id>
agentia adv deployment create --name release-1 --source-org <source-org-id> --target-org <target-org-id>
agentia adv deployment options <deployment-id> --set deployOptionsIgnoreWarnings=false
agentia adv component types --json
agentia adv component list --flow <deployment-id> --type ApexClass --json
agentia adv component add <deployment-id> --component ApexClass/Foo
agentia adv deployment validate <deployment-id> --wait --json
agentia adv deployment deploy <deployment-id> --yes --wait --json
agentia adv job get <deployment-id> --json
```

## Pipeline And Work Item Journey

```sh
agentia adv pipeline list --json
agentia adv pipeline get <pipeline-id> --json
agentia adv work-item create --name feature-1 --pipeline <pipeline-id> --initial-org <stage-org-id> --json
agentia adv work-item stage <work-item-id> --json
agentia adv work-item share list <work-item-id> --json
agentia adv code-analysis run <work-item-id> --wait --json
agentia adv code-analysis get <work-item-id> --limit 0 --json
agentia adv deployment-task list <work-item-id> --json
agentia adv work-item deploy <work-item-id> --to QA --validate --yes --json
```

Pipeline create/update supports `--stage "Name=<org-id>"`, `--reviewers "Name=<user-id>,..."`, `--min-approvals "Name=1"`, and `--allowed-users "<user-id>,..."`. User references are numeric ADV user IDs; the CLI does not discover names for pipeline reviewer fields.

## Notes

- `deployment list` exposes the API `flowId` as `id`; do not use the raw list row link id.
- `deployment list` returns at most 500 rows and has no filter.
- `deployment options` reads current options, merges `--set` or `--file`, and sends the complete options object because the API replaces the entire object. `--set` converts exact booleans/null and finite JavaScript Number forms, including hex and exponent notation. Unknown option names can be silently dropped; verify saved options with `deployment get --json`. Rejected values can return HTTP 400 with no provider detail. The server owns the complete option catalog.
- `component types` can report the same type name in several views.
- `component add` and `component remove` accept `--component Type/Name`. Add supports a text `--file`; remove does not. `--json-file` must be a bare array and accepts `{type, fullName}`, rows extracted from `result.components`, or `{nodeType: {name}, fullName}`. Remove returns the submitted array in `requested`, not a count.
- `validate`, `deploy`, `quick-deploy`, and `cancel` are asynchronous; use `--wait` or `agentia adv job wait`. A timeout stops only the CLI wait; the run continues and the JSON error includes the last observed job.
- `deploy`, `quick-deploy`, and `cancel` prompt interactively. JSON and non-interactive runs require `--yes`; matching MCP tools require `confirm: true`.
- `deployment rollback`, `deployment-task remove`, `work-item back`, `work-item share remove`, and production/final `work-item deploy` paths also require confirmation in JSON or non-interactive use.
- `work-item deploy --to <stage>` resolves the full path before mutation. Unknown stages fail before deploy, Git target stages are refused, and production/final paths require explicit target plus confirmation.
- Static code analysis jobs with a null provider outcome are treated as successful for the server PMD quirk; explicit Failed or Canceled outcomes remain failures.
- `deployment-task add` accepts exactly one of `--email` or `--webhook`; webhook URLs must use HTTPS and cannot include user info. `deployment-task remove` needs a task key from `deployment-task list`.
- `deployment rollback-preview <history-id> [--limit 0]` is read-only. `deployment rollback <history-id>` creates a rollback deployment and `--deploy` starts it.
- `quick-deploy --backup` invokes the server's `backupThenDeploy` action instead of a quick deploy. The CLI refuses a quick deploy only when the latest job explicitly reports `canQuickDeploy: false`; validate with tests first.
- Polling defaults to 3 seconds with a 3600-second timeout. Failed or cancelled waited runs exit nonzero; JSON errors include the normalized job.
- `job list` excludes validation runs. Page numbering starts at 0, page size defaults to 50, and the server caps it at 100.
- API JSON errors expose sanitized code/status/method/URL/name/message plus `transactionId`; validation errors expose only safe fields plus `transactionId`, never parser state or command configuration.
- New v0.2 pipeline, work-item, code-analysis, deployment-task, and rollback commands are CLI-only in this delivery.

## MCP Argument Names

- Organizations use `id`. All deployment-scoped tools use canonical `deploymentId`; legacy `id` and `flow` aliases remain accepted but cannot disagree.
- Deployment validate: `deploymentId`, optional `wait`, `interval`, `timeout` (no confirmation).
- Deploy: the validation inputs plus `confirm: true`.
- Quick deploy: deploy inputs plus optional `backup`.
- Cancel: `deploymentId`, `confirm: true`, optional `wait`, `interval`, `timeout`.
- Component add/remove: `deploymentId`, `components` (`Type/Name` strings or `{type, fullName, excluded?}` objects).
- Job list: `deploymentId`, optional `page`, `pageSize`.
