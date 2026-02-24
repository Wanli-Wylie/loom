# dgtsvx

This operator definition is mapped from `examples/dgtsvx.json` using the
standard structure from `.vibe/thoughts/0002-Operator-Layout.md`.

## Intent

`dgtsvx` solves a real tridiagonal linear system (`A * X = B` or `A^T * X = B`)
using LU factorization, and returns solution quality signals (`RCOND`, `FERR`,
`BERR`) in addition to `X`.
