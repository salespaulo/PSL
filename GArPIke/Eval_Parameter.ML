(*  Title:      PSL/SeLFiE/src/Eval_Parameter.ML
    Author:     Yutaka Nagashima, Czech Technical University in Prague, the University of Innsbruck
*)

(*** signature EVAL_PARAMETER ***)
signature EVAL_PARAMETER =
sig

datatype non_path_literal =
  Bool    of bool
| Print   of string
| Number  of int
| Command of Definition_Pattern.command;

datatype literal =
  Outer_Path of outer_path
| Inner_Path of UN.inner_path
| Non_Path   of non_path_literal;

type literals = literal list;

val eval: Proof.state -> Gen_Path.gen_path_to_unode_table -> SeLFiE_Util.induct_arguments -> SeLFiE_Util.atomic_assert -> literals -> Eval_Bool.assert;

end;

(*** structure Eval_Parameter ***)
structure Eval_Parameter: EVAL_PARAMETER =
struct

structure PA   = Path_Assert;
structure EPT  = Eval_Path;
structure EPR  = Eval_Print;
structure ENMB = Eval_Number;
structure SU   = SeLFiE_Util;
structure GP   = Gen_Path;

datatype non_path_literal =
  Bool    of bool
| Print   of string
| Number  of int
| Command of Definition_Pattern.command;

datatype literal =
  Outer_Path of outer_path
| Inner_Path of UN.inner_path
| Non_Path   of non_path_literal;

type literals = literal list;

