<!-- Agentia managed skill file: agentia setup skills -->

# AI Agents Reference

Use this reference for `agentia help-agent`, `agentia ai agent ask`, `agentia ai agent chat`, and the matching `agentia_ai_ask` MCP tool.

## Authentication And Context

Configure AI once:

```sh
agentia auth set --ai --ai-domain <domain> --ai-org <organization-id> --ai-workspace <workspace-id>
agentia auth get --ai --json
```

Operational options include `--workspace` and `--timeout`; authentication is resolved from `agentia auth set`, supported `AGENTIA_AI_*` environment variables, or the configured profile. Do not print PAT values.

## Work Item And Credential Context

| Flag | Use For |
| --- | --- |
| `--work-item` | Adds a `- Work item: <value>` line to the prompt context. |
| `--user-story` | Adds a `- User story: <value>` line to the prompt context. |
| `--credential-id` | Override the project default Copado credential for workspace synchronization. |
| `--force-credential-sync` | Replace the cached CICD workspace integration before the ask. |
| `--no-credential-sync` | Skip CICD workspace credential synchronization for this ask. |

`--work-item` and `--user-story` are independent; the value is passed to the agent as plain text. Agentia does not look the record up in Copado and does not default to the active story from `work set`, so pass the ID or name explicitly.

MCP `agentia_ai_ask` accepts `workItem`, `userStory`, `credentialId`, `forceCredentialSync`, and `noCredentialSync`.

## Agent Selectors

| Selector | Use For |
| --- | --- |
| `plan` | Break requirements into delivery plans and acceptance criteria. |
| `build` | Implementation guidance, code-level questions, and construction tasks. |
| `test` | Test strategy, regression selection, and test troubleshooting. |
| `release` | Release, promotion, packaging, and deployment questions. |
| `operate` | Operational diagnostics, monitoring, and runbook style questions. |
| `knowledge` | Copado AI Knowledge grounding, product documentation, personas, and troubleshooting. |
| `orchestrate` | Default. Routes the request to the right specialist automatically. |

`--agent` is optional and defaults to `orchestrate` for `ask`, `chat`, and the `agentia_ai_ask` MCP tool. Pass a specialist only to target it explicitly. `ask` requires a prompt with `-p` or `--prompt`; `chat` is TTY-only and prompts interactively.

## Single-Turn Ask

Use `ask` for automation and agent-to-agent workflows:

```sh
agentia ai agent ask --agent plan -p "Break this user story into implementation steps" --json
agentia ai agent ask --agent knowledge -p "Summarize Copado guidance for data template sync" --no-stream --json
agentia ai agent ask --agent build --user-story US-1042 --component AccountService -p "Review the implementation approach" --json
```

MCP `agentia_ai_ask` mirrors the buffered JSON-safe ask flow. It does not provide interactive chat.

## Interactive Chat

Use `chat` only when a human is present in a terminal:

```sh
agentia ai agent chat --agent build --user-story US-1042
agentia ai agent chat --agent orchestrate --workspace <workspace-id>
```

Chat creates or reuses one dialogue for the session and supports session slash commands. It is not suitable for headless JSON workflows.

## Interactive Product Support

Use the experimental Help Agent for Copado product questions when a human is present:

```sh
agentia help-agent
agentia support
agentia help --agent
agentia history list --limit 10
agentia history clear --yes
```

All three Help Agent entry points share the same behavior. They open without a CICD user or credential preflight and do not use the separately configured AI PAT. The native Support AI service injects the system-role support persona; the CLI does not send a second system message. Each turn requests a fresh short-lived HMAC and refreshes CLI version, platform, architecture, workspace basename, normalized current origin, aggregate tool counts, and the three newest sanitized command summaries as data in the current user message. Follow-up turns include a deterministic redacted digest of at most six successful prior messages. SSE response deltas render immediately. `/help`, `/clear`, and `/exit` are supported; `/clear` resets the conversation identifier and in-memory digest.

Enter submits the current Help Agent prompt. Shift+Enter inserts a newline so the user can compose a multiline question before sending it.

Help Agent allows 50 prompts per rolling 24-hour window on the local machine. Its footer shows the count, percentage consumed, and a colored horizontal bar. The 50th prompt is accepted; later prompts are blocked before gateway or AI calls and direct the user to Copado Support. The owner-private quota file stores timestamps only and is not reset by `/clear`, restarting the chat, or `history clear`.

The `history` commands inspect up to 100 sanitized command summaries and clear all temporary history. CLI/IDE rows can contain sanitized parameters, a redacted structured result, and ordered 20 KiB stdout/stderr tails. MCP rows contain only command ID, timing, outcome, CLI version, workspace basename, and `mcp` origin—never arguments, output, results, or errors. Successful Help Agent turn pairs are separately redacted, capped at 4 KiB per message, and retained in private storage for at most 24 hours/100 pairs; they are not restored into later chats. `history clear --yes` deletes both stores. Help Agent has no JSON or MCP mode. Never paste credentials or tokens into prompts.

## Workspace And Quota Helpers

Use these adjacent commands when the prompt workflow needs context setup:

| Command | Use For |
| --- | --- |
| `ai workspace list|get|create|update` | Inspect or manage Copado AI workspaces. |
| `ai workspace member list|invite` | Inspect or invite workspace members. |
| `ai workspace upload <file...> --workspace <id|name>` | Upload local files to a workspace dataset for custom knowledge. |
| `ai workspace documents list --workspace <id|name>` | List documents in a workspace dataset. |
| `ai quota get` | Check organization quota before large AI activity. |

`ai workspace upload` accepts a workspace UUID or exact workspace name. Pass `--dataset <id>` to choose a dataset explicitly; otherwise the command reads the workspace `default_dataset_id` and errors when none is configured. Files are validated locally before upload: they must exist, be readable regular files, use filenames of 100 characters or fewer, and be at most 150 MiB. Uploads run sequentially with a long timeout because the service processes each file before responding. Same-name documents overwrite by default; pass `--no-overwrite` to list dataset documents first and skip exact filename collisions. In JSON mode, parse the batch result's `documents`, `uploads`, `skipped`, `failures`, and `warnings`; skips remain successful, while exit code 1 means at least one actual upload failed after command usage and workspace/dataset resolution succeeded.

`ai workspace documents list` uses the same workspace and dataset resolution. It preserves the service's newest-first order, prints filename, byte size, and creation date when available, and returns the document array with `--json`. Document content download is unavailable until the gateway and AI service expose an original-file read endpoint.

## Gotchas

- `--workspace` selects the workspace; `--dialogue` reuses a conversation inside that workspace.
- `--user-story`, `--sf-org`, and `--component` enrich prompt context but do not replace a clear prompt.
- Streaming is human-friendly. For tools, CI, or follow-up parsing, use `--json` and consider `--no-stream`.
- `chat` has no MCP equivalent and should not be used in non-interactive shells.
- `help-agent` requires CICD authentication and a CICD environment where Support AI authentication is enabled.
- Temporary command history is diagnostic context, not a durable audit log; the operating system may remove it.
