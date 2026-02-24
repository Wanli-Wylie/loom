# Fortran binding notes

- The exported symbol is typically `dgtsvx_` (toolchain dependent).
- All routine arguments are passed by reference.
- `INFO` carries success/error status and must be checked by callers.
