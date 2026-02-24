/- Canonical semantic definition for DGTSVX. -/

namespace Loom.Operators.DGTSVX

inductive TransposeMode where
  | noTranspose
  | transpose
  | conjugateTranspose
deriving Repr, DecidableEq

structure Problem where
  n : Nat
  nrhs : Nat
  mode : TransposeMode
  dl : Array Float
  d : Array Float
  du : Array Float
  b : Array Float
deriving Repr

def Problem.wellFormed (p : Problem) : Prop :=
  p.dl.size = p.n - 1 /\
  p.d.size = p.n /\
  p.du.size = p.n - 1 /\
  p.b.size = p.n * p.nrhs

structure Result where
  x : Array Float
  rcond : Float
  ferr : Array Float
  berr : Array Float
  info : Int
deriving Repr

def Result.wellFormed (p : Problem) (r : Result) : Prop :=
  r.x.size = p.n * p.nrhs /\
  r.ferr.size = p.nrhs /\
  r.berr.size = p.nrhs

constant solve : Problem -> Result

end Loom.Operators.DGTSVX
