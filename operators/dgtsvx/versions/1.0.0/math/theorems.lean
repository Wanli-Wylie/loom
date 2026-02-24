/- Theorem declarations for DGTSVX semantic guarantees. -/

namespace Loom.Operators.DGTSVX

axiom solve_preserves_output_shape :
  forall p : Problem, p.wellFormed -> (solve p).wellFormed p

axiom ferr_nonnegative :
  forall p : Problem, p.wellFormed ->
    forall i : Nat, i < p.nrhs -> 0.0 <= (solve p).ferr.get! i

axiom berr_nonnegative :
  forall p : Problem, p.wellFormed ->
    forall i : Nat, i < p.nrhs -> 0.0 <= (solve p).berr.get! i

axiom rcond_nonnegative :
  forall p : Problem, p.wellFormed -> 0.0 <= (solve p).rcond

axiom info_semantics :
  forall p : Problem, p.wellFormed ->
    let info := (solve p).info
    info = 0 \/ info = Int.ofNat (p.n + 1) \/ (0 < info /\ info <= Int.ofNat p.n)

end Loom.Operators.DGTSVX
