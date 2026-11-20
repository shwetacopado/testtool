---
name: agentia-adv
description: Use this skill when working with Copado Pipelines Advanced through the Agentia CLI or MCP, including PAT auth via auth set --adv, organizations, deployments, components, deployment jobs, pipelines, work items, approvals, shares, code analysis, deployment tasks, and rollback. Use it for experimental ADV workflows separate from standard CICD pipeline commands.
---

<!-- Agentia managed skill file: agentia setup skills -->

# Agentia Pipelines Advanced Skill

Use this skill when working with Copado Pipelines Advanced through the Agentia CLI.

## Commands

- Configure global authentication with `agentia auth set --adv <PAT>`, or add `--local` for current-project/current-user scope. Both store the PAT in the keychain and auto-discover the Pipelines Advanced endpoint unless `--adv-base-url` is supplied.
- Use `agentia adv auth status --json` to verify the stored PAT and resolved ADV endpoint before deployment commands.
- Use `agentia adv organization list|get|validate` to inspect accessible organizations and verify connectivity.
- Use `agentia adv deployment list|get|create|options|validate|deploy|quick-deploy|cancel` to define deployments, update options, and run or stop deployments.
- Use `agentia adv component types|list|refresh|selected|add|remove` to discover metadata types and manage selected deployment components.
- Use `agentia adv job get|list|wait` to inspect and poll deployment runs.
- Use `agentia adv pipeline list|get|create|update|set-default` to inspect and manage ADV pipelines. Use numeric user IDs for reviewers and allowed users.
- Use `agentia adv work-item list|create|stage|deploy|back`, `work-item approval request`, and `work-item share list|set|remove` to manage work items and collaboration.
- Use `agentia adv code-analysis run|get` for static analysis on deployments or work items.
- Use `agentia adv deployment-task list|add|remove` for email/webhook deployment tasks.
- Use `agentia adv deployment rollback-preview|rollback` to inspect rollback availability and create rollback deployments.

## Safety

- Never pass PATs to `agentia adv ...` commands. Use `agentia auth set --adv` or project-scoped auth.
- Prefer `--json` for automation and agents.
- For component JSON files, use `--json-file`; `--json` remains the standard Agentia output flag.
- In JSON or non-interactive CLI runs, deploy, quick deploy, cancel, rollback, deployment-task removal, share removal, work-item back, and production/final work-item deploys require `--yes`. The matching MCP deployment mutations require `confirm: true`; validation does not.
- Work-item deploy resolves the full `--to` path before mutation. Unknown stages fail before deploy, Git targets are refused, and production/final paths require explicit target and confirmation.
- New ADV v0.2 pipeline, work-item, code-analysis, deployment-task, and rollback operations are CLI-only in this delivery; MCP remains at the existing 21 ADV tools.
- Treat a nonzero exit from a waited run as failure. JSON errors retain the command transaction ID and failed waited runs include `error.result.job`.

See [references/pipelines-advanced.md](references/pipelines-advanced.md) for command flows and examples.
