def eulers_method (f : Float → Float → Float)
                  (i_time : Float)
                  (f_time : Float)
                  (n_meshpoints : Nat)
                  (y_0 : Float)
                  : List (Float × Float) :=
  let h := (f_time - i_time) / (n_meshpoints.toFloat) -- step size
  let rec loop (i : Nat) (t : Float) (y : Float) (acc : List (Float × Float)) : List (Float × Float) :=
    if h : i ≤ n_meshpoints then -- Use `i ≤ n_meshpoints` instead of `i > n_meshpoints`
      let new_acc := (t, y) :: acc -- prepend the new (t, y) pair
      let y_new := y + h * f t y -- update y using Euler's method
      let t_new := t + h -- update t
      loop (i + 1) t_new y_new new_acc
    else
      acc.reverse -- reverse to get the correct order
  termination_by loop i _ _ _ => n_meshpoints - i
  decreasing_by
    simp_wf -- Simplify the well-founded relation
    exact Nat.sub_lt (Nat.zero_le n_meshpoints) (Nat.lt_of_le_of_lt (Nat.zero_le i) (Nat.lt_succ_of_le h)) -- Termination proof
  loop 0 i_time y_0 [(i_time, y_0)] -- start the loop with initial values
