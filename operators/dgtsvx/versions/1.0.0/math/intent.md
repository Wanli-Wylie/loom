# DGTSVX intent

DGTSVX computes a solution matrix `X` for:
- `A * X = B` (no transpose), or
- `A^T * X = B` (transpose),

where `A` is a real tridiagonal matrix of order `N` and `B` has `NRHS` right
hand sides.

The operator also returns:
- `RCOND`: reciprocal condition estimate of `A`,
- `FERR`: forward error bounds (per right-hand side),
- `BERR`: backward error estimates (per right-hand side),
- `INFO`: status and failure code channel.

The canonical math operator in this version is represented by
`Loom.Operators.DGTSVX.solve` in `spec.lean`.
