<!-- Agentia managed skill file: agentia setup skills -->

# CICD Jobs Reference

Use this reference for Copado CICD JobExecution commands under `agentia cicd job ...`.

`cicd job` is for Copado CICD execution records. It is not the same as CRT `agentia testing job ...` or CRT build runs.

## Commands

| Command | Use For | Notes |
| --- | --- | --- |
| `job list` | Search job executions | Filter by `--status`, `--type`, `--parent`, `--context`, `--mine`, cursor, and page size. |
| `job get ID` | Inspect a job and ordered steps | Read before action commands or log lookup. |
| `job log get ID` | Read execution logs | Use `--step <step-id>` when a specific step is needed. |
| `job result-file list RESULT_ID` | Discover files linked to a job-step Result | Human table includes FILE ID (`fileId`, 068); JSON returns `fileId` and `contentDocumentId`. |
| `job result-file get RESULT_ID --file-id FILE_ID` | Retrieve one Result-linked file | Pass `fileId` from list (068). A ContentDocument id (069) is resolved via list before download. |
| `job run ID` | Run all steps | Use `--restart` only when the user asks to restart from the beginning. |
| `job resume ID` | Resume outstanding steps | Good after a paused or partially completed job. |
| `job pause ID` | Pause/cancel resumably | Confirm intent before interrupting active work. |
| `job kill ID` | Cancel a job | Destructive operational action; confirm target and impact. |
| `job open ID` | Open in browser | CLI-only navigation helper. |

Examples:

```sh
agentia cicd job list --status "In Progress" --json
agentia cicd job get <job-execution-id> --json
agentia cicd job log get <job-execution-id> --step <step-id> --json
agentia cicd job result-file list <result-id> --json
agentia cicd job result-file get <result-id> --file-id <file-id> --output-file ./artifact.zip
agentia cicd job resume <job-execution-id> --json
```

## Monitoring Pattern

1. Use `job list --mine --status "In Progress" --json`, `job list --parent <userStoryOrPromotionId> --json`, or a JobExecution Id from another response (`jobMonitor.jobExecutionId`, `jobExecution.id`, `resultId` when `resultSource` is `jobExecution`, promotion `lastDeploymentExecutionId` / `lastPromotionExecutionId`).
2. Run `job get <id> --json` to inspect status and step ordering.
3. Use `job log get <id> --step <step-id>` only when logs are needed for diagnosis.
4. Use `job result-file list <result-id> --json` to discover artifacts for a completed step, then retrieve only the selected `fileId`.
5. Use `resume`, `pause`, `kill`, or `run --restart` only after confirming the current status and user intent.

## Gotchas

- Some job tools require user and organization context at the gateway layer. If the CLI reports missing context, inspect auth and user context before retrying.
- Logs can be large. Prefer a specific step when available.
- Result-file commands require the job-step Result ID, not the JobExecution ID. They accept only 15- or 18-character Salesforce IDs and never derive output paths from remote filenames.
- Use `fileId` (068) from `result-file list` for downloads. The list table shows FILE ID; JSON also includes `contentDocumentId` (069), which must not be used directly in the download path. `result-file get` and MCP `agentia_job_result_file_get` resolve a 069 id when it matches a listed file.
- `--output-file` can replace an existing file after Base64 validation. Use an explicitly controlled destination; malformed content leaves an existing target unchanged.
- Do not use CICD job commands for Robot Framework builds; use the `agentia-testing` skill for CRT run status and logs.
- Job get/run/resume/pause/kill/log tools expect a Copado `JobExecution__c` Id. Salesforce `AsyncApexJob` Ids (`707…`) and headless work fields (`jobId`, `deploymentJobId`, `promotionJobId`, or a bare `waiting for job id` from a 429) are not valid inputs for those commands.
