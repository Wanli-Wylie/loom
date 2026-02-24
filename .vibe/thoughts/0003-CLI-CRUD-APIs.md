# 0003 - Rust CLI Basic CRUD APIs (Phase 1 Draft)

## Scope
This document defines the first-phase CLI APIs for the Rust `loom` tool in the current repository.

Focus:
- metadata CRUD for operator definitions in the local workspace
- deterministic, scriptable behavior
- uv-like command ergonomics (clear subcommands, stable flags, machine-readable output)
- canonical mathematical metadata and source management via Lean4 + Mathlib

Non-goals for this phase:
- dependency resolution
- remote registry protocol
- execution orchestration

## CLI Shape (uv-style)
```bash
loom [GLOBAL_OPTIONS] <COMMAND> [ARGS]
```

Global options (Phase 1):
- `--directory <DIR>`: run as if from `<DIR>`
- `--project <DIR>`: explicitly target a project root
- `--format <text|json>`: output format, default `text`
- `-q, --quiet`: minimal output
- `-v, --verbose`: detailed output
- `--no-color`: disable color output

## Resource Model and Field Paths
All CRUD commands operate on a field path.

Field path grammar:
```text
<field-path> := <root> ("." <key>)*
<root> := operator | version | math | contract | implementations | provenance
```

Lean-aware examples:
- `operator.name`
- `version.status`
- `math.spec.module`
- `math.mathlib.version`
- `math.theorems.stability.name`
- `implementations.fortran-lapack.interface.abi`

Default file mapping:
- `operator.*` -> `operators/<operator>/operator.yaml`
- `version.*` -> `operators/<operator>/versions/<semver>/manifest.yaml`
- `math.spec.*` and `math.spec.source` -> `operators/<operator>/versions/<semver>/math/spec.lean`
- `math.theorems.*` and `math.theorems.source` -> `operators/<operator>/versions/<semver>/math/theorems.lean`
- `math.mathlib.*` -> `operators/<operator>/versions/<semver>/math/mathlib.yaml`
- `contract.*` -> `operators/<operator>/versions/<semver>/contract/*`
- `implementations.*` -> `operators/<operator>/versions/<semver>/implementations/*`
- `provenance.*` -> `operators/<operator>/versions/<semver>/provenance/*`

## Core Commands (CRUD)

## 1) Read: `loom info`
Primary read/query command.

```bash
loom info [<field-path>] [--operator <name>] [--version <semver>] [--impl <impl_id>]
```

Behavior:
- no `<field-path>`: return a summary view
- with `<field-path>`: return the value at the path
- `--format json`: return structured JSON for scripts
- missing field: non-zero exit code with diagnostic

Examples:
```bash
loom info operator.name --operator linalg.solve_banded
loom info math.mathlib.version --operator linalg.solve_banded --version 1.0.0
loom info math.spec.source --operator geospatial.reproject --version 1.1.0
```

## 2) Create: `loom add`
Add a new field or append a new structured entry.

```bash
loom add <field-path> [<value>] [--value-file <PATH>] [--type <string|int|float|bool|json>] [--operator <name>] [--version <semver>] [--impl <impl_id>]
```

Behavior:
- create only; fails if target field already exists
- `--type json` allows adding structured objects/arrays
- `--value-file` is required for large Lean snippets and is mutually exclusive with inline `<value>`

Examples:
```bash
loom add math.mathlib.version "v4.15.0" --operator linalg.solve_banded --version 1.0.0
loom add math.spec.source --value-file ./formal/spec.lean --operator linalg.solve_banded --version 1.0.0
```

## 3) Update: `loom set`
Update an existing field value.

```bash
loom set <field-path> [<value>] [--value-file <PATH>] [--type <string|int|float|bool|json>] [--operator <name>] [--version <semver>] [--impl <impl_id>]
```

Behavior:
- update only; fails if target does not exist
- no implicit create in Phase 1 (avoid hidden state changes)
- `--value-file` is preferred for updating Lean source blobs

Examples:
```bash
loom set math.spec.source --value-file ./formal/linalg_solve_banded.lean --operator linalg.solve_banded --version 1.0.0
loom set math.theorems.source --value-file ./formal/geospatial_reproject_theorems.lean --operator geospatial.reproject --version 1.1.0
```

## 4) Delete: `loom remove`
Delete a field or subtree.

```bash
loom remove <field-path> [--recursive] [--operator <name>] [--version <semver>] [--impl <impl_id>]
loom rm <field-path> ...
```

Behavior:
- default: remove single leaf field
- `--recursive`: remove object subtree
- alias: `rm`

Examples:
```bash
loom remove contract.parameters.legacy_tol --operator linalg.solve_banded --version 2.0.0
loom rm implementations.cuda-custom --recursive --operator geospatial.rasterize --version 1.0.0
```

## Consistency Rules
- Commands are explicit and non-ambiguous (`add` vs `set` are separated).
- Path resolution must be deterministic.
- Validation runs before write commit.
- On write success, output changed file list and normalized path.
- `--format json` output must be stable for automation.
- Any update under `math.*` must remain parsable and version-compatible with the pinned Lean4/Mathlib environment.

## Exit Codes
- `0`: success
- `2`: invalid arguments
- `3`: path/resource not found
- `4`: conflict (e.g., `add` on existing field)
- `5`: validation failed
- `10`: I/O or parse failure

## Phase 1 API Surface Summary
- `loom info`
- `loom add`
- `loom set`
- `loom remove` (`loom rm`)

This is sufficient for local metadata CRUD of operator identity, Lean4/Mathlib mathematical definition, contract definition, implementation definition, and provenance.

## Example Session
```bash
# Read Lean environment pin
loom info math.mathlib.version --operator linalg.solve_banded --version 1.0.0

# Create implementation ABI metadata
loom add implementations.fortran-lapack.interface.abi "lapack-f77" \
  --operator linalg.solve_banded --version 1.0.0

# Update formal Lean specification
loom set math.spec.source --value-file ./formal/solve_banded_spec.lean \
  --operator linalg.solve_banded --version 1.0.0

# Delete deprecated contract field
loom remove contract.parameters.old_flag \
  --operator linalg.solve_banded --version 1.0.0
```

## Next Phase (Out of Scope but Natural)
- `loom list` for key/index listing
- `loom validate` for schema, Lean checks, and invariants
- `loom diff` for semantic and contract changes
- `loom init` for scaffold generation
