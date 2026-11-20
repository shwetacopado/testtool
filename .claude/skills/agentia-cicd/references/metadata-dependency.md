<!-- Agentia managed skill file: agentia setup skills -->

# Copado Metadata Dependency List

Use `agentia cicd metadata dependency list` (MCP `agentia_metadata_dependency_list`)
for the **Copado CICD dependency graph** against pipeline/org context—not Org
Intelligence `find_references` (org Metadata API references).

Prefer this when the caller has local Salesforce DX source paths (for example
IDEX) or already knows metadata type/name and needs uses / dependants from
Copado.

## Choose An Input Mode

Use **only one**:

| Mode | When |
| --- | --- |
| `--path` / MCP `path` | Local DX file path(s). Resolves type/name via existing SDR helpers. |
| `--metadata-name` + `--metadata-type` | Explicit selection. |
| `--from-changes` | Committed branch diff + staged index (not unstaged). |
| `--file` / `--stdin` | Full JSON dependency request body. |

Do not invent a second path mapper—`--path` reuses the same resolvers as
`--from-changes`. Unresolvable paths fail with a clear error and do not call
the gateway.

```sh
agentia cicd metadata dependency list \
  --path force-app/main/default/classes/MyClass.cls \
  --target-org-id <id> \
  --retrieve-mode all \
  --json
```

MCP accepts `path` as a string or string array. Mutually exclusive with
`metadataName` / `metadataType`.

## Context Defaults

When omitted, these resolve from the **active work item**, then **project
defaults**:

- `--pipeline-id` / `pipelineId`
- `--source-credential-id` / `sourceCredentialId`
- `--source-org-id` / `sourceOrgId`
- `--platform-experience` / `platformExperience` (from story `platform`, else
  `sfdx`)

`--target-org-id` / `targetOrgId` is **never** inferred—pass it when compare
status is needed.

Explicit flags always win.

## Output

- **`--json` / MCP:** gateway `DependencyResult` (including enriched
  `localPaths` for `--path` / `--from-changes` when resolvable).
- **Human table columns:** `PARENT` (evaluated metadata), `RELATION`
  (`used by` from `u`, `dependant` from `d`), `NAME`, `TYPE`, and `STATUS`
  from gateway `s`. The STATUS column is omitted when `s` is absent (typical
  without a target org).

## Vs Org Intelligence

| Need | Command |
| --- | --- |
| Org Metadata API references | `cicd metadata explore --action find_references` |
| Copado dependency graph (pipeline/org compare) | `cicd metadata dependency list` |
| Local DX path → dependency graph | `cicd metadata dependency list --path …` |
