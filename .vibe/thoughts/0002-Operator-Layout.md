# 0002 - Standard Operator Folder Layout (Draft)

This document assumes operators are pure functions.

## Boundary and Invariants
- Every operator must define: `identity`, `mathematical semantics`, `interface contract`, and `reproducibility evidence`.
- Definition and implementation are separate: semantic meaning is stable first, implementation can evolve.
- Version is a first-class structural layer; no implicit overwrite in place.
- Each version must maintain both:
  - a language-agnostic mathematical definition, and
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
          formalism.yaml
          invariants.md
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
          semantic/
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
- `math/intent.md`: semantic intent in domain language.
- `math/formalism.yaml`: domain/codomain, symbols, preconditions, postconditions, and invariants.
- `contract/io.yaml` and `contract/parameters.yaml`: machine-readable function signature and parameter constraints.
- `implementations/<impl_id>/impl.yaml`: implementation identity, language/runtime, and algorithm class.
- `provenance/sources.yaml`: derivation and reference provenance.

`SHOULD`:
- `math/invariants.md`: detailed numerical or geometric invariants.
- `contract/errors.yaml`: explicit failure semantics and stability guarantees.
- `implementations/<impl_id>/numerics.yaml`: precision model, conditioning assumptions, and tolerance policy.
- `tests/contract`, `tests/semantic`, `tests/numeric`: tests aligned with structural boundaries.
- `examples/<example_id>`: minimal reproducible examples.

`MAY`:
- Multiple implementations under `implementations/*` for different languages, libraries, or hardware targets.
- Multiple binding metadata files under `bindings/*` for ABI/interface differences.

## Dual-Definition Model (Mathematics + Implementation)
Each operator version keeps two synchronized definition layers:

1. Mathematical definition layer (`math/*`)
- Describes the operator as an abstract mapping, independent of language and runtime.
- Captures symbols, admissible input sets, output guarantees, and invariants.

2. Implementation definition layer (`implementations/*`)
- Describes concrete executable forms and interface details.
- Captures language/runtime API, memory layout assumptions, ABI details, numeric behavior, and dependency requirements.

Rule: implementation metadata can vary by language/runtime, but it must trace back to the same mathematical definition in `math/*` for that version.

## Multi-Language and Multi-Runtime Space
The layout is intentionally open for heterogeneous execution:
- `implementations/fortran-lapack/`
- `implementations/julia-linearalgebra/`
- `implementations/cpp-eigen/`
- `implementations/rust-ndarray/`
- `implementations/cuda-custom/`

Each implementation can have its own binding metadata under `bindings/<language_or_runtime>/`, while sharing one versioned mathematical core.

## Domain Example Types
Linear algebra examples:
- Solve a banded linear system.
- Compute QR factorization.
- Estimate matrix condition number.

Geospatial examples:
- Reproject coordinates between CRS definitions.
- Compute geodesic distance on an ellipsoid.
- Rasterize vector polygons onto a grid.

In both domains, the same operator intent can have multiple implementation definitions with different language/runtime interfaces.

## Evolution and Compatibility Rules
- New implementation only: update `implementations/*` without changing major version.
- Backward-compatible contract extension: bump minor version.
- Breaking contract change: bump major version and record `breaking_changes` in `manifest.yaml`.
- Before release, all contract and semantic tests must pass; numeric tests must pass for each implementation profile.

## Minimal First-Phase Adoption
Minimum viable set:
- `operator.yaml`
- `versions/<semver>/manifest.yaml`
- `versions/<semver>/math/intent.md`
- `versions/<semver>/math/formalism.yaml`
- `versions/<semver>/contract/parameters.yaml`
- `versions/<semver>/implementations/<impl_id>/impl.yaml`
- `versions/<semver>/provenance/sources.yaml`

Additional files can be introduced incrementally as operator complexity grows.
