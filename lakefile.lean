import Lake
open Lake DSL

package "numerical-analysis" where
  -- add package configuration options here

lean_lib «NumericalAnalysis» where
  -- add library configuration options here

@[default_target]
lean_exe "numerical-analysis" where
  root := `Main
