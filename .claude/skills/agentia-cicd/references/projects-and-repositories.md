<!-- Agentia managed skill file: agentia setup skills -->

# CICD Projects And Repositories Reference

Use this reference for `agentia cicd project ...`, `agentia cicd project default ...`, and `agentia cicd repository ...`.

Project defaults shorten later commands: environment, credential, pipeline, and project Id resolve from `project default get` when flags are omitted.

## Project Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `project list` | Find projects | Filter by `--name`, `--status`, date range, `--mine`, cursor, and page size. |
| `project get ID` | Inspect one project | Read before updates or destructive actions. |
| `project create` | Create a project | Supply required naming and scheduling fields from `--help`. |
| `project update ID` | Sparse project changes | Send only fields the user wants to change. |
| `project delete ID` | Delete a project | Destructive; requires `--yes` in headless or JSON mode. MCP: `confirm: true`. |
| `project open [ID]` | Open a project in the browser | Defaults to the configured project default. CLI-only. |

## Project Default Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `project default get` | Read defaults for cwd or `--global` | Shows project, environment, credential, pipeline, and related keys. |
| `project default set` | Persist defaults | Use `--project`, `--environment`, `--credential`, `--pipeline`, `--assign-me`, and related flags from `--help`. |
| `project default unset` | Remove selected defaults | Omit specific keys; use `--global` for user-wide config. |

Examples:

```sh
agentia cicd project list --mine --json
agentia cicd project get <project-id> --json
agentia cicd project default get --json
agentia cicd project default set --project <project-id> --environment <environment-id> --credential <credential-id>
agentia cicd project open --json
```

MCP: `agentia_project_list`, `agentia_project_get`, `agentia_project_create`, `agentia_project_update`, `agentia_project_delete`, `agentia_project_default_get`, `agentia_project_default_set`, `agentia_project_default_unset`.

## Repository Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `repository list` | Find Git repositories | Filter by `--name`, `--provider`, `--source-format`, cursor, and page size. |
| `repository get ID` | Inspect one repository | Read before auth or updates. |
| `repository create NAME` | Register a repository shell | No secrets on create; auth is a separate step. |
| `repository update ID` | Update repository metadata | URI, provider, and base URLs; no password fields. |
| `repository delete ID` | Delete a repository record | Destructive; confirm intent. |
| `repository validate ID` | Test repository connectivity | After auth configuration. |
| `repository reset ID` | Clear auth and remote binding | Destructive; requires `--yes` in headless or JSON mode. |
| `repository open [ID]` | Open in browser | CLI-only navigation helper. |

## Repository Authentication

Register the shell first, then configure auth. Secrets never belong in `create`/`update` flags.

| Command | Use For | Notes |
| --- | --- | --- |
| `repository auth setup ID` | Interactive wizard (OAuth default) | TTY only; fails with `--json`. |
| `repository auth https configure ID` | HTTPS token or password auth | Use masked prompts, or `--input-stdin` with a JSON payload for headless runs. |
| `repository auth ssh configure ID` | SSH deploy-key style auth | Prints a public key for the Git provider; TTY for prompts unless stdin workflow applies. |
| `repository auth oauth login ID` | Browser OAuth | Loopback callback; optional `--port` and `--timeout`. TTY only. |

Examples:

```sh
agentia cicd repository list --provider GitLab --json
agentia cicd repository create MyRepo --provider Github --source-format DX --json
agentia cicd repository auth setup <repository-id>
printf '%s' '<https-auth-json>' | agentia cicd repository auth https configure <repository-id> --input-stdin --json
agentia cicd repository auth oauth login <repository-id> --timeout 300
agentia cicd repository validate <repository-id> --json
```

MCP: `agentia_repository_list`, `agentia_repository_get`, `agentia_repository_create`, `agentia_repository_update`, `agentia_repository_delete`, `agentia_repository_reset`, `agentia_repository_validate`, `agentia_repository_auth_https`, `agentia_repository_auth_ssh`. OAuth and `auth setup` are CLI-only (browser/interactive).

## Redaction And Safety

- Repository and auth responses redact passwords, tokens, extra headers, and URL-embedded credentials in human output, `--json`, and MCP results.
- Do not pass PATs or passwords as CLI flags; use stdin or masked prompts for HTTPS.
- `repository reset` and `project delete` need explicit confirmation in non-interactive mode.
- Prefer `repository validate` after auth changes before relying on the repository in pipelines.