fun eval pst term_tables induct_args assert literals =
  let
    val ctxt = Proof.context_of pst;
    fun
      (*Eval_Node (Outer)*)
        eval' SU.Node_Is_Cnst                     [Outer_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Cnst                     (GP.Outer_Path p))
      | eval' SU.Node_Is_Free                     [Outer_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Free                     (GP.Outer_Path p))
      | eval' SU.Node_Is_Var                      [Outer_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Var                      (GP.Outer_Path p))
      | eval' SU.Node_Is_Bound                    [Outer_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Bound                    (GP.Outer_Path p))
      | eval' SU.Node_Is_Lambda                   [Outer_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Lambda                   (GP.Outer_Path p))
      | eval' SU.Node_Is_App                      [Outer_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_App                      (GP.Outer_Path p))
      | eval' SU.Node_Is_Defined_With             [Outer_Path path,       Non_Path (Command cmd)] = EPT.eval pst term_tables (PA.Node_Is_Defined_With             (GP.Outer_Path path, cmd))
      | eval' SU.Node_Is_Defined_With_N_Clauses   [Outer_Path path,       Non_Path (Number n)   ] = EPT.eval pst term_tables (PA.Node_Is_Defined_With_N_Clauses   (GP.Outer_Path path, n))
      | eval' SU.Is_Rule_Of_Node                  [Non_Path (Print rule), Outer_Path path       ] = EPT.eval pst term_tables (PA.Is_Rule_Of_Node                  (rule, GP.Outer_Path path))
      | eval' SU.Is_Set_Of_Node                   [Non_Path (Print rule), Outer_Path path       ] = EPT.eval pst term_tables (PA.Is_Set_Of_Node                   (rule, GP.Outer_Path path))
      | eval' SU.Node_Takes_N_Arguments           [Outer_Path path,       Non_Path (Number n)   ] = EPT.eval pst term_tables (PA.Node_Takes_N_Arguments           (GP.Outer_Path path, n))
      | eval' SU.Node_Takes_Less_Than_N_Arguments [Outer_Path path,       Non_Path (Number n)   ] = EPT.eval pst term_tables (PA.Node_Takes_Less_Than_N_Arguments (GP.Outer_Path path, n))
      (*Eval_Node (Inner)*)
      | eval' SU.Node_Is_Cnst                     [Inner_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Cnst                     (GP.Inner_Path p))
      | eval' SU.Node_Is_Free                     [Inner_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Free                     (GP.Inner_Path p))
      | eval' SU.Node_Is_Var                      [Inner_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Var                      (GP.Inner_Path p))
      | eval' SU.Node_Is_Bound                    [Inner_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Bound                    (GP.Inner_Path p))
      | eval' SU.Node_Is_Lambda                   [Inner_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_Lambda                   (GP.Inner_Path p))
      | eval' SU.Node_Is_App                      [Inner_Path p]                                  = EPT.eval pst term_tables (PA.Node_Is_App                      (GP.Inner_Path p))
      | eval' SU.Node_Is_Defined_With             [Inner_Path path,       Non_Path (Command cmd)] = EPT.eval pst term_tables (PA.Node_Is_Defined_With             (GP.Inner_Path path, cmd))
      | eval' SU.Node_Is_Defined_With_N_Clauses   [Inner_Path path,       Non_Path (Number n)   ] = EPT.eval pst term_tables (PA.Node_Is_Defined_With_N_Clauses   (GP.Inner_Path path,  n))
      | eval' SU.Is_Rule_Of_Node                  [Non_Path (Print rule), Inner_Path path       ] = EPT.eval pst term_tables (PA.Is_Rule_Of_Node                  (rule, GP.Inner_Path path))
      | eval' SU.Is_Set_Of_Node                   [Non_Path (Print set),  Inner_Path path       ] = EPT.eval pst term_tables (PA.Is_Set_Of_Node                   (set,  GP.Inner_Path path))
      | eval' SU.Node_Takes_N_Arguments           [Inner_Path path,       Non_Path (Number n)   ] = EPT.eval pst term_tables (PA.Node_Takes_N_Arguments           (GP.Inner_Path path, n))
      | eval' SU.Node_Takes_Less_Than_N_Arguments [Inner_Path path,       Non_Path (Number n)   ] = EPT.eval pst term_tables (PA.Node_Takes_Less_Than_N_Arguments (GP.Inner_Path path, n))
      (*Eval_Unode (Outer)*)
      | eval' SU.Has_Same_Prnt_As       [Outer_Path p1, Outer_Path p2]       = EPT.eval pst term_tables (PA.Has_Same_Prnt_As       (GP.Outer_Path p1, GP.Outer_Path p2))
      | eval' SU.Is_Deeper_Than         [Outer_Path p1, Outer_Path p2]       = EPT.eval pst term_tables (PA.Is_Deeper_Than         (GP.Outer_Path p1, GP.Outer_Path p2))
      | eval' SU.Is_Shallower_Than      [Outer_Path p1, Outer_Path p2]       = EPT.eval pst term_tables (PA.Is_Shallower_Than      (GP.Outer_Path p1, GP.Outer_Path p2))
      | eval' SU.Is_Nth_Child           [Outer_Path p,  Non_Path (Number n)] = EPT.eval pst term_tables (PA.Is_Nth_Child           (GP.Outer_Path p,  n ))
      | eval' SU.Is_N_Plus_One_th_Child [Outer_Path p,  Non_Path (Number n)] = EPT.eval pst term_tables (PA.Is_N_Plus_One_th_Child (GP.Outer_Path p,  n ))
      | eval' SU.Is_Root_In_A_Location  [Outer_Path p]                       = EPT.eval pst term_tables (PA.Is_Root_In_A_Location  (GP.Outer_Path p))
      (*Eval_Unode (Inner)*)
      | eval' SU.Has_Same_Prnt_As       [Inner_Path p1, Inner_Path p2]       = EPT.eval pst term_tables (PA.Has_Same_Prnt_As       (GP.Inner_Path p1, GP.Inner_Path p2))
      | eval' SU.Is_Deeper_Than         [Inner_Path p1, Inner_Path p2]       = EPT.eval pst term_tables (PA.Is_Deeper_Than         (GP.Inner_Path p1, GP.Inner_Path p2))
      | eval' SU.Is_Shallower_Than      [Inner_Path p1, Inner_Path p2]       = EPT.eval pst term_tables (PA.Is_Shallower_Than      (GP.Inner_Path p1, GP.Inner_Path p2))
      | eval' SU.Is_Nth_Child           [Inner_Path p,  Non_Path (Number n)] = EPT.eval pst term_tables (PA.Is_Nth_Child           (GP.Inner_Path p,  n ))
      | eval' SU.Is_N_Plus_One_th_Child [Inner_Path p,  Non_Path (Number n)] = EPT.eval pst term_tables (PA.Is_N_Plus_One_th_Child (GP.Inner_Path p,  n))
      | eval' SU.Is_Root_In_A_Location  [Inner_Path p]                       = EPT.eval pst term_tables (PA.Is_Root_In_A_Location  (GP.Inner_Path p))
      (*Eval_Path (Outer)*)
      | eval' SU.Unode_Has_Print                          [Outer_Path p, Non_Path (Print str)]              = EPT.eval pst term_tables (PA.Unode_Has_Print                          (GP.Outer_Path p, str))
      | eval' SU.Is_In_Subgoal                            [Outer_Path p]                                    = EPT.eval pst term_tables (PA.Is_In_Subgoal                            (GP.Outer_Path p))
      | eval' SU.Is_In_Chained_Fact                       [Outer_Path p]                                    = EPT.eval pst term_tables (PA.Is_In_Chained_Fact                       (GP.Outer_Path p))
      | eval' SU.Is_In_Nth_Subgoal                        [Outer_Path p, Non_Path (Number n)]               = EPT.eval pst term_tables (PA.Is_In_Nth_Subgoal                        (GP.Outer_Path p,  n))
      | eval' SU.Is_In_Nth_Chained_Fact                   [Outer_Path p, Non_Path (Number n)]               = EPT.eval pst term_tables (PA.Is_In_Nth_Chained_Fact                   (GP.Outer_Path p,  n))
      | eval' SU.Are_In_Same_Location                     [Outer_Path p1, Outer_Path p2]                    = EPT.eval pst term_tables (PA.Are_In_Same_Location                     (GP.Outer_Path p1, GP.Outer_Path p2))
      | eval' SU.Is_Parent_Of                             [Outer_Path p,  Outer_Path c]                     = EPT.eval pst term_tables (PA.Is_Parent_Of                             (GP.Outer_Path p,  GP.Outer_Path c))
      | eval' SU.Is_Path_Above                            [Outer_Path p1, Outer_Path p2]                    = EPT.eval pst term_tables (PA.Is_Path_Above                            (GP.Outer_Path p1, GP.Outer_Path p2))
      | eval' SU.Is_Same_Path_As                          [Outer_Path p1, Outer_Path p2]                    = EPT.eval pst term_tables (PA.Is_Same_Path_As                          (GP.Outer_Path p1, GP.Outer_Path p2))
      | eval' SU.Is_An_Argument_Of                        [Outer_Path a, Outer_Path f]                      = EPT.eval pst term_tables (PA.Is_An_Argument_Of                        (GP.Outer_Path a,  GP.Outer_Path f))
      | eval' SU.Is_An_Argument_Or_Below_Argument_Of      [Outer_Path a, Outer_Path f]                      = EPT.eval pst term_tables (PA.Is_An_Argument_Or_Below_Argument_Of      (GP.Outer_Path a,  GP.Outer_Path f))
      | eval' SU.Is_Below_N_Plus_One_th_Child_Of          [Outer_Path d, Non_Path (Number n), Outer_Path a] = EPT.eval pst term_tables (PA.Is_Below_N_Plus_One_th_Child_Of          (GP.Outer_Path d,  n, GP.Outer_Path a))
      | eval' SU.Is_Nth_Child_Or_Below_Nth_Child_Of       [Outer_Path d, Non_Path (Number n), Outer_Path a] = EPT.eval pst term_tables (PA.Is_Nth_Child_Or_Below_Nth_Child_Of       (GP.Outer_Path d,  n, GP.Outer_Path a))
      | eval' SU.Is_Nth_Argument_Of                       [Outer_Path a, Non_Path (Number n), Outer_Path f] = EPT.eval pst term_tables (PA.Is_Nth_Argument_Of                       (GP.Outer_Path a,  n, GP.Outer_Path f))
      | eval' SU.Is_Nth_Argument_Or_Below_Nth_Argument_Of [Outer_Path a, Non_Path (Number n), Outer_Path f] = EPT.eval pst term_tables (PA.Is_Nth_Argument_Or_Below_Nth_Argument_Of (GP.Outer_Path a,  n, GP.Outer_Path f))
      | eval' SU.Is_A_Meta_Premise                        [Outer_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Premise                        (GP.Outer_Path p))
      | eval' SU.Is_A_Meta_Conclusion                     [Outer_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Conclusion                     (GP.Outer_Path p))
      | eval' SU.Is_A_Meta_Premise_Or_Below               [Outer_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Premise_Or_Below               (GP.Outer_Path p))
      | eval' SU.Is_A_Meta_Conclusion_Or_Below            [Outer_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Conclusion_Or_Below            (GP.Outer_Path p))
      | eval' SU.Unode_Has_As_Subprint                    [Outer_Path p, Non_Path (Print str)]              = EPT.eval pst term_tables (PA.Unode_Has_As_Subprint                    (GP.Outer_Path p,  str))
      (*Eval_Path (Inner)*)
      | eval' SU.Unode_Has_Print                          [Inner_Path p, Non_Path (Print str)]              = EPT.eval pst term_tables (PA.Unode_Has_Print                          (GP.Inner_Path p, str))
      | eval' SU.Is_In_Subgoal                            [Inner_Path p]                                    = EPT.eval pst term_tables (PA.Is_In_Subgoal                            (GP.Inner_Path p))
      | eval' SU.Is_In_Chained_Fact                       [Inner_Path p]                                    = EPT.eval pst term_tables (PA.Is_In_Chained_Fact                       (GP.Inner_Path p))
      | eval' SU.Is_In_Nth_Subgoal                        [Inner_Path p, Non_Path (Number n)]               = EPT.eval pst term_tables (PA.Is_In_Nth_Subgoal                        (GP.Inner_Path p, n))
      | eval' SU.Is_In_Nth_Chained_Fact                   [Inner_Path p, Non_Path (Number n)]               = EPT.eval pst term_tables (PA.Is_In_Nth_Chained_Fact                   (GP.Inner_Path p, n))
      | eval' SU.Are_In_Same_Location                     [Inner_Path p1, Inner_Path p2]                    = EPT.eval pst term_tables (PA.Are_In_Same_Location                     (GP.Inner_Path p1, GP.Inner_Path p2))
      | eval' SU.Is_Parent_Of                             [Inner_Path p,  Inner_Path c]                     = EPT.eval pst term_tables (PA.Is_Parent_Of                             (GP.Inner_Path p,  GP.Inner_Path c))
      | eval' SU.Is_Path_Above                            [Inner_Path p1, Inner_Path p2]                    = EPT.eval pst term_tables (PA.Is_Path_Above                            (GP.Inner_Path p1, GP.Inner_Path p2))
      | eval' SU.Is_Same_Path_As                          [Inner_Path p1, Inner_Path p2]                    = EPT.eval pst term_tables (PA.Is_Same_Path_As                          (GP.Inner_Path p1, GP.Inner_Path p2))
      | eval' SU.Is_An_Argument_Of                        [Inner_Path a,  Inner_Path f]                     = EPT.eval pst term_tables (PA.Is_An_Argument_Of                        (GP.Inner_Path a,  GP.Inner_Path f))
      | eval' SU.Is_An_Argument_Or_Below_Argument_Of      [Inner_Path a,  Inner_Path f]                     = EPT.eval pst term_tables (PA.Is_An_Argument_Or_Below_Argument_Of      (GP.Inner_Path a,  GP.Inner_Path f))
      | eval' SU.Is_Below_N_Plus_One_th_Child_Of          [Inner_Path d, Non_Path (Number n), Inner_Path a] = EPT.eval pst term_tables (PA.Is_Below_N_Plus_One_th_Child_Of          (GP.Inner_Path d,  n, GP.Inner_Path a))
      | eval' SU.Is_Nth_Child_Or_Below_Nth_Child_Of       [Inner_Path d, Non_Path (Number n), Inner_Path a] = EPT.eval pst term_tables (PA.Is_Nth_Child_Or_Below_Nth_Child_Of       (GP.Inner_Path d,  n, GP.Inner_Path a))
      | eval' SU.Is_Nth_Argument_Of                       [Inner_Path a, Non_Path (Number n), Inner_Path f] = EPT.eval pst term_tables (PA.Is_Nth_Argument_Of                       (GP.Inner_Path a,  n, GP.Inner_Path f))
      | eval' SU.Is_Nth_Argument_Or_Below_Nth_Argument_Of [Inner_Path a, Non_Path (Number n), Inner_Path f] = EPT.eval pst term_tables (PA.Is_Nth_Argument_Or_Below_Nth_Argument_Of (GP.Inner_Path a,  n, GP.Inner_Path f))
      | eval' SU.Is_A_Meta_Premise                        [Inner_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Premise                        (GP.Inner_Path p))
      | eval' SU.Is_A_Meta_Conclusion                     [Inner_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Conclusion                     (GP.Inner_Path p))
      | eval' SU.Is_A_Meta_Premise_Or_Below               [Inner_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Premise_Or_Below               (GP.Inner_Path p))
      | eval' SU.Is_A_Meta_Conclusion_Or_Below            [Inner_Path p]                                    = EPT.eval pst term_tables (PA.Is_A_Meta_Conclusion_Or_Below            (GP.Inner_Path p))
      | eval' SU.Unode_Has_As_Subprint                    [Inner_Path p, Non_Path (Print str)]              = EPT.eval pst term_tables (PA.Unode_Has_As_Subprint                    (GP.Inner_Path p,  str))
      (*Eval_Print*)
      | eval' SU.Are_Same_Prints  [Non_Path (Print p1), Non_Path (Print p2)] = EPR.eval (EPR.Are_Same_Prints (p1, p2))  induct_args ctxt
      | eval' SU.Is_Subprint_Of   [Non_Path (Print p1), Non_Path (Print p2)] = EPR.eval (EPR.Is_Subprint_Of  (p1, p2))  induct_args ctxt
      | eval' SU.Is_Nth_Induct    [Non_Path (Print p),  Non_Path (Number n)] = EPR.eval (EPR.Is_Nth_Induct (p, n))      induct_args ctxt
      | eval' SU.Is_Nth_Arbitrary [Non_Path (Print p),  Non_Path (Number n)] = EPR.eval (EPR.Is_Nth_Arbitrary (p, n))   induct_args ctxt
      | eval' SU.Is_Induct        [Non_Path (Print p)]                       = EPR.eval (EPR.Is_Induct p)               induct_args ctxt
      | eval' SU.Is_Arbitrary     [Non_Path (Print p)]                       = EPR.eval (EPR.Is_Arbitrary p)            induct_args ctxt
      | eval' SU.Is_Rule          [Non_Path (Print p)]                       = EPR.eval (EPR.Is_Rule p)                 induct_args ctxt
      | eval' SU.Is_Rule_Of_Print [Non_Path (Print p1), Non_Path (Print p2)] = EPR.eval (EPR.Is_Rule_Of_Print (p1, p2)) induct_args ctxt
      | eval' SU.Is_Set           [Non_Path (Print p)]                       = EPR.eval (EPR.Is_Set p)                  induct_args ctxt
      | eval' SU.Is_Set_Of_Print  [Non_Path (Print p1), Non_Path (Print p2)] = EPR.eval (EPR.Is_Set_Of_Print  (p1, p2)) induct_args ctxt
      (*Eval_Print node*)
      | eval' SU.Print_Is_Cnst                     [Non_Path (Print print)]                          = EPR.eval (EPR.Print_Is_Cnst   print) induct_args ctxt
      | eval' SU.Print_Is_Free                     [Non_Path (Print print)]                          = EPR.eval (EPR.Print_Is_Free   print) induct_args ctxt
      | eval' SU.Print_Is_Var                      [Non_Path (Print print)]                          = EPR.eval (EPR.Print_Is_Var    print) induct_args ctxt
      | eval' SU.Print_Is_Bound                    [Non_Path (Print print)]                          = EPR.eval (EPR.Print_Is_Bound  print) induct_args ctxt
      | eval' SU.Print_Is_Lambda                   [Non_Path (Print print)]                          = EPR.eval (EPR.Print_Is_Lambda print) induct_args ctxt
      | eval' SU.Print_Is_App                      [Non_Path (Print print)]                          = EPR.eval (EPR.Print_Is_App    print) induct_args ctxt
      | eval' SU.Print_Is_Defined_With             [Non_Path (Print print), Non_Path (Command cmd )] = EPR.eval (EPR.Print_Is_Defined_With             (print, cmd )) induct_args ctxt
      | eval' SU.Print_Is_Defined_With_N_Clauses   [Non_Path (Print print), Non_Path (Number  numb)] = EPR.eval (EPR.Print_Is_Defined_With_N_Clauses   (print, numb)) induct_args ctxt
      | eval' SU.Print_Takes_N_Arguments           [Non_Path (Print print), Non_Path (Number  numb)] = EPR.eval (EPR.Print_Takes_N_Arguments           (print, numb)) induct_args ctxt
      | eval' SU.Print_Takes_Less_Than_N_Arguments [Non_Path (Print print), Non_Path (Number  numb)] = EPR.eval (EPR.Print_Takes_Less_Than_N_Arguments (print, numb)) induct_args ctxt
      (*Eval_Number*)
      | eval' SU.Are_Same_Number     [Non_Path (Number numb1), Non_Path (Number numb2)] = ENMB.eval (ENMB.Are_Same_Number     (numb1, numb2))
      | eval' SU.Is_Less_Than        [Non_Path (Number numb1), Non_Path (Number numb2)] = ENMB.eval (ENMB.Is_Less_Than        (numb1, numb2))
      | eval' SU.Is_Less_Than_By_One [Non_Path (Number numb1), Non_Path (Number numb2)] = ENMB.eval (ENMB.Is_Less_Than_By_One (numb1, numb2))
      (*debug*)
      | eval' SU.Debug_Non_Path_Literal [Non_Path (Bool    b)] = (tracing ("Debug Bool       : " ^ (if b then "true" else "false"   ));  Eval_Bool.True)
      | eval' SU.Debug_Non_Path_Literal [Non_Path (Print   p)] = (tracing ("Debug Print      : " ^ p                                 );  Eval_Bool.True)
      | eval' SU.Debug_Non_Path_Literal [Non_Path (Number  n)] = (tracing ("Debug Number     : " ^ Int.toString n                    );  Eval_Bool.True)
      | eval' SU.Debug_Non_Path_Literal [Non_Path (Command c)] = (tracing ("Debug Number     : " ^ Definition_Pattern.print_command c);  Eval_Bool.True)
      | eval' SU.Debug_Print_Unode      [Outer_Path p]         = (EPT.eval pst term_tables (PA.Debug_Print_Unode (GP.Outer_Path p)); Eval_Bool.True)
      | eval' SU.Debug_Print_Unode      [Inner_Path p]         = (EPT.eval pst term_tables (PA.Debug_Print_Unode (GP.Inner_Path p)); Eval_Bool.True)
      | eval' assert _ = error ("- eval' in Eval_Parameter.ML failed at " ^ SU.print_atomic_assert assert);
  in
    eval' assert literals: Eval_Bool.assert
  end;

end;