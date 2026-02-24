# Operator Package Manager: loom

This project is a package manager for computational operators.

An *operator* is a reusable unit of computation with:
- a declared interface (inputs/outputs),
- a stable semantic intent (what the transformation means),
- and an explicit effect boundary (what it may read or change outside its inputs/outputs).

The goal is to make operators as easy to **publish, discover, install, version, verify, and reuse** as libraries are in modern package ecosystems—while staying neutral to languages, runtimes, and execution environments.

## Why operators as first-class artifacts

Modern software is increasingly built by assembling small transformations: data operators, scientific operators, media operators, ML operators, spatial operators, etc. These operators exist today, but they are often:
- scattered across repos and scripts,
- hard to search by capability or interface,
- difficult to reproduce across machines and time,
- coupled to a specific runtime or project structure,
- and opaque to tooling (no machine-readable semantics or effects).

Treating operators as first-class artifacts turns “a function somewhere” into “a managed object with identity, interface, semantics, and provenance”.

## Core philosophy

1) Semantics before implementation  
An operator is defined by *what it does*, not by how it is currently implemented. Multiple implementations may exist for the same operator intent.

2) Pure functions as the default anchor  
The most stable form of computation is a deterministic transformation from inputs to outputs. When effects are unavoidable, they should be declared explicitly rather than hidden.

3) Explicit boundaries enable composition  
Clear interfaces and effect declarations make operators composable, testable, cacheable, replaceable, and analyzable.

4) Reproducibility is a first-class requirement  
Resolving “which operators” a project uses should be deterministic and auditable, enabling exact re-creation of a computational environment.

5) Tool-agnostic and language-agnostic  
The system should not assume a single programming language, runtime, or deployment model. Operators are artifacts that can be executed in different contexts.

6) Minimal core, extensible ecosystem  
The core focuses on identity, metadata, resolution, and reproducibility. Higher-level concerns (workflows, orchestration, scheduling, UI) should remain optional and pluggable.

## What success looks like

- Operators can be searched by interface, domain tags, and declared properties.
- Operators can be installed and pinned with reproducible resolution.
- Operators can be composed safely because their boundaries are explicit.
- Operators can evolve via versioning without breaking the ecosystem silently.
- Operators can be compared, replaced, and verified based on declared semantics and effects.
- A shared operator ecosystem emerges across projects and domains.

## Non-goals

- Not a workflow engine or orchestrator.
- Not a new programming language.
- Not a monolithic registry requirement; distribution models should remain flexible.
- Not a replacement for existing package managers; it complements them by managing computational *units* rather than general-purpose libraries.

## Guiding principle

Make computation modular by making operators manageable.
