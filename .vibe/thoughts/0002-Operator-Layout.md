# 0002 - Standard Operator Folder Layout (Draft)

This document assumes operators are pure functions.

## Boundary and Invariants
- Every operator must define: `identity`, `mathematical semantics`, `interface contract`, and `reproducibility evidence`.
- Mathematical semantics are canonicalized in `Lean4 + Mathlib`.
- Definition and implementation are separate: semantic meaning is stable first, implementation can evolve.
- Version is a first-class structural layer; no implicit overwrite in place.
- Each version must maintain both:
  - a canonical Lean4/Mathlib mathematical definition, and
  - one or more language/runtime-specific implementation definitions.

## Standard Directory Layout
Use an `operator name + versioned definitions` structure:

```text
operators/
  <operator_name>/
    operator.yaml
    README.md
    versions/
      <semver>/
        manifest.yaml
        math/
          intent.md
          spec.lean
          theorems.lean
          mathlib.yaml
          references.md
        contract/
          io.yaml
          parameters.yaml
          errors.yaml
        implementations/
          <impl_id>/
            impl.yaml
            interface.yaml
            numerics.yaml
            README.md
            bindings/
              <language_or_runtime>/
                abi.yaml
                notes.md
        tests/
          contract/
          lean/
          numeric/
        examples/
          <example_id>/
            case.yaml
            expected.yaml
        provenance/
          sources.yaml
          checksums.txt
```

## Required vs Optional Artifacts
`MUST`:
- `operator.yaml`: stable identity (`name`, `namespace`, `owner`, `license`, `homepage`).
- `versions/<semver>/manifest.yaml`: version entry (`version`, `status`, `compatibility`, `default_impl`).
- `math/spec.lean`: canonical operator definition (domain/codomain, symbols, constraints).
- `math/theorems.lean`: theorem statements for invariants and guarantees (with proof status).
- `math/mathlib.yaml`: Lean toolchain and Mathlib pin (`lean_version`, `mathlib_version`, module entrypoints).
- `contract/io.yaml` and `contract/parameters.yaml`: machine-readable function signature and parameter constraints.
- `implementations/<impl_id>/impl.yaml`: implementation identity, language/runtime, and algorithm class.
- `provenance/sources.yaml`: derivation and reference provenance.

`SHOULD`:
- `math/intent.md`: human-readable intent that matches Lean definitions.
- `contract/errors.yaml`: explicit failure semantics and stability guarantees.
- `implementations/<impl_id>/numerics.yaml`: precision model, conditioning assumptions, and tolerance policy.
- `tests/contract`, `tests/lean`, `tests/numeric`: tests aligned with structural boundaries.
- `examples/<example_id>`: minimal reproducible examples.

`MAY`:
- Multiple implementations under `implementations/*` for different languages, libraries, or hardware targets.
- Multiple binding metadata files under `bindings/*` for ABI/interface differences.

## Dual-Definition Model (Lean Mathematics + Runtime Implementation)
Each operator version keeps two synchronized definition layers:

1. Mathematical definition layer (`math/*`, Lean4 + Mathlib)
- `spec.lean` defines the canonical abstract operator.
- `theorems.lean` defines required semantic and numerical properties.
- `mathlib.yaml` pins the formal environment for reproducibility.

2. Implementation definition layer (`implementations/*`)
- Describes concrete executable forms and interface details.
- Captures language/runtime API, memory layout assumptions, ABI details, numeric behavior, and dependency requirements.

Rule: implementation metadata can vary by language/runtime, but each implementation must map to the same Lean definitions/theorems for that version (for example via `math_ref` entries in `impl.yaml`).

## Multi-Language and Multi-Runtime Space
The layout is intentionally open for heterogeneous execution:
- `implementations/fortran-lapack/`
- `implementations/julia-linearalgebra/`
- `implementations/cpp-eigen/`
- `implementations/rust-ndarray/`
- `implementations/cuda-custom/`

Each implementation can have its own binding metadata under `bindings/<language_or_runtime>/`, while sharing one versioned Lean4/Mathlib mathematical core.

## Domain Example Types
Linear algebra examples:
- Solve a banded linear system.
- Compute QR factorization.
- Estimate matrix condition number.

Geospatial examples:
- Reproject coordinates between CRS definitions.
- Compute geodesic distance on an ellipsoid.
- Rasterize vector polygons onto a grid.

In both domains, the same operator intent can have multiple implementation definitions with different language/runtime interfaces, all linked to one Lean formal definition.

## Evolution and Compatibility Rules
- New implementation only: update `implementations/*` without changing major version.
- Backward-compatible contract extension: bump minor version.
- Breaking contract change: bump major version and record `breaking_changes` in `manifest.yaml`.
- Any change to `math/spec.lean` or theorem interfaces must be evaluated as a semantic compatibility change.
- Before release, all contract and Lean checks must pass; numeric tests must pass for each implementation profile.

## Minimal First-Phase Adoption
Minimum viable set:
- `operator.yaml`
- `versions/<semver>/manifest.yaml`
- `versions/<semver>/math/spec.lean`
- `versions/<semver>/math/theorems.lean`
- `versions/<semver>/math/mathlib.yaml`
- `versions/<semver>/contract/parameters.yaml`
- `versions/<semver>/implementations/<impl_id>/impl.yaml`
- `versions/<semver>/provenance/sources.yaml`

Additional files can be introduced incrementally as operator complexity grows.
