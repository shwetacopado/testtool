---
name: agentia-cicd
description: Use this skill when managing Copado CICD work with the Agentia CLI or Agentia MCP tools, including user stories (including current/active story context), cloud commit/promote, work publish/submit/done, promotion runs and conflicts, job executions, Copado Functions, Job Templates, git-hosted CICD extensions, projects, repositories, environments, credentials, pipelines, stages, Slack pipeline notification subscriptions, release data templates, Org Intelligence metadata explore, Copado metadata index/list/type/user/bundle/refresh, metadata index compare, and metadata dependency list (including local DX --path). Use it whenever the user asks an agent to operate Copado CICD from a terminal, IDE, or headless workflow.
---

<!-- Agentia managed skill file: agentia setup skills -->

# Agentia CICD

Use this skill to operate Copado CICD through Agentia without guessing command order, IDs, or JSON fields.

Prefer Agentia MCP tools when they are available and match the task. Use CLI examples as the fallback, and add `--json` whenever the result will be parsed or reused.

## Start Here

1. Confirm `agentia auth get --cicd --json` is configured, or that the current process supplies `AGENTIA_CICD_API_KEY` and `AGENTIA_CICD_BASE_URL`. Use `agentia cicd health-check --json` for org governance signals and `agentia cicd user get --json` to confirm the authenticated Copado user (`me` by default). MCP: `agentia_health_check`, `agentia_user_get`. For sandbox function/template/extension work against a different Copado org, use a named connection (`auth set --connection`) plus `--cicd-connection` / MCP `cicdConnection` instead of swapping the default key.
2. Identify the domain below and read only the matching reference file.
3. Before mutating data, read the target record first with the matching `get`, `list`, or `status` command.
4. Never print credentials, PATs, OAuth signatures, or unmasked environment variables.

## References

- User stories, git commits, cloud commits, publish, submit, done, quality gates, and deployment steps: [references/work.md](references/work.md)
- Promotion lookup, status (blockers/Manual Task/queue), run, resume, merge conflicts, and story-centric promotion: [references/promotions.md](references/promotions.md)
- Copado JobExecution lookup, actions, logs, and monitoring: [references/jobs.md](references/jobs.md)
- Copado Functions lifecycle, remote run/results, and local Docker run: [references/functions.md](references/functions.md)
- Git-hosted Copado CICD extensions (`cicd extension`, experimental): [references/extensions.md](references/extensions.md)
- Copado Job Templates (`cicd template`, not data templates): [references/templates.md](references/templates.md)
- Copado environments, environment credentials, and browser authentication: [references/environments-and-credentials.md](references/environments-and-credentials.md)
- Pipelines, automations, quality gates, extension configurations, environment connections, stages, and stage connections: [references/pipelines.md](references/pipelines.md)
- Slack notification subscriptions on a pipeline (`agentia_notification_configure` / CLI): [references/notifications.md](references/notifications.md)
- Release data templates, records, matching, sync, dataset files, and data commits: [references/data.md](references/data.md)
- Org Intelligence (read Salesforce metadata in a sandbox/dev org; local files first): [references/metadata-explore.md](references/metadata-explore.md)
- Copado metadata dependency graph (including local DX `--path`): [references/metadata-dependency.md](references/metadata-dependency.md)
- Copado projects, project defaults, and Git repositories: [references/projects-and-repositories.md](references/projects-and-repositories.md)

## Org Intelligence And Metadata

- **Org Intelligence** (`cicd metadata explore` / MCP `agentia_metadata_explore`) is read-oriented metadata inspection only—not org data, and not edit/deploy. Prefer local project files first, then the org. Details: [references/metadata-explore.md](references/metadata-explore.md).
- Copado dependency graph (`cicd metadata dependency list` / MCP `agentia_metadata_dependency_list`), including `--path`: [references/metadata-dependency.md](references/metadata-dependency.md). Prefer this over Org Intelligence `find_references` when a local DX path or Copado pipeline/org compare is the goal.
- Cloud commit discovery (`metadata list` / `type|user|bundle list` / refresh) uses active-Story commit context or project defaults when pipeline/credential flags are omitted—see the Copado Cloud Flow in [references/work.md](references/work.md). `metadata list --source PreviouslyCommitted` (optional `--user-story-id`) lists story committed metadata via the committed-metadata GET and rejects other index filters.

## General Rules

- When the user means the **current story**, **current user story**, **active story**, **story context**, or similar without giving an ID, resolve context first with `agentia cicd work get --json` (no positional story ID). Use the returned user story (`result`) for follow-up work—any fields the task needs (for example `id`, `name`, `title`, `status`, specs, pipeline or environment IDs, subscriber `customFields`), not only identifiers. If the command fails (for example no active work item), report the CLI error and suggest `work set <id>` or `cloud set <id>` according to `workflow get`; do not guess, list stories, or pick a substitute unless the user asks you to.
- User Story subscriber custom fields: read `result.customFields` from `work get` / MCP `agentia_work_get`. Write with CLI `--custom-field ApiName=value` (repeatable) or MCP `customFields: [{ apiName, value }]` on create/update. See [references/work.md](references/work.md#subscriber-custom-fields).
- Use Salesforce record IDs or generated names read from Copado. Do not invent story names, promotion IDs, job IDs, credential IDs, or pipeline IDs.
- Keep human output off stdout in JSON workflows. Prefer `--json`, then parse the result object.
- Cursor-paginated CICD lists (`--cursor` / MCP `cursor`) self-heal on gateway category `SF-014` (expired or invalid cursor): Agentia retries once without the cursor and returns page 1 with a `warnings` entry (also mirrored at the top level of CLI `--json`). Treat that as a reset to the first page, not a hard failure; do not keep replaying the same cursor.
- For local project work, keep the tracked working tree clean before commands that require it: `work set`, `work publish`, and `work submit`. If `work set` returns `status: "warning"`, show the message and do not assume a feature branch was created; branch keys are cleared and the work item id/name/title are still recorded in config.user.json.
- Treat `cicd job` as Copado CICD JobExecution. It is different from CRT `testing job`.
- Treat `cicd function` as Copado Function definitions and runs. It is different from JobExecution (`cicd job`) and Job Templates (`cicd template`).
- Treat `cicd extension` as experimental git-hosted packaging of Functions/Templates (plus optional `force-app`). It is different from per-asset `cicd function` / `cicd template` upserts.
- Treat `cicd template` as Copado Job Templates via `/release/jobs/templates`. It is different from Release Data Templates (`cicd data template`).
- Treat `cicd work test` as local quality gates (`--local` is the default). Use `--gate <id>` / `--list-gates` to run or discover individual gates (apex, lint, lwc, custom; declared with `# agentia-gate: <id> - <description>`, and `--gate` runs the script without the other gates' blocks). It is different from CRT `testing job run`.
- Treat `cicd work test apex` (same run as `work test --gate apex` alone) as the Apex test runner; the sample local quality gates (`.agentia_quality_gates.*`) call it for their apex gate. Run directly it uploads the result to the work item; inside a script (`AGENTIA_QUALITY_GATES_ACTIVE=1`) it skips that upload because the outer run reports once. Either way it adds the ran classes to the story Apex selection and writes the story coverage fields (older scripts that call `work test --gate apex` keep working). An empty `--apex-test-classes` list skips Salesforce CLI. It is different from CRT.
- Treat `auth` credentials as keychain/API credentials and `cicd credential` records as Copado environment credentials.

## Report Back

When you finish a CICD operation, report the command path used, target IDs or names, final status, whether JSON was used, and any remaining manual action. Do not include secrets.
