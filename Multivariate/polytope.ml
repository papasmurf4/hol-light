(* ========================================================================= *)
(* Faces, extreme points, polytopes, polyhedra etc.                          *)
(* ========================================================================= *)

needs "Multivariate/paths.ml";;

(* ------------------------------------------------------------------------- *)
(* Faces of a (usually convex) set.                                          *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("face_of",(12,"right"));;

let face_of = new_definition
 `t face_of s <=>
        t SUBSET s /\ convex t /\
        !a b x. a IN s /\ b IN s /\ x IN t /\ x IN segment(a,b)
                ==> a IN t /\ b IN t`;;

let FACE_OF_TRANSLATION_EQ = prove
 (`!a f s:real^N->bool.
        (IMAGE (\x. a + x) f) face_of (IMAGE (\x. a + x) s) <=> f face_of s`,
  REWRITE_TAC[face_of] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [FACE_OF_TRANSLATION_EQ];;

let FACE_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N c s.
      linear f /\ (!x y. f x = f y ==> x = y)
      ==> ((IMAGE f c) face_of (IMAGE f s) <=> c face_of s)`,
  REWRITE_TAC[face_of; IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_IMAGE] THEN
  REPEAT STRIP_TAC THEN MP_TAC(end_itlist CONJ
   (mapfilter (ISPEC `f:real^M->real^N`) (!invariant_under_linear))) THEN
  ASM_REWRITE_TAC[] THEN DISCH_TAC THEN ASM_REWRITE_TAC[]);;

add_linear_invariants [FACE_OF_LINEAR_IMAGE];;

let FACE_OF_REFL = prove
 (`!s. convex s ==> s face_of s`,
  SIMP_TAC[face_of] THEN SET_TAC[]);;

let FACE_OF_REFL_EQ = prove
 (`!s. s face_of s <=> convex s`,
  SIMP_TAC[face_of] THEN SET_TAC[]);;

let EMPTY_FACE_OF = prove
 (`!s. {} face_of s`,
  REWRITE_TAC[face_of; CONVEX_EMPTY] THEN SET_TAC[]);;

let FACE_OF_EMPTY = prove
 (`!s. s face_of {} <=> s = {}`,
  REWRITE_TAC[face_of; SUBSET_EMPTY; NOT_IN_EMPTY] THEN
  MESON_TAC[CONVEX_EMPTY]);;

let FACE_OF_TRANS = prove
 (`!s t u. s face_of t /\ t face_of u
           ==> s face_of u`,
  REWRITE_TAC[face_of] THEN SET_TAC[]);;

let FACE_OF_FACE = prove
 (`!f s t.
        t face_of s
        ==> (f face_of t <=> f face_of s /\ f SUBSET t)`,
  REWRITE_TAC[face_of] THEN SET_TAC[]);;

let FACE_OF_SUBSET = prove
 (`!f s t. f face_of s /\ f SUBSET t /\ t SUBSET s ==> f face_of t`,
  REWRITE_TAC[face_of] THEN SET_TAC[]);;

let FACE_OF_SLICE = prove
 (`!f s t.
        f face_of s /\ convex t
        ==> (f INTER t) face_of (s INTER t)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[face_of; IN_INTER] THEN STRIP_TAC THEN
  REPEAT CONJ_TAC THENL
   [ASM SET_TAC[];
    ASM_MESON_TAC[CONVEX_INTER];
    ASM_MESON_TAC[]]);;

let FACE_OF_INTER = prove
 (`!s t1 t2. t1 face_of s /\ t2 face_of s
             ==> (t1 INTER t2) face_of s`,
  SIMP_TAC[face_of; CONVEX_INTER] THEN SET_TAC[]);;

let FACE_OF_INTERS = prove
 (`!P s. ~(P = {}) /\ (!t. t IN P ==> t face_of s)
         ==> (INTERS P) face_of s`,
  REWRITE_TAC[face_of] THEN REPEAT STRIP_TAC THENL
   [ASM SET_TAC[]; ASM_SIMP_TAC[CONVEX_INTERS]; ASM SET_TAC[]; ASM SET_TAC[]]);;

let FACE_OF_INTER_INTER = prove
 (`!f t f' t'.
     f face_of t /\ f' face_of t' ==> (f INTER f') face_of (t INTER t')`,
  REWRITE_TAC[face_of; SUBSET; IN_INTER] THEN MESON_TAC[CONVEX_INTER]);;

let FACE_OF_STILLCONVEX = prove
 (`!s t:real^N->bool.
        convex s
        ==> (t face_of s <=>
             t SUBSET s /\
             convex(s DIFF t) /\
             t = (affine hull t) INTER s)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[face_of] THEN
  ASM_CASES_TAC `(t:real^N->bool) SUBSET s` THEN ASM_REWRITE_TAC[] THEN
  EQ_TAC THEN STRIP_TAC THENL
   [CONJ_TAC THENL
     [REPEAT(POP_ASSUM MP_TAC) THEN
      REWRITE_TAC[CONVEX_CONTAINS_SEGMENT; open_segment; IN_DIFF] THEN
      REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; SUBSET_DIFF] THEN SET_TAC[];
      ALL_TAC] THEN
    REWRITE_TAC[EXTENSION] THEN X_GEN_TAC `x:real^N` THEN EQ_TAC THENL
     [ASM MESON_TAC[HULL_INC; SUBSET; IN_INTER]; ALL_TAC] THEN
    ASM_CASES_TAC `t:real^N -> bool = {}` THEN
    ASM_REWRITE_TAC[IN_INTER; AFFINE_HULL_EMPTY; NOT_IN_EMPTY] THEN
    MP_TAC(ISPEC `t:real^N->bool` RELATIVE_INTERIOR_EQ_EMPTY) THEN
    ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `y:real^N` THEN REWRITE_TAC[IN_RELATIVE_INTERIOR_CBALL] THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
    DISCH_THEN(X_CHOOSE_THEN `e:real` STRIP_ASSUME_TAC) THEN
    STRIP_TAC THEN ASM_CASES_TAC `x:real^N = y` THEN ASM_REWRITE_TAC[] THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`x:real^N`; `y:real^N`]) THEN
    REWRITE_TAC[] THEN ONCE_REWRITE_TAC[SEGMENT_SYM] THEN
    ASM_SIMP_TAC[LEFT_FORALL_IMP_THM; OPEN_SEGMENT_ALT] THEN
    ANTS_TAC THENL [ALL_TAC; SIMP_TAC[]] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[SUBSET]) THEN ASM_SIMP_TAC[] THEN
    ASM_REWRITE_TAC[] THEN ONCE_REWRITE_TAC[CONJ_SYM] THEN
    REWRITE_TAC[EXISTS_IN_GSPEC] THEN
    EXISTS_TAC `min (&1 / &2) (e / norm(x - y:real^N))` THEN
    REWRITE_TAC[REAL_LT_MIN; REAL_MIN_LT] THEN
    CONV_TAC REAL_RAT_REDUCE_CONV THEN
    ASM_SIMP_TAC[REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ] THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN REWRITE_TAC[IN_INTER; IN_CBALL; dist] THEN
    CONJ_TAC THENL
     [REWRITE_TAC[NORM_MUL; VECTOR_ARITH
       `y - ((&1 - u) % y + u % x):real^N = u % (y - x)`] THEN
      ASM_SIMP_TAC[GSYM REAL_LE_RDIV_EQ; NORM_POS_LT; VECTOR_SUB_EQ] THEN
      REWRITE_TAC[NORM_SUB] THEN
      MATCH_MP_TAC(REAL_ARITH `&0 < e ==> abs(min (&1 / &2) e) <= e`) THEN
      ASM_SIMP_TAC[REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ];
      MATCH_MP_TAC(REWRITE_RULE[AFFINE_ALT] AFFINE_AFFINE_HULL) THEN
      ASM_SIMP_TAC[HULL_INC]];
    CONJ_TAC THENL
     [ONCE_ASM_REWRITE_TAC[] THEN MATCH_MP_TAC CONVEX_INTER THEN
      ASM_SIMP_TAC[AFFINE_IMP_CONVEX; AFFINE_AFFINE_HULL];
      ALL_TAC] THEN
    MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real^N`; `x:real^N`] THEN
    SUBGOAL_THEN
     `!a b x:real^N. a IN s /\ b IN s /\ x IN t /\ x IN segment(a,b) /\
                     (a IN affine hull t ==> b IN affine hull t)
                     ==> a IN t /\ b IN t`
     (fun th -> MESON_TAC[th; SEGMENT_SYM]) THEN
    REPEAT GEN_TAC THEN ASM_CASES_TAC `(a:real^N) IN affine hull t` THEN
    ASM_REWRITE_TAC[] THENL [ASM SET_TAC[]; STRIP_TAC] THEN
    ASM_CASES_TAC `a:real^N = b` THENL
     [ASM_MESON_TAC[SEGMENT_REFL; NOT_IN_EMPTY]; ALL_TAC] THEN
    SUBGOAL_THEN `(a:real^N) IN (s DIFF t) /\ b IN  (s DIFF t)`
    STRIP_ASSUME_TAC THENL
     [ASM_REWRITE_TAC[IN_DIFF] THEN ONCE_ASM_REWRITE_TAC[] THEN
      ASM_REWRITE_TAC[IN_INTER] THEN
      UNDISCH_TAC `~((a:real^N) IN affine hull t)` THEN
      UNDISCH_TAC `(x:real^N) IN segment(a,b)` THEN
      ASM_SIMP_TAC[OPEN_SEGMENT_ALT; CONTRAPOS_THM; IN_ELIM_THM] THEN
      DISCH_THEN(X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC) THEN
      FIRST_X_ASSUM(MP_TAC o AP_TERM `(%) (inv(&1 - u)) :real^N->real^N`) THEN
      REWRITE_TAC[VECTOR_ADD_LDISTRIB; VECTOR_MUL_ASSOC] THEN
      ASM_SIMP_TAC[REAL_MUL_LINV; REAL_ARITH `x < &1 ==> ~(&1 - x = &0)`] THEN
      REWRITE_TAC[VECTOR_ARITH
       `x:real^N = &1 % a + u % b <=> a = x + --u %  b`] THEN
      DISCH_THEN SUBST1_TAC THEN DISCH_TAC THEN
      MATCH_MP_TAC(REWRITE_RULE[affine] AFFINE_AFFINE_HULL) THEN
      ASM_SIMP_TAC[HULL_INC] THEN
      UNDISCH_TAC `u < &1` THEN CONV_TAC REAL_FIELD;
      MP_TAC(ISPEC `s DIFF t:real^N->bool` CONVEX_CONTAINS_SEGMENT) THEN
      ASM_REWRITE_TAC[] THEN
      DISCH_THEN(MP_TAC o SPECL [`a:real^N`; `b:real^N`]) THEN
      ASM_REWRITE_TAC[SUBSET; IN_DIFF] THEN
      DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN
      ASM_MESON_TAC[segment; IN_DIFF]]]);;

let FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE_STRONG = prove
 (`!s a:real^N b.
        convex(s INTER {x | a dot x = b}) /\ (!x. x IN s ==> a dot x <= b)
        ==> (s INTER {x | a dot x = b}) face_of s`,
  MAP_EVERY X_GEN_TAC [`s:real^N->bool`; `c:real^N`; `d:real`] THEN
  SIMP_TAC[face_of; INTER_SUBSET] THEN
  STRIP_TAC THEN REWRITE_TAC[IN_INTER; IN_ELIM_THM] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real^N`; `x:real^N`] THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(REAL_ARITH
   `a <= x /\ b <= x /\ ~(a < x) /\ ~(b < x) ==> a = x /\ b = x`) THEN
  ASM_SIMP_TAC[] THEN UNDISCH_TAC `(x:real^N) IN segment(a,b)` THEN
  ASM_CASES_TAC `a:real^N = b` THEN
  ASM_REWRITE_TAC[SEGMENT_REFL; NOT_IN_EMPTY] THEN
  ASM_SIMP_TAC[OPEN_SEGMENT_ALT; IN_ELIM_THM] THEN
  DISCH_THEN(X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC) THEN
  CONJ_TAC THEN DISCH_TAC THEN UNDISCH_TAC `(c:real^N) dot x = d` THEN
  MATCH_MP_TAC(REAL_ARITH `x < a ==> x = a ==> F`) THEN
  SUBST1_TAC(REAL_ARITH `d = (&1 - u) * d + u * d`) THEN
  ASM_REWRITE_TAC[DOT_RADD; DOT_RMUL] THENL
   [MATCH_MP_TAC REAL_LTE_ADD2; MATCH_MP_TAC REAL_LET_ADD2] THEN
  ASM_SIMP_TAC[REAL_LE_LMUL_EQ; REAL_LT_LMUL_EQ; REAL_SUB_LT]);;

let FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE_STRONG = prove
 (`!s a:real^N b.
        convex(s INTER {x | a dot x = b}) /\ (!x. x IN s ==> a dot x >= b)
        ==> (s INTER {x | a dot x = b}) face_of s`,
  REWRITE_TAC[real_ge] THEN REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `--a:real^N`; `--b:real`]
    FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE_STRONG) THEN
  ASM_REWRITE_TAC[DOT_LNEG; REAL_EQ_NEG2; REAL_LE_NEG2]);;

let FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE = prove
 (`!s a:real^N b.
        convex s /\ (!x. x IN s ==> a dot x <= b)
        ==> (s INTER {x | a dot x = b}) face_of s`,
  SIMP_TAC[FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE_STRONG;
           CONVEX_INTER; CONVEX_HYPERPLANE]);;

let FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE = prove
 (`!s a:real^N b.
        convex s /\ (!x. x IN s ==> a dot x >= b)
        ==> (s INTER {x | a dot x = b}) face_of s`,
  SIMP_TAC[FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE_STRONG;
           CONVEX_INTER; CONVEX_HYPERPLANE]);;

let FACE_OF_IMP_SUBSET = prove
 (`!s t. t face_of s ==> t SUBSET s`,
  SIMP_TAC[face_of]);;

let FACE_OF_IMP_CONVEX = prove
 (`!s t. t face_of s ==> convex t`,
  SIMP_TAC[face_of]);;

let FACE_OF_IMP_CLOSED = prove
 (`!s t. convex s /\ closed s /\ t face_of s ==> closed t`,
  REPEAT GEN_TAC THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  ASM_SIMP_TAC[FACE_OF_STILLCONVEX] THEN
  STRIP_TAC THEN ONCE_ASM_REWRITE_TAC[] THEN
  ASM_SIMP_TAC[CLOSED_AFFINE; AFFINE_AFFINE_HULL; CLOSED_INTER]);;

let FACE_OF_IMP_COMPACT = prove
 (`!s t. convex s /\ compact s /\ t face_of s ==> compact t`,
  SIMP_TAC[COMPACT_EQ_BOUNDED_CLOSED] THEN
  ASM_MESON_TAC[BOUNDED_SUBSET; FACE_OF_IMP_SUBSET; FACE_OF_IMP_CLOSED]);;

let FACE_OF_INTER_SUBFACE = prove
 (`!c1 c2 d1 d2:real^N->bool.
        (c1 INTER c2) face_of c1 /\ (c1 INTER c2) face_of c2 /\
        d1 face_of c1 /\ d2 face_of c2
        ==> (d1 INTER d2) face_of d1 /\ (d1 INTER d2) face_of d2`,
 REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_SUBSET THENL
   [EXISTS_TAC `c1:real^N->bool`; EXISTS_TAC `c2:real^N->bool`] THEN
  ASM_SIMP_TAC[FACE_OF_IMP_SUBSET; INTER_SUBSET] THEN
  TRANS_TAC FACE_OF_TRANS `c1 INTER c2:real^N->bool` THEN
  ASM_SIMP_TAC[FACE_OF_INTER_INTER]);;

let SUBSET_OF_FACE_OF = prove
 (`!s t u:real^N->bool.
      t face_of s /\ u SUBSET s /\
      ~(DISJOINT t (relative_interior u))
      ==> u SUBSET t`,
  REWRITE_TAC[DISJOINT] THEN REPEAT STRIP_TAC THEN
  REWRITE_TAC[SUBSET] THEN X_GEN_TAC `c:real^N` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  REWRITE_TAC[IN_INTER; LEFT_IMP_EXISTS_THM] THEN X_GEN_TAC `b:real^N` THEN
  REWRITE_TAC[IN_RELATIVE_INTERIOR_CBALL] THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  DISCH_THEN(X_CHOOSE_THEN `e:real` MP_TAC) THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  REWRITE_TAC[SUBSET; IN_CBALL; IN_INTER] THEN
  ASM_CASES_TAC `c:real^N = b` THEN ASM_REWRITE_TAC[] THEN
  ABBREV_TAC `d:real^N = b + e / norm(b - c) % (b - c)` THEN
  DISCH_THEN(MP_TAC o SPEC `d:real^N`) THEN ANTS_TAC THENL
   [EXPAND_TAC "d" THEN CONJ_TAC THENL
     [REWRITE_TAC[NORM_ARITH `dist(b:real^N,b + e) = norm e`] THEN
      REWRITE_TAC[NORM_MUL; REAL_ABS_DIV; REAL_ABS_NORM] THEN
      ASM_SIMP_TAC[REAL_DIV_RMUL; NORM_EQ_0; VECTOR_SUB_EQ] THEN
      ASM_REAL_ARITH_TAC;
      REWRITE_TAC[VECTOR_ARITH
       `b + u % (b - c):real^N = (&1 - --u) % b + --u % c`] THEN
      MATCH_MP_TAC(REWRITE_RULE[AFFINE_ALT] AFFINE_AFFINE_HULL) THEN
      ASM_SIMP_TAC[HULL_INC]];
    STRIP_TAC THEN
    SUBGOAL_THEN `(d:real^N) IN t /\ c IN t` (fun th -> MESON_TAC[th]) THEN
    FIRST_ASSUM(STRIP_ASSUME_TAC o GEN_REWRITE_RULE I [face_of]) THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN EXISTS_TAC `b:real^N` THEN
    REPEAT(CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC]) THEN
    SUBGOAL_THEN `~(b:real^N = d)` ASSUME_TAC THENL
     [EXPAND_TAC "d" THEN
      REWRITE_TAC[VECTOR_ARITH `b:real^N = b + e <=> e = vec 0`] THEN
      ASM_SIMP_TAC[REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ;
                   VECTOR_MUL_EQ_0; REAL_LT_IMP_NZ];
      ASM_REWRITE_TAC[segment; IN_DIFF; IN_INSERT; NOT_IN_EMPTY] THEN
      REWRITE_TAC[IN_ELIM_THM] THEN
      EXISTS_TAC `(e / norm(b - c:real^N)) / (&1 + e / norm(b - c))` THEN
      ASM_SIMP_TAC[REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ;
                   REAL_ARITH `&0 < x ==> &0 < &1 + x`;
                   REAL_LE_RDIV_EQ; REAL_LE_LDIV_EQ; REAL_MUL_LID] THEN
      REWRITE_TAC[REAL_MUL_LZERO; REAL_MUL_LID] THEN
      ASM_SIMP_TAC[REAL_FIELD `&0 < n ==> (&1 + e / n) * n = n + e`;
                   NORM_POS_LT; VECTOR_SUB_EQ; REAL_LE_ADDL] THEN
      ASM_SIMP_TAC[NORM_POS_LT; REAL_LT_IMP_LE; VECTOR_SUB_EQ] THEN
      EXPAND_TAC "d" THEN REWRITE_TAC[VECTOR_ARITH
       `b:real^N = (&1 - u) % (b + e % (b - c)) + u % c <=>
        (u - e * (&1 - u)) % (b - c) = vec 0`] THEN
      ASM_REWRITE_TAC[VECTOR_MUL_EQ_0; VECTOR_SUB_EQ] THEN
      MATCH_MP_TAC(REAL_FIELD
       `&0 < e ==> e / (&1 + e) - e * (&1 - e / (&1 + e)) = &0`) THEN
      ASM_SIMP_TAC[REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ]]]);;

let FACE_OF_EQ = prove
 (`!s t u:real^N->bool.
        t face_of s /\ u face_of s /\
        ~(DISJOINT (relative_interior t) (relative_interior u))
        ==> t = u`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
  CONJ_TAC THEN MATCH_MP_TAC SUBSET_OF_FACE_OF THEN
  EXISTS_TAC `s:real^N->bool` THEN ASM_SIMP_TAC[FACE_OF_IMP_SUBSET] THENL
   [MP_TAC(ISPEC `u:real^N->bool` RELATIVE_INTERIOR_SUBSET);
    MP_TAC(ISPEC `t:real^N->bool` RELATIVE_INTERIOR_SUBSET)] THEN
  ASM SET_TAC[]);;

let FACE_OF_DISJOINT_RELATIVE_INTERIOR = prove
 (`!f s:real^N->bool.
        f face_of s /\ ~(f = s) ==> f INTER relative_interior s = {}`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:real^N->bool`; `s:real^N->bool`]
        SUBSET_OF_FACE_OF) THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
  ASM SET_TAC[]);;

let FACE_OF_DISJOINT_INTERIOR = prove
 (`!f s:real^N->bool.
        f face_of s /\ ~(f = s) ==> f INTER interior s = {}`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(MP_TAC o MATCH_MP FACE_OF_DISJOINT_RELATIVE_INTERIOR) THEN
  MP_TAC(ISPEC `s:real^N->bool` INTERIOR_SUBSET_RELATIVE_INTERIOR) THEN
  SET_TAC[]);;

let SUBSET_OF_FACE_OF_AFFINE_HULL = prove
 (`!s t u:real^N->bool.
        t face_of s /\ convex s /\ u SUBSET s /\
        ~DISJOINT (affine hull t) (relative_interior u)
        ==> u SUBSET t`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC SUBSET_OF_FACE_OF THEN
  EXISTS_TAC `s:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `t:real^N->bool`] FACE_OF_STILLCONVEX) THEN
  MP_TAC(ISPEC `u:real^N->bool` RELATIVE_INTERIOR_SUBSET) THEN
  ASM_REWRITE_TAC[] THEN ASM SET_TAC[]);;

let AFFINE_HULL_FACE_OF_DISJOINT_RELATIVE_INTERIOR = prove
 (`!s f:real^N->bool.
        convex s /\ f face_of s /\ ~(f = s)
        ==> affine hull f INTER relative_interior s = {}`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:real^N->bool`; `s:real^N->bool`]
        SUBSET_OF_FACE_OF_AFFINE_HULL) THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN ASM SET_TAC[]);;

let FACE_OF_SUBSET_RELATIVE_BOUNDARY = prove
 (`!s f:real^N->bool.
        f face_of s /\ ~(f = s) ==> f SUBSET (s DIFF relative_interior s)`,
  ASM_SIMP_TAC[SET_RULE `s SUBSET u DIFF t <=> s SUBSET u /\ s INTER t = {}`;
               FACE_OF_DISJOINT_RELATIVE_INTERIOR; FACE_OF_IMP_SUBSET]);;

let FACE_OF_SUBSET_RELATIVE_FRONTIER = prove
 (`!s f:real^N->bool.
        f face_of s /\ ~(f = s) ==> f SUBSET relative_frontier s`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(MP_TAC o MATCH_MP FACE_OF_SUBSET_RELATIVE_BOUNDARY) THEN
  REWRITE_TAC[relative_frontier] THEN
  MP_TAC(ISPEC `s:real^N->bool` CLOSURE_SUBSET) THEN SET_TAC[]);;

let FACE_OF_SUBSET_RELATIVE_FRONTIER_AFF_DIM = prove
 (`!f s:real^N->bool.
        f face_of s /\ aff_dim f < aff_dim s
        ==> f SUBSET relative_frontier s`,
  MESON_TAC[FACE_OF_SUBSET_RELATIVE_FRONTIER; INT_LT_REFL]);;

let FACE_OF_SUBSET_FRONTIER_AFF_DIM = prove
 (`!f s:real^N->bool.
        f face_of s /\ aff_dim f < &(dimindex(:N))
        ==> f SUBSET frontier s`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `interior s:real^N->bool = {}` THENL
   [ASM_SIMP_TAC[frontier; DIFF_EMPTY] THEN
    ASM_MESON_TAC[FACE_OF_IMP_SUBSET; SUBSET_TRANS; CLOSURE_SUBSET];
    TRANS_TAC SUBSET_TRANS `relative_frontier s:real^N->bool` THEN
    REWRITE_TAC[RELATIVE_FRONTIER_SUBSET_FRONTIER] THEN
    ASM_MESON_TAC[AFF_DIM_NONEMPTY_INTERIOR;
                  FACE_OF_SUBSET_RELATIVE_FRONTIER_AFF_DIM]]);;

let FACE_OF_AFF_DIM_LT = prove
 (`!f s:real^N->bool.
        convex s /\ f face_of s /\ ~(f = s) ==> aff_dim f < aff_dim s`,
  REPEAT GEN_TAC THEN
  SIMP_TAC[INT_LT_LE; FACE_OF_IMP_SUBSET; AFF_DIM_SUBSET] THEN
  REWRITE_TAC[IMP_CONJ; CONTRAPOS_THM] THEN
  ASM_CASES_TAC `f:real^N->bool = {}` THENL
   [CONV_TAC(ONCE_DEPTH_CONV SYM_CONV) THEN
    ASM_REWRITE_TAC[AFF_DIM_EQ_MINUS1; AFF_DIM_EMPTY];
    REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_EQ THEN
    EXISTS_TAC `s:real^N->bool` THEN ASM_SIMP_TAC[FACE_OF_REFL] THEN
    MATCH_MP_TAC(SET_RULE `~(f = {}) /\ f SUBSET s ==> ~DISJOINT f s`) THEN
    FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_CONVEX) THEN
    ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY] THEN
    MATCH_MP_TAC SUBSET_RELATIVE_INTERIOR THEN
    ASM_MESON_TAC[FACE_OF_IMP_SUBSET; AFF_DIM_EQ_AFFINE_HULL; INT_LE_REFL]]);;

let FACE_OF_CONVEX_HULLS = prove
 (`!f s:real^N->bool.
        FINITE s /\ f SUBSET s /\
        DISJOINT (affine hull f) (convex hull (s DIFF f))
        ==> (convex hull f) face_of (convex hull s)`,
  let lemma = prove
   (`!s x y:real^N.
          affine s /\ ~(k = &0) /\ ~(k = &1) /\ x IN s /\ inv(&1 - k) % y IN s
          ==> inv(k) % (x - y) IN s`,
    REWRITE_TAC[AFFINE_ALT] THEN REPEAT STRIP_TAC THEN
    SUBGOAL_THEN
     `inv(k) % (x - y):real^N = (&1 - inv k) % inv(&1 - k) % y + inv(k) % x`
     (fun th -> ASM_SIMP_TAC[th]) THEN
    REWRITE_TAC[VECTOR_MUL_EQ_0; VECTOR_ARITH
     `k % (x - y):real^N = a % b % y + k % x <=> (a * b + k) % y = vec 0`] THEN
    DISJ1_TAC THEN MAP_EVERY UNDISCH_TAC [`~(k = &0)`; `~(k = &1)`] THEN
    CONV_TAC REAL_FIELD) in
  REPEAT STRIP_TAC THEN REWRITE_TAC[face_of] THEN
  SUBGOAL_THEN `FINITE(f:real^N->bool)` ASSUME_TAC THENL
   [ASM_MESON_TAC[FINITE_SUBSET]; ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o GEN_REWRITE_RULE I [SUBSET]) THEN
  ASM_SIMP_TAC[HULL_MONO; CONVEX_CONVEX_HULL] THEN
  MAP_EVERY X_GEN_TAC [`x:real^N`; `y:real^N`; `w:real^N`] THEN
  STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_SEGMENT]) THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC
   (X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC)) THEN
  SUBGOAL_THEN `(w:real^N) IN affine hull f` ASSUME_TAC THENL
   [ASM_MESON_TAC[CONVEX_HULL_SUBSET_AFFINE_HULL; SUBSET]; ALL_TAC] THEN
  MAP_EVERY UNDISCH_TAC
   [`(y:real^N) IN convex hull s`; `(x:real^N) IN convex hull s`] THEN
  REWRITE_TAC[CONVEX_HULL_FINITE; IN_ELIM_THM] THEN
  DISCH_THEN(X_CHOOSE_THEN `a:real^N->real` STRIP_ASSUME_TAC) THEN
  DISCH_THEN(X_CHOOSE_THEN `b:real^N->real` STRIP_ASSUME_TAC) THEN
  ABBREV_TAC `(c:real^N->real) = \x. (&1 - u) * a x + u * b x` THEN
  SUBGOAL_THEN `!x:real^N. x IN s ==> &0 <= c x` ASSUME_TAC THENL
   [REPEAT STRIP_TAC THEN EXPAND_TAC "c" THEN REWRITE_TAC[] THEN
    MATCH_MP_TAC REAL_LE_ADD THEN CONJ_TAC THEN MATCH_MP_TAC REAL_LE_MUL THEN
    ASM_SIMP_TAC[] THEN ASM_REAL_ARITH_TAC;
    ALL_TAC] THEN
  ASM_CASES_TAC `sum (s DIFF f:real^N->bool) c = &0` THENL
   [SUBGOAL_THEN `!x:real^N. x IN (s DIFF f) ==> c x = &0` MP_TAC THENL
     [MATCH_MP_TAC SUM_POS_EQ_0 THEN ASM_MESON_TAC[FINITE_DIFF; IN_DIFF];
      ALL_TAC] THEN
    EXPAND_TAC "c" THEN
    ASM_SIMP_TAC[IN_DIFF; REAL_LE_MUL; REAL_LT_IMP_LE; REAL_SUB_LT;
     REAL_ARITH `&0 <= x /\ &0 <= y ==> (x + y = &0 <=> x = &0 /\ y = &0)`;
     REAL_ENTIRE; REAL_SUB_0; REAL_LT_IMP_NE] THEN
    STRIP_TAC THEN CONJ_TAC THENL
     [EXISTS_TAC `a:real^N->real`; EXISTS_TAC `b:real^N->real`] THEN
    ASM_SIMP_TAC[] THEN CONJ_TAC THEN FIRST_X_ASSUM(fun th g ->
      (GEN_REWRITE_TAC RAND_CONV [GSYM th] THEN CONV_TAC SYM_CONV THEN
       (MATCH_MP_TAC SUM_SUPERSET ORELSE MATCH_MP_TAC VSUM_SUPERSET)) g) THEN
    ASM_SIMP_TAC[VECTOR_MUL_LZERO];
    ALL_TAC] THEN
  ABBREV_TAC `k = sum (s DIFF f:real^N->bool) c` THEN
  SUBGOAL_THEN `&0 < k` ASSUME_TAC THENL
   [ASM_REWRITE_TAC[REAL_LT_LE] THEN EXPAND_TAC "k" THEN
    MATCH_MP_TAC SUM_POS_LE THEN ASM_SIMP_TAC[FINITE_DIFF; IN_DIFF];
    ALL_TAC] THEN
  ASM_CASES_TAC `k = &1` THENL
   [FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_DISJOINT]) THEN
    MATCH_MP_TAC(TAUT `b ==> ~b ==> c`) THEN
    EXISTS_TAC `w:real^N` THEN
    ASM_REWRITE_TAC[CONVEX_HULL_FINITE; IN_ELIM_THM] THEN
    EXISTS_TAC `c:real^N->real` THEN
    ASM_SIMP_TAC[IN_DIFF; SUM_DIFF; VSUM_DIFF] THEN
    SUBGOAL_THEN `vsum f (\x:real^N. c x % x) = vec 0` SUBST1_TAC THENL
     [ALL_TAC;
      EXPAND_TAC "c" THEN REWRITE_TAC[VECTOR_ADD_RDISTRIB] THEN
      ASM_SIMP_TAC[VSUM_ADD; GSYM VECTOR_MUL_ASSOC; VSUM_LMUL] THEN
      REWRITE_TAC[VECTOR_SUB_RZERO]] THEN
    SUBGOAL_THEN `sum(s DIFF f) c = sum s c - sum f (c:real^N->real)`
    MP_TAC THENL [ASM_MESON_TAC[SUM_DIFF]; ALL_TAC] THEN ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN `sum s (c:real^N->real) = &1` SUBST1_TAC THENL
     [EXPAND_TAC "c" THEN REWRITE_TAC[VECTOR_ADD_RDISTRIB] THEN
      ASM_SIMP_TAC[SUM_ADD; GSYM REAL_MUL_ASSOC; SUM_LMUL] THEN
      REAL_ARITH_TAC;
      ALL_TAC] THEN
    REWRITE_TAC[REAL_ARITH `&1 = &1 - x <=> x = &0`] THEN DISCH_TAC THEN
    MP_TAC(ISPECL [`c:real^N->real`;`f:real^N->bool`] SUM_POS_EQ_0) THEN
    ANTS_TAC THENL [ASM_MESON_TAC[FINITE_SUBSET; SUBSET]; ALL_TAC] THEN
    SIMP_TAC[VECTOR_MUL_LZERO; VSUM_0];
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_DISJOINT]) THEN
  MATCH_MP_TAC(TAUT `b ==> ~b ==> c`) THEN
  EXISTS_TAC `inv(k) % (w - vsum f (\x:real^N. c x % x))` THEN CONJ_TAC THENL
   [ALL_TAC;
    SUBGOAL_THEN `w = vsum f (\x:real^N. c x % x) +
                      vsum (s DIFF f) (\x:real^N. c x % x)`
    SUBST1_TAC THENL
     [ASM_SIMP_TAC[VSUM_DIFF; VECTOR_ARITH `a + b - a:real^N = b`] THEN
      EXPAND_TAC "c" THEN REWRITE_TAC[VECTOR_ADD_RDISTRIB] THEN
      ASM_SIMP_TAC[VSUM_ADD; GSYM VECTOR_MUL_ASSOC; VSUM_LMUL];
      REWRITE_TAC[VECTOR_ADD_SUB]] THEN
    ASM_SIMP_TAC[GSYM VSUM_LMUL; FINITE_DIFF] THEN
    REWRITE_TAC[CONVEX_HULL_FINITE; IN_ELIM_THM] THEN
    EXISTS_TAC `\x. inv k * (c:real^N->real) x` THEN
    ASM_REWRITE_TAC[VECTOR_MUL_ASSOC] THEN
    ASM_SIMP_TAC[IN_DIFF; REAL_LE_MUL; REAL_LE_INV_EQ; REAL_LT_IMP_LE] THEN
    ASM_SIMP_TAC[SUM_LMUL; ETA_AX; REAL_MUL_LINV]] THEN
  MATCH_MP_TAC lemma THEN REPEAT CONJ_TAC THENL
   [REWRITE_TAC[AFFINE_AFFINE_HULL];
    ASM_REWRITE_TAC[];
    ASM_REWRITE_TAC[];
    ASM_MESON_TAC[CONVEX_HULL_SUBSET_AFFINE_HULL; SUBSET];
    ALL_TAC] THEN
  ASM_SIMP_TAC[GSYM VSUM_LMUL; AFFINE_HULL_FINITE; IN_ELIM_THM] THEN
  EXISTS_TAC `(\x. inv(&1 - k) * c x):real^N->real` THEN
  REWRITE_TAC[VECTOR_MUL_ASSOC; SUM_LMUL] THEN
  MATCH_MP_TAC(REAL_FIELD
   `~(k = &1) /\ f = &1 - k ==> inv(&1 - k) * f = &1`) THEN
  ASM_REWRITE_TAC[] THEN
  SUBGOAL_THEN `sum(s DIFF f) c = sum s c - sum f (c:real^N->real)`
  MP_TAC THENL [ASM_MESON_TAC[SUM_DIFF]; ALL_TAC] THEN ASM_REWRITE_TAC[] THEN
  SUBGOAL_THEN `sum s (c:real^N->real) = &1` SUBST1_TAC THENL
   [EXPAND_TAC "c" THEN REWRITE_TAC[VECTOR_ADD_RDISTRIB] THEN
    ASM_SIMP_TAC[SUM_ADD; GSYM REAL_MUL_ASSOC; SUM_LMUL];
    ALL_TAC] THEN
  REAL_ARITH_TAC);;

let FACE_OF_CONVEX_HULL_INSERT = prove
 (`!f s a:real^N.
        FINITE s /\ ~(a IN affine hull s) /\ f face_of (convex hull s)
        ==> f face_of (convex hull (a INSERT s))`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_TRANS THEN
  EXISTS_TAC `convex hull s:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC FACE_OF_CONVEX_HULLS THEN
  ASM_REWRITE_TAC[FINITE_INSERT; SET_RULE `s SUBSET a INSERT s`] THEN
  FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
   `~(a IN s) ==> t SUBSET {a} ==> DISJOINT s t`)) THEN
  MATCH_MP_TAC HULL_MINIMAL THEN REWRITE_TAC[CONVEX_SING] THEN SET_TAC[]);;

let FACE_OF_AFFINE_TRIVIAL = prove
 (`!s f:real^N->bool.
        affine s /\ f face_of s ==> f = {} \/ f = s`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `f:real^N->bool = {}` THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  DISCH_THEN(X_CHOOSE_TAC `a:real^N`) THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN ASM_REWRITE_TAC[] THEN
  REWRITE_TAC[SUBSET] THEN X_GEN_TAC `b:real^N` THEN DISCH_TAC THEN
  ASM_CASES_TAC `(b:real^N) IN f` THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [face_of]) THEN
  DISCH_THEN(MP_TAC o SPECL [`&2 % a - b:real^N`; `b:real^N`; `a:real^N`] o
             CONJUNCT2 o CONJUNCT2) THEN
  SUBGOAL_THEN `~(a:real^N = b)` ASSUME_TAC THENL
   [ASM_MESON_TAC[]; ALL_TAC] THEN
  ASM_SIMP_TAC[IN_SEGMENT; VECTOR_ARITH `&2 % a - b:real^N = b <=> a = b`] THEN
  CONJ_TAC THENL
   [REWRITE_TAC[VECTOR_ARITH `&2 % a - b:real^N = a + &1 % (a - b)`] THEN
    MATCH_MP_TAC IN_AFFINE_ADD_MUL_DIFF THEN ASM SET_TAC[];
    EXISTS_TAC `&1 / &2` THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN
    VECTOR_ARITH_TAC]);;

let FACE_OF_AFFINE_EQ = prove
 (`!s:real^N->bool f. affine s ==> (f face_of s <=> f = {} \/ f = s)`,
  MESON_TAC[FACE_OF_AFFINE_TRIVIAL; EMPTY_FACE_OF; FACE_OF_REFL;
            AFFINE_IMP_CONVEX]);;

let INTERS_FACES_FINITE_BOUND = prove
 (`!s f:(real^N->bool)->bool.
        convex s /\ (!c. c IN f ==> c face_of s)
        ==> ?f'. FINITE f' /\ f' SUBSET f /\ CARD f' <= dimindex(:N) + 1 /\
                 INTERS f' = INTERS f`,
  SUBGOAL_THEN
   `!s f:(real^N->bool)->bool.
        convex s /\ (!c. c IN f ==> c face_of s /\ ~(c = s))
        ==> ?f'. FINITE f' /\ f' SUBSET f /\ CARD f' <= dimindex(:N) + 1 /\
                 INTERS f' = INTERS f`
  ASSUME_TAC THENL
   [ALL_TAC;
    REPEAT STRIP_TAC THEN
    ASM_CASES_TAC `(s:real^N->bool) IN f` THENL
     [ALL_TAC; FIRST_X_ASSUM MATCH_MP_TAC THEN ASM_MESON_TAC[]] THEN
    FIRST_ASSUM(DISJ_CASES_THEN2 SUBST1_TAC MP_TAC o MATCH_MP (SET_RULE
     `s IN f ==> f = {s} \/ ?t. ~(t = s) /\ t IN f`)) THENL
     [EXISTS_TAC `{s:real^N->bool}` THEN
      SIMP_TAC[FINITE_INSERT; FINITE_EMPTY; SUBSET_REFL; CARD_CLAUSES] THEN
      ARITH_TAC;
      DISCH_THEN(X_CHOOSE_THEN `t:real^N->bool` STRIP_ASSUME_TAC)] THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`s:real^N->bool`; `f DELETE
      (s:real^N->bool)`]) THEN
    ASM_SIMP_TAC[IN_DELETE; SUBSET_DELETE] THEN
    MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `f':(real^N->bool)->bool` THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN `f = (s:real^N->bool) INSERT (f DELETE s)` MP_TAC THENL
     [ASM SET_TAC[];
      DISCH_THEN(fun th -> GEN_REWRITE_TAC (funpow 2 RAND_CONV) [th])] THEN
    REWRITE_TAC[INTERS_INSERT] THEN
    MATCH_MP_TAC(SET_RULE `t SUBSET s ==> t = s INTER t`) THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `t:real^N->bool`) THEN
    ASM_REWRITE_TAC[] THEN
    DISCH_THEN(ASSUME_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
    MATCH_MP_TAC SUBSET_TRANS THEN EXISTS_TAC `t:real^N->bool` THEN
    ASM_REWRITE_TAC[] THEN REWRITE_TAC[SUBSET; IN_INTERS; IN_DELETE] THEN
    ASM SET_TAC[]] THEN
  REPEAT STRIP_TAC THEN ASM_CASES_TAC
   `!f':(real^N->bool)->bool.
        FINITE f' /\ f' SUBSET f /\ CARD f' <= dimindex(:N) + 1
        ==> ?c. c IN f /\ c INTER (INTERS f') PSUBSET (INTERS f')`
  THENL
   [ALL_TAC;
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [NOT_FORALL_THM]) THEN
    MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC THEN
    SIMP_TAC[NOT_IMP; GSYM CONJ_ASSOC] THEN
    REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    ASM_REWRITE_TAC[PSUBSET; INTER_SUBSET] THEN ASM SET_TAC[]] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE BINDER_CONV
   [RIGHT_IMP_EXISTS_THM]) THEN
  REWRITE_TAC[SKOLEM_THM; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:((real^N->bool)->bool)->real^N->bool` THEN DISCH_TAC THEN
  CHOOSE_TAC(prove_recursive_functions_exist num_RECURSION
   `d 0 = {c {} :real^N->bool} /\ !n. d(SUC n) = c(d n) INSERT d n`) THEN
  SUBGOAL_THEN `!n:num. ~(d n:(real^N->bool)->bool = {})` ASSUME_TAC THENL
   [INDUCT_TAC THEN ASM_REWRITE_TAC[] THEN SET_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN
   `!n. n <= dimindex(:N) + 1
        ==> (d n) SUBSET (f:(real^N->bool)->bool) /\
            FINITE(d n) /\ CARD(d n) <= n + 1`
  ASSUME_TAC THENL
   [INDUCT_TAC THEN ASM_REWRITE_TAC[] THEN
    ASM_SIMP_TAC[INSERT_SUBSET; CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY;
      EMPTY_SUBSET; ARITH_RULE `SUC n <= m + 1 ==> n <= m + 1`] THEN
    REPEAT STRIP_TAC THEN TRY ASM_ARITH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `(d:num->(real^N->bool)->bool) n`) THEN
    FIRST_X_ASSUM(MP_TAC o check (is_imp o concl)) THEN
    ANTS_TAC THENL [ASM_ARITH_TAC; STRIP_TAC] THEN ASM_REWRITE_TAC[] THEN
    ANTS_TAC THENL [ASM_ARITH_TAC; SIMP_TAC[]];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `!n. n <= dimindex(:N)
        ==> (INTERS(d(SUC n)):real^N->bool) PSUBSET INTERS(d n)`
  ASSUME_TAC THENL
   [REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[INTERS_INSERT] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `(d:num->(real^N->bool)->bool) n`) THEN
    ANTS_TAC THENL [ALL_TAC; SIMP_TAC[]] THEN
    REPEAT(FIRST_X_ASSUM(MP_TAC o SPEC `n:num`)) THEN
    ASM_SIMP_TAC[ARITH_RULE `n <= N ==> n <= N + 1`] THEN
    ASM_ARITH_TAC;
    ALL_TAC] THEN
  FIRST_X_ASSUM(CONJUNCTS_THEN(K ALL_TAC)) THEN
  SUBGOAL_THEN
   `!n. n <= dimindex(:N) + 1
        ==> aff_dim(INTERS(d n):real^N->bool) < &(dimindex(:N)) - &n`
  MP_TAC THENL
   [INDUCT_TAC THENL
     [DISCH_TAC THEN REWRITE_TAC[INT_SUB_RZERO] THEN
      MATCH_MP_TAC INT_LTE_TRANS THEN
      EXISTS_TAC `aff_dim(s:real^N->bool)` THEN
      REWRITE_TAC[AFF_DIM_LE_UNIV] THEN
      MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
      ASM_REWRITE_TAC[] THEN CONJ_TAC THENL
       [MATCH_MP_TAC FACE_OF_INTERS THEN ASM_REWRITE_TAC[] THEN ASM SET_TAC[];
        FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY] o
          SPEC `0`) THEN
        DISCH_THEN(X_CHOOSE_TAC `e:real^N->bool`) THEN
        FIRST_X_ASSUM(MP_TAC o SPEC `e:real^N->bool`) THEN
        ANTS_TAC THENL [ASM SET_TAC[]; STRIP_TAC] THEN
        MATCH_MP_TAC(SET_RULE
         `!t. t PSUBSET s /\ u SUBSET t ==> ~(u = s)`) THEN
        EXISTS_TAC `e:real^N->bool` THEN
        FIRST_X_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
        ASM SET_TAC[]];
      DISCH_TAC THEN REWRITE_TAC[GSYM INT_OF_NUM_SUC] THEN
      MATCH_MP_TAC(INT_ARITH
       `!d':int. d < d' /\ d' < m - n ==> d < m - (n + &1)`) THEN
      EXISTS_TAC `aff_dim(INTERS(d(n:num)):real^N->bool)` THEN
      ASM_SIMP_TAC[ARITH_RULE `SUC n <= k + 1 ==> n <= k + 1`] THEN
      MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
      ASM_SIMP_TAC[ARITH_RULE `SUC n <= m + 1 ==> n <= m`;
                   SET_RULE `s PSUBSET t ==> ~(s = t)`] THEN
      CONJ_TAC THENL
       [MATCH_MP_TAC CONVEX_INTERS THEN
        REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_IMP_CONVEX THEN
        EXISTS_TAC `s:real^N->bool` THEN
        ASM_MESON_TAC[SUBSET; ARITH_RULE `SUC n <= m + 1 ==> n <= m + 1`];
        ALL_TAC] THEN
      MP_TAC(ISPECL [`INTERS(d(SUC n)):real^N->bool`;`s:real^N->bool`;
                     `INTERS(d(n:num)):real^N->bool`] FACE_OF_FACE) THEN
      ASM_SIMP_TAC[SET_RULE `s PSUBSET t ==> s SUBSET t`;
                   ARITH_RULE `SUC n <= m + 1 ==> n <= m`] THEN
      MATCH_MP_TAC(TAUT `a /\ b ==> (a ==> (c <=> b)) ==> c`) THEN
      CONJ_TAC THEN MATCH_MP_TAC FACE_OF_INTERS THEN ASM_REWRITE_TAC[] THEN
      ASM_MESON_TAC[SUBSET; ARITH_RULE `SUC n <= m + 1 ==> n <= m + 1`]];
    ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `dimindex(:N) + 1`) THEN REWRITE_TAC[LE_REFL] THEN
  MATCH_MP_TAC(TAUT `~p ==> p ==> q`) THEN REWRITE_TAC[INT_NOT_LT] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_ADD; INT_ARITH `d - (d + &1):int = -- &1`] THEN
  REWRITE_TAC[AFF_DIM_GE]);;

let INTERS_FACES_FINITE_ALTBOUND = prove
 (`!s f:(real^N->bool)->bool.
        (!c. c IN f ==> c face_of s)
        ==> ?f'. FINITE f' /\ f' SUBSET f /\ CARD f' <= dimindex(:N) + 2 /\
                 INTERS f' = INTERS f`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC
   `!f':(real^N->bool)->bool.
        FINITE f' /\ f' SUBSET f /\ CARD f' <= dimindex(:N) + 2
        ==> ?c. c IN f /\ c INTER (INTERS f') PSUBSET (INTERS f')`
  THENL
   [ALL_TAC;
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [NOT_FORALL_THM]) THEN
    MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC THEN
    SIMP_TAC[NOT_IMP; GSYM CONJ_ASSOC] THEN
    REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    ASM_REWRITE_TAC[PSUBSET; INTER_SUBSET] THEN ASM SET_TAC[]] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE BINDER_CONV
   [RIGHT_IMP_EXISTS_THM]) THEN
  REWRITE_TAC[SKOLEM_THM; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:((real^N->bool)->bool)->real^N->bool` THEN DISCH_TAC THEN
  CHOOSE_TAC(prove_recursive_functions_exist num_RECURSION
   `d 0 = {c {} :real^N->bool} /\ !n. d(SUC n) = c(d n) INSERT d n`) THEN
  SUBGOAL_THEN `!n:num. ~(d n:(real^N->bool)->bool = {})` ASSUME_TAC THENL
   [INDUCT_TAC THEN ASM_REWRITE_TAC[] THEN SET_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN
   `!n. n <= dimindex(:N) + 2
        ==> (d n) SUBSET (f:(real^N->bool)->bool) /\
            FINITE(d n) /\ CARD(d n) <= n + 1`
  ASSUME_TAC THENL
   [INDUCT_TAC THEN ASM_REWRITE_TAC[] THEN
    ASM_SIMP_TAC[INSERT_SUBSET; CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY;
      EMPTY_SUBSET; ARITH_RULE `SUC n <= m + 2 ==> n <= m + 2`] THEN
    REPEAT STRIP_TAC THEN TRY ASM_ARITH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `(d:num->(real^N->bool)->bool) n`) THEN
    FIRST_X_ASSUM(MP_TAC o check (is_imp o concl)) THEN
    ANTS_TAC THENL [ASM_ARITH_TAC; STRIP_TAC] THEN ASM_REWRITE_TAC[] THEN
    ANTS_TAC THENL [ASM_ARITH_TAC; SIMP_TAC[]];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `!n. n <= dimindex(:N) + 1
        ==> (INTERS(d(SUC n)):real^N->bool) PSUBSET INTERS(d n)`
  ASSUME_TAC THENL
   [REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[INTERS_INSERT] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `(d:num->(real^N->bool)->bool) n`) THEN
    ANTS_TAC THENL [ALL_TAC; SIMP_TAC[]] THEN
    REPEAT(FIRST_X_ASSUM(MP_TAC o SPEC `n:num`)) THEN
    ASM_SIMP_TAC[ARITH_RULE `n <= N + 1 ==> n <= N + 2`] THEN
    ASM_ARITH_TAC;
    ALL_TAC] THEN
  FIRST_X_ASSUM(CONJUNCTS_THEN(K ALL_TAC)) THEN
  SUBGOAL_THEN
   `!n. n <= dimindex(:N) + 2
        ==> aff_dim(INTERS(d n):real^N->bool) <= &(dimindex(:N)) - &n`
  MP_TAC THENL
   [INDUCT_TAC THEN REWRITE_TAC[INT_SUB_RZERO; AFF_DIM_LE_UNIV] THEN
    DISCH_TAC THEN REWRITE_TAC[GSYM INT_OF_NUM_SUC] THEN
    MATCH_MP_TAC(INT_ARITH
     `!d':int. d < d' /\ d' <= m - n ==> d <= m - (n + &1)`) THEN
    EXISTS_TAC `aff_dim(INTERS(d(n:num)):real^N->bool)` THEN
    ASM_SIMP_TAC[ARITH_RULE `SUC n <= k + 2 ==> n <= k + 2`] THEN
    MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
    ASM_SIMP_TAC[ARITH_RULE `SUC n <= m + 2 ==> n <= m + 1`;
                 SET_RULE `s PSUBSET t ==> ~(s = t)`] THEN
    CONJ_TAC THENL
     [MATCH_MP_TAC CONVEX_INTERS THEN
      REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_IMP_CONVEX THEN
      EXISTS_TAC `s:real^N->bool` THEN
      ASM_MESON_TAC[SUBSET; ARITH_RULE `SUC n <= m + 2 ==> n <= m + 2`];
      ALL_TAC] THEN
    MP_TAC(ISPECL [`INTERS(d(SUC n)):real^N->bool`;`s:real^N->bool`;
                   `INTERS(d(n:num)):real^N->bool`] FACE_OF_FACE) THEN
    ASM_SIMP_TAC[SET_RULE `s PSUBSET t ==> s SUBSET t`;
                 ARITH_RULE `SUC n <= m + 2 ==> n <= m + 1`] THEN
    MATCH_MP_TAC(TAUT `a /\ b ==> (a ==> (c <=> b)) ==> c`) THEN
    CONJ_TAC THEN MATCH_MP_TAC FACE_OF_INTERS THEN ASM_REWRITE_TAC[] THEN
    ASM_MESON_TAC[SUBSET; ARITH_RULE `SUC n <= m + 2 ==> n <= m + 2`];
    ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `dimindex(:N) + 2`) THEN REWRITE_TAC[LE_REFL] THEN
  MATCH_MP_TAC(TAUT `~p ==> p ==> q`) THEN REWRITE_TAC[INT_NOT_LE] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_ADD; INT_ARITH
    `d - (d + &2):int < i <=> -- &1 <= i`] THEN
  REWRITE_TAC[AFF_DIM_GE]);;

let FACES_OF_TRANSLATION = prove
 (`!s a:real^N.
        {f | f face_of IMAGE (\x. a + x) s} =
        IMAGE (IMAGE (\x. a + x)) {f | f face_of s}`,
  REPEAT GEN_TAC THEN CONV_TAC SYM_CONV THEN
  MATCH_MP_TAC SURJECTIVE_IMAGE_EQ THEN
  REWRITE_TAC[IN_ELIM_THM; FACE_OF_TRANSLATION_EQ] THEN
  REPEAT STRIP_TAC THEN ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN
  ONCE_REWRITE_TAC[TRANSLATION_GALOIS] THEN
  REWRITE_TAC[EXISTS_REFL]);;

let FACES_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N s.
        linear f /\ (!x y. f x = f y ==> x = y)
        ==> {t | t face_of (IMAGE f s)} = IMAGE (IMAGE f) {t | t face_of s}`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  REWRITE_TAC[face_of; SUBSET_IMAGE; SET_RULE
   `{y | (?x. P x /\ y = f x) /\ Q y} = {f x |x| P x /\ Q(f x)}`] THEN
  REWRITE_TAC[SET_RULE `IMAGE f {x | P x} = {f x | P x}`] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_IMAGE] THEN
  FIRST_ASSUM(fun th ->
   REWRITE_TAC[MATCH_MP CONVEX_LINEAR_IMAGE_EQ th;
               MATCH_MP OPEN_SEGMENT_LINEAR_IMAGE th;
               MATCH_MP (SET_RULE
   `(!x y. f x = f y ==> x = y)  ==> (!s x. f x IN IMAGE f s <=> x IN s)`)
   (CONJUNCT2 th)]));;

let FACE_OF_CONIC = prove
 (`!s f:real^N->bool. conic s /\ f face_of s ==> conic f`,
  REPEAT GEN_TAC THEN REWRITE_TAC[face_of; conic] THEN STRIP_TAC THEN
  MAP_EVERY X_GEN_TAC [`x:real^N`; `c:real`] THEN STRIP_TAC THEN
  ASM_CASES_TAC `x:real^N = vec 0` THENL
   [ASM_MESON_TAC[VECTOR_MUL_RZERO]; ALL_TAC] THEN
  ASM_CASES_TAC `c = &1` THENL
   [ASM_MESON_TAC[VECTOR_MUL_LID]; ALL_TAC] THEN
  SUBGOAL_THEN `?d e. &0 <= d /\ &0 <= e /\ d < &1 /\ &1 < e /\ d < e /\
                      (d = c \/ e = c)`
  MP_TAC THENL
   [FIRST_X_ASSUM(DISJ_CASES_TAC o MATCH_MP (REAL_ARITH
     `~(c = &1) ==> c < &1 \/ &1 < c`))
    THENL
     [MAP_EVERY EXISTS_TAC [`c:real`; `&2`] THEN ASM_REAL_ARITH_TAC;
      MAP_EVERY EXISTS_TAC [`&1 / &2`; `c:real`] THEN ASM_REAL_ARITH_TAC];
    DISCH_THEN(REPEAT_TCL CHOOSE_THEN
      (REPEAT_TCL CONJUNCTS_THEN ASSUME_TAC)) THEN
    FIRST_X_ASSUM(MP_TAC o SPECL
     [`d % x :real^N`; `e % x:real^N`; `x:real^N`]) THEN
    ANTS_TAC THENL [ALL_TAC; ASM_MESON_TAC[]] THEN
    SUBGOAL_THEN `(x:real^N) IN s` ASSUME_TAC THENL
     [ASM SET_TAC[]; ASM_SIMP_TAC[IN_SEGMENT]] THEN
    ASM_SIMP_TAC[VECTOR_MUL_RCANCEL; REAL_LT_IMP_NE] THEN
    EXISTS_TAC `(&1 - d) / (e - d)`  THEN
    ASM_SIMP_TAC[REAL_LT_LDIV_EQ; REAL_LT_RDIV_EQ; REAL_SUB_LT] THEN
    REPEAT(CONJ_TAC THENL [ASM_REAL_ARITH_TAC; ALL_TAC]) THEN
    REWRITE_TAC[VECTOR_MUL_ASSOC; GSYM VECTOR_ADD_RDISTRIB] THEN
    REWRITE_TAC[VECTOR_ARITH `x:real^N = a % x <=> (a - &1) % x = vec 0`] THEN
    ASM_REWRITE_TAC[VECTOR_MUL_EQ_0] THEN
    UNDISCH_TAC `d:real < e` THEN CONV_TAC REAL_FIELD]);;

let FACE_OF_PCROSS = prove
 (`!f s:real^M->bool f' s':real^N->bool.
        f face_of s /\ f' face_of s' ==> (f PCROSS f') face_of (s PCROSS s')`,
  REPEAT GEN_TAC THEN SIMP_TAC[face_of; CONVEX_PCROSS; PCROSS_MONO] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN
  REWRITE_TAC[IN_SEGMENT; FORALL_IN_PCROSS] THEN
  REWRITE_TAC[RIGHT_IMP_FORALL_THM; IMP_IMP; GSYM CONJ_ASSOC] THEN
  REWRITE_TAC[GSYM PASTECART_CMUL; PASTECART_ADD; PASTECART_INJ] THEN
  REWRITE_TAC[PASTECART_IN_PCROSS] THEN
  MAP_EVERY X_GEN_TAC
   [`a:real^M`; `a':real^N`; `b:real^M`; `b':real^N`] THEN
  MAP_EVERY ASM_CASES_TAC [`b:real^M = a`; `b':real^N = a'`] THEN
  ASM_REWRITE_TAC[VECTOR_ARITH `(&1 - u) % a + u % a:real^N = a`] THEN
  ASM_MESON_TAC[]);;

let FACE_OF_PCROSS_DECOMP = prove
 (`!s:real^M->bool s':real^N->bool c.
        c face_of (s PCROSS s') <=>
        ?f f'. f face_of s /\ f' face_of s' /\ c = f PCROSS f'`,
  REPEAT GEN_TAC THEN EQ_TAC THENL
   [ALL_TAC; STRIP_TAC THEN ASM_SIMP_TAC[FACE_OF_PCROSS]] THEN
  ASM_CASES_TAC `c:real^(M,N)finite_sum->bool = {}` THENL
   [ASM_MESON_TAC[EMPTY_FACE_OF; PCROSS_EMPTY]; DISCH_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_CONVEX) THEN
  MAP_EVERY EXISTS_TAC
   [`IMAGE fstcart (c:real^(M,N)finite_sum->bool)`;
    `IMAGE sndcart (c:real^(M,N)finite_sum->bool)`] THEN
  MATCH_MP_TAC(TAUT `(p /\ q ==> r) /\ p /\ q ==> p /\ q /\ r`) THEN
  CONJ_TAC THENL
   [STRIP_TAC THEN MATCH_MP_TAC FACE_OF_EQ THEN
    EXISTS_TAC `(s:real^M->bool) PCROSS (s':real^N->bool)` THEN
    ASM_SIMP_TAC[FACE_OF_PCROSS; RELATIVE_INTERIOR_PCROSS] THEN
    ASM_SIMP_TAC[RELATIVE_INTERIOR_LINEAR_IMAGE_CONVEX;
                 LINEAR_FSTCART; LINEAR_SNDCART] THEN
    MATCH_MP_TAC(SET_RULE `~(s = {}) /\ s SUBSET t ==> ~DISJOINT s t`) THEN
    ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY] THEN
    REWRITE_TAC[SUBSET; FORALL_PASTECART; PASTECART_IN_PCROSS; IN_IMAGE] THEN
    REWRITE_TAC[EXISTS_PASTECART; FSTCART_PASTECART; SNDCART_PASTECART] THEN
    MESON_TAC[];
    ALL_TAC] THEN
  FIRST_X_ASSUM(STRIP_ASSUME_TAC o GEN_REWRITE_RULE I [face_of]) THEN
  REWRITE_TAC[face_of] THEN
  ASM_SIMP_TAC[CONVEX_LINEAR_IMAGE; LINEAR_FSTCART; LINEAR_SNDCART] THEN
  FIRST_ASSUM(MP_TAC o ISPEC `fstcart:real^(M,N)finite_sum->real^M` o
        MATCH_MP IMAGE_SUBSET) THEN
  FIRST_ASSUM(MP_TAC o ISPEC `sndcart:real^(M,N)finite_sum->real^N` o
        MATCH_MP IMAGE_SUBSET) THEN
  REWRITE_TAC[IMAGE_FSTCART_PCROSS; IMAGE_SNDCART_PCROSS] THEN
  REPEAT(DISCH_THEN(ASSUME_TAC o MATCH_MP (SET_RULE
   `s SUBSET (if p then {} else t) ==> s SUBSET t`))) THEN
  ASM_REWRITE_TAC[] THEN CONJ_TAC THENL
   [MAP_EVERY X_GEN_TAC [`a:real^M`; `b:real^M`; `x:real^M`] THEN
    STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_IMAGE]) THEN
    REWRITE_TAC[EXISTS_PASTECART; FSTCART_PASTECART] THEN
    REWRITE_TAC[RIGHT_EXISTS_AND_THM; UNWIND_THM1] THEN
    DISCH_THEN(X_CHOOSE_TAC `y:real^N`) THEN FIRST_X_ASSUM(MP_TAC o SPECL
     [`pastecart (a:real^M) (y:real^N)`;
      `pastecart (b:real^M) (y:real^N)`;
      `pastecart (x:real^M) (y:real^N)`]) THEN
    ASM_REWRITE_TAC[PASTECART_IN_PCROSS; IN_IMAGE; EXISTS_PASTECART] THEN
    REWRITE_TAC[FSTCART_PASTECART; RIGHT_EXISTS_AND_THM; UNWIND_THM1] THEN
    ANTS_TAC THENL [ALL_TAC; MESON_TAC[]] THEN
    UNDISCH_TAC `(c:real^(M,N)finite_sum->bool) SUBSET s PCROSS s'` THEN
    REWRITE_TAC[SUBSET] THEN
    DISCH_THEN(MP_TAC o SPEC `pastecart (x:real^M) (y:real^N)`);
    MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real^N`; `x:real^N`] THEN
    STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_IMAGE]) THEN
    REWRITE_TAC[EXISTS_PASTECART; SNDCART_PASTECART] THEN
    REWRITE_TAC[RIGHT_EXISTS_AND_THM; UNWIND_THM1] THEN
    DISCH_THEN(X_CHOOSE_TAC `y:real^M`) THEN FIRST_X_ASSUM(MP_TAC o SPECL
     [`pastecart (y:real^M) (a:real^N)`;
      `pastecart (y:real^M) (b:real^N)`;
      `pastecart (y:real^M) (x:real^N)`]) THEN
    ASM_REWRITE_TAC[PASTECART_IN_PCROSS; IN_IMAGE; EXISTS_PASTECART] THEN
    REWRITE_TAC[SNDCART_PASTECART; RIGHT_EXISTS_AND_THM; UNWIND_THM1] THEN
    ANTS_TAC THENL [ALL_TAC; MESON_TAC[]] THEN
    UNDISCH_TAC `(c:real^(M,N)finite_sum->bool) SUBSET s PCROSS s'` THEN
    REWRITE_TAC[SUBSET] THEN
    DISCH_THEN(MP_TAC o SPEC `pastecart (y:real^M) (x:real^N)`)] THEN
  ASM_REWRITE_TAC[PASTECART_IN_PCROSS] THEN STRIP_TAC THEN
  ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_SEGMENT]) THEN
  REWRITE_TAC[IN_SEGMENT; PASTECART_INJ] THEN
  REWRITE_TAC[PASTECART_ADD; GSYM PASTECART_CMUL;
              VECTOR_ARITH `(&1 - u) % a + u % a:real^N = a`] THEN
  MESON_TAC[]);;

let FACE_OF_PCROSS_EQ = prove
 (`!f s:real^M->bool f' s':real^N->bool.
        (f PCROSS f') face_of (s PCROSS s') <=>
        f = {} \/ f' = {} \/ f face_of s /\ f' face_of s'`,
  REPEAT GEN_TAC THEN MAP_EVERY ASM_CASES_TAC
   [`f:real^M->bool = {}`; `f':real^N->bool = {}`] THEN
  ASM_REWRITE_TAC[PCROSS_EMPTY; EMPTY_FACE_OF] THEN
  ASM_REWRITE_TAC[FACE_OF_PCROSS_DECOMP; PCROSS_EQ] THEN MESON_TAC[]);;

let HYPERPLANE_FACE_OF_HALFSPACE_LE = prove
 (`!a:real^N b. {x | a dot x = b} face_of {x | a dot x <= b}`,
  REPEAT GEN_TAC THEN
  ONCE_REWRITE_TAC[REAL_ARITH `a:real = b <=> a <= b /\ a = b`] THEN
  REWRITE_TAC[SET_RULE `{x | P x /\ Q x} = {x | P x} INTER {x | Q x}`] THEN
  MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN
  REWRITE_TAC[IN_ELIM_THM; CONVEX_HALFSPACE_LE]);;

let HYPERPLANE_FACE_OF_HALFSPACE_GE = prove
 (`!a:real^N b. {x | a dot x = b} face_of {x | a dot x >= b}`,
  REPEAT GEN_TAC THEN
  ONCE_REWRITE_TAC[REAL_ARITH `a:real = b <=> a >= b /\ a = b`] THEN
  REWRITE_TAC[SET_RULE `{x | P x /\ Q x} = {x | P x} INTER {x | Q x}`] THEN
  MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE THEN
  REWRITE_TAC[IN_ELIM_THM; CONVEX_HALFSPACE_GE]);;

let FACE_OF_HALFSPACE_LE = prove
 (`!f a:real^N b.
         f face_of {x | a dot x <= b} <=>
         f = {} \/ f = {x | a dot x = b} \/ f = {x | a dot x <= b}`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `a:real^N = vec 0` THENL
   [ASM_SIMP_TAC[DOT_LZERO; SET_RULE `{x | p} = if p then UNIV else {}`] THEN
    REPEAT(COND_CASES_TAC THEN ASM_REWRITE_TAC[FACE_OF_EMPTY]) THEN
    ASM_SIMP_TAC[FACE_OF_AFFINE_EQ; AFFINE_UNIV; DISJ_ACI] THEN
    ASM_REAL_ARITH_TAC;
    ALL_TAC] THEN
  EQ_TAC THEN STRIP_TAC THEN
  ASM_SIMP_TAC[EMPTY_FACE_OF; FACE_OF_REFL; CONVEX_HALFSPACE_LE;
               HYPERPLANE_FACE_OF_HALFSPACE_LE] THEN
  MATCH_MP_TAC(TAUT `(~r ==> p \/ q) ==> p \/ q \/ r`) THEN DISCH_TAC THEN
  SUBGOAL_THEN `f face_of {x:real^N | a dot x = b}` MP_TAC THENL
   [ASM_SIMP_TAC[GSYM FRONTIER_HALFSPACE_LE] THEN
    ASM_SIMP_TAC[CONV_RULE(RAND_CONV SYM_CONV)
                  (SPEC_ALL RELATIVE_FRONTIER_NONEMPTY_INTERIOR);
                 INTERIOR_HALFSPACE_LE; HALFSPACE_EQ_EMPTY_LT] THEN
    MATCH_MP_TAC FACE_OF_SUBSET THEN
    EXISTS_TAC `{x:real^N | a dot x <= b}` THEN
    ASM_SIMP_TAC[FACE_OF_SUBSET_RELATIVE_FRONTIER] THEN
    ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED; CLOSED_HALFSPACE_LE] THEN
    SET_TAC[];
    ASM_SIMP_TAC[FACE_OF_AFFINE_EQ; AFFINE_HYPERPLANE]]);;

let FACE_OF_HALFSPACE_GE = prove
 (`!f a:real^N b.
         f face_of {x | a dot x >= b} <=>
         f = {} \/ f = {x | a dot x = b} \/ f = {x | a dot x >= b}`,
  REPEAT GEN_TAC THEN
  MP_TAC(ISPECL [`f:real^N->bool`; `--a:real^N`; `--b:real`]
        FACE_OF_HALFSPACE_LE) THEN
  REWRITE_TAC[DOT_LNEG; REAL_LE_NEG2; REAL_EQ_NEG2; real_ge]);;

let RELATIVE_BOUNDARY_POINT_IN_PROPER_FACE = prove
 (`!s x:real^N.
        convex s /\ x IN s /\ ~(x IN relative_interior s)
        ==> ?f. f face_of s /\ ~(f = s) /\ x IN f`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `x:real^N`]
        SUPPORTING_HYPERPLANE_RELATIVE_FRONTIER) THEN
  ASM_SIMP_TAC[relative_frontier; IN_DIFF;
               REWRITE_RULE[SUBSET] CLOSURE_SUBSET] THEN
  DISCH_THEN(X_CHOOSE_THEN `a:real^N` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `s INTER {y:real^N | a dot y = a dot x}` THEN
  ASM_REWRITE_TAC[IN_INTER; IN_ELIM_THM] THEN CONJ_TAC THENL
   [MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE THEN
    ASM_MESON_TAC[SUBSET; CLOSURE_SUBSET; real_ge];
    SUBGOAL_THEN `~(relative_interior s:real^N->bool = {})` MP_TAC THENL
     [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY] THEN ASM SET_TAC[];
      MATCH_MP_TAC(SET_RULE
       `(!x. x IN i ==> x IN s /\ ~(x IN t)) ==> ~(i = {}) ==> ~(t = s)`) THEN
      X_GEN_TAC `y:real^N` THEN DISCH_TAC THEN
      ASM_SIMP_TAC[IN_INTER; REWRITE_RULE[SUBSET]
                   RELATIVE_INTERIOR_SUBSET] THEN
      ASM_SIMP_TAC[IN_ELIM_THM; REAL_LT_IMP_NE]]]);;

let RELATIVE_FRONTIER_OF_CONVEX_CLOSED = prove
 (`!s:real^N->bool.
        convex s /\ closed s
        ==> relative_frontier s = UNIONS {f | f face_of s /\ ~(f = s)}`,
  REPEAT STRIP_TAC THEN ONCE_REWRITE_TAC[EXTENSION] THEN
  ASM_SIMP_TAC[relative_frontier; UNIONS_GSPEC; IN_ELIM_THM;
               CLOSURE_CLOSED; IN_DIFF] THEN
  X_GEN_TAC `x:real^N` THEN EQ_TAC THENL
   [ASM_MESON_TAC[RELATIVE_BOUNDARY_POINT_IN_PROPER_FACE]; ALL_TAC] THEN
  DISCH_THEN(CHOOSE_THEN (CONJUNCTS_THEN2 MP_TAC ASSUME_TAC)) THEN
  DISCH_THEN(MP_TAC o MATCH_MP FACE_OF_SUBSET_RELATIVE_BOUNDARY) THEN
  ASM SET_TAC[]);;

let IN_RELATIVE_INTERIOR_OF_FACE = prove
 (`!s:real^N->bool x.
        convex s /\ x IN s ==> ?f. f face_of s /\ x IN relative_interior f`,
  REPEAT STRIP_TAC THEN
  EXISTS_TAC `INTERS {f | f face_of s /\ (x:real^N) IN f}` THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [MATCH_MP_TAC FACE_OF_INTERS THEN
    SIMP_TAC[FORALL_IN_GSPEC; GSYM MEMBER_NOT_EMPTY] THEN
    REWRITE_TAC[IN_ELIM_THM] THEN ASM_MESON_TAC[FACE_OF_REFL];
    DISCH_TAC] THEN
  MATCH_MP_TAC(SET_RULE
   `x IN s /\ ~(x IN s /\ ~(x IN relative_interior s))
    ==> x IN relative_interior s`) THEN
  CONJ_TAC THENL [SET_TAC[]; ALL_TAC] THEN DISCH_THEN(MP_TAC o MATCH_MP
   (ONCE_REWRITE_RULE[IMP_CONJ_ALT]
      RELATIVE_BOUNDARY_POINT_IN_PROPER_FACE)) THEN
  REWRITE_TAC[NOT_IMP] THEN CONJ_TAC THENL
   [ASM_MESON_TAC[FACE_OF_IMP_CONVEX]; ALL_TAC] THEN
  DISCH_THEN(X_CHOOSE_THEN `f:real^N->bool` STRIP_ASSUME_TAC) THEN
  FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
   `~(s = t) ==> s SUBSET t /\ t SUBSET s ==> F`)) THEN
  ASM_SIMP_TAC[FACE_OF_IMP_SUBSET] THEN
  MATCH_MP_TAC(SET_RULE `f IN t ==> INTERS t SUBSET f`) THEN
  ASM_REWRITE_TAC[IN_ELIM_THM] THEN ASM_MESON_TAC[FACE_OF_TRANS]);;

let CONVEX_FACIAL_PARTITION = prove
 (`!s:real^N->bool.
        convex s ==> UNIONS {relative_interior f | f face_of s} = s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[UNIONS_GSPEC; EXTENSION; IN_ELIM_THM] THEN
  ASM_MESON_TAC[IN_RELATIVE_INTERIOR_OF_FACE; FACE_OF_IMP_SUBSET; SUBSET;
                RELATIVE_INTERIOR_SUBSET]);;

let IN_RELATIVE_INTERIOR_OF_UNIQUE_FACE = prove
 (`!s:real^N->bool x.
        convex s /\ x IN s ==> ?!f. f face_of s /\ x IN relative_interior f`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[EXISTS_UNIQUE_DEF] THEN
  ASM_SIMP_TAC[IN_RELATIVE_INTERIOR_OF_FACE] THEN
  REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_EQ THEN
  EXISTS_TAC `s:real^N->bool` THEN ASM SET_TAC[]);;

let RELATIVE_INTERIOR_SUBSET_OF_PROPER_FACE = prove
 (`!s t:real^N->bool.
        convex s /\ t SUBSET s /\
        ~(relative_interior t DIFF relative_interior s = {})
        ==> ?f. f face_of s /\ ~(f = s) /\ t SUBSET f`,
  REPEAT GEN_TAC THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `a:real^N` THEN REWRITE_TAC[IN_INTER; IN_DIFF] THEN STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `a:real^N`]
        RELATIVE_BOUNDARY_POINT_IN_PROPER_FACE) THEN
  ANTS_TAC THENL
   [ASM_MESON_TAC[SUBSET; RELATIVE_INTERIOR_SUBSET]; ALL_TAC] THEN
  MATCH_MP_TAC MONO_EXISTS THEN
  GEN_TAC THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC SUBSET_OF_FACE_OF THEN EXISTS_TAC `s:real^N->bool` THEN
  ASM SET_TAC[]);;

let CONVEX_RELATIVE_BOUNDARY_SUBSET_OF_PROPER_FACE = prove
 (`!s t:real^N->bool.
        convex s /\ ~(s = {}) /\
        convex t /\ t SUBSET s DIFF relative_interior s
        ==> ?f. f face_of s /\ ~(f = s) /\ t SUBSET f`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `t:real^N->bool = {}` THENL
   [EXISTS_TAC `{}:real^N->bool` THEN
    ASM_REWRITE_TAC[EMPTY_FACE_OF; SUBSET_REFL];
    MATCH_MP_TAC RELATIVE_INTERIOR_SUBSET_OF_PROPER_FACE THEN
    MP_TAC(ISPEC `t:real^N->bool` RELATIVE_INTERIOR_EQ_EMPTY) THEN
    MP_TAC(ISPEC `t:real^N->bool` RELATIVE_INTERIOR_SUBSET) THEN
    ASM SET_TAC[]]);;

let RELATIVE_FRONTIER_FACIAL_PARTITION_ALT = prove
 (`!s:real^N->bool.
        convex s /\ closed s
        ==> UNIONS { relative_interior f | f face_of s /\ ~(f = s)} =
            relative_frontier s`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN
  FIRST_ASSUM(fun th ->
   GEN_REWRITE_TAC (RAND_CONV o LAND_CONV)
     [GSYM(MATCH_MP CONVEX_FACIAL_PARTITION th)]) THEN
  MATCH_MP_TAC(SET_RULE
   `u UNION s = t /\ DISJOINT u s ==> s = t DIFF u`) THEN
  CONJ_TAC THENL
   [ASM_SIMP_TAC[FACE_OF_REFL; GSYM UNIONS_INSERT; SET_RULE
     `P a ==> f a INSERT {f x | P x /\ ~(x = a)} = {f x | P x}`];
    REWRITE_TAC[DISJOINT; INTER_UNIONS; EMPTY_UNIONS; FORALL_IN_GSPEC] THEN
    REWRITE_TAC[GSYM DISJOINT] THEN ASM_MESON_TAC[FACE_OF_EQ; FACE_OF_REFL]]);;

let RELATIVE_FRONTIER_FACIAL_PARTITION = prove
 (`!s:real^N->bool.
        convex s /\ closed s
        ==> UNIONS { relative_interior f |
                     f face_of s /\ aff_dim f < aff_dim s} =
            relative_frontier s`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[GSYM RELATIVE_FRONTIER_FACIAL_PARTITION_ALT] THEN
  AP_TERM_TAC THEN MATCH_MP_TAC(SET_RULE
   `(!x. P x ==> (Q x <=> R x))
    ==> {f x | P x /\ Q x} = {f x | P x /\ R x}`) THEN
  ASM_MESON_TAC[FACE_OF_AFF_DIM_LT; INT_LT_REFL; FACE_OF_REFL]);;

let FRONTIER_OF_CONVEX_CLOSED = prove
 (`!s:real^N->bool.
        convex s /\ closed s
        ==> frontier s =
            UNIONS {f | f face_of s /\ aff_dim f < &(dimindex(:N))}`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ] THEN
  REWRITE_TAC[UNIONS_SUBSET; FORALL_IN_GSPEC] THEN
  CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[FACE_OF_SUBSET_FRONTIER_AFF_DIM]] THEN
  ASM_SIMP_TAC[frontier; CLOSURE_CLOSED] THEN FIRST_ASSUM(fun th ->
   GEN_REWRITE_TAC (LAND_CONV o LAND_CONV)
        [SYM(MATCH_MP CONVEX_FACIAL_PARTITION th)]) THEN
  REWRITE_TAC[UNIONS_GSPEC; SUBSET; IN_DIFF; IN_ELIM_THM] THEN
  X_GEN_TAC `z:real^N` THEN DISCH_THEN(CONJUNCTS_THEN2
   (X_CHOOSE_THEN `f:real^N->bool` STRIP_ASSUME_TAC) ASSUME_TAC) THEN
  EXISTS_TAC `f:real^N->bool` THEN ASM_REWRITE_TAC[] THEN CONJ_TAC THENL
   [ALL_TAC; ASM_MESON_TAC[SUBSET; RELATIVE_INTERIOR_SUBSET]] THEN
  REWRITE_TAC[INT_LT_LE; AFF_DIM_LE_UNIV] THEN DISCH_TAC THEN
  MP_TAC(ISPEC `f:real^N->bool` RELATIVE_INTERIOR_INTERIOR) THEN
  ASM_REWRITE_TAC[GSYM AFF_DIM_EQ_FULL] THEN DISCH_THEN SUBST_ALL_TAC THEN
  MP_TAC(ISPECL [`f:real^N->bool`; `s:real^N->bool`] SUBSET_INTERIOR) THEN
  ASM_SIMP_TAC[FACE_OF_IMP_SUBSET] THEN ASM SET_TAC[]);;

let FACE_OF_INTER_AS_INTER_OF_FACE = prove
 (`!s t f:real^N->bool.
        convex s /\ convex t /\ f face_of (s INTER t)
        ==> ?k l. k face_of s /\ l face_of t /\ k INTER l = f`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `relative_interior f:real^N->bool = {}` THENL
   [REPEAT(EXISTS_TAC `{}:real^N->bool`) THEN REWRITE_TAC[EMPTY_FACE_OF] THEN
    MP_TAC(ISPEC `f:real^N->bool` RELATIVE_INTERIOR_EQ_EMPTY) THEN
    REWRITE_TAC[INTER_EMPTY] THEN ASM_MESON_TAC[face_of];
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  DISCH_THEN(X_CHOOSE_THEN `x:real^N` STRIP_ASSUME_TAC) THEN
  MAP_EVERY (MP_TAC o C SPEC CONVEX_FACIAL_PARTITION)
   [`t:real^N->bool`; `s:real^N->bool`] THEN
  ASM_REWRITE_TAC[EXTENSION; IMP_IMP; AND_FORALL_THM] THEN
  DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN REWRITE_TAC[UNIONS_GSPEC] THEN
  SUBGOAL_THEN `(x:real^N) IN s /\ x IN t` STRIP_ASSUME_TAC THENL
   [FIRST_ASSUM(MP_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
    MP_TAC(ISPEC `f:real^N->bool` RELATIVE_INTERIOR_SUBSET) THEN
    ASM SET_TAC[];
    ASM_REWRITE_TAC[IN_ELIM_THM]] THEN
  REWRITE_TAC[LEFT_AND_EXISTS_THM] THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `k:real^N->bool` THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `l:real^N->bool` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[GSYM EXTENSION] THEN
  MATCH_MP_TAC FACE_OF_EQ THEN
  EXISTS_TAC `s INTER t:real^N->bool` THEN
  ASM_SIMP_TAC[FACE_OF_INTER_INTER] THEN
  MP_TAC(ISPECL [`k:real^N->bool`; `l:real^N->bool`]
        INTER_RELATIVE_INTERIOR_SUBSET) THEN
  ANTS_TAC THENL [ASM_MESON_TAC[FACE_OF_IMP_CONVEX]; ASM SET_TAC[]]);;

(* ------------------------------------------------------------------------- *)
(* Exposed faces (faces that are intersection with supporting hyperplane).   *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("exposed_face_of",(12,"right"));;

let exposed_face_of = new_definition
 `t exposed_face_of s <=>
    t face_of s /\
    ?a b. s SUBSET {x | a dot x <= b} /\ t = s INTER {x | a dot x = b}`;;

let EXPOSED_FACE_OF_IMP_FACE_OF = prove
 (`!s t:real^N->bool. t exposed_face_of s ==> t face_of s`,
  SIMP_TAC[exposed_face_of]);;

let EMPTY_EXPOSED_FACE_OF = prove
 (`!s:real^N->bool. {} exposed_face_of s`,
  GEN_TAC THEN REWRITE_TAC[exposed_face_of; EMPTY_FACE_OF] THEN
  MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `&1:real`] THEN
  REWRITE_TAC[DOT_LZERO] THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN SET_TAC[]);;

let EXPOSED_FACE_OF_REFL_EQ = prove
 (`!s:real^N->bool. s exposed_face_of s <=> convex s`,
  GEN_TAC THEN REWRITE_TAC[exposed_face_of; FACE_OF_REFL_EQ] THEN
  ASM_CASES_TAC `convex(s:real^N->bool)` THEN ASM_REWRITE_TAC[] THEN
  MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `&0:real`] THEN
  REWRITE_TAC[DOT_LZERO] THEN CONV_TAC REAL_RAT_REDUCE_CONV THEN SET_TAC[]);;

let EXPOSED_FACE_OF_REFL = prove
 (`!s:real^N->bool. convex s ==> s exposed_face_of s`,
  REWRITE_TAC[EXPOSED_FACE_OF_REFL_EQ]);;

let EXPOSED_FACE_OF = prove
 (`!s t. t exposed_face_of s <=>
             t face_of s /\
             (t = {} \/ t = s \/
              ?a b. ~(a = vec 0) /\
                    s SUBSET {x:real^N | a dot x <= b} /\
                    t = s INTER {x | a dot x = b})`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[EMPTY_EXPOSED_FACE_OF; EMPTY_FACE_OF] THEN
  ASM_CASES_TAC `t:real^N->bool = s` THEN
  ASM_REWRITE_TAC[EXPOSED_FACE_OF_REFL_EQ; FACE_OF_REFL_EQ] THEN
  REWRITE_TAC[exposed_face_of] THEN AP_TERM_TAC THEN
  EQ_TAC THENL [REWRITE_TAC[LEFT_IMP_EXISTS_THM]; MESON_TAC[]] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real`] THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MAP_EVERY EXISTS_TAC [`a:real^N`; `b:real`] THEN
  ASM_CASES_TAC `a:real^N = vec 0` THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM SUBST_ALL_TAC THEN REPEAT(POP_ASSUM MP_TAC) THEN
  REWRITE_TAC[DOT_LZERO] THEN SET_TAC[]);;

let EXPOSED_FACE_OF_TRANSLATION_EQ = prove
 (`!a f s:real^N->bool.
        (IMAGE (\x. a + x) f) exposed_face_of (IMAGE (\x. a + x) s) <=>
        f exposed_face_of s`,
  REPEAT GEN_TAC THEN REWRITE_TAC[exposed_face_of; FACE_OF_TRANSLATION_EQ] THEN
  MP_TAC(ISPEC `\x:real^N. a + x` QUANTIFY_SURJECTION_THM) THEN
  REWRITE_TAC[] THEN ANTS_TAC THENL
   [MESON_TAC[VECTOR_ARITH `y + (x - y):real^N = x`]; ALL_TAC] THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV)
    [last(CONJUNCTS th)]) THEN
  REWRITE_TAC[end_itlist CONJ (!invariant_under_translation)] THEN
  REWRITE_TAC[DOT_RADD] THEN ONCE_REWRITE_TAC[REAL_ADD_SYM] THEN
  REWRITE_TAC[GSYM REAL_LE_SUB_LADD; GSYM REAL_EQ_SUB_LADD] THEN
  AP_TERM_TAC THEN AP_TERM_TAC THEN GEN_REWRITE_TAC I [FUN_EQ_THM] THEN
  X_GEN_TAC `c:real^N` THEN REWRITE_TAC[] THEN
  EQ_TAC THEN DISCH_THEN(X_CHOOSE_THEN `b:real` STRIP_ASSUME_TAC) THENL
   [EXISTS_TAC `b - (c:real^N) dot a`;
    EXISTS_TAC `b + (c:real^N) dot a`] THEN
  ASM_REWRITE_TAC[REAL_ARITH `(x + y) - y:real = x`]);;

add_translation_invariants [EXPOSED_FACE_OF_TRANSLATION_EQ];;

let EXPOSED_FACE_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N c s.
      linear f /\ (!x y. f x = f y ==> x = y) /\ (!y. ?x. f x = y)
      ==> ((IMAGE f c) exposed_face_of (IMAGE f s) <=> c exposed_face_of s)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[exposed_face_of] THEN
  BINOP_TAC THENL [ASM_MESON_TAC[FACE_OF_LINEAR_IMAGE]; ALL_TAC] THEN
  MP_TAC(ISPEC `f:real^M->real^N` QUANTIFY_SURJECTION_THM) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV)
    [last(CONJUNCTS th)]) THEN
  ONCE_REWRITE_TAC[DOT_SYM] THEN ASM_SIMP_TAC[ADJOINT_WORKS] THEN
  MP_TAC(end_itlist CONJ
   (mapfilter (ISPEC `f:real^M->real^N`) (!invariant_under_linear))) THEN
  ASM_REWRITE_TAC[] THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
  ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN AP_TERM_TAC THEN ABS_TAC THEN
  EQ_TAC THENL
   [DISCH_THEN(X_CHOOSE_THEN `a:real^N` STRIP_ASSUME_TAC) THEN
    EXISTS_TAC `adjoint(f:real^M->real^N) a` THEN ASM_REWRITE_TAC[];
    DISCH_THEN(X_CHOOSE_THEN `a:real^M` STRIP_ASSUME_TAC) THEN
    MP_TAC(ISPEC `adjoint(f:real^M->real^N)`
      LINEAR_SURJECTIVE_RIGHT_INVERSE) THEN
    ASM_SIMP_TAC[ADJOINT_SURJECTIVE; ADJOINT_LINEAR] THEN
    REWRITE_TAC[FUN_EQ_THM; o_THM; I_THM; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `g:real^M->real^N` THEN STRIP_TAC THEN
    EXISTS_TAC `(g:real^M->real^N) a` THEN ASM_REWRITE_TAC[]]);;

let EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE = prove
 (`!s a:real^N b.
        convex s /\ (!x. x IN s ==> a dot x <= b)
        ==> (s INTER {x | a dot x = b}) exposed_face_of s`,
  SIMP_TAC[FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE; exposed_face_of] THEN
  SET_TAC[]);;

let EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE = prove
 (`!s a:real^N b.
        convex s /\ (!x. x IN s ==> a dot x >= b)
        ==> (s INTER {x | a dot x = b}) exposed_face_of s`,
  REWRITE_TAC[real_ge] THEN REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `--a:real^N`; `--b:real`]
    EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE) THEN
  ASM_REWRITE_TAC[DOT_LNEG; REAL_EQ_NEG2; REAL_LE_NEG2]);;

let EXPOSED_FACE_OF_INTER = prove
 (`!s t u:real^N->bool.
        t exposed_face_of s /\ u exposed_face_of s
        ==> (t INTER u) exposed_face_of s`,
  REPEAT GEN_TAC THEN SIMP_TAC[exposed_face_of; FACE_OF_INTER] THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM] THEN
  REWRITE_TAC[LEFT_AND_EXISTS_THM; LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`a':real^N`; `b':real`; `a:real^N`; `b:real`] THEN
  REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN STRIP_TAC THEN
  ASM_REWRITE_TAC[] THEN
  MAP_EVERY EXISTS_TAC [`a + a':real^N`; `b + b':real`] THEN
  REWRITE_TAC[SET_RULE
   `(s INTER t1) INTER (s INTER t2) = s INTER u <=>
    !x. x IN s ==> (x IN t1 /\ x IN t2 <=> x IN u)`] THEN
  ASM_SIMP_TAC[DOT_LADD; REAL_LE_ADD2; IN_ELIM_THM] THEN
  X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
  REPEAT(FIRST_X_ASSUM(MP_TAC o SPEC `x:real^N`)) THEN
  ASM_REWRITE_TAC[] THEN REAL_ARITH_TAC);;

let EXPOSED_FACE_OF_INTERS = prove
 (`!P s:real^N->bool.
        ~(P = {}) /\ (!t. t IN P ==> t exposed_face_of s)
        ==> INTERS P exposed_face_of s`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `P:(real^N->bool)->bool`]
    INTERS_FACES_FINITE_ALTBOUND) THEN
  ANTS_TAC THENL [ASM_MESON_TAC[exposed_face_of]; ALL_TAC] THEN
  DISCH_THEN(X_CHOOSE_THEN `Q:(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
  FIRST_X_ASSUM(MP_TAC o SYM) THEN
  ASM_CASES_TAC `Q:(real^N->bool)->bool = {}` THENL
   [ASM_SIMP_TAC[INTERS_0] THEN
    REWRITE_TAC[SET_RULE `INTERS s = UNIV <=> !t. t IN s ==> t = UNIV`] THEN
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
    ASM_MESON_TAC[];
    DISCH_THEN SUBST1_TAC THEN
    FIRST_X_ASSUM(MP_TAC o check (is_neg o concl)) THEN
    SUBGOAL_THEN `!t:real^N->bool. t IN Q ==> t exposed_face_of s` MP_TAC THENL
     [ASM SET_TAC[]; UNDISCH_TAC `FINITE(Q:(real^N->bool)->bool)`] THEN
    SPEC_TAC(`Q:(real^N->bool)->bool`,`Q:(real^N->bool)->bool`) THEN
    POP_ASSUM_LIST(K ALL_TAC) THEN
    MATCH_MP_TAC FINITE_INDUCT_STRONG THEN REWRITE_TAC[FORALL_IN_INSERT] THEN
    MAP_EVERY X_GEN_TAC [`t:real^N->bool`; `P:(real^N->bool)->bool`] THEN
    DISCH_THEN(fun th -> STRIP_TAC THEN MP_TAC th) THEN ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[INTERS_INSERT] THEN
    ASM_CASES_TAC `P:(real^N->bool)->bool = {}` THEN
    ASM_SIMP_TAC[INTERS_0; INTER_UNIV; EXPOSED_FACE_OF_INTER]]);;

let EXPOSED_FACE_OF_SUMS = prove
 (`!s t f:real^N->bool.
        convex s /\ convex t /\
        f exposed_face_of {x + y | x IN s /\ y IN t}
        ==> ?k l. k exposed_face_of s /\ l exposed_face_of t /\
                  f = {x + y | x IN k /\ y IN l}`,
  REPEAT STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [EXPOSED_FACE_OF]) THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  ASM_CASES_TAC `f:real^N->bool = {}` THENL
   [DISCH_TAC THEN REPEAT (EXISTS_TAC `{}:real^N->bool`) THEN
    ASM_REWRITE_TAC[EMPTY_EXPOSED_FACE_OF] THEN SET_TAC[];
    ALL_TAC] THEN
  ASM_CASES_TAC `f = {x + y :real^N | x IN s /\ y IN t}` THENL
   [DISCH_TAC THEN
    MAP_EVERY EXISTS_TAC [`s:real^N->bool`; `t:real^N->bool`] THEN
    ASM_SIMP_TAC[EXPOSED_FACE_OF_REFL];
    ALL_TAC] THEN
  ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC [`u:real^N`; `z:real`] THEN
  REWRITE_TAC[SUBSET; FORALL_IN_GSPEC; IN_ELIM_THM] THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  DISCH_THEN SUBST_ALL_TAC THEN
  RULE_ASSUM_TAC(REWRITE_RULE[GSYM SUBSET_INTER_ABSORPTION]) THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  REWRITE_TAC[EXISTS_IN_GSPEC; IN_INTER] THEN
  REWRITE_TAC[IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC [`a0:real^N`; `b0:real^N`] THEN STRIP_TAC THEN
  FIRST_X_ASSUM(SUBST_ALL_TAC o SYM) THEN
  EXISTS_TAC `s INTER {x:real^N | u dot x = u dot a0}` THEN
  EXISTS_TAC `t INTER {y:real^N | u dot y = u dot b0}` THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN
    ASM_REWRITE_TAC[] THEN X_GEN_TAC `a:real^N` THEN DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`a:real^N`; `b0:real^N`]) THEN
    ASM_REWRITE_TAC[DOT_RADD] THEN REAL_ARITH_TAC;
    MATCH_MP_TAC EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN
    ASM_REWRITE_TAC[] THEN X_GEN_TAC `b:real^N` THEN DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`a0:real^N`; `b:real^N`]) THEN
    ASM_REWRITE_TAC[DOT_RADD] THEN REAL_ARITH_TAC;
    ALL_TAC] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THEN
  REWRITE_TAC[SUBSET; FORALL_IN_GSPEC; IN_INTER; IMP_CONJ] THENL
   [ALL_TAC; SIMP_TAC[IN_INTER; IN_ELIM_THM; DOT_RADD] THEN MESON_TAC[]] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real^N`] THEN
  DISCH_TAC THEN DISCH_TAC THEN REWRITE_TAC[IN_ELIM_THM; DOT_RADD] THEN
  DISCH_TAC THEN MAP_EVERY EXISTS_TAC [`a:real^N`; `b:real^N`] THEN
  ASM_REWRITE_TAC[] THEN
  FIRST_ASSUM(MP_TAC o SPECL  [`a:real^N`; `b0:real^N`]) THEN
  FIRST_X_ASSUM(MP_TAC o SPECL  [`a0:real^N`; `b:real^N`]) THEN
  ASM_REWRITE_TAC[DOT_RADD] THEN ASM_REAL_ARITH_TAC);;

let EXPOSED_FACE_OF_PARALLEL = prove
 (`!t s. t exposed_face_of s <=>
         t face_of s /\
          ?a b. s SUBSET {x:real^N | a dot x <= b} /\
                t = s INTER {x | a dot x = b} /\
                (~(t = {}) /\ ~(t = s) ==> ~(a = vec 0)) /\
                (!w. w IN affine hull s /\ ~(t = s)
                     ==> (w + a) IN affine hull s)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[exposed_face_of] THEN
  AP_TERM_TAC THEN EQ_TAC THENL
   [REWRITE_TAC[LEFT_IMP_EXISTS_THM];
    REPEAT(MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC) THEN SIMP_TAC[]] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real`] THEN STRIP_TAC THEN
  MP_TAC(ISPECL [`affine hull s:real^N->bool`; `--a:real^N`; `--b:real`]
        AFFINE_PARALLEL_SLICE) THEN
  SIMP_TAC[AFFINE_AFFINE_HULL; DOT_LNEG; REAL_LE_NEG2; REAL_EQ_NEG2] THEN
  DISCH_THEN(REPEAT_TCL DISJ_CASES_THEN ASSUME_TAC) THENL
   [MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `&1`] THEN
    REWRITE_TAC[DOT_LZERO; REAL_POS; SET_RULE `{x | T} = UNIV`] THEN
    SIMP_TAC[SUBSET_UNIV; VECTOR_ADD_RID; REAL_ARITH `~(&0 = &1)`] THEN
    REWRITE_TAC[EMPTY_GSPEC] THEN ASM_REWRITE_TAC[INTER_EMPTY] THEN
    MATCH_MP_TAC(TAUT `p ==> p /\ ~(~p /\ q)`) THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
     `s' INTER t' = {}
      ==> s SUBSET s' /\ t SUBSET t' ==> s INTER t = {}`)) THEN
    REWRITE_TAC[HULL_SUBSET] THEN SIMP_TAC[SUBSET; IN_ELIM_THM; REAL_LE_REFL];
    SUBGOAL_THEN `t:real^N->bool = s` SUBST1_TAC THENL
     [FIRST_X_ASSUM SUBST1_TAC THEN REWRITE_TAC[GSYM REAL_LE_ANTISYM] THEN
      SUBGOAL_THEN `s SUBSET affine hull (s:real^N->bool)` MP_TAC THENL
       [REWRITE_TAC[HULL_SUBSET]; ASM SET_TAC[]];
      MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `&0`] THEN
      REWRITE_TAC[DOT_LZERO; SET_RULE `{x | T} = UNIV`; REAL_LE_REFL] THEN
      SET_TAC[]];
    FIRST_X_ASSUM(X_CHOOSE_THEN `a':real^N` MP_TAC) THEN
    DISCH_THEN(X_CHOOSE_THEN `b':real` STRIP_ASSUME_TAC) THEN
    MAP_EVERY EXISTS_TAC [`--a':real^N`; `--b':real`] THEN
    ASM_REWRITE_TAC[DOT_LNEG; REAL_LE_NEG2; REAL_EQ_NEG2] THEN
    REPEAT CONJ_TAC THENL
     [ONCE_REWRITE_TAC[REAL_ARITH `b <= a <=> ~(a <= b) \/ a = b`] THEN
      MATCH_MP_TAC(SET_RULE
       `!s'. s SUBSET s' /\
            s SUBSET (UNIV DIFF (s' INTER {x | P x})) UNION
                     (s' INTER {x | Q x})
            ==> s SUBSET {x | ~P x \/ Q x}`) THEN
      EXISTS_TAC `affine hull s:real^N->bool` THEN
      ASM_REWRITE_TAC[HULL_SUBSET] THEN
      MATCH_MP_TAC(SET_RULE
       `s SUBSET s' /\ s SUBSET (UNIV DIFF {x | P x}) UNION {x | Q x}
        ==> s SUBSET (UNIV DIFF (s' INTER {x | P x})) UNION
                     (s' INTER {x | Q x})`) THEN
      REWRITE_TAC[HULL_SUBSET] THEN MATCH_MP_TAC SUBSET_TRANS THEN
      EXISTS_TAC `{x:real^N | a dot x <= b}` THEN ASM_REWRITE_TAC[] THEN
      REWRITE_TAC[SUBSET; IN_DIFF; IN_UNIV; IN_UNION; IN_ELIM_THM] THEN
      REAL_ARITH_TAC;
      FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
       `s' INTER a = s' INTER b
        ==> s SUBSET s' ==> s INTER b = s INTER a`)) THEN
      REWRITE_TAC[HULL_SUBSET];
      ASM_REWRITE_TAC[VECTOR_NEG_EQ_0];
      ONCE_REWRITE_TAC[VECTOR_ARITH
       `w + --a:real^N = w + &1 % (w - (w + a))`] THEN
      ASM_SIMP_TAC[IN_AFFINE_ADD_MUL_DIFF; AFFINE_AFFINE_HULL]]]);;

let RELATIVE_BOUNDARY_POINT_IN_EXPOSED_FACE = prove
 (`!s x:real^N.
           convex s /\ x IN s /\ ~(x IN relative_interior s)
           ==> ?f. f exposed_face_of s /\ ~(f = s) /\ x IN f`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `x:real^N`]
        SUPPORTING_HYPERPLANE_RELATIVE_BOUNDARY) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(X_CHOOSE_THEN `a:real^N` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `s INTER {y:real^N | a dot y = a dot x}` THEN
  ASM_REWRITE_TAC[IN_ELIM_THM; IN_INTER] THEN CONJ_TAC THENL
   [MATCH_MP_TAC EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE THEN
    ASM_REWRITE_TAC[real_ge];
    SUBGOAL_THEN `~(relative_interior s:real^N->bool = {})` MP_TAC THENL
     [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY] THEN ASM SET_TAC[];
      REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; EXTENSION; NOT_FORALL_THM]] THEN
    MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `z:real^N` THEN
    SIMP_TAC[IN_INTER; REWRITE_RULE[SUBSET] RELATIVE_INTERIOR_SUBSET] THEN
    ASM_SIMP_TAC[IN_ELIM_THM; REAL_LT_IMP_NE]]);;

(* ------------------------------------------------------------------------- *)
(* Extreme points of a set, which are its singleton faces.                   *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("extreme_point_of",(12,"right"));;

let extreme_point_of = new_definition
 `x extreme_point_of s <=>
    x IN s /\ !a b. a IN s /\ b IN s ==> ~(x IN segment(a,b))`;;

let EXTREME_POINT_OF_STILLCONVEX = prove
 (`!s x:real^N.
        convex s ==> (x extreme_point_of s <=> x IN s /\ convex(s DELETE x))`,
  REWRITE_TAC[CONVEX_CONTAINS_SEGMENT; extreme_point_of; open_segment] THEN
  REWRITE_TAC[IN_DIFF; IN_DELETE; IN_INSERT; NOT_IN_EMPTY; SUBSET_DELETE] THEN
  SET_TAC[]);;

let FACE_OF_SING = prove
 (`!x s. {x} face_of s <=> x extreme_point_of s`,
  SIMP_TAC[face_of; extreme_point_of; SING_SUBSET; CONVEX_SING; IN_SING] THEN
  MESON_TAC[SEGMENT_REFL; NOT_IN_EMPTY]);;

let FACE_OF_AFF_DIM_0 = prove
 (`!s f:real^N->bool.
        f face_of s /\ aff_dim f = &0 <=> ?a. a extreme_point_of s /\ f = {a}`,
  REPEAT GEN_TAC THEN REWRITE_TAC[AFF_DIM_EQ_0] THEN MESON_TAC[FACE_OF_SING]);;

let EXTREME_POINT_NOT_IN_RELATIVE_INTERIOR = prove
 (`!s x:real^N.
        x extreme_point_of s /\ ~(s = {x})
        ==> ~(x IN relative_interior s)`,
  REPEAT GEN_TAC THEN CONV_TAC(ONCE_DEPTH_CONV SYM_CONV) THEN
  REWRITE_TAC[GSYM FACE_OF_SING] THEN
  DISCH_THEN(MP_TAC o MATCH_MP FACE_OF_DISJOINT_RELATIVE_INTERIOR) THEN
  SET_TAC[]);;

let EXTREME_POINT_NOT_IN_INTERIOR = prove
 (`!s x:real^N. x extreme_point_of s ==> ~(x IN interior s)`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN ASM_CASES_TAC `s = {x:real^N}` THEN
  ASM_SIMP_TAC[EMPTY_INTERIOR_FINITE; FINITE_SING; NOT_IN_EMPTY] THEN
  DISCH_THEN(MP_TAC o MATCH_MP (REWRITE_RULE[SUBSET]
    INTERIOR_SUBSET_RELATIVE_INTERIOR)) THEN
  ASM_SIMP_TAC[EXTREME_POINT_NOT_IN_RELATIVE_INTERIOR]);;

let EXTREME_POINT_IN_RELATIVE_FRONTIER = prove
 (`!s x:real^N.
        x extreme_point_of s /\ ~(s = {x}) ==> x IN relative_frontier s`,
  SIMP_TAC[EXTREME_POINT_NOT_IN_RELATIVE_INTERIOR;
           relative_frontier; IN_DIFF] THEN
  SIMP_TAC[extreme_point_of; REWRITE_RULE[SUBSET] CLOSURE_SUBSET]);;

let EXTREME_POINT_OF_FACE = prove
 (`!f s v. f face_of s
           ==> (v extreme_point_of f <=> v extreme_point_of s /\ v IN f)`,
  REWRITE_TAC[GSYM FACE_OF_SING; GSYM SING_SUBSET; FACE_OF_FACE]);;

let EXTREME_POINT_OF_MIDPOINT = prove
 (`!s x:real^N.
        convex s
        ==> (x extreme_point_of s <=>
             x IN s /\
             !a b. a IN s /\ b IN s /\ x = midpoint(a,b) ==> x = a /\ x = b)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[extreme_point_of] THEN
  AP_TERM_TAC THEN EQ_TAC THEN
  DISCH_TAC THEN MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real^N`] THEN
  DISCH_TAC THENL
   [FIRST_X_ASSUM(MP_TAC o SPECL [`a:real^N`; `b:real^N`]) THEN
    ASM_SIMP_TAC[MIDPOINT_IN_SEGMENT; MIDPOINT_REFL];
    ALL_TAC] THEN
  REWRITE_TAC[IN_SEGMENT] THEN DISCH_THEN(CONJUNCTS_THEN2
    ASSUME_TAC (X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC)) THEN
  ABBREV_TAC `d = min (&1 - u) u` THEN
  FIRST_X_ASSUM(MP_TAC o SPECL
   [`x - d / &2 % (b - a):real^N`; `x + d / &2 % (b - a):real^N`]) THEN
  REWRITE_TAC[NOT_IMP] THEN REPEAT CONJ_TAC THENL
   [FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [CONVEX_ALT]) THEN
    ASM_REWRITE_TAC[VECTOR_ARITH
     `((&1 - u) % a + u % b) - d / &2 % (b - a):real^N =
      (&1 - (u - d / &2)) % a + (u - d / &2) % b`] THEN
    DISCH_THEN MATCH_MP_TAC THEN ASM_REWRITE_TAC[] THEN ASM_REAL_ARITH_TAC;
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [CONVEX_ALT]) THEN
    ASM_REWRITE_TAC[VECTOR_ARITH
     `((&1 - u) % a + u % b) + d / &2 % (b - a):real^N =
      (&1 - (u + d / &2)) % a + (u + d / &2) % b`] THEN
    DISCH_THEN MATCH_MP_TAC THEN ASM_REWRITE_TAC[] THEN ASM_REAL_ARITH_TAC;
    REWRITE_TAC[midpoint] THEN VECTOR_ARITH_TAC;
    REWRITE_TAC[VECTOR_ARITH `x:real^N = x - d <=> d = vec 0`;
                VECTOR_ARITH `x:real^N = x + d <=> d = vec 0`] THEN
    ASM_REWRITE_TAC[VECTOR_MUL_EQ_0; VECTOR_SUB_EQ] THEN ASM_REAL_ARITH_TAC]);;

let EXTREME_POINT_OF_CONVEX_HULL = prove
 (`!x:real^N s. x extreme_point_of (convex hull s) ==> x IN s`,
  REPEAT GEN_TAC THEN
  SIMP_TAC[EXTREME_POINT_OF_STILLCONVEX; CONVEX_CONVEX_HULL] THEN
  MP_TAC(ISPECL [`convex:(real^N->bool)->bool`; `s:real^N->bool`;
                 `(convex hull s) DELETE (x:real^N)`] HULL_MINIMAL) THEN
  MP_TAC(ISPECL [`convex:(real^N->bool)->bool`; `s:real^N->bool`]
        HULL_SUBSET) THEN
  ASM SET_TAC[]);;

let EXTREME_POINTS_OF_CONVEX_HULL = prove
 (`!s. {x | x extreme_point_of (convex hull s)} SUBSET s`,
  REWRITE_TAC[SUBSET; IN_ELIM_THM; EXTREME_POINT_OF_CONVEX_HULL]);;

let EXTREME_POINT_OF_EMPTY = prove
 (`!x. ~(x extreme_point_of {})`,
  REWRITE_TAC[extreme_point_of; NOT_IN_EMPTY]);;

let EXTREME_POINT_OF_SING = prove
 (`!a x. x extreme_point_of {a} <=> x = a`,
  REWRITE_TAC[extreme_point_of; IN_SING] THEN
  MESON_TAC[SEGMENT_REFL; NOT_IN_EMPTY]);;

let EXTREME_POINT_OF_TRANSLATION_EQ = prove
 (`!a:real^N x s.
           (a + x) extreme_point_of (IMAGE (\x. a + x) s) <=>
           x extreme_point_of s`,
  REWRITE_TAC[extreme_point_of] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [EXTREME_POINT_OF_TRANSLATION_EQ];;

let EXTREME_POINT_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N.
      linear f /\ (!x y. f x = f y ==> x = y)
      ==> ((f x) extreme_point_of (IMAGE f s) <=> x extreme_point_of s)`,
  REWRITE_TAC[GSYM FACE_OF_SING] THEN GEOM_TRANSFORM_TAC[]);;

add_linear_invariants [EXTREME_POINT_OF_LINEAR_IMAGE];;

let EXTREME_POINTS_OF_TRANSLATION = prove
 (`!a s. {x:real^N | x extreme_point_of (IMAGE (\x. a + x) s)} =
         IMAGE (\x. a + x) {x | x extreme_point_of s}`,
  REPEAT GEN_TAC THEN CONV_TAC SYM_CONV THEN
  MATCH_MP_TAC SURJECTIVE_IMAGE_EQ THEN
  REWRITE_TAC[VECTOR_ARITH `a + x:real^N = y <=> x = y - a`; EXISTS_REFL] THEN
  REWRITE_TAC[IN_ELIM_THM; EXTREME_POINT_OF_TRANSLATION_EQ]);;

let EXTREME_POINT_OF_INTER = prove
 (`!x s t. x extreme_point_of s /\ x extreme_point_of t
           ==> x extreme_point_of (s INTER t)`,
  REWRITE_TAC[extreme_point_of; IN_INTER] THEN MESON_TAC[]);;

let EXTREME_POINT_OF_INTER_GEN = prove
 (`!x s t. (x extreme_point_of s \/ x extreme_point_of t) /\ x IN s INTER t
           ==> x extreme_point_of (s INTER t)`,
  REWRITE_TAC[extreme_point_of; IN_INTER] THEN MESON_TAC[]);;

let EXTREME_POINTS_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N.
        linear f /\ (!x y. f x = f y ==> x = y)
        ==> {y | y extreme_point_of (IMAGE f s)} =
            IMAGE f {x | x extreme_point_of s}`,

  REPEAT GEN_TAC THEN DISCH_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP OPEN_SEGMENT_LINEAR_IMAGE) THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN
  REWRITE_TAC[FORALL_IN_IMAGE; FORALL_IN_GSPEC; SUBSET;
              extreme_point_of; IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN
  ASM_SIMP_TAC[FUN_IN_IMAGE; IN_ELIM_THM; IMP_IMP; GSYM CONJ_ASSOC] THEN
  ASM SET_TAC[]);;

let EXTREME_POINT_OF_INTER_SUPPORTING_HYPERPLANE_LE = prove
 (`!s a b c. (!x. x IN s ==> a dot x <= b) /\
             s INTER {x | a dot x = b} = {c}
             ==> c extreme_point_of s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM FACE_OF_SING] THEN
  FIRST_ASSUM(SUBST1_TAC o SYM) THEN
  MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE_STRONG THEN
  ASM_REWRITE_TAC[CONVEX_SING]);;

let EXTREME_POINT_OF_INTER_SUPPORTING_HYPERPLANE_GE = prove
 (`!s a b c. (!x. x IN s ==> a dot x >= b) /\
             s INTER {x | a dot x = b} = {c}
             ==> c extreme_point_of s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM FACE_OF_SING] THEN
  FIRST_ASSUM(SUBST1_TAC o SYM) THEN
  MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE_STRONG THEN
  ASM_REWRITE_TAC[CONVEX_SING]);;

let EXPOSED_POINT_OF_INTER_SUPPORTING_HYPERPLANE_LE = prove
 (`!s a b c:real^N.
        (!x. x IN s ==> a dot x <= b) /\
        s INTER {x | a dot x = b} = {c}
        ==> {c} exposed_face_of s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[exposed_face_of] THEN CONJ_TAC THENL
   [REWRITE_TAC[FACE_OF_SING] THEN
    MATCH_MP_TAC EXTREME_POINT_OF_INTER_SUPPORTING_HYPERPLANE_LE;
    ALL_TAC] THEN
  MAP_EVERY EXISTS_TAC [`a:real^N`; `b:real`] THEN ASM SET_TAC[]);;

let EXPOSED_POINT_OF_INTER_SUPPORTING_HYPERPLANE_GE = prove
 (`!s a b c:real^N.
        (!x. x IN s ==> a dot x >= b) /\
        s INTER {x | a dot x = b} = {c}
        ==> {c} exposed_face_of s`,
  REWRITE_TAC[real_ge] THEN REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `--a:real^N`; `--b:real`; `c:real^N`]
    EXPOSED_POINT_OF_INTER_SUPPORTING_HYPERPLANE_LE) THEN
  ASM_REWRITE_TAC[DOT_LNEG; REAL_EQ_NEG2; REAL_LE_NEG2]);;

let EXPOSED_POINT_OF_FURTHEST_POINT = prove
 (`!s a b:real^N.
        b IN s /\ (!x. x IN s ==> dist(a,x) <= dist(a,b))
        ==> {b} exposed_face_of s`,
  REPEAT GEN_TAC THEN GEOM_ORIGIN_TAC `a:real^N` THEN
  REWRITE_TAC[DIST_0; NORM_LE] THEN REPEAT STRIP_TAC THEN
  MATCH_MP_TAC EXPOSED_POINT_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN
  MAP_EVERY EXISTS_TAC [`b:real^N`; `(b:real^N) dot b`] THEN CONJ_TAC THENL
   [X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `x:real^N`) THEN
    ASM_REWRITE_TAC[];
    MATCH_MP_TAC SUBSET_ANTISYM THEN
    ASM_REWRITE_TAC[IN_INTER; SING_SUBSET; IN_ELIM_THM] THEN
    REWRITE_TAC[SUBSET; IN_SING; IN_INTER; IN_ELIM_THM] THEN
    X_GEN_TAC `x:real^N` THEN STRIP_TAC THEN
    CONV_TAC SYM_CONV THEN ASM_REWRITE_TAC[VECTOR_EQ] THEN
    ASM_SIMP_TAC[GSYM REAL_LE_ANTISYM] THEN
    UNDISCH_TAC `(b:real^N) dot x = b dot b`] THEN
  MP_TAC(ISPEC `b - x:real^N` DOT_POS_LE) THEN
  REWRITE_TAC[DOT_LSUB; DOT_RSUB; DOT_SYM] THEN REAL_ARITH_TAC);;

let COLLINEAR_EXTREME_POINTS = prove
 (`!s. collinear s
       ==> FINITE {x:real^N | x extreme_point_of s} /\
           CARD {x | x extreme_point_of s} <= 2`,
  REWRITE_TAC[GSYM NOT_LT; TAUT `a /\ ~b <=> ~(a ==> b)`] THEN
  REWRITE_TAC[ARITH_RULE `2 < n <=> 3 <= n`] THEN REPEAT STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP CHOOSE_SUBSET_STRONG) THEN
  CONV_TAC(ONCE_DEPTH_CONV HAS_SIZE_CONV) THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM] THEN REWRITE_TAC[NOT_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`t:real^N->bool`; `a:real^N`; `b:real^N`; `c:real^N`] THEN
  REPEAT STRIP_TAC THEN FIRST_X_ASSUM SUBST_ALL_TAC THEN
  SUBGOAL_THEN
   `(a:real^N) extreme_point_of s /\
    b extreme_point_of s /\ c extreme_point_of s`
  STRIP_ASSUME_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN `(a:real^N) IN s /\ b IN s /\ c IN s` STRIP_ASSUME_TAC THENL
   [ASM_MESON_TAC[extreme_point_of]; ALL_TAC] THEN
  SUBGOAL_THEN `collinear {a:real^N,b,c}` MP_TAC THENL
   [MATCH_MP_TAC COLLINEAR_SUBSET THEN EXISTS_TAC `s:real^N->bool` THEN
    ASM SET_TAC[];
    REWRITE_TAC[COLLINEAR_BETWEEN_CASES; BETWEEN_IN_SEGMENT] THEN
    ASM_SIMP_TAC[SEGMENT_CLOSED_OPEN; IN_INSERT; NOT_IN_EMPTY; IN_UNION] THEN
    ASM_MESON_TAC[extreme_point_of]]);;

let EXTREME_POINT_OF_CONIC = prove
 (`!s x:real^N.
        conic s /\ x extreme_point_of s ==> x = vec 0`,
  REPEAT GEN_TAC THEN REWRITE_TAC[GSYM FACE_OF_SING] THEN
  DISCH_THEN(MP_TAC o MATCH_MP FACE_OF_CONIC) THEN
  SIMP_TAC[conic; IN_SING; VECTOR_MUL_EQ_0; REAL_SUB_0; VECTOR_ARITH
    `c % x:real^N = x <=> (c - &1) % x = vec 0`] THEN
  MESON_TAC[REAL_ARITH `&0 <= &0 /\ ~(&1 = &0)`]);;

let EXTREME_POINT_OF_CONVEX_HULL_INSERT = prove
 (`!s a:real^N.
        FINITE s /\ ~(a IN convex hull s)
        ==> a extreme_point_of (convex hull (a INSERT s))`,
  REPEAT GEN_TAC THEN
  ASM_CASES_TAC `(a:real^N) IN s` THEN ASM_SIMP_TAC[HULL_INC] THEN
  STRIP_TAC THEN MP_TAC(ISPECL [`{a:real^N}`; `(a:real^N) INSERT s`]
    FACE_OF_CONVEX_HULLS) THEN
  ASM_REWRITE_TAC[FINITE_INSERT; AFFINE_HULL_SING; CONVEX_HULL_SING] THEN
  REWRITE_TAC[FACE_OF_SING] THEN DISCH_THEN MATCH_MP_TAC THEN
  ASM_SIMP_TAC[SET_RULE `~(a IN s) ==> a INSERT s DIFF {a} = s`] THEN
  ASM SET_TAC[]);;

let FACE_OF_CONIC_HULL = prove
 (`!f s:real^N->bool.
      f face_of s /\ ~(vec 0 IN affine hull s)
      ==> (conic hull f) face_of (conic hull s)`,
  REPEAT GEN_TAC THEN SIMP_TAC[face_of; HULL_MONO; CONVEX_CONIC_HULL] THEN
  STRIP_TAC THEN REWRITE_TAC[IMP_CONJ; CONIC_HULL_EXPLICIT] THEN
  REWRITE_TAC[RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
  MAP_EVERY X_GEN_TAC [`a:real`; `x:real^N`] THEN STRIP_TAC THEN
  MAP_EVERY X_GEN_TAC [`c:real`; `z:real^N`] THEN STRIP_TAC THEN
  MAP_EVERY X_GEN_TAC [`b:real`; `y:real^N`] THEN STRIP_TAC THEN
  ASM_CASES_TAC `z:real^N = x` THENL
   [ASM_REWRITE_TAC[IN_SEGMENT] THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
    DISCH_THEN(X_CHOOSE_THEN `u:real` MP_TAC) THEN
    REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    REWRITE_TAC[GSYM VECTOR_ADD_RDISTRIB; VECTOR_MUL_ASSOC] THEN
    DISCH_TAC THEN REWRITE_TAC[IN_ELIM_THM] THEN
    SUBGOAL_THEN `?c. &0 <= c /\ x:real^N = c % y`
     (fun th -> ASM_MESON_TAC[VECTOR_MUL_ASSOC; REAL_LE_MUL; th]) THEN
    EXISTS_TAC `b / ((&1 - u) * a + u * c)` THEN
    FIRST_X_ASSUM(K ALL_TAC o SPEC `z:real^N`) THEN FIRST_X_ASSUM(MP_TAC o
     AP_TERM `(%) (inv((&1 - u) * a + u * c)):real^N->real^N`) THEN
    SUBGOAL_THEN `&0 < (&1 - u) * a + u * c` ASSUME_TAC THENL
     [MATCH_MP_TAC(REAL_ARITH
       `&0 <= x /\ &0 <= y /\ ~(x = &0 /\ y = &0) ==> &0 < x + y`) THEN
      ASM_SIMP_TAC[REAL_LE_MUL; REAL_SUB_LE; REAL_LT_IMP_LE; REAL_ENTIRE;
                   REAL_SUB_LT; REAL_LT_IMP_NZ] THEN
      ASM_MESON_TAC[VECTOR_MUL_LZERO];
      REWRITE_TAC[VECTOR_MUL_ASSOC] THEN
      ASM_SIMP_TAC[REAL_MUL_LINV; REAL_LT_IMP_NZ; REAL_LE_DIV;
                   REAL_LT_IMP_LE; VECTOR_MUL_LID] THEN
      DISCH_THEN(SUBST1_TAC o SYM) THEN
      REWRITE_TAC[real_div; REAL_MUL_AC]];
    ALL_TAC] THEN
  ASM_CASES_TAC `a = &0` THENL
   [ASM_REWRITE_TAC[IN_ELIM_THM; VECTOR_MUL_LZERO] THEN
    ASM_CASES_TAC `c = &0` THEN
    ASM_REWRITE_TAC[VECTOR_MUL_LZERO; SEGMENT_REFL; NOT_IN_EMPTY] THEN
    REWRITE_TAC[IN_SEGMENT; VECTOR_MUL_RZERO; VECTOR_ADD_LID] THEN
    STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o AP_TERM `(%) (inv(u * c)):real^N->real^N`) THEN
    FIRST_X_ASSUM(K ALL_TAC o SPEC `z:real^N`) THEN
    ASM_SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_MUL_LID; REAL_FIELD
     `&0 < u /\ ~(c = &0) ==> (inv(u * c) * u) * c = &1`] THEN
    DISCH_THEN(SUBST1_TAC o SYM) THEN CONJ_TAC THEN
    ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN EXISTS_TAC `y:real^N` THEN
    REWRITE_TAC[VECTOR_MUL_ASSOC] THEN
    ASM_MESON_TAC[REAL_LE_MUL; REAL_LE_INV_EQ; VECTOR_MUL_LZERO; REAL_LE_REFL;
                  REAL_LT_IMP_LE];
    ALL_TAC] THEN
  ASM_CASES_TAC `c = &0` THENL
   [ASM_REWRITE_TAC[IN_ELIM_THM; VECTOR_MUL_LZERO] THEN
    REWRITE_TAC[IN_SEGMENT; VECTOR_MUL_RZERO; VECTOR_ADD_RID] THEN
    STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o AP_TERM
     `(%) (inv((&1 - u) * a)):real^N->real^N`) THEN
    FIRST_X_ASSUM(K ALL_TAC o SPEC `z:real^N`) THEN
    ASM_SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_MUL_LID; REAL_FIELD
     `u < &1 /\ ~(a = &0) ==> (inv((&1 - u) * a) * (&1 - u)) * a = &1`] THEN
    DISCH_THEN(SUBST1_TAC o SYM) THEN CONJ_TAC THEN
    ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN EXISTS_TAC `y:real^N` THEN
    REWRITE_TAC[VECTOR_MUL_ASSOC] THEN
    ASM_MESON_TAC[REAL_LE_MUL; REAL_LE_INV_EQ; VECTOR_MUL_LZERO; REAL_LE_REFL;
                  REAL_LT_IMP_LE; REAL_SUB_LE];
    ALL_TAC] THEN
  DISCH_TAC THEN MP_TAC(ISPECL
   [`a:real`; `b:real`; `c:real`; `x:real^N`; `y:real^N`; `z:real^N`]
        OPEN_SEGMENT_DESCALE) THEN
  ASM_REWRITE_TAC[REAL_LT_LE] THEN ANTS_TAC THENL
   [CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[]] THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
     `~(z IN s) ==> t SUBSET s ==> ~(z IN t)`)) THEN
    MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[];
    DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPECL [`x:real^N`; `z:real^N`; `y:real^N`]) THEN
    ASM_REWRITE_TAC[IN_ELIM_THM] THEN ASM_MESON_TAC[]]);;

let FACE_OF_CONIC_HULL_REV = prove
 (`!s f:real^N->bool.
        f face_of (conic hull s) /\ ~(vec 0 IN affine hull s)
        ==> f = {vec 0} \/ ?f'. f' face_of s /\ conic hull f' = f`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `f = {vec 0:real^N}` THEN ASM_REWRITE_TAC[] THEN
  EXISTS_TAC `f INTER affine hull s:real^N->bool` THEN CONJ_TAC THENL
   [MP_TAC(SPECL [`s:real^N->bool`; `s:real^N->bool`]
     CONIC_HULL_INTER_AFFINE_HULL) THEN ASM_REWRITE_TAC[SUBSET_REFL] THEN
    DISCH_THEN(fun th -> GEN_REWRITE_TAC RAND_CONV [GSYM th]) THEN
    MATCH_MP_TAC FACE_OF_INTER_INTER THEN
    ASM_SIMP_TAC[FACE_OF_REFL; AFFINE_AFFINE_HULL; AFFINE_IMP_CONVEX];
    MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
     [MATCH_MP_TAC HULL_MINIMAL THEN REWRITE_TAC[INTER_SUBSET] THEN
      ASM_MESON_TAC[FACE_OF_CONIC; CONIC_CONIC_HULL];
      SUBGOAL_THEN
       `!x:real^N. x IN conic hull s /\ x IN f /\ ~(x = vec 0)
                   ==> x IN conic hull (f INTER affine hull s)`
      ASSUME_TAC THENL
       [REWRITE_TAC[CONIC_HULL_EXPLICIT; IMP_CONJ; FORALL_IN_GSPEC] THEN
        MAP_EVERY X_GEN_TAC [`c:real`; `x:real^N`] THEN
        REWRITE_TAC[VECTOR_MUL_EQ_0; DE_MORGAN_THM] THEN
        REPEAT STRIP_TAC THEN REWRITE_TAC[IN_ELIM_THM] THEN
        MAP_EVERY EXISTS_TAC  [`c:real`; `x:real^N`] THEN
        ASM_SIMP_TAC[IN_INTER; HULL_INC] THEN
        FIRST_X_ASSUM(MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ_ALT]
          FACE_OF_CONIC)) THEN
        REWRITE_TAC[CONIC_CONIC_HULL] THEN REWRITE_TAC[conic] THEN
        DISCH_THEN(MP_TAC o SPECL [`c % x:real^N`; `inv c:real`]) THEN
        ASM_SIMP_TAC[REAL_LE_INV_EQ; VECTOR_MUL_ASSOC; REAL_MUL_LINV] THEN
        REWRITE_TAC[VECTOR_MUL_LID];
        REWRITE_TAC[SUBSET] THEN X_GEN_TAC `x:real^N` THEN
        ASM_CASES_TAC `x:real^N = vec 0` THENL
         [ASM_SIMP_TAC[CONIC_CONIC_HULL; CONIC_CONTAINS_0]; ALL_TAC] THEN
        FIRST_ASSUM(MP_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
        ASM SET_TAC[]]]]);;

let EXTREME_POINT_OF_CONIC_HULL = prove
 (`!s x:real^N.
        ~(vec 0 IN affine hull s)
        ==> (x extreme_point_of conic hull s <=> x = vec 0 /\ ~(s = {}))`,
  REPEAT STRIP_TAC THEN EQ_TAC THENL
   [DISCH_TAC THEN
    FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM FACE_OF_SING]) THEN
    DISCH_THEN(MP_TAC o MATCH_MP(REWRITE_RULE[IMP_CONJ]
      FACE_OF_CONIC_HULL_REV)) THEN
    FIRST_ASSUM(MP_TAC o
      CONJUNCT1 o GEN_REWRITE_RULE I [extreme_point_of]) THEN
    ASM_REWRITE_TAC[SET_RULE `{a} = {b} <=> a = b`] THEN
    DISCH_THEN(MP_TAC o MATCH_MP (SET_RULE `x IN s ==> ~(s = {})`)) THEN
    REWRITE_TAC[CONIC_HULL_EQ_EMPTY] THEN
    REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[CONIC_HULL_EQ_SING]) THEN
    ASM_MESON_TAC[FACE_OF_EMPTY; NOT_INSERT_EMPTY];
    STRIP_TAC THEN
    ASM_REWRITE_TAC[extreme_point_of; CONIC_HULL_CONTAINS_0] THEN
    REWRITE_TAC[CONIC_HULL_EXPLICIT; IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN
    REWRITE_TAC[FORALL_IN_GSPEC] THEN
    MAP_EVERY X_GEN_TAC [`a:real`; `u:real^N`] THEN STRIP_TAC THEN
    MAP_EVERY X_GEN_TAC [`b:real`; `v:real^N`] THEN STRIP_TAC THEN
    ASM_CASES_TAC `a = &0` THEN
    ASM_REWRITE_TAC[VECTOR_MUL_LZERO; ENDS_NOT_IN_SEGMENT] THEN
    ASM_CASES_TAC `b = &0` THEN
    ASM_REWRITE_TAC[VECTOR_MUL_LZERO; ENDS_NOT_IN_SEGMENT] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `affine hull {u:real^N,v}` o MATCH_MP (SET_RULE
     `~(z IN s) ==> !t. t SUBSET s ==> ~(z IN t)`)) THEN
    ASM_SIMP_TAC[HULL_MONO; INSERT_SUBSET; EMPTY_SUBSET] THEN
    REWRITE_TAC[AFFINE_HULL_0_2_EXPLICIT; IN_SEGMENT; VECTOR_MUL_ASSOC] THEN
    REWRITE_TAC[CONTRAPOS_THM] THEN DISCH_THEN(CONJUNCTS_THEN2
     ASSUME_TAC (X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC)) THEN
    MAP_EVERY EXISTS_TAC [`(&1 - u) * a`; `u * b:real`] THEN
    ASM_REWRITE_TAC[] THEN MATCH_MP_TAC REAL_LT_IMP_NZ THEN
    MATCH_MP_TAC REAL_LT_ADD THEN CONJ_TAC THEN MATCH_MP_TAC REAL_LT_MUL THEN
    ASM_REAL_ARITH_TAC]);;

let FACE_OF_CONIC_HULL_EQ = prove
 (`!s f:real^N->bool.
     ~(vec 0 IN affine hull s)
     ==> (f face_of (conic hull s) <=>
          f = {vec 0} /\ ~(s = {}) \/ ?f'. f' face_of s /\ conic hull f' = f)`,
  REPEAT STRIP_TAC THEN EQ_TAC THEN STRIP_TAC THENL
   [ASM_CASES_TAC `s:real^N->bool = {}` THENL
     [ASM_REWRITE_TAC[] THEN EXISTS_TAC `{}:real^N->bool` THEN
      FIRST_X_ASSUM(MP_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
      ASM_SIMP_TAC[EMPTY_FACE_OF; CONIC_HULL_EMPTY; SUBSET_EMPTY];
      ASM_SIMP_TAC[FACE_OF_CONIC_HULL_REV]];
    ASM_SIMP_TAC[FACE_OF_SING; EXTREME_POINT_OF_CONIC_HULL];
    ASM_MESON_TAC[FACE_OF_CONIC_HULL]]);;

(* ------------------------------------------------------------------------- *)
(* Closure and (relative) openness of conic hulls etc.                       *)
(* ------------------------------------------------------------------------- *)

let CLOSED_IN_CONIC_HULL = prove
 (`!s t:real^N->bool.
        compact t /\ ~(vec 0 IN t) /\ t SUBSET s
        ==> closed_in (subtopology euclidean (conic hull s))
                      (conic hull t)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[CONIC_HULL_AS_IMAGE] THEN
  MP_TAC(ISPECL
   [`\z. drop(fstcart z) % (sndcart z:real^N)`;
    `{t | &0 <= drop t} PCROSS (t:real^N->bool)`;
    `IMAGE (\z. drop(fstcart z) % (sndcart z:real^N))
           ({t | &0 <= drop t} PCROSS s)`]
   PROPER_MAP) THEN
  ASM_SIMP_TAC[IMAGE_SUBSET; SUBSET_PCROSS; SUBSET_REFL] THEN
  DISCH_THEN(MP_TAC o MATCH_MP (TAUT `(p <=> q /\ r) ==> p ==> q`)) THEN
  ANTS_TAC THENL [ALL_TAC; SIMP_TAC[CLOSED_IN_REFL]] THEN
  REWRITE_TAC[GSYM CONIC_HULL_AS_IMAGE] THEN
  X_GEN_TAC `k:real^N->bool` THEN STRIP_TAC THEN
  REWRITE_TAC[COMPACT_EQ_BOUNDED_CLOSED] THEN CONJ_TAC THENL
   [ALL_TAC;
    MATCH_MP_TAC CONTINUOUS_CLOSED_PREIMAGE THEN
    SIMP_TAC[CONTINUOUS_ON_MUL; o_DEF; LIFT_DROP; ETA_AX; LINEAR_CONTINUOUS_ON;
             LINEAR_FSTCART; LINEAR_SNDCART] THEN
    ASM_SIMP_TAC[CLOSED_PCROSS_EQ; COMPACT_IMP_CLOSED] THEN
    REWRITE_TAC[drop; GSYM real_ge; CLOSED_HALFSPACE_COMPONENT_GE]] THEN
  MP_TAC(ISPECL [`k:real^N->bool`; `vec 0:real^N`]
        BOUNDED_SUBSET_CBALL) THEN
  ASM_SIMP_TAC[SUBSET; IN_CBALL_0; COMPACT_IMP_BOUNDED] THEN
  DISCH_THEN(X_CHOOSE_THEN `r:real` STRIP_ASSUME_TAC) THEN
  MATCH_MP_TAC BOUNDED_SUBSET THEN
  EXISTS_TAC `interval[vec 0,lift(r / setdist({vec 0:real^N},t))] PCROSS
              (t:real^N->bool)` THEN
  ASM_SIMP_TAC[BOUNDED_PCROSS; BOUNDED_INTERVAL; COMPACT_IMP_BOUNDED] THEN
  REWRITE_TAC[SUBSET; FORALL_PASTECART; PASTECART_IN_PCROSS; IN_ELIM_THM] THEN
  REWRITE_TAC[FSTCART_PASTECART; SNDCART_PASTECART; IN_INTERVAL_1] THEN
  SIMP_TAC[GSYM FORALL_DROP; LIFT_DROP; DROP_VEC] THEN
  MAP_EVERY X_GEN_TAC [`a:real`; `x:real^N`] THEN STRIP_TAC THEN
  SUBGOAL_THEN `~(t:real^N->bool = {})` ASSUME_TAC THENL
   [ASM SET_TAC[]; ALL_TAC] THEN
  ASM_SIMP_TAC[REAL_LE_RDIV_EQ; SETDIST_EQ_0_SING; CLOSURE_CLOSED;
               COMPACT_IMP_CLOSED; SETDIST_POS_LE;
               REAL_ARITH `&0 < x <=> &0 <= x /\ ~(x = &0)`] THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `a % x:real^N`) THEN
  ASM_REWRITE_TAC[NORM_MUL; real_abs] THEN
  MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ] REAL_LE_TRANS) THEN
  MATCH_MP_TAC REAL_LE_LMUL THEN
  ASM_REWRITE_TAC[NORM_ARITH `norm(x:real^N) = dist(vec 0,x)`] THEN
  MATCH_MP_TAC SETDIST_LE_DIST THEN ASM_REWRITE_TAC[IN_SING]);;

let CLOSED_CONIC_HULL = prove
 (`!s:real^N->bool.
     vec 0 IN relative_interior s \/ compact s /\ ~(vec 0 IN s)
     ==> closed(conic hull s)`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[CONIC_HULL_EQ_AFFINE_HULL; CLOSED_AFFINE_HULL] THEN
  MP_TAC(ISPECL [`(:real^N)`; `s:real^N->bool`] CLOSED_IN_CONIC_HULL) THEN
  ASM_REWRITE_TAC[SUBSET_UNIV; HULL_UNIV; SUBTOPOLOGY_UNIV] THEN
  ASM_SIMP_TAC[GSYM CLOSED_IN; COMPACT_IMP_CLOSED]);;

let CONIC_CLOSURE = prove
 (`!s:real^N->bool. conic s ==> conic(closure s)`,
  REWRITE_TAC[conic; CLOSURE_SEQUENTIAL] THEN
  GEN_TAC THEN DISCH_TAC THEN MAP_EVERY X_GEN_TAC [`x:real^N`; `c:real`] THEN
  DISCH_THEN(CONJUNCTS_THEN2 (X_CHOOSE_TAC `a:num->real^N`) ASSUME_TAC) THEN
  EXISTS_TAC `\n. c % (a:num->real^N) n` THEN
  ASM_SIMP_TAC[LIM_ADD; LIM_CMUL]);;

let CLOSURE_CONIC_HULL = prove
 (`!s:real^N->bool.
        vec 0 IN relative_interior s \/ bounded s /\ ~(vec 0 IN closure s)
        ==> closure(conic hull s) = conic hull (closure s)`,
  REPEAT STRIP_TAC THENL
   [ASM_SIMP_TAC[CONIC_HULL_EQ_AFFINE_HULL; CLOSED_AFFINE_HULL;
                 CLOSURE_CLOSED] THEN
    CONV_TAC SYM_CONV THEN
    GEN_REWRITE_TAC RAND_CONV [GSYM AFFINE_HULL_CLOSURE] THEN
    MATCH_MP_TAC CONIC_HULL_EQ_AFFINE_HULL THEN
    MP_TAC(ISPEC `s:real^N->bool` RELATIVE_INTERIOR_CLOSURE_SUBSET) THEN
    ASM SET_TAC[];
    REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ] THEN CONJ_TAC THENL
     [MATCH_MP_TAC CLOSURE_MINIMAL THEN
      SIMP_TAC[HULL_MONO; CLOSURE_SUBSET] THEN
      MATCH_MP_TAC CLOSED_CONIC_HULL THEN ASM_REWRITE_TAC[COMPACT_CLOSURE];
      MATCH_MP_TAC HULL_MINIMAL THEN SIMP_TAC[SUBSET_CLOSURE; HULL_SUBSET] THEN
      MATCH_MP_TAC CONIC_CLOSURE THEN REWRITE_TAC[CONIC_CONIC_HULL]]]);;

let OPEN_IN_SAME_CONIC_HULL = prove
 (`!u s:real^N->bool.
        conic u /\ open_in (subtopology euclidean u) s
        ==> open_in (subtopology euclidean u) (conic hull s DELETE vec 0)`,
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN
    `conic hull s DELETE (vec 0:real^N) =
     UNIONS {IMAGE (\x. c % x) s | &0 < c} DELETE vec 0`
  SUBST1_TAC THENL
   [REWRITE_TAC[UNIONS_GSPEC; CONIC_HULL_EXPLICIT] THEN
    REWRITE_TAC[EXTENSION; IN_ELIM_THM; REAL_LE_LT; IN_IMAGE; IN_DELETE] THEN
    MESON_TAC[VECTOR_MUL_EQ_0];
    ALL_TAC] THEN
  MATCH_MP_TAC OPEN_IN_DELETE THEN MATCH_MP_TAC OPEN_IN_UNIONS THEN
  REWRITE_TAC[FORALL_IN_GSPEC] THEN X_GEN_TAC `c:real` THEN DISCH_TAC THEN
  MP_TAC(ISPECL [`\x:real^N. c % x`; `s:real^N->bool`; `u:real^N->bool`]
   OPEN_IN_INJECTIVE_LINEAR_IMAGE) THEN
  ASM_SIMP_TAC[LINEAR_SCALING; VECTOR_MUL_LCANCEL; REAL_LT_IMP_NZ] THEN
  MATCH_MP_TAC(ONCE_REWRITE_RULE[IMP_CONJ_ALT] OPEN_IN_SUBSET_TRANS) THEN
  ASM_SIMP_TAC[CONIC_IMAGE_MULTIPLE; SUBSET_REFL] THEN
  FIRST_X_ASSUM(ASSUME_TAC o MATCH_MP OPEN_IN_IMP_SUBSET) THEN
  REWRITE_TAC[SUBSET; FORALL_IN_IMAGE] THEN
  ASM_MESON_TAC[conic; SUBSET; REAL_LT_IMP_LE]);;

let OPEN_CONIC_HULL = prove
 (`!s:real^N->bool. open s ==> open(conic hull s DELETE vec 0)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`(:real^N)`; `s:real^N->bool`] OPEN_IN_SAME_CONIC_HULL) THEN
  ASM_REWRITE_TAC[CONIC_UNIV; SUBTOPOLOGY_UNIV; GSYM OPEN_IN]);;

let OPEN_IN_CONIC_HULL = prove
 (`!u s:real^N->bool.
        open_in (subtopology euclidean (affine hull u)) s
        ==> open_in (subtopology euclidean (affine hull (conic hull u)))
                    (conic hull s DELETE vec 0)`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY; EMPTY_DELETE; OPEN_IN_EMPTY] THEN
  ASM_REWRITE_TAC[AFFINE_HULL_CONIC_HULL] THEN
  ASM_CASES_TAC `u:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[AFFINE_HULL_EMPTY; OPEN_IN_SUBTOPOLOGY_EMPTY] THEN
  ASM_CASES_TAC `(vec 0:real^N) IN affine hull u` THENL
   [SUBGOAL_THEN
      `affine hull (vec 0 INSERT u:real^N->bool) = affine hull u`
    SUBST1_TAC THENL
     [MATCH_MP_TAC AFFINE_HULLS_EQ THEN
      ASM_REWRITE_TAC[INSERT_SUBSET; HULL_SUBSET] THEN
      MATCH_MP_TAC(SET_RULE `vec 0 INSERT s SUBSET t ==> s SUBSET t`) THEN
      REWRITE_TAC[HULL_SUBSET];
      MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ] OPEN_IN_SAME_CONIC_HULL) THEN
      ASM_SIMP_TAC[AFFINE_HULL_EQ_SPAN; CONIC_SPAN]];
    MP_TAC(ISPECL [`{vec 0:real^N}`; `affine hull u:real^N->bool`]
        SEPARATING_HYPERPLANE_AFFINE_AFFINE) THEN
    ASM_REWRITE_TAC[AFFINE_SING; AFFINE_AFFINE_HULL; NOT_INSERT_EMPTY;
                    AFFINE_HULL_EQ_EMPTY; DISJOINT_INSERT; DISJOINT_EMPTY] THEN
    REWRITE_TAC[FORALL_IN_INSERT; NOT_IN_EMPTY; DOT_RZERO] THEN
    ONCE_REWRITE_TAC[TAUT `p /\ q /\ r /\ s <=> r /\ p /\ q /\ s`] THEN
    REWRITE_TAC[RIGHT_EXISTS_AND_THM; UNWIND_THM1] THEN
    DISCH_THEN(X_CHOOSE_THEN `a:real^N`
      (CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    DISCH_THEN(X_CHOOSE_THEN `b:real`
      (CONJUNCTS_THEN2 (ASSUME_TAC o GSYM) ASSUME_TAC)) THEN
    REWRITE_TAC[open_in] THEN STRIP_TAC THEN CONJ_TAC THENL
     [MATCH_MP_TAC(SET_RULE `s SUBSET t ==> s DELETE a SUBSET t`) THEN
      TRANS_TAC SUBSET_TRANS `conic hull (affine hull u):real^N->bool` THEN
      ASM_SIMP_TAC[HULL_MONO] THEN ONCE_REWRITE_TAC[HULL_INSERT] THEN
      ASM_SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC; IN_INSERT] THEN
      REWRITE_TAC[SPAN_INSERT_0; CONIC_HULL_SUBSET_SPAN];
      ALL_TAC] THEN
    SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC; IN_INSERT; SPAN_INSERT_0] THEN
    REWRITE_TAC[IN_DELETE; IMP_CONJ; CONIC_HULL_EXPLICIT; FORALL_IN_GSPEC] THEN
    MAP_EVERY X_GEN_TAC [`c:real`; `x:real^N`] THEN
    REWRITE_TAC[VECTOR_MUL_EQ_0; DE_MORGAN_THM] THEN REPEAT STRIP_TAC THEN
    REWRITE_TAC[GSYM CONIC_HULL_EXPLICIT] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `x:real^N`) THEN ASM_REWRITE_TAC[] THEN
    DISCH_THEN(X_CHOOSE_THEN `e:real` STRIP_ASSUME_TAC) THEN
    SUBGOAL_THEN `!x:real^N. x IN s ==> a dot x = b`
    ASSUME_TAC THENL [ASM_MESON_TAC[SUBSET]; ALL_TAC] THEN
    SUBGOAL_THEN `(\y:real^N. lift(a dot y)) continuous (at (c % x))`
    ASSUME_TAC THENL
     [REWRITE_TAC[REWRITE_RULE[o_DEF] CONTINUOUS_AT_LIFT_DOT];
      ALL_TAC] THEN
    FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [continuous_at]) THEN
    DISCH_THEN(MP_TAC o SPEC `a dot (c % x:real^N)`) THEN
    SUBGOAL_THEN `&0 < c` ASSUME_TAC THENL
     [ASM_REWRITE_TAC[REAL_LT_LE]; ALL_TAC] THEN
    ASM_SIMP_TAC[DOT_RMUL; HULL_INC; REAL_LT_MUL; DIST_LIFT] THEN
    DISCH_THEN(X_CHOOSE_THEN `k:real` STRIP_ASSUME_TAC) THEN
    SUBGOAL_THEN
     `(\y:real^N. (b / (a dot y)) % y) continuous (at (c % x))`
    MP_TAC THENL
     [MATCH_MP_TAC CONTINUOUS_MUL THEN
      REWRITE_TAC[CONTINUOUS_AT_ID; o_DEF; LIFT_CMUL; real_div] THEN
      MATCH_MP_TAC CONTINUOUS_CMUL THEN
      MATCH_MP_TAC(REWRITE_RULE[o_DEF] CONTINUOUS_AT_INV) THEN
      ASM_SIMP_TAC[DOT_RMUL; HULL_INC; REAL_ENTIRE; REAL_LT_IMP_NZ];
      ALL_TAC] THEN
    REWRITE_TAC[continuous_at] THEN
    DISCH_THEN(MP_TAC o SPEC `min e (norm(x:real^N))`) THEN
    ASM_REWRITE_TAC[REAL_LT_MIN; NORM_POS_LT] THEN
    ASM_SIMP_TAC[DOT_RMUL; HULL_INC; VECTOR_MUL_ASSOC] THEN
    ASM_SIMP_TAC[VECTOR_MUL_LID; REAL_FIELD
     `&0 < b /\ &0 < c ==> b / (c * b) * c = &1`] THEN
    DISCH_THEN(X_CHOOSE_THEN `d:real` (CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    DISCH_THEN(fun th ->
      EXISTS_TAC `min d k:real` THEN ASM_REWRITE_TAC[REAL_LT_MIN] THEN
      X_GEN_TAC `y:real^N` THEN REPEAT DISCH_TAC THEN
      MP_TAC(SPEC `y:real^N` th)) THEN
    ASM_REWRITE_TAC[] THEN STRIP_TAC THEN
    UNDISCH_TAC `dist (b / (a dot y) % y:real^N,x) < norm x` THEN
    ASM_CASES_TAC `y:real^N = vec 0` THEN
    ASM_REWRITE_TAC[VECTOR_MUL_RZERO; DIST_0; REAL_LT_REFL] THEN
    DISCH_TAC THEN REWRITE_TAC[CONIC_HULL_EXPLICIT; IN_ELIM_THM] THEN
    MAP_EVERY EXISTS_TAC
     [`(a dot (y:real^N)) / b`; `(b / (a dot y)) % y:real^N`] THEN
    SUBGOAL_THEN `&0 < (a:real^N) dot y` ASSUME_TAC THENL
     [MATCH_MP_TAC(REAL_ARITH `!y. &0 < y /\ abs(x - y) < y ==> &0 < x`) THEN
      EXISTS_TAC `c * b:real` THEN ASM_SIMP_TAC[REAL_LT_MUL];
      ASM_SIMP_TAC[REAL_LT_DIV; REAL_LT_IMP_LE]] THEN
    ASM_SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_MUL_LID; REAL_FIELD
     `&0 < a /\ &0 < b ==> a / b * b / a = &1`] THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN
     `!z:real^N. z IN span u /\ a dot z = b ==> z IN affine hull u`
    MATCH_MP_TAC THENL
     [ALL_TAC;
      ASM_SIMP_TAC[SPAN_MUL; DOT_RMUL; REAL_DIV_RMUL; REAL_LT_IMP_NZ]] THEN
    X_GEN_TAC `z:real^N` THEN
    REWRITE_TAC[SPAN_EXPLICIT; AFFINE_HULL_EXPLICIT; IMP_CONJ] THEN
    REWRITE_TAC[IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN
    MAP_EVERY X_GEN_TAC [`t:real^N->bool`; `q:real^N->real`] THEN
    REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    DISCH_THEN(SUBST1_TAC o SYM) THEN ASM_SIMP_TAC[DOT_RSUM] THEN
    SUBGOAL_THEN
     `sum t (\x:real^N. a dot q x % x) = b * sum t q`
    SUBST1_TAC THENL
     [REWRITE_TAC[GSYM SUM_LMUL] THEN MATCH_MP_TAC SUM_EQ THEN
      RULE_ASSUM_TAC(REWRITE_RULE[SUBSET]) THEN
      ASM_SIMP_TAC[HULL_INC; DOT_RMUL; REAL_MUL_SYM];
      ASM_SIMP_TAC[REAL_FIELD `&0 < b ==> (b * t = b <=> t = &1)`] THEN
      STRIP_TAC] THEN
    MAP_EVERY EXISTS_TAC [`t:real^N->bool`; `q:real^N->real`] THEN
    ASM_REWRITE_TAC[] THEN UNDISCH_TAC `sum (t:real^N->bool) q = &1` THEN
    ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
    SIMP_TAC[SUM_CLAUSES] THEN CONV_TAC REAL_RAT_REDUCE_CONV]);;

let CONIC_INTERIOR_INSERT = prove
 (`!s:real^N->bool. conic s ==> conic(vec 0 INSERT interior s)`,
  REWRITE_TAC[conic; IN_INTERIOR; SUBSET; IN_BALL; dist; IN_INSERT] THEN
  REPEAT GEN_TAC THEN STRIP_TAC THEN
  MAP_EVERY X_GEN_TAC [`x:real^N`; `c:real`] THEN
  REWRITE_TAC[REAL_LE_LT] THEN
  ASM_CASES_TAC `c = &0` THEN ASM_REWRITE_TAC[VECTOR_MUL_EQ_0] THEN
  ASM_CASES_TAC `x:real^N = vec 0` THEN ASM_REWRITE_TAC[] THEN
  DISCH_THEN(CONJUNCTS_THEN2 (X_CHOOSE_THEN `e:real` STRIP_ASSUME_TAC)
    ASSUME_TAC) THEN
  EXISTS_TAC `c * e:real` THEN ASM_SIMP_TAC[REAL_LT_MUL] THEN
  X_GEN_TAC `y:real^N` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPECL [`inv(c) % y:real^N`; `c:real`]) THEN
  ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_RINV; REAL_LT_IMP_NZ] THEN
  ASM_SIMP_TAC[VECTOR_MUL_LID; REAL_LT_IMP_LE] THEN
  DISCH_THEN MATCH_MP_TAC THEN FIRST_X_ASSUM MATCH_MP_TAC THEN
  MATCH_MP_TAC REAL_LT_LCANCEL_IMP THEN EXISTS_TAC `abs c:real` THEN
  CONJ_TAC THENL [ASM_REAL_ARITH_TAC; REWRITE_TAC[GSYM NORM_MUL]] THEN
  ASM_SIMP_TAC[real_abs; REAL_LT_IMP_LE; VECTOR_SUB_LDISTRIB] THEN
  ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_RINV; REAL_LT_IMP_NZ] THEN
  ASM_REWRITE_TAC[VECTOR_MUL_LID]);;

let CONIC_INTERIOR = prove
 (`!s:real^N->bool. conic s /\ vec 0 IN interior s ==> conic(interior s)`,
  MESON_TAC[SET_RULE `a IN s ==> a INSERT s = s`; CONIC_INTERIOR_INSERT]);;

let CONIC_RELATIVE_INTERIOR_INSERT = prove
 (`!s:real^N->bool. conic s ==> conic(vec 0 INSERT relative_interior s)`,
  REWRITE_TAC[conic; IN_RELATIVE_INTERIOR; SUBSET;
              IN_INTER; IN_BALL; dist; IN_INSERT] THEN
  REPEAT GEN_TAC THEN STRIP_TAC THEN
  MAP_EVERY X_GEN_TAC [`x:real^N`; `c:real`] THEN
  REWRITE_TAC[REAL_LE_LT] THEN
  ASM_CASES_TAC `c = &0` THEN ASM_REWRITE_TAC[VECTOR_MUL_EQ_0] THEN
  ASM_CASES_TAC `x:real^N = vec 0` THEN
  ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN
  DISCH_THEN(CONJUNCTS_THEN2
   (CONJUNCTS_THEN2 ASSUME_TAC (X_CHOOSE_THEN `e:real` STRIP_ASSUME_TAC))
    ASSUME_TAC) THEN
  EXISTS_TAC `c * e:real` THEN ASM_SIMP_TAC[REAL_LT_MUL] THEN
  X_GEN_TAC `y:real^N` THEN DISCH_TAC THEN
  FIRST_ASSUM(MP_TAC o SPECL [`x:real^N`; `&0`]) THEN
  REWRITE_TAC[REAL_LE_REFL; VECTOR_MUL_LZERO] THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[]; DISCH_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o SPECL [`inv(c) % y:real^N`; `c:real`]) THEN
  ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_RINV; REAL_LT_IMP_NZ] THEN
  ASM_SIMP_TAC[VECTOR_MUL_LID; REAL_LT_IMP_LE] THEN
  DISCH_THEN MATCH_MP_TAC THEN FIRST_X_ASSUM MATCH_MP_TAC THEN CONJ_TAC THENL
   [ALL_TAC; ASM_MESON_TAC[SPAN_MUL; AFFINE_HULL_EQ_SPAN; HULL_INC]] THEN
  MATCH_MP_TAC REAL_LT_LCANCEL_IMP THEN EXISTS_TAC `abs c:real` THEN
  CONJ_TAC THENL [ASM_REAL_ARITH_TAC; REWRITE_TAC[GSYM NORM_MUL]] THEN
  ASM_SIMP_TAC[real_abs; REAL_LT_IMP_LE; VECTOR_SUB_LDISTRIB] THEN
  ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_RINV; REAL_LT_IMP_NZ] THEN
  ASM_REWRITE_TAC[VECTOR_MUL_LID]);;

let CONIC_RELATIVE_INTERIOR = prove
 (`!s:real^N->bool.
        conic s /\ vec 0 IN relative_interior s
        ==> conic(relative_interior s)`,
  MESON_TAC[SET_RULE `a IN s ==> a INSERT s = s`;
            CONIC_RELATIVE_INTERIOR_INSERT]);;

let CONIC_HULL_RELATIVE_INTERIOR_SUBSET = prove
 (`!s:real^N->bool.
        conic hull (relative_interior s) DELETE (vec 0) SUBSET
        relative_interior(conic hull s)`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC RELATIVE_INTERIOR_MAXIMAL THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC(SET_RULE `s SUBSET t ==> s DELETE a SUBSET t`) THEN
    MATCH_MP_TAC HULL_MONO THEN REWRITE_TAC[RELATIVE_INTERIOR_SUBSET];
    MATCH_MP_TAC OPEN_IN_CONIC_HULL THEN
    REWRITE_TAC[OPEN_IN_RELATIVE_INTERIOR]]);;

let CONIC_SUBSET_AS_CONIC_HULL = prove
 (`!s c:real^N->bool.
        conic c /\ ~(c = {vec 0}) /\ c SUBSET conic hull s
        ==> conic hull (s INTER c) = c`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ] THEN
  ASM_SIMP_TAC[HULL_MINIMAL; INTER_SUBSET] THEN
  FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
   `c SUBSET k ==> (!x. x IN k ==> x IN c ==> x IN u) ==> c SUBSET u`)) THEN
  REWRITE_TAC[CONIC_HULL_EXPLICIT; FORALL_IN_GSPEC] THEN
  MAP_EVERY X_GEN_TAC [`a:real`; `x:real^N`] THEN
  ASM_CASES_TAC `a % x:real^N = vec 0` THENL
   [ASM_REWRITE_TAC[GSYM CONIC_HULL_EXPLICIT] THEN
    REPEAT STRIP_TAC THEN REWRITE_TAC[CONIC_HULL_CONTAINS_0] THEN
    SUBGOAL_THEN `?y:real^N. ~(y = vec 0) /\ y IN c` STRIP_ASSUME_TAC THENL
     [ASM SET_TAC[]; ALL_TAC] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `y:real^N` o REWRITE_RULE[SUBSET]) THEN
    ASM_REWRITE_TAC[IN_ELIM_THM; CONIC_HULL_EXPLICIT; LEFT_IMP_EXISTS_THM] THEN
    MAP_EVERY X_GEN_TAC [`b:real`; `z:real^N`] THEN
    ASM_CASES_TAC `b = &0` THEN ASM_REWRITE_TAC[VECTOR_MUL_LZERO] THEN
    ASM_REWRITE_TAC[REAL_LE_LT; GSYM MEMBER_NOT_EMPTY] THEN STRIP_TAC THEN
    EXISTS_TAC `z:real^N` THEN ASM_REWRITE_TAC[IN_INTER] THEN
    SUBGOAL_THEN `z:real^N = inv b % y` SUBST1_TAC THENL
     [ASM_SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_MUL_LID; REAL_MUL_LINV];
      ASM_MESON_TAC[conic; REAL_LT_IMP_LE; REAL_LE_INV_EQ]];
    UNDISCH_TAC `~(a % x:real^N = vec 0)` THEN
    SIMP_TAC[VECTOR_MUL_EQ_0; DE_MORGAN_THM] THEN REPEAT STRIP_TAC THEN
    REWRITE_TAC[IN_ELIM_THM; IN_INTER] THEN
    MAP_EVERY EXISTS_TAC [`a:real`; `x:real^N`] THEN
    ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN `x:real^N = inv a % a % x` SUBST1_TAC THENL
     [ASM_SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_MUL_LID; REAL_MUL_LINV];
      ASM_MESON_TAC[conic; REAL_LT_IMP_LE; REAL_LE_INV_EQ]]]);;

let RELATIVE_INTERIOR_CONIC_HULL = prove
 (`!s:real^N->bool.
        ~(vec 0 IN affine hull s)
        ==> relative_interior(conic hull s) =
            conic hull (relative_interior s) DELETE (vec 0)`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
  REWRITE_TAC[CONIC_HULL_RELATIVE_INTERIOR_SUBSET] THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY; RELATIVE_INTERIOR_EMPTY; EMPTY_SUBSET] THEN
  ASM_CASES_TAC `relative_interior (conic hull s):real^N->bool = {}` THEN
  ASM_REWRITE_TAC[EMPTY_SUBSET] THEN
  SUBGOAL_THEN
   `~((vec 0:real^N) IN relative_interior(conic hull s))`
  ASSUME_TAC THENL
   [MATCH_MP_TAC EXTREME_POINT_NOT_IN_RELATIVE_INTERIOR THEN
    ASM_SIMP_TAC[EXTREME_POINT_OF_CONIC_HULL; CONIC_HULL_EQ_SING] THEN
    ASM_MESON_TAC[IN_SING; HULL_INC];
    ALL_TAC] THEN
  MATCH_MP_TAC(SET_RULE
   `~(a IN t) /\ a INSERT t SUBSET s ==> t SUBSET s DELETE a`) THEN
  ASM_REWRITE_TAC[] THEN
  TRANS_TAC SUBSET_TRANS
   `conic hull
      ((vec 0 INSERT relative_interior (conic hull s:real^N->bool)) INTER
        affine hull s)` THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC(SET_RULE `s = t ==> t SUBSET s`) THEN
    ONCE_REWRITE_TAC[INTER_COMM] THEN
    MATCH_MP_TAC CONIC_SUBSET_AS_CONIC_HULL THEN REPEAT CONJ_TAC THENL
     [SIMP_TAC[CONIC_RELATIVE_INTERIOR_INSERT; CONIC_CONIC_HULL];
      ASM SET_TAC[];
      ASM_REWRITE_TAC[INSERT_SUBSET; CONIC_HULL_CONTAINS_0] THEN
      ASM_REWRITE_TAC[AFFINE_HULL_EQ_EMPTY] THEN
      TRANS_TAC SUBSET_TRANS `conic hull s:real^N->bool` THEN
      SIMP_TAC[RELATIVE_INTERIOR_SUBSET; HULL_MONO; HULL_SUBSET]];
    MATCH_MP_TAC HULL_MINIMAL THEN
    ASM_SIMP_TAC[CONIC_CONIC_HULL; SET_RULE
     `~(a IN t) ==> (a INSERT s) INTER t = s INTER t`] THEN
    TRANS_TAC SUBSET_TRANS `relative_interior s:real^N->bool` THEN
    REWRITE_TAC[HULL_SUBSET] THEN MATCH_MP_TAC RELATIVE_INTERIOR_MAXIMAL THEN
    CONJ_TAC THENL
     [MP_TAC(ISPECL [`s:real^N->bool`; `s:real^N->bool`]
        CONIC_HULL_INTER_AFFINE_HULL) THEN
      ASM_REWRITE_TAC[SUBSET_REFL] THEN DISCH_THEN(fun th ->
        GEN_REWRITE_TAC RAND_CONV [SYM th]) THEN
      MP_TAC(ISPEC `conic hull s:real^N->bool` RELATIVE_INTERIOR_SUBSET) THEN
      SET_TAC[];
      ONCE_REWRITE_TAC[INTER_COMM] THEN
      MATCH_MP_TAC OPEN_IN_SUBTOPOLOGY_INTER_SUBSET THEN
      EXISTS_TAC `affine hull (conic hull s):real^N->bool` THEN
      SIMP_TAC[HULL_SUBSET; HULL_MONO] THEN MATCH_MP_TAC OPEN_IN_INTER THEN
      REWRITE_TAC[OPEN_IN_REFL; OPEN_IN_RELATIVE_INTERIOR]]]);;

let CONIC_HULL_RELATIVE_INTERIOR = prove
 (`!s:real^N->bool.
        ~(vec 0 IN affine hull s)
        ==> conic hull (relative_interior s) =
            if relative_interior s = {} then {}
            else (vec 0) INSERT relative_interior(conic hull s)`,
  REPEAT STRIP_TAC THEN COND_CASES_TAC THEN
  ASM_REWRITE_TAC[RELATIVE_INTERIOR_EMPTY; CONIC_HULL_EMPTY] THEN
  ASM_SIMP_TAC[RELATIVE_INTERIOR_CONIC_HULL] THEN MATCH_MP_TAC(SET_RULE
   `a IN s ==> s = a INSERT (s DELETE a)`) THEN
  ASM_REWRITE_TAC[CONIC_HULL_CONTAINS_0]);;

let CONIC_HULL_DIFF = prove
 (`!s t:real^N->bool.
        ~(vec 0 IN affine hull s) /\ t SUBSET s
        ==> conic hull (s DIFF t) =
            if t = s then {}
            else conic hull s DIFF (conic hull t DELETE vec 0)`,
  REPEAT STRIP_TAC THEN
  COND_CASES_TAC THEN ASM_REWRITE_TAC[DIFF_EQ_EMPTY; CONIC_HULL_EMPTY] THEN
  REWRITE_TAC[EXTENSION; IN_DIFF; IN_DELETE;
              CONIC_HULL_EXPLICIT; IN_ELIM_THM] THEN
  X_GEN_TAC `y:real^N` THEN ASM_CASES_TAC `y:real^N = vec 0` THEN
  ASM_REWRITE_TAC[] THENL
   [EQ_TAC THENL [MESON_TAC[]; STRIP_TAC] THEN
    EXISTS_TAC `&0` THEN REWRITE_TAC[VECTOR_MUL_LZERO; REAL_LE_REFL] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  EQ_TAC THENL [REWRITE_TAC[LEFT_IMP_EXISTS_THM]; MESON_TAC[]] THEN
  MAP_EVERY X_GEN_TAC [`c:real`; `x:real^N`] THEN STRIP_TAC THEN
  CONJ_TAC THENL [ASM_MESON_TAC[]; REWRITE_TAC[NOT_EXISTS_THM]] THEN
  MAP_EVERY X_GEN_TAC [`d:real`; `z:real^N`] THEN ASM_REWRITE_TAC[] THEN
  STRIP_TAC THEN SUBGOAL_THEN `vec 0 IN affine hull {x:real^N,z}` MP_TAC THENL
   [REWRITE_TAC[AFFINE_HULL_0_2_EXPLICIT] THEN
    MAP_EVERY EXISTS_TAC [`c:real`; `--d:real`] THEN
    ASM_REWRITE_TAC[VECTOR_ARITH
     `a + --b % y:real^N = vec 0 <=> a = b % y`] THEN
    REWRITE_TAC[REAL_ARITH `a + --b = &0 <=> a = b`] THEN DISCH_TAC THEN
    UNDISCH_TAC `c % x:real^N = d % z` THEN
    ASM_SIMP_TAC[VECTOR_MUL_LCANCEL; REAL_LT_IMP_NZ] THEN
    ASM_MESON_TAC[VECTOR_MUL_LZERO];
    FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
     `~(z IN s) ==> t SUBSET s ==> z IN t ==> F`)) THEN
    MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[]]);;

let CONIC_HULL_INTER = prove
 (`!s t:real^N->bool.
        ~(vec 0 IN affine hull (s UNION t))
        ==> conic hull (s INTER t) =
            if s INTER t = {} then {}
            else conic hull s INTER conic hull t`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `s INTER t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY] THEN REWRITE_TAC[CONIC_HULL_EXPLICIT] THEN
  REWRITE_TAC[EXTENSION; IN_INTER; IN_ELIM_THM] THEN
  X_GEN_TAC `z:real^N` THEN EQ_TAC THENL [MESON_TAC[]; ALL_TAC] THEN
  REWRITE_TAC[IMP_CONJ; LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC [`c:real`; `x:real^N`] THEN REPEAT DISCH_TAC THEN
  MAP_EVERY X_GEN_TAC [`d:real`; `y:real^N`] THEN REPEAT DISCH_TAC THEN
  ASM_CASES_TAC `z:real^N = vec 0` THENL
   [EXISTS_TAC `&0` THEN ASM_REWRITE_TAC[REAL_POS; VECTOR_MUL_LZERO] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  ASM_CASES_TAC `c:real = d` THENL
   [SUBGOAL_THEN `x:real^N = y` SUBST_ALL_TAC THEN
    ASM_MESON_TAC[VECTOR_MUL_RZERO; VECTOR_MUL_LCANCEL];
    ALL_TAC] THEN
  SUBGOAL_THEN `vec 0 IN affine hull {x:real^N,y}` MP_TAC THENL
   [REWRITE_TAC[AFFINE_HULL_0_2_EXPLICIT] THEN
    MAP_EVERY EXISTS_TAC [`c:real`; `--d:real`] THEN
    ASM_REWRITE_TAC[VECTOR_ARITH
     `a + --b % y:real^N = vec 0 <=> a = b % y`] THEN
    ASM_REWRITE_TAC[REAL_ARITH `a + --b = &0 <=> a = b`] THEN
    ASM_MESON_TAC[];
    FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
     `!q t. ~(z IN s) ==> t SUBSET s ==> z IN t ==> q`)) THEN
    MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[]]);;

let INTER_CONIC_HULL_SUBSETS_CONVEX_RELATIVE_FRONTIER = prove
 (`!s t u:real^N->bool.
        convex u /\ vec 0 IN relative_interior u /\
        s UNION t SUBSET relative_frontier u
        ==> conic hull s INTER conic hull t =
            if s = {} \/ t = {} then {}
            else if s INTER t = {} then {vec 0}
            else conic hull (s INTER t)`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY; INTER_EMPTY] THEN
  ASM_CASES_TAC `t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY; INTER_EMPTY] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [ALL_TAC;
    COND_CASES_TAC THEN REWRITE_TAC[SUBSET_INTER] THEN
    SIMP_TAC[HULL_MONO; INTER_SUBSET; SING_SUBSET] THEN
    ASM_REWRITE_TAC[CONIC_HULL_CONTAINS_0]] THEN
  MATCH_MP_TAC(SET_RULE
   `s DELETE vec 0 SUBSET t /\ vec 0 IN t ==> s SUBSET t`) THEN
  CONJ_TAC THENL [ALL_TAC; MESON_TAC[CONIC_HULL_CONTAINS_0; IN_SING]] THEN
  TRANS_TAC SUBSET_TRANS `conic hull (s INTER t) DELETE (vec 0:real^N)` THEN
  CONJ_TAC THENL
   [ALL_TAC;
    COND_CASES_TAC THEN ASM_REWRITE_TAC[CONIC_HULL_EMPTY] THEN SET_TAC[]] THEN
  REWRITE_TAC[CONIC_HULL_EXPLICIT; SUBSET; IN_DELETE; IN_INTER] THEN
  X_GEN_TAC `z:real^N` THEN
  ASM_CASES_TAC `z:real^N = vec 0` THEN ASM_REWRITE_TAC[]  THEN
  REWRITE_TAC[IN_ELIM_THM; IMP_CONJ; LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC [`c:real`; `x:real^N`] THEN REPEAT DISCH_TAC THEN
  MAP_EVERY X_GEN_TAC [`d:real`; `y:real^N`] THEN REPEAT DISCH_TAC THEN
  ASM_CASES_TAC `z:real^N = vec 0` THENL
   [EXISTS_TAC `&0` THEN ASM_REWRITE_TAC[REAL_POS; VECTOR_MUL_LZERO] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  ASM_CASES_TAC `c:real = d` THENL
   [SUBGOAL_THEN `x:real^N = y` SUBST_ALL_TAC THEN
    ASM_MESON_TAC[VECTOR_MUL_RZERO; VECTOR_MUL_LCANCEL];
    ALL_TAC] THEN
  POP_ASSUM_LIST(MP_TAC o end_itlist CONJ) THEN
  MAP_EVERY (fun t -> SPEC_TAC(t,t))
   [`y:real^N`; `x:real^N`; `z:real^N`; `t:real^N->bool`; `s:real^N->bool`;
    `d:real`; `c:real`] THEN
  MATCH_MP_TAC REAL_WLOG_LT THEN REWRITE_TAC[] THEN CONJ_TAC THENL
   [REPEAT GEN_TAC THEN
    GEN_REWRITE_TAC RAND_CONV [SWAP_FORALL_THM] THEN
    REPLICATE_TAC 3 (AP_TERM_TAC THEN ABS_TAC) THEN
    GEN_REWRITE_TAC RAND_CONV [SWAP_FORALL_THM] THEN
    REPLICATE_TAC 2 (AP_TERM_TAC THEN ABS_TAC) THEN
    MESON_TAC[INTER_COMM; UNION_COMM];
    REPEAT STRIP_TAC] THEN
  MP_TAC(ISPECL
   [`u:real^N->bool`; `vec 0:real^N`; `x:real^N`]
        IN_RELATIVE_INTERIOR_CLOSURE_CONVEX_SEGMENT) THEN
  ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(TAUT `p /\ ~q ==> (p ==> q) ==> r`) THEN CONJ_TAC THENL
   [RULE_ASSUM_TAC(REWRITE_RULE[relative_frontier]) THEN ASM SET_TAC[];
    REWRITE_TAC[SUBSET; IN_SEGMENT]] THEN
  DISCH_THEN(MP_TAC o SPEC `y:real^N`) THEN
  REWRITE_TAC[NOT_IMP] THEN REPEAT CONJ_TAC THENL
   [ASM_MESON_TAC[VECTOR_MUL_RZERO];
    EXISTS_TAC `c / d:real`;
    RULE_ASSUM_TAC(REWRITE_RULE[relative_frontier]) THEN ASM SET_TAC[]] THEN
  SUBGOAL_THEN `&0 < d` ASSUME_TAC THENL [ASM_REAL_ARITH_TAC; ALL_TAC] THEN
  ASM_SIMP_TAC[REAL_LT_LDIV_EQ; REAL_LT_RDIV_EQ] THEN
  ASM_REWRITE_TAC[REAL_MUL_LID; VECTOR_MUL_RZERO; VECTOR_ADD_LID] THEN
  ASM_REWRITE_TAC[REAL_MUL_LZERO; REAL_LT_LE] THEN
  CONJ_TAC THENL [ASM_MESON_TAC[VECTOR_MUL_LZERO]; ALL_TAC] THEN
  UNDISCH_TAC `z:real^N = c % x` THEN
  DISCH_THEN(MP_TAC o AP_TERM `(%) (inv d):real^N->real^N`) THEN
  ASM_REWRITE_TAC[VECTOR_MUL_ASSOC; real_div] THEN
  ASM_SIMP_TAC[REAL_MUL_LINV; REAL_LT_IMP_NZ; VECTOR_MUL_LID] THEN
  REWRITE_TAC[real_div; REAL_MUL_SYM]);;

let RELATIVE_FRONTIER_CONIC_HULL = prove
 (`!s:real^N->bool.
        bounded s /\ ~(vec 0 IN affine hull s)
        ==> relative_frontier(conic hull s) =
            if ?a. s = {a} then {vec 0}
            else conic hull (relative_frontier s)`,
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `~((vec 0:real^N) IN closure s)` ASSUME_TAC THENL
   [MP_TAC(ISPEC `s:real^N->bool` CLOSURE_SUBSET_AFFINE_HULL) THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[relative_frontier] THEN ASM_SIMP_TAC[CLOSURE_CONIC_HULL] THEN
  ASM_SIMP_TAC[RELATIVE_INTERIOR_CONIC_HULL] THEN
  ASM_CASES_TAC `affine(s:real^N->bool)` THENL
   [FIRST_ASSUM(fun th ->
     REWRITE_TAC[GEN_REWRITE_RULE I
       [GSYM RELATIVE_INTERIOR_EQ_CLOSURE] th]) THEN
    REWRITE_TAC[DIFF_EQ_EMPTY; CONIC_HULL_EMPTY] THEN
    FIRST_ASSUM(MP_TAC o MATCH_MP AFFINE_BOUNDED_EQ_TRIVIAL) THEN
    ASM_REWRITE_TAC[] THEN DISCH_THEN(DISJ_CASES_THEN2
     SUBST1_TAC (X_CHOOSE_THEN `a:real^N` SUBST_ALL_TAC)) THEN
    ASM_REWRITE_TAC[CLOSURE_EMPTY; CONIC_HULL_EMPTY; EMPTY_DIFF;
      CLOSURE_SING; RELATIVE_INTERIOR_SING; NOT_INSERT_EMPTY] THEN
    REWRITE_TAC[SET_RULE `{a} = {b} <=> b = a`; EXISTS_REFL] THEN
    MATCH_MP_TAC(SET_RULE `a IN s ==> s DIFF (s DELETE a) = {a}`) THEN
    ASM_REWRITE_TAC[CONIC_HULL_CONTAINS_0; CONIC_HULL_EQ_EMPTY] THEN
    REWRITE_TAC[NOT_INSERT_EMPTY];
    COND_CASES_TAC THENL [ASM_MESON_TAC[AFFINE_SING]; ALL_TAC] THEN
    W(MP_TAC o PART_MATCH (lhs o rand) CONIC_HULL_DIFF o rand o snd) THEN
    ANTS_TAC THENL
     [ASM_REWRITE_TAC[AFFINE_HULL_CLOSURE] THEN
      MESON_TAC[RELATIVE_INTERIOR_SUBSET; CLOSURE_SUBSET; SUBSET];
      ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_CLOSURE]]]);;

let CONIC_HULL_RELATIVE_FRONTIER = prove
 (`!s:real^N->bool.
        bounded s /\ ~(vec 0 IN affine hull s)
        ==> conic hull (relative_frontier s) =
            if ?a. s = {a} then {}
            else relative_frontier(conic hull s)`,
  REPEAT STRIP_TAC THEN
  COND_CASES_TAC THEN ASM_SIMP_TAC[RELATIVE_FRONTIER_CONIC_HULL] THEN
  FIRST_X_ASSUM(CHOOSE_THEN SUBST1_TAC) THEN
  REWRITE_TAC[RELATIVE_FRONTIER_SING; CONIC_HULL_EMPTY]);;

let INTER_CONIC_HULL = prove
 (`!s t:real^N->bool.
        ~(vec 0 IN affine hull (s UNION t))
        ==> conic hull s INTER conic hull t =
            if s = {} \/ t = {} then {}
            else if s INTER t = {} then {vec 0}
            else conic hull (s INTER t)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`{vec 0:real^N}`; `affine hull (s UNION t):real^N->bool`]
      SEPARATING_HYPERPLANE_AFFINE_AFFINE) THEN
  REWRITE_TAC[AFFINE_SING; AFFINE_AFFINE_HULL; NOT_INSERT_EMPTY] THEN
  REWRITE_TAC[AFFINE_HULL_EQ_EMPTY; EMPTY_UNION] THEN
  ASM_REWRITE_TAC[SET_RULE `DISJOINT {x} s <=> ~(x IN s)`] THEN
  ASM_CASES_TAC `s:real^N->bool = {} /\ t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY; INTER_EMPTY; LEFT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[FORALL_IN_INSERT; NOT_IN_EMPTY; DOT_RZERO] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real`; `c:real`] THEN
  ASM_CASES_TAC `b:real = &0` THEN ASM_REWRITE_TAC[] THEN STRIP_TAC THEN
  MATCH_MP_TAC INTER_CONIC_HULL_SUBSETS_CONVEX_RELATIVE_FRONTIER THEN
  EXISTS_TAC `{x:real^N | a dot x <= c}` THEN
  REWRITE_TAC[CONVEX_HALFSPACE_LE] THEN
  SUBGOAL_THEN `(vec 0:real^N) IN interior {x | a dot x <= c}` ASSUME_TAC THENL
   [ASM_SIMP_TAC[INTERIOR_HALFSPACE_LE; IN_ELIM_THM; DOT_RZERO]; ALL_TAC] THEN
  ASM_SIMP_TAC[REWRITE_RULE[SUBSET] INTERIOR_SUBSET_RELATIVE_INTERIOR] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP (SET_RULE `a IN s ==> ~(s = {})`)) THEN
  ASM_SIMP_TAC[RELATIVE_FRONTIER_NONEMPTY_INTERIOR] THEN
  ASM_SIMP_TAC[FRONTIER_HALFSPACE_LE; SUBSET; IN_ELIM_THM] THEN
  ASM_MESON_TAC[HULL_INC]);;

let RELATIVE_INTERIOR_CONIC_HULL_0 = prove
 (`!s:real^N->bool.
        convex s
        ==> (vec 0 IN relative_interior(conic hull s) <=>
             vec 0 IN relative_interior s)`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONIC_HULL_EMPTY; RELATIVE_INTERIOR_EMPTY; NOT_IN_EMPTY] THEN
  ASM_CASES_TAC `(vec 0:real^N) IN affine hull s` THENL
   [ALL_TAC;
    ASM_SIMP_TAC[RELATIVE_INTERIOR_CONIC_HULL; IN_DELETE] THEN
    ASM_MESON_TAC[SUBSET; HULL_INC; RELATIVE_INTERIOR_SUBSET]] THEN
  ASM_CASES_TAC `conic hull s:real^N->bool = span s` THENL
   [ALL_TAC;
    ASM_MESON_TAC[CONIC_HULL_EQ_SPAN; CONIC_HULL_EQ_SPAN_EQ]] THEN
  ASM_SIMP_TAC[RELATIVE_INTERIOR_AFFINE; AFFINE_SPAN; SPAN_0] THEN
  ASM_SIMP_TAC[IN_RELATIVE_INTERIOR_IN_OPEN_SEGMENT_EQ] THEN
  X_GEN_TAC `x:real^N` THEN STRIP_TAC THEN
  SUBGOAL_THEN `(--x:real^N) IN conic hull s` MP_TAC THENL
   [ASM_SIMP_TAC[SPAN_NEG; SPAN_SUPERSET]; ALL_TAC] THEN
  REWRITE_TAC[CONIC_HULL_EXPLICIT; IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `a:real` THEN ASM_CASES_TAC `a = &0` THEN
  ASM_REWRITE_TAC[VECTOR_MUL_LZERO; VECTOR_NEG_EQ_0; REAL_LE_LT] THEN
  X_GEN_TAC `y:real^N` THEN STRIP_TAC THEN EXISTS_TAC `y:real^N` THEN
  ASM_REWRITE_TAC[IN_OPEN_SEGMENT] THEN CONJ_TAC THENL
   [REWRITE_TAC[GSYM BETWEEN_IN_SEGMENT; between] THEN
    ONCE_REWRITE_TAC[NORM_ARITH `dist(a:real^N,b) = dist(--a,--b)`] THEN
    ASM_REWRITE_TAC[] THEN
    REWRITE_TAC[dist; VECTOR_SUB_LZERO; VECTOR_NEG_0; VECTOR_NEG_NEG;
       VECTOR_SUB_RZERO; VECTOR_ARITH `a % y - --y:real^N = (a + &1) % y`] THEN
    REWRITE_TAC[NORM_MUL] THEN MATCH_MP_TAC(REAL_RING
     `a = b + &1 ==> a * y = b * y + y`) THEN
    ASM_REAL_ARITH_TAC;
    ASM_MESON_TAC[VECTOR_MUL_RZERO; VECTOR_NEG_EQ_0]]);;

(* ------------------------------------------------------------------------- *)
(* Facets.                                                                   *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("facet_of",(12, "right"));;

let facet_of = new_definition
 `f facet_of s <=> f face_of s /\ ~(f = {}) /\ aff_dim f = aff_dim s - &1`;;

let FACET_OF_EMPTY = prove
 (`!s. ~(s facet_of {})`,
  REWRITE_TAC[facet_of; FACE_OF_EMPTY] THEN CONV_TAC TAUT);;

let FACET_OF_REFL = prove
 (`!s. ~(s facet_of s)`,
  REWRITE_TAC[facet_of; INT_ARITH `~(x:int = x - &1)`]);;

let FACET_OF_IMP_FACE_OF = prove
 (`!f s. f facet_of s ==> f face_of s`,
  SIMP_TAC[facet_of]);;

let FACET_OF_IMP_SUBSET = prove
 (`!f s. f facet_of s ==> f SUBSET s`,
  SIMP_TAC[FACET_OF_IMP_FACE_OF; FACE_OF_IMP_SUBSET]);;

let FACET_OF_IMP_PROPER = prove
 (`!f s. f facet_of s ==> ~(f = {}) /\ ~(f = s)`,
  REWRITE_TAC[facet_of] THEN MESON_TAC[INT_ARITH `~(x - &1:int = x)`]);;

let FACET_OF_TRANSLATION_EQ = prove
 (`!a:real^N f s.
        (IMAGE (\x. a + x) f) facet_of (IMAGE (\x. a + x) s) <=> f facet_of s`,
  REWRITE_TAC[facet_of] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [FACET_OF_TRANSLATION_EQ];;

let FACET_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N c s.
      linear f /\ (!x y. f x = f y ==> x = y)
      ==> ((IMAGE f c) facet_of (IMAGE f s) <=> c facet_of s)`,
  REWRITE_TAC[facet_of] THEN GEOM_TRANSFORM_TAC[]);;

add_linear_invariants [FACET_OF_LINEAR_IMAGE];;

let HYPERPLANE_FACET_OF_HALFSPACE_LE = prove
 (`!a:real^N b.
        ~(a = vec 0) ==> {x | a dot x = b} facet_of {x | a dot x <= b}`,
  SIMP_TAC[facet_of; HYPERPLANE_FACE_OF_HALFSPACE_LE; HYPERPLANE_EQ_EMPTY;
           AFF_DIM_HYPERPLANE; AFF_DIM_HALFSPACE_LE]);;

let HYPERPLANE_FACET_OF_HALFSPACE_GE = prove
 (`!a:real^N b.
        ~(a = vec 0) ==> {x | a dot x = b} facet_of {x | a dot x >= b}`,
  SIMP_TAC[facet_of; HYPERPLANE_FACE_OF_HALFSPACE_GE; HYPERPLANE_EQ_EMPTY;
           AFF_DIM_HYPERPLANE; AFF_DIM_HALFSPACE_GE]);;

let FACET_OF_HALFSPACE_LE = prove
 (`!f a:real^N b.
        f facet_of {x | a dot x <= b} <=>
        ~(a = vec 0) /\ f = {x | a dot x = b}`,
  REPEAT GEN_TAC THEN
  EQ_TAC THEN ASM_SIMP_TAC[HYPERPLANE_FACET_OF_HALFSPACE_LE] THEN
  SIMP_TAC[AFF_DIM_HALFSPACE_LE; facet_of; FACE_OF_HALFSPACE_LE] THEN
  REWRITE_TAC[TAUT `(p \/ q) /\ ~p /\ r <=> (~p /\ q) /\ r`] THEN
  ASM_CASES_TAC `a:real^N = vec 0` THENL
   [ASM_REWRITE_TAC[DOT_LZERO; SET_RULE
     `{x | p} = if p then UNIV else {}`] THEN
    REPEAT(COND_CASES_TAC THEN ASM_REWRITE_TAC[TAUT `~(~p /\ p)`]) THEN
    TRY ASM_REAL_ARITH_TAC THEN
    DISCH_THEN(CONJUNCTS_THEN2 STRIP_ASSUME_TAC MP_TAC) THEN
    ASM_REWRITE_TAC[AFF_DIM_UNIV] THEN TRY INT_ARITH_TAC THEN ASM SET_TAC[];
    DISCH_THEN(CONJUNCTS_THEN2 STRIP_ASSUME_TAC MP_TAC) THEN
    ASM_REWRITE_TAC[AFF_DIM_HALFSPACE_LE] THEN INT_ARITH_TAC]);;

let FACET_OF_HALFSPACE_GE = prove
 (`!f a:real^N b.
        f facet_of {x | a dot x >= b} <=>
        ~(a = vec 0) /\ f = {x | a dot x = b}`,
  REPEAT GEN_TAC THEN
  MP_TAC(ISPECL [`f:real^N->bool`; `--a:real^N`; `--b:real`]
        FACET_OF_HALFSPACE_LE) THEN
  SIMP_TAC[DOT_LNEG; REAL_LE_NEG2; REAL_EQ_NEG2; VECTOR_NEG_EQ_0; real_ge]);;

let EXPOSED_FACET_OF = prove
 (`!s t:real^N->bool. convex s /\ t facet_of s ==> t exposed_face_of s`,
  REWRITE_TAC[facet_of] THEN REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `~(relative_interior t:real^N->bool = {})` MP_TAC THENL
   [ASM_MESON_TAC[RELATIVE_INTERIOR_EQ_EMPTY; face_of];
    REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM]] THEN
  X_GEN_TAC `a:real^N` THEN DISCH_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `a:real^N`]
        RELATIVE_BOUNDARY_POINT_IN_EXPOSED_FACE) THEN
  ASM_REWRITE_TAC[] THEN ANTS_TAC THENL
   [MP_TAC(ISPECL [`s:real^N->bool`; `t:real^N->bool`]
        FACE_OF_SUBSET_RELATIVE_BOUNDARY) THEN
    ASM_REWRITE_TAC[SUBSET; IN_DIFF] THEN
    ASM_MESON_TAC[SUBSET; face_of; RELATIVE_INTERIOR_SUBSET;
                  INT_ARITH `~(t:int = t - &1)`];
    DISCH_THEN(X_CHOOSE_THEN `f:real^N->bool` STRIP_ASSUME_TAC)] THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:real^N->bool`; `t:real^N->bool`]
        SUBSET_OF_FACE_OF) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[EXPOSED_FACE_OF_IMP_FACE_OF; FACE_OF_IMP_SUBSET] THEN
    ASM SET_TAC[];
    DISCH_TAC] THEN
  ASM_CASES_TAC `t:real^N->bool = f` THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP (INT_ARITH
   `t:int = s - &1 ==> !f. t < f /\ f < s ==> F`)) THEN
  MATCH_MP_TAC(TAUT `~p ==> p ==> q`) THEN
  DISCH_THEN(MP_TAC o SPEC `aff_dim(f:real^N->bool)`) THEN
  REWRITE_TAC[] THEN CONJ_TAC THEN MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
  ASM_SIMP_TAC[EXPOSED_FACE_OF_IMP_FACE_OF] THEN
  CONJ_TAC THENL [ASM_MESON_TAC[exposed_face_of; face_of]; ALL_TAC] THEN
  MATCH_MP_TAC FACE_OF_SUBSET THEN EXISTS_TAC `s:real^N->bool` THEN
  ASM_MESON_TAC[exposed_face_of; face_of]);;

let OPEN_IN_RELATIVE_FRONTIER_INTERIOR_FACET = prove
 (`!s f:real^N->bool.
        convex s /\ f facet_of s
        ==> open_in (subtopology euclidean (relative_frontier s))
                    (relative_interior f)`,
  REPEAT GEN_TAC THEN
  ASM_CASES_TAC `relative_interior s:real^N->bool = {}` THENL
   [ASM_MESON_TAC[RELATIVE_INTERIOR_EQ_EMPTY; FACET_OF_EMPTY];
    POP_ASSUM MP_TAC] THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `z:real^N` THEN GEOM_ORIGIN_TAC `z:real^N` THEN
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `relative_interior f:real^N->bool`]
        INTER_RELATIVE_FRONTIER_CONIC_HULL) THEN
  ASM_REWRITE_TAC[] THEN ANTS_TAC THENL
   [ASM_MESON_TAC[FACE_OF_SUBSET_RELATIVE_FRONTIER; FACET_OF_REFL; facet_of;
                  SUBSET_TRANS; RELATIVE_INTERIOR_SUBSET];
    DISCH_THEN SUBST1_TAC] THEN
  SUBGOAL_THEN
   `~(vec 0 IN affine hull (f:real^N->bool))`
  ASSUME_TAC THENL
   [MP_TAC(ISPECL [`s:real^N->bool`; `f:real^N->bool`]
        AFFINE_HULL_FACE_OF_DISJOINT_RELATIVE_INTERIOR) THEN
    ANTS_TAC THENL [ASM_MESON_TAC[facet_of; FACET_OF_REFL]; ASM SET_TAC[]];
    ASM_SIMP_TAC[CONIC_HULL_RELATIVE_INTERIOR]] THEN
  COND_CASES_TAC THENL
   [ASM_MESON_TAC[RELATIVE_INTERIOR_EQ_EMPTY; facet_of; face_of]; ALL_TAC] THEN
  ASM_SIMP_TAC[relative_frontier; SET_RULE
    `z IN i ==> (c DIFF i) INTER (z INSERT s) = (c DIFF i) INTER s`] THEN
  REWRITE_TAC[GSYM relative_frontier] THEN
  MATCH_MP_TAC OPEN_IN_SUBTOPOLOGY_INTER_SUBSET THEN
  EXISTS_TAC `affine hull s:real^N->bool` THEN
  SIMP_TAC[CLOSURE_SUBSET_AFFINE_HULL; relative_frontier;
           SET_RULE `s SUBSET t ==> s DIFF u SUBSET t`] THEN
  MATCH_MP_TAC OPEN_IN_INTER THEN REWRITE_TAC[OPEN_IN_REFL] THEN
  MP_TAC(ISPEC `conic hull f:real^N->bool` OPEN_IN_RELATIVE_INTERIOR) THEN
  MATCH_MP_TAC EQ_IMP THEN AP_THM_TAC THEN AP_TERM_TAC THEN AP_TERM_TAC THEN
  REWRITE_TAC[AFFINE_HULL_CONIC_HULL] THEN
  COND_CASES_TAC THENL [ASM_MESON_TAC[facet_of]; ALL_TAC] THEN
  MATCH_MP_TAC AFF_DIM_EQ_AFFINE_HULL THEN
  RULE_ASSUM_TAC(REWRITE_RULE[facet_of]) THEN
  ASM_REWRITE_TAC[INSERT_SUBSET; AFF_DIM_INSERT] THEN
  CONJ_TAC THENL [ALL_TAC; INT_ARITH_TAC] THEN
  ASM_MESON_TAC[face_of; SUBSET; RELATIVE_INTERIOR_SUBSET; SUBSET]);;

(* ------------------------------------------------------------------------- *)
(* Extreme points of convex closed set with aff_dim <= 2 are closed.         *)
(* ------------------------------------------------------------------------- *)

let CLOSED_EXTREME_POINTS_2D = prove
 (`!s:real^N->bool.
        closed s /\ convex s /\ aff_dim s <= &2
        ==> closed {x | x extreme_point_of s}`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP (INT_ARITH
   `a:int <= &2
    ==> -- &1 <= a ==> a = -- &1 \/ a = &0 \/ &1 <= a`)) THEN
  REWRITE_TAC[AFF_DIM_GE; AFF_DIM_EQ_MINUS1; AFF_DIM_EQ_0] THEN STRIP_TAC THEN
  ASM_REWRITE_TAC[] THENL
   [ASM_REWRITE_TAC[EXTREME_POINT_OF_EMPTY; EMPTY_GSPEC; CLOSED_EMPTY];
    ASM_REWRITE_TAC[EXTREME_POINT_OF_SING; SING_GSPEC; CLOSED_SING];
    MATCH_MP_TAC CLOSED_IN_CLOSED_TRANS THEN
    EXISTS_TAC `relative_frontier s:real^N->bool` THEN
    REWRITE_TAC[CLOSED_RELATIVE_FRONTIER]] THEN
  SUBGOAL_THEN
   `{x:real^N | x extreme_point_of s} =
    relative_frontier s DIFF
    UNIONS {relative_interior f | f face_of s /\ aff_dim f = &1}`
  SUBST1_TAC THENL
   [ASM_SIMP_TAC[GSYM RELATIVE_FRONTIER_FACIAL_PARTITION] THEN
    ASM_SIMP_TAC[AFF_DIM_GE; INT_ARITH
     `-- &1:int <= f /\ &1 <= s /\ s <= &2
      ==> (f < s <=> f = -- &1 /\ &0 <= s \/
                     f = &0 \/
                     f = &1 /\ s = &2)`] THEN
    REWRITE_TAC[UNIONS_UNION; LEFT_OR_DISTRIB;
      SET_RULE `{f x | P x \/ Q x} = {f x | P x} UNION {f x | Q x}`] THEN
    MATCH_MP_TAC(SET_RULE
     `f1 SUBSET f /\ DISJOINT f f0 /\ fn = {} /\ f0 = e
      ==>  e = (fn UNION f0 UNION f1) DIFF f`) THEN
    REPEAT CONJ_TAC THENL
     [SET_TAC[];
      REWRITE_TAC[DISJOINT; INTER_UNIONS; EMPTY_UNIONS; FORALL_IN_GSPEC] THEN
      REWRITE_TAC[GSYM DISJOINT] THEN
      MESON_TAC[FACE_OF_EQ; INT_ARITH `~(&1:int = &0)`];
      SIMP_TAC[EMPTY_UNIONS; FORALL_IN_GSPEC; AFF_DIM_EQ_MINUS1;
               RELATIVE_INTERIOR_EMPTY];
      REWRITE_TAC[AFF_DIM_EQ_0; SET_RULE
       `{f x | P x /\ (?a. x = s a)} = {f (s a) |a| P (s a)}`] THEN
      REWRITE_TAC[RELATIVE_INTERIOR_SING; FACE_OF_SING; UNIONS_GSPEC] THEN
      SET_TAC[]];
     FIRST_ASSUM(MP_TAC o MATCH_MP (INT_ARITH
      `&1:int <= a ==> a <= &2 ==> a = &1 \/ a = &2`)) THEN
     ASM_REWRITE_TAC[] THEN STRIP_TAC THENL
      [SUBGOAL_THEN
        `!f:real^N->bool. f face_of s /\ aff_dim f = &1 <=> f = s`
        (fun th -> REWRITE_TAC[th])
       THENL
        [ASM_MESON_TAC[FACE_OF_AFF_DIM_LT; INT_LT_REFL; FACE_OF_REFL];
         REWRITE_TAC[SET_RULE `{f x | x = a} = {f a}`; UNIONS_1] THEN
         REWRITE_TAC[relative_frontier; CLOSED_IN_REFL;
            SET_RULE `(s DIFF i) DIFF i = s DIFF i`]];
       FIRST_ASSUM(fun th -> REWRITE_TAC
        [MATCH_MP (INT_ARITH
           `s:int = &2 ==> (f = &1 <=> ~(f = -- &1) /\ f = s - &1)`) th]) THEN
       REWRITE_TAC[AFF_DIM_EQ_MINUS1; GSYM facet_of] THEN
       MATCH_MP_TAC CLOSED_IN_DIFF THEN REWRITE_TAC[CLOSED_IN_REFL] THEN
       MATCH_MP_TAC OPEN_IN_UNIONS THEN
       ASM_SIMP_TAC[FORALL_IN_GSPEC;
                    OPEN_IN_RELATIVE_FRONTIER_INTERIOR_FACET]]]);;

(* ------------------------------------------------------------------------- *)
(* Edges, i.e. faces of affine dimension 1.                                  *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("edge_of",(12, "right"));;

let edge_of = new_definition
 `e edge_of s <=> e face_of s /\ aff_dim e = &1`;;

let EDGE_OF_TRANSLATION_EQ = prove
 (`!a:real^N f s.
        (IMAGE (\x. a + x) f) edge_of (IMAGE (\x. a + x) s) <=> f edge_of s`,
  REWRITE_TAC[edge_of] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [EDGE_OF_TRANSLATION_EQ];;

let EDGE_OF_LINEAR_IMAGE = prove
 (`!f:real^M->real^N c s.
      linear f /\ (!x y. f x = f y ==> x = y)
      ==> ((IMAGE f c) edge_of (IMAGE f s) <=> c edge_of s)`,
  REWRITE_TAC[edge_of] THEN GEOM_TRANSFORM_TAC[]);;

add_linear_invariants [EDGE_OF_LINEAR_IMAGE];;

let EDGE_OF_IMP_SUBSET = prove
 (`!s t. s edge_of t ==> s SUBSET t`,
  SIMP_TAC[edge_of; face_of]);;

(* ------------------------------------------------------------------------- *)
(* Existence of extreme points.                                              *)
(* ------------------------------------------------------------------------- *)

let DIFFERENT_NORM_3_COLLINEAR_POINTS = prove
 (`!a b x:real^N.
     ~(x IN segment(a,b) /\ norm(a) = norm(b) /\ norm(x) = norm(b))`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `a:real^N = b` THEN
  ASM_SIMP_TAC[SEGMENT_REFL; NOT_IN_EMPTY; OPEN_SEGMENT_ALT] THEN
  REWRITE_TAC[IN_ELIM_THM] THEN DISCH_THEN
   (CONJUNCTS_THEN2 (X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC) MP_TAC) THEN
  ASM_REWRITE_TAC[NORM_EQ] THEN REWRITE_TAC[VECTOR_ARITH
   `(x + y:real^N) dot (x + y) = x dot x + &2 * x dot y + y dot y`] THEN
  REWRITE_TAC[DOT_LMUL; DOT_RMUL] THEN
  DISCH_THEN(CONJUNCTS_THEN2 (ASSUME_TAC o SYM) MP_TAC) THEN
  UNDISCH_TAC `~(a:real^N = b)` THEN
  GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM VECTOR_SUB_EQ] THEN
  REWRITE_TAC[GSYM DOT_EQ_0; VECTOR_ARITH
   `(a - b:real^N) dot (a - b) = a dot a + b dot b - &2 * a dot b`] THEN
  ASM_REWRITE_TAC[REAL_RING `a + a - &2 * ab = &0 <=> ab = a`] THEN
  SIMP_TAC[REAL_RING
   `(&1 - u) * (&1 - u) * a + &2 * (&1 - u) * u * x + u * u * a = a <=>
    x = a \/ u = &0 \/ u = &1`] THEN
  ASM_REAL_ARITH_TAC);;

let EXTREME_POINT_EXISTS_CONVEX = prove
 (`!s:real^N->bool.
        compact s /\ convex s /\ ~(s = {}) ==> ?x. x extreme_point_of s`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `vec 0:real^N`] DISTANCE_ATTAINS_SUP) THEN
  ASM_REWRITE_TAC[DIST_0; extreme_point_of] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `x:real^N` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real^N`] THEN
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`a:real^N`; `b:real^N`; `x:real^N`]
     DIFFERENT_NORM_3_COLLINEAR_POINTS) THEN
  ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(REAL_ARITH
   `a <= x /\ b <= x /\ (a < x ==> x < x) /\ (b < x ==> x < x)
    ==> a = b /\ x = b`) THEN
  ASM_SIMP_TAC[] THEN
  UNDISCH_TAC `(x:real^N) IN segment(a,b)` THEN
  ASM_CASES_TAC `a:real^N = b` THEN
  ASM_REWRITE_TAC[SEGMENT_REFL; NOT_IN_EMPTY] THEN
  ASM_SIMP_TAC[OPEN_SEGMENT_ALT; IN_ELIM_THM] THEN
  DISCH_THEN(X_CHOOSE_THEN `u:real` STRIP_ASSUME_TAC) THEN
  CONJ_TAC THEN DISCH_TAC THEN
  FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th]) THEN
  MATCH_MP_TAC NORM_TRIANGLE_LT THEN REWRITE_TAC[NORM_MUL] THEN
  ASM_SIMP_TAC[REAL_ARITH
   `&0 < u /\ u < &1 ==> abs u = u /\ abs(&1 - u) = &1 - u`] THEN
  SUBST1_TAC(REAL_RING `norm(x:real^N) = (&1 - u) * norm x + u * norm x`) THENL
   [MATCH_MP_TAC REAL_LTE_ADD2; MATCH_MP_TAC REAL_LET_ADD2] THEN
  ASM_SIMP_TAC[REAL_LE_LMUL_EQ; REAL_LT_LMUL_EQ; REAL_SUB_LT]);;

(* ------------------------------------------------------------------------- *)
(* Krein-Milman, the weaker form as in more general spaces first.            *)
(* ------------------------------------------------------------------------- *)

let KREIN_MILMAN = prove
 (`!s:real^N->bool.
        convex s /\ compact s
        ==> s = closure(convex hull {x | x extreme_point_of s})`,
  GEN_TAC THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [ASM_REWRITE_TAC[extreme_point_of; NOT_IN_EMPTY; EMPTY_GSPEC] THEN
    REWRITE_TAC[CONVEX_HULL_EMPTY; CLOSURE_EMPTY];
    ALL_TAC] THEN
  STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [ALL_TAC;
    MATCH_MP_TAC CLOSURE_MINIMAL THEN ASM_SIMP_TAC[COMPACT_IMP_CLOSED] THEN
    MATCH_MP_TAC HULL_MINIMAL THEN
    ASM_SIMP_TAC[SUBSET; IN_ELIM_THM; extreme_point_of]] THEN
  REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN
  X_GEN_TAC `u:real^N` THEN DISCH_TAC THEN
  MATCH_MP_TAC(TAUT `(~p ==> F) ==> p`) THEN DISCH_TAC THEN
  MP_TAC(ISPECL [`closure(convex hull {x:real^N | x extreme_point_of s})`;
                 `u:real^N`] SEPARATING_HYPERPLANE_CLOSED_POINT) THEN
  ASM_SIMP_TAC[CONVEX_CLOSURE; CLOSED_CLOSURE; CONVEX_CONVEX_HULL] THEN
  REWRITE_TAC[NOT_EXISTS_THM; TAUT `~(a /\ b) <=> a ==> ~b`] THEN
  MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real`] THEN REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`\x:real^N. a dot x`; `s:real^N->bool`]
    CONTINUOUS_ATTAINS_INF) THEN
  ASM_REWRITE_TAC[CONTINUOUS_ON_LIFT_DOT] THEN
  DISCH_THEN(X_CHOOSE_THEN `m:real^N` STRIP_ASSUME_TAC) THEN
  ABBREV_TAC `t = {x:real^N | x IN s /\ a dot x = a dot m}` THEN
  SUBGOAL_THEN `?x:real^N. x extreme_point_of t` (X_CHOOSE_TAC `v:real^N`)
  THENL
   [MATCH_MP_TAC EXTREME_POINT_EXISTS_CONVEX THEN
    EXPAND_TAC "t" THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_ELIM_THM] THEN
    REWRITE_TAC[SET_RULE `{x | x IN s /\ P x} = s INTER {x | P x}`] THEN
    ASM_SIMP_TAC[CONVEX_INTER; CONVEX_HYPERPLANE; COMPACT_INTER_CLOSED;
                 CLOSED_HYPERPLANE] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `(v:real^N) extreme_point_of s` ASSUME_TAC THENL
   [REWRITE_TAC[GSYM FACE_OF_SING] THEN MATCH_MP_TAC FACE_OF_TRANS THEN
    EXISTS_TAC `t:real^N->bool` THEN ASM_SIMP_TAC[FACE_OF_SING] THEN
    EXPAND_TAC "t" THEN
    REWRITE_TAC[SET_RULE `{x | x IN s /\ P x} = s INTER {x | P x}`] THEN
    MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE THEN
    ASM_SIMP_TAC[real_ge];
    SUBGOAL_THEN `(a:real^N) dot v > b` MP_TAC THENL
     [FIRST_X_ASSUM MATCH_MP_TAC THEN
      MATCH_MP_TAC(REWRITE_RULE[SUBSET] CLOSURE_SUBSET) THEN
      MATCH_MP_TAC HULL_INC THEN ASM_REWRITE_TAC[IN_ELIM_THM];
      ALL_TAC] THEN
    REWRITE_TAC[real_gt; REAL_NOT_LT] THEN
    MATCH_MP_TAC REAL_LE_TRANS THEN EXISTS_TAC `(a:real^N) dot u` THEN
    ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN
    MATCH_MP_TAC REAL_LE_TRANS THEN EXISTS_TAC `(a:real^N) dot m` THEN
    ASM_SIMP_TAC[] THEN
    UNDISCH_TAC `(v:real^N) extreme_point_of t` THEN EXPAND_TAC "t" THEN
    SIMP_TAC[extreme_point_of; IN_ELIM_THM; REAL_LE_REFL]]);;

(* ------------------------------------------------------------------------- *)
(* Now the sharper form.                                                     *)
(* ------------------------------------------------------------------------- *)

let KREIN_MILMAN_MINKOWSKI = prove
 (`!s:real^N->bool.
        convex s /\ compact s
        ==> s = convex hull {x | x extreme_point_of s}`,
  SUBGOAL_THEN
   `!s:real^N->bool.
        convex s /\ compact s /\ (vec 0) IN s
        ==> (vec 0) IN convex hull {x | x extreme_point_of s}`
  ASSUME_TAC THENL
   [GEN_TAC THEN WF_INDUCT_TAC `dim(s:real^N->bool)` THEN STRIP_TAC THEN
    ASM_CASES_TAC `(vec 0:real^N) IN relative_interior s` THENL
     [MP_TAC(ISPEC `s:real^N->bool` KREIN_MILMAN) THEN
      ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
      UNDISCH_TAC `(vec 0:real^N) IN relative_interior s` THEN
      FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC
       (LAND_CONV o RAND_CONV o RAND_CONV) [th]) THEN
      SIMP_TAC[CONVEX_RELATIVE_INTERIOR_CLOSURE; CONVEX_CONVEX_HULL] THEN
      MESON_TAC[RELATIVE_INTERIOR_SUBSET; SUBSET];
      ALL_TAC] THEN
    SUBGOAL_THEN `~(relative_interior(s:real^N->bool) = {})` ASSUME_TAC THENL
     [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY] THEN ASM SET_TAC[];
      ALL_TAC] THEN
    MP_TAC(ISPECL [`s:real^N->bool`; `vec 0:real^N`]
          SUPPORTING_HYPERPLANE_RELATIVE_BOUNDARY) THEN
    ASM_REWRITE_TAC[DOT_RZERO] THEN
    DISCH_THEN(X_CHOOSE_THEN `a:real^N` STRIP_ASSUME_TAC) THEN
    MP_TAC(ISPECL [`s:real^N->bool`; `a:real^N`; `&0`]
      FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE) THEN
    ASM_REWRITE_TAC[real_ge] THEN DISCH_TAC THEN
    SUBGOAL_THEN
     `(vec 0:real^N) IN convex hull
          {x | x extreme_point_of (s INTER {x | a dot x = &0})}`
    MP_TAC THENL
     [ALL_TAC;
      MATCH_MP_TAC(SET_RULE `s SUBSET t ==> x IN s ==> x IN t`) THEN
      MATCH_MP_TAC HULL_MONO THEN REWRITE_TAC[SUBSET] THEN
      GEN_TAC THEN REWRITE_TAC[IN_ELIM_THM; GSYM FACE_OF_SING] THEN
      ASM_MESON_TAC[FACE_OF_TRANS]] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[IMP_IMP]) THEN FIRST_X_ASSUM MATCH_MP_TAC THEN
    ASM_SIMP_TAC[CONVEX_INTER; CONVEX_HYPERPLANE; COMPACT_INTER_CLOSED;
                 CLOSED_HYPERPLANE; IN_INTER; IN_ELIM_THM; DOT_RZERO] THEN
    REWRITE_TAC[GSYM NOT_LE] THEN DISCH_TAC THEN
    MP_TAC(ISPECL
     [`s INTER {x:real^N | a dot x = &0}`; `s:real^N->bool`]
          DIM_EQ_SPAN) THEN
    ASM_REWRITE_TAC[INTER_SUBSET; EXTENSION; NOT_FORALL_THM] THEN
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
    MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `c:real^N` THEN DISCH_TAC THEN
    MATCH_MP_TAC(TAUT `b /\ ~a ==> ~(a <=> b)`) THEN CONJ_TAC THENL
     [ASM_MESON_TAC[SUBSET; SPAN_INC; RELATIVE_INTERIOR_SUBSET]; ALL_TAC] THEN
    SUBGOAL_THEN
     `!x:real^N. x IN span (s INTER {x | a dot x = &0}) ==> a dot x = &0`
     (fun th -> ASM_MESON_TAC[th; REAL_LT_REFL]) THEN
    MATCH_MP_TAC SPAN_INDUCT THEN SIMP_TAC[IN_INTER; IN_ELIM_THM] THEN
    REWRITE_TAC[subspace; DOT_RZERO; DOT_RADD; DOT_RMUL; IN_ELIM_THM] THEN
    CONV_TAC REAL_RING;
    ALL_TAC] THEN
  REPEAT STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [REWRITE_TAC[SUBSET] THEN X_GEN_TAC `a:real^N` THEN DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `IMAGE (\x:real^N. --a + x) s`) THEN
    ASM_SIMP_TAC[CONVEX_TRANSLATION_EQ; COMPACT_TRANSLATION_EQ] THEN
    REWRITE_TAC[IN_IMAGE; VECTOR_ARITH `vec 0:real^N = --a + x <=> x = a`] THEN
    ASM_REWRITE_TAC[UNWIND_THM2] THEN
    REWRITE_TAC[EXTREME_POINTS_OF_TRANSLATION; CONVEX_HULL_TRANSLATION] THEN
    REWRITE_TAC[IN_IMAGE; VECTOR_ARITH `vec 0:real^N = --a + x <=> x = a`] THEN
    REWRITE_TAC[UNWIND_THM2];
    MATCH_MP_TAC HULL_MINIMAL THEN
    ASM_SIMP_TAC[SUBSET; extreme_point_of; IN_ELIM_THM]]);;

let KREIN_MILMAN_EQ = prove
 (`!s e:real^N->bool.
        compact s /\ convex s
        ==> (convex hull e = s <=>
             e SUBSET s /\ {x | x extreme_point_of s} SUBSET e)`,
  REPEAT STRIP_TAC THEN EQ_TAC THEN STRIP_TAC THENL
   [EXPAND_TAC "s" THEN
    REWRITE_TAC[HULL_SUBSET; EXTREME_POINTS_OF_CONVEX_HULL];
    MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
     [MATCH_MP_TAC HULL_MINIMAL THEN ASM_REWRITE_TAC[];
      TRANS_TAC SUBSET_TRANS
       `convex hull {x:real^N | x extreme_point_of s}` THEN
      ASM_SIMP_TAC[HULL_MONO] THEN
      ASM_MESON_TAC[KREIN_MILMAN_MINKOWSKI; SUBSET_REFL]]]);;

(* ------------------------------------------------------------------------- *)
(* Applying it to convex hulls of explicitly indicated finite sets.          *)
(* ------------------------------------------------------------------------- *)

let KREIN_MILMAN_POLYTOPE = prove
 (`!s. FINITE s
       ==> convex hull s =
           convex hull {x | x extreme_point_of (convex hull s)}`,
  SIMP_TAC[KREIN_MILMAN_MINKOWSKI; CONVEX_CONVEX_HULL;
           COMPACT_CONVEX_HULL; FINITE_IMP_COMPACT]);;

let EXTREME_POINTS_OF_CONVEX_HULL_EQ = prove
 (`!s:real^N->bool.
        compact s /\
        (!t. t PSUBSET s ==> ~(convex hull t = convex hull s))
        ==> {x | x extreme_point_of (convex hull s)} = s`,
  REPEAT STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o SPEC
   `{x:real^N | x extreme_point_of (convex hull s)}`) THEN
  MATCH_MP_TAC(SET_RULE
   `P /\ t SUBSET s ==> (t PSUBSET s ==> ~P) ==> t = s`) THEN
  REWRITE_TAC[EXTREME_POINTS_OF_CONVEX_HULL] THEN
  CONV_TAC SYM_CONV THEN MATCH_MP_TAC KREIN_MILMAN_MINKOWSKI THEN
  ASM_SIMP_TAC[CONVEX_CONVEX_HULL; COMPACT_CONVEX_HULL]);;

let EXTREME_POINT_OF_CONVEX_HULL_EQ = prove
 (`!s x:real^N.
        compact s /\
        (!t. t PSUBSET s ==> ~(convex hull t = convex hull s))
        ==> (x extreme_point_of (convex hull s) <=> x IN s)`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(MP_TAC o MATCH_MP EXTREME_POINTS_OF_CONVEX_HULL_EQ) THEN
  SET_TAC[]);;

let EXTREME_POINT_OF_CONVEX_HULL_CONVEX_INDEPENDENT = prove
 (`!s x:real^N.
        compact s /\
        (!a. a IN s ==> ~(a IN convex hull (s DELETE a)))
        ==> (x extreme_point_of (convex hull s) <=> x IN s)`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC EXTREME_POINT_OF_CONVEX_HULL_EQ THEN
  ASM_REWRITE_TAC[PSUBSET_MEMBER] THEN X_GEN_TAC `t:real^N->bool` THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (X_CHOOSE_TAC `a:real^N`)) THEN
  DISCH_TAC THEN FIRST_X_ASSUM(MP_TAC o SPEC `a:real^N`) THEN
  ASM_REWRITE_TAC[] THEN
  SUBGOAL_THEN `s SUBSET convex hull (s DELETE (a:real^N))` MP_TAC THENL
   [ALL_TAC; ASM SET_TAC[]] THEN
  MATCH_MP_TAC SUBSET_TRANS THEN EXISTS_TAC `convex hull t:real^N->bool` THEN
  CONJ_TAC THENL
   [ASM_REWRITE_TAC[HULL_SUBSET];
    MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[]]);;

let EXTREME_POINT_OF_CONVEX_HULL_AFFINE_INDEPENDENT = prove
 (`!s x. ~affine_dependent s
         ==> (x extreme_point_of (convex hull s) <=> x IN s)`,
  REPEAT STRIP_TAC THEN
  MATCH_MP_TAC EXTREME_POINT_OF_CONVEX_HULL_CONVEX_INDEPENDENT THEN
  ASM_SIMP_TAC[AFFINE_INDEPENDENT_IMP_FINITE; FINITE_IMP_COMPACT] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE RAND_CONV [affine_dependent]) THEN
  MESON_TAC[SUBSET; CONVEX_HULL_SUBSET_AFFINE_HULL]);;

let EXTREME_POINTS_OF_CONVEX_HULL_AFFINE_INDEPENDENT = prove
 (`!s:real^N->bool.
        ~affine_dependent s ==> {x | x extreme_point_of convex hull s} = s`,
  SIMP_TAC[EXTENSION; IN_ELIM_THM;
           EXTREME_POINT_OF_CONVEX_HULL_AFFINE_INDEPENDENT]);;

let SIMPLEX_VERTICES_UNIQUE = prove
 (`!s t:real^N->bool.
        ~affine_dependent s /\ ~affine_dependent t /\
        convex hull s = convex hull t
        ==> s = t`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[EXTENSION] THEN
  ASM_MESON_TAC[EXTREME_POINT_OF_CONVEX_HULL_AFFINE_INDEPENDENT]);;

let EXTREME_POINT_OF_CONVEX_HULL_2 = prove
 (`!a b x. x extreme_point_of (convex hull {a,b}) <=> x = a \/ x = b`,
  REWRITE_TAC[SET_RULE `x = a \/ x = b <=> x IN {a,b}`] THEN
  SIMP_TAC[EXTREME_POINT_OF_CONVEX_HULL_AFFINE_INDEPENDENT;
           AFFINE_INDEPENDENT_2]);;

let EXTREME_POINT_OF_SEGMENT = prove
 (`!a b x:real^N. x extreme_point_of segment[a,b] <=> x = a \/ x = b`,
  REWRITE_TAC[SEGMENT_CONVEX_HULL; EXTREME_POINT_OF_CONVEX_HULL_2]);;

let FACE_OF_CONVEX_HULL_SUBSET = prove
 (`!s t:real^N->bool.
        compact s /\ t face_of (convex hull s)
        ==> ?s'. s' SUBSET s /\ t = convex hull s'`,
  REPEAT STRIP_TAC THEN EXISTS_TAC `{x:real^N | x extreme_point_of t}` THEN
  REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN CONJ_TAC THENL
   [X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
    MATCH_MP_TAC EXTREME_POINT_OF_CONVEX_HULL THEN
    ASM_MESON_TAC[FACE_OF_SING; FACE_OF_TRANS];
    MATCH_MP_TAC KREIN_MILMAN_MINKOWSKI THEN
    ASM_MESON_TAC[FACE_OF_IMP_CONVEX; FACE_OF_IMP_COMPACT;
                  COMPACT_CONVEX_HULL; CONVEX_CONVEX_HULL]]);;

let FACE_OF_CONVEX_HULL_AFFINE_INDEPENDENT = prove
 (`!s t:real^N->bool.
        ~affine_dependent s
        ==> (t face_of (convex hull s) <=>
             ?c. c SUBSET s /\ t = convex hull c)`,
  REPEAT STRIP_TAC THEN EQ_TAC THENL
   [ASM_MESON_TAC[AFFINE_INDEPENDENT_IMP_FINITE; FINITE_IMP_COMPACT;
                  FACE_OF_CONVEX_HULL_SUBSET];
    STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    MATCH_MP_TAC FACE_OF_CONVEX_HULLS THEN
    ASM_SIMP_TAC[AFFINE_INDEPENDENT_IMP_FINITE] THEN
    MATCH_MP_TAC(SET_RULE `
     !t. u SUBSET t /\ DISJOINT s t ==> DISJOINT s u`) THEN
    EXISTS_TAC `affine hull (s DIFF c:real^N->bool)` THEN
    REWRITE_TAC[CONVEX_HULL_SUBSET_AFFINE_HULL] THEN
    MATCH_MP_TAC DISJOINT_AFFINE_HULL THEN
    EXISTS_TAC `s:real^N->bool` THEN ASM SET_TAC[]]);;

let FACET_OF_CONVEX_HULL_AFFINE_INDEPENDENT = prove
 (`!s t:real^N->bool.
        ~affine_dependent s
        ==> (t facet_of (convex hull s) <=>
             ~(t = {}) /\ ?u. u IN s /\ t = convex hull (s DELETE u))`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[facet_of; FACE_OF_CONVEX_HULL_AFFINE_INDEPENDENT] THEN
  REWRITE_TAC[AFF_DIM_CONVEX_HULL] THEN EQ_TAC THENL
   [DISCH_THEN(CONJUNCTS_THEN2 MP_TAC STRIP_ASSUME_TAC) THEN
    DISCH_THEN(X_CHOOSE_THEN `c:real^N->bool` MP_TAC) THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC SUBST_ALL_TAC) THEN
    UNDISCH_TAC
     `aff_dim(convex hull c:real^N->bool) = aff_dim(s:real^N->bool) - &1` THEN
    SUBGOAL_THEN `~affine_dependent(c:real^N->bool)` ASSUME_TAC THENL
     [ASM_MESON_TAC[AFFINE_INDEPENDENT_SUBSET];
      ASM_SIMP_TAC[AFF_DIM_AFFINE_INDEPENDENT; AFF_DIM_CONVEX_HULL]] THEN
    REWRITE_TAC[INT_ARITH `x - &1:int = y - &1 - &1 <=> y = x + &1`] THEN
    REWRITE_TAC[INT_OF_NUM_ADD; INT_OF_NUM_EQ] THEN DISCH_TAC THEN
    SUBGOAL_THEN `(s DIFF c:real^N->bool) HAS_SIZE 1` MP_TAC THENL
     [ASM_SIMP_TAC[HAS_SIZE; FINITE_DIFF; CARD_DIFF;
                   AFFINE_INDEPENDENT_IMP_FINITE] THEN ARITH_TAC;
      CONV_TAC(LAND_CONV HAS_SIZE_CONV) THEN
      MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `u:real^N` THEN
      DISCH_THEN(MP_TAC o MATCH_MP (SET_RULE
       `s DIFF t = {a} ==> t SUBSET s ==> s = a INSERT t`)) THEN
      ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST_ALL_TAC THEN
      UNDISCH_TAC `CARD((u:real^N) INSERT c) = CARD c + 1` THEN
      ASM_SIMP_TAC[CARD_CLAUSES; AFFINE_INDEPENDENT_IMP_FINITE] THEN
      COND_CASES_TAC THENL [ARITH_TAC; DISCH_THEN(K ALL_TAC)] THEN
      CONJ_TAC THENL [ALL_TAC; AP_TERM_TAC] THEN ASM SET_TAC[]];
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN ASM_REWRITE_TAC[] THEN
    DISCH_THEN(X_CHOOSE_THEN `u:real^N` MP_TAC) THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC SUBST1_TAC) THEN
    CONJ_TAC THENL [MESON_TAC[DELETE_SUBSET]; ALL_TAC] THEN
    ASM_SIMP_TAC[AFF_DIM_CONVEX_HULL] THEN
    SUBGOAL_THEN `~affine_dependent(s DELETE (u:real^N))` ASSUME_TAC THENL
     [ASM_MESON_TAC[AFFINE_INDEPENDENT_SUBSET; DELETE_SUBSET];
      ASM_SIMP_TAC[AFF_DIM_AFFINE_INDEPENDENT]] THEN
    REWRITE_TAC[INT_ARITH `x - &1:int = y - &1 - &1 <=> y = x + &1`] THEN
    REWRITE_TAC[INT_OF_NUM_ADD; INT_OF_NUM_EQ] THEN
    ASM_SIMP_TAC[CARD_DELETE; AFFINE_INDEPENDENT_IMP_FINITE] THEN
    MATCH_MP_TAC(ARITH_RULE `~(s = 0) ==> s = s - 1 + 1`) THEN
    ASM_SIMP_TAC[CARD_EQ_0; AFFINE_INDEPENDENT_IMP_FINITE] THEN
    ASM SET_TAC[]]);;

let FACET_OF_CONVEX_HULL_AFFINE_INDEPENDENT_ALT = prove
 (`!s t:real^N->bool.
        ~affine_dependent s
        ==> (t facet_of (convex hull s) <=>
             2 <= CARD s /\ ?u. u IN s /\ t = convex hull (s DELETE u))`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[FACET_OF_CONVEX_HULL_AFFINE_INDEPENDENT] THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM] THEN AP_TERM_TAC THEN
  GEN_REWRITE_TAC I [FUN_EQ_THM] THEN
  X_GEN_TAC `u:real^N` THEN
  ASM_CASES_TAC `t = convex hull (s DELETE (u:real^N))` THEN
  ASM_REWRITE_TAC[CONVEX_HULL_EQ_EMPTY] THEN
  ASM_CASES_TAC `(u:real^N) IN s` THEN ASM_REWRITE_TAC[] THEN
  SUBGOAL_THEN `CARD s = 1 + CARD(s DELETE (u:real^N))` SUBST1_TAC THENL
   [ASM_SIMP_TAC[CARD_DELETE; AFFINE_INDEPENDENT_IMP_FINITE] THEN
    MATCH_MP_TAC(ARITH_RULE `~(s = 0) ==> s = 1 + s - 1`) THEN
    ASM_SIMP_TAC[CARD_EQ_0; AFFINE_INDEPENDENT_IMP_FINITE] THEN
    ASM SET_TAC[];
    REWRITE_TAC[ARITH_RULE `2 <= 1 + x <=> ~(x = 0)`] THEN
    ASM_SIMP_TAC[CARD_EQ_0; AFFINE_INDEPENDENT_IMP_FINITE; FINITE_DELETE]]);;

let SEGMENT_FACE_OF = prove
 (`!s a b:real^N.
    segment[a,b] face_of s ==> a extreme_point_of s /\ b extreme_point_of s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM FACE_OF_SING] THEN
  MATCH_MP_TAC FACE_OF_TRANS THEN EXISTS_TAC `segment[a:real^N,b]` THEN
  ASM_REWRITE_TAC[] THEN REWRITE_TAC[FACE_OF_SING; EXTREME_POINT_OF_SEGMENT]);;

let SEGMENT_EDGE_OF = prove
 (`!s a b:real^N.
        segment[a,b] edge_of s
        ==> ~(a = b) /\ a extreme_point_of s /\ b extreme_point_of s`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN CONJ_TAC THENL
   [ALL_TAC; ASM_MESON_TAC[edge_of; SEGMENT_FACE_OF]] THEN
  POP_ASSUM MP_TAC THEN ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
  SIMP_TAC[SEGMENT_REFL; edge_of; AFF_DIM_SING] THEN INT_ARITH_TAC);;

let COMPACT_CONVEX_COLLINEAR_SEGMENT = prove
 (`!s:real^N->bool.
        ~(s = {}) /\ compact s /\ convex s /\ collinear s
        ==> ?a b. s = segment[a,b]`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPEC `s:real^N->bool` KREIN_MILMAN_MINKOWSKI) THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP COLLINEAR_EXTREME_POINTS) THEN
  REWRITE_TAC[ARITH_RULE `n <= 2 <=> n = 0 \/ n = 1 \/ n = 2`] THEN
  REWRITE_TAC[LEFT_OR_DISTRIB; GSYM HAS_SIZE] THEN
  CONV_TAC(ONCE_DEPTH_CONV HAS_SIZE_CONV) THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[CONVEX_HULL_EMPTY; SEGMENT_CONVEX_HULL] THEN
  DISCH_THEN SUBST1_TAC THEN MESON_TAC[SET_RULE `{a} = {a,a}`]);;

let KREIN_MILMAN_RELATIVE_BOUNDARY = prove
 (`!s:real^N->bool.
        convex s /\ compact s /\ ~(?a. s = {a})
        ==> s = convex hull (s DIFF relative_interior s)`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [MATCH_MP_TAC SUBSET_TRANS THEN
    EXISTS_TAC `convex hull {x:real^N | x extreme_point_of s}` THEN
    CONJ_TAC THENL
     [ASM_SIMP_TAC[GSYM KREIN_MILMAN_MINKOWSKI; SUBSET_REFL];
      MATCH_MP_TAC HULL_MONO THEN SIMP_TAC[SUBSET; IN_ELIM_THM; IN_DIFF] THEN
      ASM_MESON_TAC[EXTREME_POINT_NOT_IN_RELATIVE_INTERIOR; extreme_point_of]];
    MATCH_MP_TAC SUBSET_TRANS THEN
    EXISTS_TAC `convex hull s:real^N->bool` THEN CONJ_TAC THENL
     [MATCH_MP_TAC HULL_MONO THEN SET_TAC[];
      ASM_SIMP_TAC[HULL_P; SUBSET_REFL]]]);;

let KREIN_MILMAN_RELATIVE_FRONTIER = prove
 (`!s:real^N->bool.
        convex s /\ compact s /\ ~(?a. s = {a})
        ==> s = convex hull (relative_frontier s)`,
  SIMP_TAC[relative_frontier; CLOSURE_CLOSED; COMPACT_IMP_CLOSED] THEN
  REWRITE_TAC[KREIN_MILMAN_RELATIVE_BOUNDARY]);;

let KREIN_MILMAN_FRONTIER = prove
 (`!s:real^N->bool.
        convex s /\ compact s
        ==> s = convex hull (frontier s)`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[frontier; COMPACT_IMP_CLOSED; CLOSURE_CLOSED] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [MATCH_MP_TAC SUBSET_TRANS THEN
    EXISTS_TAC `convex hull {x:real^N | x extreme_point_of s}` THEN
    CONJ_TAC THENL
     [ASM_SIMP_TAC[GSYM KREIN_MILMAN_MINKOWSKI; SUBSET_REFL];
      MATCH_MP_TAC HULL_MONO THEN SIMP_TAC[SUBSET; IN_ELIM_THM; IN_DIFF] THEN
      ASM_MESON_TAC[EXTREME_POINT_NOT_IN_INTERIOR; extreme_point_of]];
    MATCH_MP_TAC SUBSET_TRANS THEN
    EXISTS_TAC `convex hull s:real^N->bool` THEN CONJ_TAC THENL
     [MATCH_MP_TAC HULL_MONO THEN SET_TAC[];
      ASM_SIMP_TAC[HULL_P; SUBSET_REFL]]]);;

let EXTREME_POINT_OF_CONVEX_HULL_INSERT_EQ = prove
 (`!s a x:real^N.
        FINITE s /\ ~(a IN affine hull s)
        ==> (x extreme_point_of (convex hull (a INSERT s)) <=>
             x = a \/ x extreme_point_of (convex hull s))`,
  REPEAT GEN_TAC THEN ONCE_REWRITE_TAC[GSYM AFFINE_HULL_CONVEX_HULL] THEN
  STRIP_TAC THEN ONCE_REWRITE_TAC[SET_RULE `a INSERT s = {a} UNION s`] THEN
  ONCE_REWRITE_TAC[HULL_UNION_RIGHT] THEN
  MP_TAC(ISPEC `convex hull s:real^N->bool` KREIN_MILMAN_MINKOWSKI) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[CONVEX_CONVEX_HULL; COMPACT_CONVEX_HULL; FINITE_IMP_COMPACT];
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ] FINITE_SUBSET)) THEN
  DISCH_THEN(MP_TAC o SPEC
   `{x:real^N | x extreme_point_of convex hull s}`) THEN
  REWRITE_TAC[EXTREME_POINTS_OF_CONVEX_HULL] THEN
  ABBREV_TAC `v = {x:real^N | x extreme_point_of (convex hull s)}` THEN
  DISCH_TAC THEN DISCH_THEN SUBST_ALL_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE (RAND_CONV o RAND_CONV)
   [AFFINE_HULL_CONVEX_HULL]) THEN
  ASM_CASES_TAC `(a:real^N) IN v` THEN ASM_SIMP_TAC[HULL_INC] THEN
  STRIP_TAC THEN REWRITE_TAC[GSYM HULL_UNION_RIGHT] THEN
  REWRITE_TAC[SET_RULE `{a} UNION s = a INSERT s`] THEN EQ_TAC THENL
   [DISCH_THEN(MP_TAC o MATCH_MP EXTREME_POINT_OF_CONVEX_HULL) THEN
    ASM SET_TAC[];
    STRIP_TAC THENL
     [ASM_REWRITE_TAC[] THEN
      MATCH_MP_TAC EXTREME_POINT_OF_CONVEX_HULL_INSERT THEN
      ASM_MESON_TAC[CONVEX_HULL_SUBSET_AFFINE_HULL; SUBSET];
      REWRITE_TAC[GSYM FACE_OF_SING] THEN
      MATCH_MP_TAC FACE_OF_TRANS THEN
      EXISTS_TAC `convex hull v:real^N->bool` THEN
      ASM_REWRITE_TAC[FACE_OF_SING] THEN
      MATCH_MP_TAC FACE_OF_CONVEX_HULLS THEN
      ASM_SIMP_TAC[FINITE_INSERT; AFFINE_HULL_SING; CONVEX_HULL_SING;
               SET_RULE `~(a IN s) ==> a INSERT s DIFF s = {a}`] THEN
      ASM SET_TAC[]]]);;

let FACE_OF_CONVEX_HULL_INSERT_EQ = prove
 (`!f s a:real^N.
        FINITE s /\ ~(a IN affine hull s)
        ==> (f face_of (convex hull (a INSERT s)) <=>
             f face_of (convex hull s) \/
             ?f'. f' face_of (convex hull s) /\
                  f = convex hull (a INSERT f'))`,
  let lemma = prove
   (`!a b c p:real^N u v w x.
          x % p = u % a + v % b + w % c
          ==> !s. u + v + w = x /\ ~(x = &0) /\ affine s /\
                  a IN s /\ b IN s /\ c IN s
                  ==> p IN s`,
    REPEAT STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o AP_TERM `(%) (inv x):real^N->real^N`) THEN
    ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_LINV; VECTOR_MUL_LID] THEN
    DISCH_THEN SUBST1_TAC THEN
    REWRITE_TAC[VECTOR_ADD_LDISTRIB; VECTOR_MUL_ASSOC] THEN
    MATCH_MP_TAC(SET_RULE `!t. x IN t /\ t SUBSET s ==> x IN s`) THEN
    EXISTS_TAC `affine hull {a:real^N,b,c}` THEN
    ASM_SIMP_TAC[HULL_MINIMAL; INSERT_SUBSET; EMPTY_SUBSET] THEN
    REWRITE_TAC[AFFINE_HULL_3; IN_ELIM_THM] THEN MAP_EVERY EXISTS_TAC
     [`inv x * u:real`; `inv x * v:real`; `inv x * w:real`] THEN
    REWRITE_TAC[] THEN UNDISCH_TAC `u + v + w:real = x` THEN
    UNDISCH_TAC `~(x = &0)` THEN CONV_TAC REAL_FIELD) in
  REPEAT STRIP_TAC THEN EQ_TAC THENL
   [DISCH_TAC THEN FIRST_ASSUM(MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ_ALT]
      FACE_OF_CONVEX_HULL_SUBSET)) THEN
    ASM_SIMP_TAC[COMPACT_INSERT; FINITE_IMP_COMPACT] THEN
    DISCH_THEN(X_CHOOSE_THEN `t:real^N->bool` STRIP_ASSUME_TAC) THEN
    FIRST_X_ASSUM SUBST_ALL_TAC THEN ASM_CASES_TAC `(a:real^N) IN t` THENL
     [ALL_TAC;
      DISJ1_TAC THEN MATCH_MP_TAC FACE_OF_SUBSET THEN
      EXISTS_TAC `convex hull ((a:real^N) INSERT s)` THEN
      ASM_REWRITE_TAC[] THEN CONJ_TAC THEN MATCH_MP_TAC HULL_MONO THEN
      ASM SET_TAC[]] THEN
    DISJ2_TAC THEN
    EXISTS_TAC `(convex hull t) INTER (convex hull s):real^N->bool` THEN
    CONJ_TAC THENL
     [MATCH_MP_TAC FACE_OF_SUBSET THEN
      EXISTS_TAC `convex hull ((a:real^N) INSERT s)` THEN
      SIMP_TAC[INTER_SUBSET; HULL_MONO; SET_RULE `s SUBSET (a INSERT s)`] THEN
      MATCH_MP_TAC FACE_OF_INTER THEN ASM_REWRITE_TAC[] THEN
      MATCH_MP_TAC FACE_OF_CONVEX_HULL_INSERT THEN
      ASM_REWRITE_TAC[FACE_OF_REFL_EQ; CONVEX_CONVEX_HULL];
      MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THEN
      MATCH_MP_TAC HULL_MINIMAL THEN REWRITE_TAC[CONVEX_CONVEX_HULL] THEN
      ASM_SIMP_TAC[INSERT_SUBSET; HULL_INC; INTER_SUBSET] THEN
      REWRITE_TAC[SUBSET] THEN REPEAT STRIP_TAC THEN MATCH_MP_TAC HULL_INC THEN
      ASM_CASES_TAC `x:real^N = a` THEN ASM_REWRITE_TAC[IN_INSERT] THEN
      REWRITE_TAC[IN_INTER] THEN CONJ_TAC THEN MATCH_MP_TAC HULL_INC THEN
      ASM SET_TAC[]];
    ALL_TAC] THEN
  DISCH_THEN(DISJ_CASES_THEN ASSUME_TAC) THENL
   [MATCH_MP_TAC FACE_OF_CONVEX_HULL_INSERT THEN ASM_REWRITE_TAC[];
    FIRST_X_ASSUM(X_CHOOSE_THEN `f':real^N->bool` MP_TAC)] THEN
  DISCH_THEN(CONJUNCTS_THEN2 MP_TAC SUBST1_TAC) THEN
  SPEC_TAC(`f':real^N->bool`,`f:real^N->bool`) THEN REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [UNDISCH_TAC `(f:real^N->bool) face_of convex hull s` THEN
    ASM_SIMP_TAC[FACE_OF_EMPTY; CONVEX_HULL_EMPTY; FACE_OF_REFL_EQ] THEN
    REWRITE_TAC[CONVEX_CONVEX_HULL];
    ALL_TAC] THEN
  ASM_CASES_TAC `f:real^N->bool = {}` THENL
   [ASM_REWRITE_TAC[CONVEX_HULL_SING; FACE_OF_SING] THEN
    MATCH_MP_TAC EXTREME_POINT_OF_CONVEX_HULL_INSERT THEN
    ASM_REWRITE_TAC[] THEN
    ASM_MESON_TAC[CONVEX_HULL_SUBSET_AFFINE_HULL; SUBSET];
    ALL_TAC] THEN
  REWRITE_TAC[face_of; CONVEX_CONVEX_HULL] THEN CONJ_TAC THENL
   [MATCH_MP_TAC HULL_MINIMAL THEN
    SIMP_TAC[INSERT_SUBSET; HULL_INC; IN_INSERT; CONVEX_CONVEX_HULL] THEN
    MATCH_MP_TAC SUBSET_TRANS THEN
    EXISTS_TAC `convex hull s:real^N->bool` THEN
    ASM_SIMP_TAC[HULL_MONO; SET_RULE `s SUBSET (a INSERT s)`] THEN
    ASM_MESON_TAC[FACE_OF_IMP_SUBSET];
    ALL_TAC] THEN
  ASM_REWRITE_TAC[CONVEX_HULL_INSERT_ALT] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
  REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC] THEN
  X_GEN_TAC `ub:real` THEN STRIP_TAC THEN
  X_GEN_TAC `b:real^N` THEN STRIP_TAC THEN
  X_GEN_TAC `uc:real` THEN STRIP_TAC THEN
  X_GEN_TAC `c:real^N` THEN STRIP_TAC THEN
  X_GEN_TAC `ux:real` THEN STRIP_TAC THEN
  X_GEN_TAC `x:real^N` THEN STRIP_TAC THEN
  FIRST_X_ASSUM(STRIP_ASSUME_TAC o GEN_REWRITE_RULE I [face_of]) THEN
  SUBGOAL_THEN `convex hull f:real^N->bool = f` SUBST_ALL_TAC THENL
   [ASM_MESON_TAC[CONVEX_HULL_EQ]; ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_SEGMENT]) THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (X_CHOOSE_THEN `v:real` MP_TAC)) THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  REWRITE_TAC[VECTOR_ARITH
   `(&1 - ux) % a + ux % x:real^N =
    (&1 - v) % ((&1 - ub) % a + ub % b) + v % ((&1 - uc) % a + uc % c) <=>
    ((&1 - ux) - ((&1 - v) * (&1 - ub) + v * (&1 - uc))) % a +
    (ux % x - (((&1 - v) * ub) % b + (v * uc) % c)) = vec 0`] THEN
  ASM_CASES_TAC `&1 - ux - ((&1 - v) * (&1 - ub) + v * (&1 - uc)) = &0` THENL
   [ASM_REWRITE_TAC[VECTOR_MUL_LZERO; VECTOR_ADD_LID] THEN
    FIRST_ASSUM(ASSUME_TAC o MATCH_MP (REAL_RING
     `(&1 - ux) - ((&1 - v) * (&1 - ub) + v * (&1 - uc)) = &0
      ==> (&1 - v) * ub + v * uc = ux`)) THEN
    ASM_CASES_TAC `uc = &0` THENL
     [UNDISCH_THEN `uc = &0` SUBST_ALL_TAC THEN
      FIRST_X_ASSUM(SUBST_ALL_TAC o MATCH_MP (REAL_ARITH
       `a + v * &0 = b ==> b = a`)) THEN
      REWRITE_TAC[REAL_MUL_RZERO; VECTOR_MUL_LZERO; VECTOR_ADD_RID] THEN
      REWRITE_TAC[VECTOR_SUB_EQ; VECTOR_MUL_LCANCEL; REAL_ENTIRE] THEN
      STRIP_TAC THENL
       [ASM_REAL_ARITH_TAC;
        ASM_MESON_TAC[VECTOR_MUL_LZERO];
        ASM_REWRITE_TAC[] THEN CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
        REWRITE_TAC[IN_ELIM_THM] THEN
        MAP_EVERY EXISTS_TAC [`&0`; `x:real^N`] THEN
        ASM_REWRITE_TAC[] THEN CONV_TAC VECTOR_ARITH];
      ALL_TAC] THEN
    ASM_CASES_TAC `ub = &0` THENL
     [UNDISCH_THEN `ub = &0` SUBST_ALL_TAC THEN
      FIRST_X_ASSUM(SUBST_ALL_TAC o MATCH_MP (REAL_ARITH
       `v * &0 + a = b ==> b = a`)) THEN
      REWRITE_TAC[REAL_MUL_RZERO; VECTOR_MUL_LZERO; VECTOR_ADD_LID] THEN
      REWRITE_TAC[VECTOR_SUB_EQ; VECTOR_MUL_LCANCEL; REAL_ENTIRE] THEN
      STRIP_TAC THENL
       [ASM_REAL_ARITH_TAC;
        ASM_MESON_TAC[VECTOR_MUL_LZERO];
        ASM_REWRITE_TAC[] THEN CONJ_TAC THENL [ALL_TAC; ASM SET_TAC[]] THEN
        REWRITE_TAC[IN_ELIM_THM] THEN
        MAP_EVERY EXISTS_TAC [`&0`; `x:real^N`] THEN
        ASM_REWRITE_TAC[] THEN CONV_TAC VECTOR_ARITH];
      ALL_TAC] THEN
    DISCH_THEN(fun th ->
      SUBGOAL_THEN
       `(b:real^N) IN f /\ (c:real^N) IN f`
      MP_TAC THENL [ALL_TAC; ASM SET_TAC[]] THEN MP_TAC th) THEN
    ASM_CASES_TAC `ux = &0` THENL
     [DISCH_THEN(K ALL_TAC) THEN FIRST_X_ASSUM MATCH_MP_TAC THEN
      EXISTS_TAC `x:real^N` THEN ASM_REWRITE_TAC[] THEN
      FIRST_X_ASSUM(MP_TAC o MATCH_MP (REAL_ARITH
       `&1 - ux - a = &0 ==> ux = &0 ==> ~(a < &1)`)) THEN
      ASM_REWRITE_TAC[] THEN MATCH_MP_TAC(TAUT `p ==> ~p ==> q`) THEN
      MATCH_MP_TAC REAL_LTE_TRANS THEN
      EXISTS_TAC `(&1 - v) * &1 + v * &1` THEN
      CONJ_TAC THENL [ALL_TAC; REAL_ARITH_TAC] THEN
      MATCH_MP_TAC(REAL_ARITH
       `x <= y /\ w <= z /\ ~(x = y /\ w = z) ==> x + w < y + z`) THEN
      ASM_SIMP_TAC[REAL_LE_LMUL_EQ; REAL_SUB_LT; REAL_EQ_MUL_LCANCEL] THEN
      REPEAT(CONJ_TAC THENL [ASM_REAL_ARITH_TAC; ALL_TAC]) THEN
      ASM_SIMP_TAC[REAL_SUB_0; REAL_LT_IMP_NE] THEN
      REWRITE_TAC[REAL_ARITH `&1 - x = &1 <=> x = &0`] THEN
      DISCH_THEN(CONJUNCTS_THEN SUBST_ALL_TAC) THEN
      ASM_MESON_TAC[VECTOR_MUL_LZERO];
      ALL_TAC] THEN
    REWRITE_TAC[VECTOR_SUB_EQ] THEN ASM_CASES_TAC `c:real^N = b` THENL
     [ASM_REWRITE_TAC[GSYM VECTOR_ADD_RDISTRIB; VECTOR_MUL_LCANCEL] THEN
      ASM_MESON_TAC[];
      ALL_TAC] THEN
    DISCH_TAC THEN FIRST_X_ASSUM MATCH_MP_TAC THEN
    EXISTS_TAC `x:real^N` THEN ASM_REWRITE_TAC[IN_SEGMENT] THEN
    EXISTS_TAC `(v * uc) / ux:real` THEN
    ASM_SIMP_TAC[REAL_LT_RDIV_EQ; REAL_LT_LDIV_EQ; REAL_ARITH
     `&0 <= x /\ ~(x = &0) ==> &0 < x`] THEN
    REWRITE_TAC[REAL_MUL_LZERO; REAL_MUL_LID] THEN REPEAT CONJ_TAC THENL
     [MATCH_MP_TAC REAL_LT_MUL THEN ASM_REAL_ARITH_TAC;
      EXPAND_TAC "ux" THEN REWRITE_TAC[REAL_ARITH `b < a + b <=> &0 < a`] THEN
      MATCH_MP_TAC REAL_LT_MUL THEN ASM_REAL_ARITH_TAC;
      FIRST_X_ASSUM(MP_TAC o AP_TERM `(%) (inv ux) :real^N->real^N`) THEN
      ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_LINV] THEN
      REWRITE_TAC[VECTOR_MUL_LID] THEN DISCH_THEN SUBST1_TAC THEN
      REWRITE_TAC[VECTOR_ADD_LDISTRIB; VECTOR_MUL_ASSOC] THEN
      BINOP_TAC THEN AP_THM_TAC THEN AP_TERM_TAC THEN
      REWRITE_TAC[REAL_ARITH `inv u * v * uc:real = (v * uc) / u`] THEN
      UNDISCH_TAC `(&1 - v) * ub + v * uc = ux` THEN
      UNDISCH_TAC `~(ux = &0)` THEN CONV_TAC REAL_FIELD];
    DISCH_THEN(MP_TAC o MATCH_MP (VECTOR_ARITH
     `a + (b - c):real^N = vec 0 ==> a = c + --b`)) THEN
    REWRITE_TAC[GSYM VECTOR_ADD_ASSOC; GSYM VECTOR_MUL_LNEG] THEN
    DISCH_THEN(MP_TAC o SPEC `affine hull s:real^N->bool` o
      MATCH_MP lemma) THEN
    ASM_REWRITE_TAC[AFFINE_AFFINE_HULL] THEN
    MATCH_MP_TAC(TAUT `p ==> ~p ==> q`) THEN
    CONJ_TAC THENL [CONV_TAC REAL_RING; REPEAT CONJ_TAC] THEN
    MATCH_MP_TAC(REWRITE_RULE[SUBSET] CONVEX_HULL_SUBSET_AFFINE_HULL) THEN
    ASM_REWRITE_TAC[] THEN ASM SET_TAC[]]);;

let HAUSDIST_FRONTIERS_CONVEX = prove
 (`!s t:real^N->bool.
        convex s /\ convex t /\ bounded s /\ bounded t
        ==> hausdist(frontier s,frontier t) = hausdist(s,t)`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[HAUSDIST_EMPTY; REAL_LE_REFL] THEN
  ASM_CASES_TAC `t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[HAUSDIST_EMPTY; FRONTIER_EMPTY; REAL_LE_REFL] THEN
  ONCE_REWRITE_TAC[GSYM(CONJUNCT2 HAUSDIST_CLOSURE)] THEN
  ONCE_REWRITE_TAC[GSYM(CONJUNCT1 HAUSDIST_CLOSURE)] THEN
  SUBGOAL_THEN
   `closure(frontier s):real^N->bool = frontier(closure s) /\
    closure(frontier t):real^N->bool = frontier(closure t)`
  (CONJUNCTS_THEN SUBST1_TAC) THENL
   [ASM_SIMP_TAC[FRONTIER_CLOSURE_CONVEX] THEN
    SIMP_TAC[CLOSURE_CLOSED; FRONTIER_CLOSED];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `compact(closure s:real^N->bool) /\
    compact(closure t:real^N->bool) /\
    convex(closure s:real^N->bool) /\
    convex(closure t:real^N->bool) /\
    ~(closure s = {}) /\ ~(closure t = {})`
  MP_TAC THENL
   [ASM_SIMP_TAC[COMPACT_CLOSURE; CONVEX_CLOSURE; CLOSURE_EQ_EMPTY];
    POP_ASSUM_LIST(K ALL_TAC) THEN
    SPEC_TAC(`closure t:real^N->bool`,`t:real^N->bool`) THEN
    SPEC_TAC(`closure s:real^N->bool`,`s:real^N->bool`) THEN
    REWRITE_TAC[COMPACT_EQ_BOUNDED_CLOSED] THEN
    MAP_EVERY X_GEN_TAC [`s:real^N->bool`; `t:real^N->bool`] THEN
    REPEAT STRIP_TAC] THEN
  REWRITE_TAC[GSYM REAL_LE_ANTISYM] THEN CONJ_TAC THENL
   [ALL_TAC;
    MP_TAC(ISPECL [`frontier s:real^N->bool`; `frontier t:real^N->bool`]
        HAUSDIST_CONVEX_HULLS) THEN
    ASM_SIMP_TAC[GSYM KREIN_MILMAN_FRONTIER; COMPACT_EQ_BOUNDED_CLOSED;
                 BOUNDED_FRONTIER]] THEN
  MATCH_MP_TAC REAL_HAUSDIST_LE THEN
  ASM_REWRITE_TAC[FRONTIER_EQ_EMPTY] THEN
  REPLICATE_TAC 2
   (CONJ_TAC THENL [ASM_MESON_TAC[NOT_BOUNDED_UNIV]; ALL_TAC]) THEN
  REPEAT STRIP_TAC THEN MATCH_MP_TAC REAL_LE_HAUSDIST THEN
  ASM_REWRITE_TAC[LEFT_EXISTS_AND_THM; RIGHT_EXISTS_AND_THM] THEN
  MP_TAC(ISPECL
   [`s:real^N->bool`; `t:real^N->bool`; `hausdist(s:real^N->bool,t)`]
        REAL_HAUSDIST_LE_EQ) THEN
  ASM_REWRITE_TAC[REAL_LE_REFL] THEN STRIP_TAC THEN
  REPEAT(CONJ_TAC THENL [ASM_MESON_TAC[]; ALL_TAC]) THENL
   [ALL_TAC;
    ONCE_REWRITE_TAC[DISJ_SYM] THEN
    REPEAT(POP_ASSUM MP_TAC) THEN
    ONCE_REWRITE_TAC[HAUSDIST_SYM] THEN
    SPEC_TAC(`y:real^N`,`x:real^N`) THEN
    SPEC_TAC(`t:real^N->bool`,`t:real^N->bool`) THEN
    SPEC_TAC(`s:real^N->bool`,`s:real^N->bool`) THEN
    MAP_EVERY X_GEN_TAC [`t:real^N->bool`; `s:real^N->bool`] THEN
    REPEAT STRIP_TAC] THEN
  (ASM_CASES_TAC `(x:real^N) IN frontier t` THENL
     [EXISTS_TAC `x:real^N` THEN
      ASM_SIMP_TAC[SETDIST_SING_IN_SET; SETDIST_POS_LE] THEN
      UNDISCH_TAC `(x:real^N) IN frontier s` THEN
      ASM_REWRITE_TAC[frontier; IN_DIFF] THEN
      ASM_SIMP_TAC[CLOSURE_CLOSED];
      ALL_TAC] THEN
    ASM_CASES_TAC `(x:real^N) IN t` THENL
     [ALL_TAC;
      EXISTS_TAC `x:real^N` THEN
      ASM_SIMP_TAC[SETDIST_SING_FRONTIER; REAL_LE_REFL] THEN
      UNDISCH_TAC `(x:real^N) IN frontier s` THEN
      ASM_REWRITE_TAC[frontier; IN_DIFF] THEN
      ASM_SIMP_TAC[CLOSURE_CLOSED]] THEN
    MP_TAC(ISPECL [`s:real^N->bool`; `x:real^N`]
        SUPPORTING_HYPERPLANE_FRONTIER) THEN
    ASM_REWRITE_TAC[] THEN
    DISCH_THEN(X_CHOOSE_THEN `a:real^N` STRIP_ASSUME_TAC) THEN
    MP_TAC(ISPECL [`t:real^N->bool`; `x:real^N`; `--a:real^N`]
        RAY_TO_FRONTIER) THEN
    ASM_REWRITE_TAC[VECTOR_NEG_EQ_0] THEN ANTS_TAC THENL
     [UNDISCH_TAC `~((x:real^N) IN frontier t)` THEN
      ASM_REWRITE_TAC[frontier; IN_DIFF] THEN
      ASM_SIMP_TAC[CLOSURE_CLOSED; COMPACT_IMP_CLOSED];
      DISCH_THEN(X_CHOOSE_THEN `d:real` STRIP_ASSUME_TAC)] THEN
    EXISTS_TAC `x + d % --a:real^N` THEN DISJ2_TAC THEN CONJ_TAC THENL
     [UNDISCH_TAC `(x + d % --a:real^N) IN frontier t` THEN
      ASM_SIMP_TAC[frontier; IN_DIFF; CLOSURE_CLOSED; COMPACT_IMP_CLOSED];
      ALL_TAC] THEN
    TRANS_TAC REAL_LE_TRANS `dist(x:real^N,x + d % --a)` THEN CONJ_TAC THENL
     [MATCH_MP_TAC SETDIST_LE_DIST THEN ASM_REWRITE_TAC[IN_SING];
      ALL_TAC] THEN
    TRANS_TAC REAL_LE_TRANS
     `setdist({x + d % --a:real^N},{y | a dot x <= a dot y})` THEN
    CONJ_TAC THENL
     [ALL_TAC;
      MATCH_MP_TAC SETDIST_SUBSET_RIGHT THEN
      MP_TAC(ISPEC `s:real^N->bool` CLOSURE_SUBSET) THEN ASM SET_TAC[]] THEN
    MATCH_MP_TAC REAL_LE_SETDIST THEN
    REWRITE_TAC[NOT_INSERT_EMPTY] THEN CONJ_TAC THENL
     [MP_TAC(ISPEC `s:real^N->bool` CLOSURE_SUBSET) THEN ASM SET_TAC[];
      ALL_TAC] THEN
    REWRITE_TAC[IMP_CONJ; IN_SING; RIGHT_FORALL_IMP_THM; FORALL_UNWIND_THM2;
                IN_ELIM_THM] THEN
    X_GEN_TAC `y:real^N` THEN DISCH_TAC THEN
    REWRITE_TAC[NORM_ARITH `dist(x:real^N,x + a) = norm a`] THEN

    MP_TAC(ISPECL [`a:real^N`; `y - (x + d % --a):real^N`]
        NORM_CAUCHY_SCHWARZ) THEN
    REWRITE_TAC[DOT_RSUB; DOT_RADD; DOT_RNEG;
                ONCE_REWRITE_RULE[DIST_SYM] dist; DOT_RMUL] THEN
    DISCH_THEN(MP_TAC o MATCH_MP (REAL_ARITH
     `ay - (ax + d * --a) <= b ==> ax <= ay ==> d * a <= b`)) THEN
    ASM_REWRITE_TAC[GSYM NORM_POW_2; NORM_MUL; NORM_NEG] THEN
    REWRITE_TAC[REAL_ARITH `(d * a pow 2):real = a * d * a`] THEN
    ASM_SIMP_TAC[REAL_LE_LMUL_EQ; NORM_POS_LT] THEN
    ASM_SIMP_TAC[real_abs; REAL_LT_IMP_LE]));;

(* ------------------------------------------------------------------------- *)
(* If we perturb a set little enough, a point stays inside or outside it.    *)
(* The "inside" needs convexity in general or we could just remove a         *)
(* thin path to the point without changing the Hausdorff distance at all.    *)
(* ------------------------------------------------------------------------- *)

let HAUSDIST_STILL_OUTSIDE = prove
 (`!s t x:real^N.

        bounded s /\ bounded t /\ hausdist(s,t) < setdist({x},s)
        ==> ~(x IN t)`,
  REPEAT GEN_TAC THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[HAUSDIST_EMPTY; SETDIST_EMPTY; REAL_LT_REFL] THEN
  ASM_CASES_TAC `t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[NOT_IN_EMPTY] THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
  REWRITE_TAC[REAL_NOT_LT] THEN STRIP_TAC THEN
  MATCH_MP_TAC REAL_LE_HAUSDIST THEN
  ASM_REWRITE_TAC[RIGHT_EXISTS_AND_THM; LEFT_EXISTS_AND_THM] THEN
  ASM_MESON_TAC[REAL_HAUSDIST_LE_EQ; REAL_LE_REFL]);;

let HAUSDIST_STILL_INSIDE = prove
 (`!s t x:real^N.
        bounded s /\ bounded t /\ convex s /\ convex t /\ ~(t = {}) /\
        hausdist(s,t) < setdist({x},(:real^N) DIFF s)
        ==> x IN t`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC(TAUT `(~p ==> F) ==> p`) THEN
  DISCH_TAC THEN
  MP_TAC(ISPECL [`t:real^N->bool`; `s:real^N->bool`;
                 `setdist({x},(:real^N) DIFF s)`; `x:real^N`]
        HAUSDIST_COMPLEMENTS_CONVEX_EXPLICIT) THEN
  ASM_REWRITE_TAC[NOT_IMP; NOT_EXISTS_THM; DE_MORGAN_THM; REAL_NOT_LT] THEN
  CONJ_TAC THENL [ASM_MESON_TAC[HAUSDIST_SYM]; ALL_TAC] THEN
  X_GEN_TAC `y:real^N` THEN ASM_CASES_TAC `(y:real^N) IN s` THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC SETDIST_LE_DIST THEN
  ASM SET_TAC[]);;

let HAUSDIST_STILL_INSIDE_INTERIOR = prove
 (`!s t x:real^N.
        bounded s /\ bounded t /\ convex s /\ convex t /\ ~(t = {}) /\
        hausdist(s,t) < setdist({x},(:real^N) DIFF s)
        ==> x IN interior t`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[IN_INTERIOR] THEN
  EXISTS_TAC
     `setdist({x},(:real^N) DIFF s) - hausdist(s:real^N->bool,t)` THEN
  ASM_REWRITE_TAC[REAL_SUB_LT] THEN
  REWRITE_TAC[SUBSET; IN_BALL] THEN X_GEN_TAC `y:real^N` THEN DISCH_TAC THEN
  MATCH_MP_TAC HAUSDIST_STILL_INSIDE THEN
  EXISTS_TAC `s:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REAL_ARITH
    `d < f - h ==> f <= d + g ==> h < g`)) THEN
  REWRITE_TAC[GSYM SETDIST_SINGS; SETDIST_TRIANGLE]);;

let HAUSDIST_STILL_NONEMPTY_INTERIOR = prove
 (`!s:real^N->bool.
      bounded s /\ convex s /\ ~(interior s = {})
      ==> ?e. &0 < e /\
              !s'. bounded s' /\ convex s' /\ ~(s' = {}) /\ hausdist(s,s') < e
                   ==> ~(interior s' = {})`,
  REPEAT GEN_TAC THEN STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  REWRITE_TAC[IN_INTERIOR] THEN
  DISCH_THEN(X_CHOOSE_THEN `a:real^N` MP_TAC) THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `r:real` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN X_GEN_TAC `t:real^N->bool` THEN
  STRIP_TAC THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] THEN
  EXISTS_TAC `a:real^N` THEN MATCH_MP_TAC HAUSDIST_STILL_INSIDE_INTERIOR THEN
  EXISTS_TAC `s:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
  FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ]
   REAL_LTE_TRANS)) THEN
  ASM_REWRITE_TAC[REAL_LE_SETDIST_EQ; IN_SING; NOT_INSERT_EMPTY] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_UNWIND_THM2] THEN
  ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
  ASM_REWRITE_TAC[IN_DIFF; IN_UNIV; REAL_NOT_LE] THEN
  ASM_REWRITE_TAC[GSYM IN_BALL; GSYM SUBSET] THEN
  REWRITE_TAC[SET_RULE `UNIV DIFF s = {} <=> s = UNIV`] THEN
  ASM_MESON_TAC[NOT_BOUNDED_UNIV]);;

let HAUSDIST_STILL_SAME_PLACE_STRONG = prove
 (`!s t x:real^N.
        bounded s /\ bounded t /\ convex s /\ convex t /\
        ~(t = {}) /\ hausdist(s,t) < setdist({x},frontier s)
        ==> ~(x IN frontier s) /\ ~(x IN frontier t) /\ (x IN t <=> x IN s)`,
  REPEAT GEN_TAC THEN STRIP_TAC THEN
  SUBGOAL_THEN `~((x:real^N) IN frontier s)` ASSUME_TAC THENL
   [ASM_MESON_TAC[SETDIST_SING_IN_SET; REAL_NOT_LT; HAUSDIST_POS_LE];
    ASM_REWRITE_TAC[]] THEN
  FIRST_X_ASSUM(MP_TAC o
    GEN_REWRITE_RULE (RAND_CONV o RAND_CONV) [frontier]) THEN
  REWRITE_TAC[IN_DIFF; DE_MORGAN_THM] THEN STRIP_TAC THENL
   [MP_TAC(ISPECL
     [`closure s:real^N->bool`; `closure t:real^N->bool`; `x:real^N`]
        HAUSDIST_STILL_OUTSIDE) THEN
    ASM_SIMP_TAC[HAUSDIST_CLOSURE; BOUNDED_CLOSURE; SETDIST_CLOSURE] THEN
    ANTS_TAC THENL
     [FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REAL_ARITH
       `x < a ==> a = b ==> x < b`)) THEN
      MATCH_MP_TAC(CONJUNCT2 SETDIST_FRONTIER);
      REWRITE_TAC[frontier] THEN
      MP_TAC(ISPEC `t:real^N->bool` CLOSURE_SUBSET)] THEN
    MP_TAC(ISPEC `s:real^N->bool` CLOSURE_SUBSET) THEN ASM SET_TAC[];
    SUBGOAL_THEN `(x:real^N) IN interior t` MP_TAC THENL
     [ALL_TAC;
      ASM_SIMP_TAC[frontier; IN_DIFF;
                   REWRITE_RULE[SUBSET] INTERIOR_SUBSET]] THEN
    REWRITE_TAC[IN_INTERIOR] THEN EXISTS_TAC
     `setdist({x:real^N},frontier s) - hausdist(s:real^N->bool,t)` THEN
    ASM_REWRITE_TAC[REAL_SUB_LT] THEN
    REWRITE_TAC[SUBSET; IN_BALL] THEN X_GEN_TAC `y:real^N` THEN DISCH_TAC THEN
    MATCH_MP_TAC HAUSDIST_STILL_INSIDE THEN
    EXISTS_TAC `interior s:real^N->bool` THEN
    ASM_SIMP_TAC[BOUNDED_INTERIOR; CONVEX_INTERIOR] THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REAL_ARITH
      `d < f - h ==> h' = h /\ f <= d + g ==> h' < g`)) THEN
    CONJ_TAC THENL
     [ONCE_REWRITE_TAC[GSYM(CONJUNCT1 HAUSDIST_CLOSURE)] THEN
      AP_TERM_TAC THEN REWRITE_TAC[PAIR_EQ] THEN
      MATCH_MP_TAC CONVEX_CLOSURE_INTERIOR THEN ASM SET_TAC[];
      TRANS_TAC REAL_LE_TRANS `setdist({x},(:real^N) DIFF interior s)` THEN
      REWRITE_TAC[GSYM SETDIST_SINGS; SETDIST_TRIANGLE] THEN
      REWRITE_TAC[GSYM CLOSURE_COMPLEMENT; SETDIST_CLOSURE] THEN
      ONCE_REWRITE_TAC[GSYM FRONTIER_COMPLEMENT] THEN
      MATCH_MP_TAC REAL_EQ_IMP_LE THEN
      MATCH_MP_TAC(CONJUNCT2 SETDIST_FRONTIER) THEN
      FIRST_ASSUM(MP_TAC o MATCH_MP(REWRITE_RULE[SUBSET] INTERIOR_SUBSET)) THEN
      SET_TAC[]]]);;

let HAUSDIST_STILL_SAME_PLACE = prove
 (`!s t x:real^N.
        bounded s /\ bounded t /\ convex s /\ convex t /\
        ~(t = {}) /\ hausdist(s,t) < setdist({x},frontier s)
        ==> (x IN t <=> x IN s)`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(MP_TAC o MATCH_MP HAUSDIST_STILL_SAME_PLACE_STRONG) THEN
  MESON_TAC[]);;

let HAUSDIST_STILL_SAME_PLACE_CONIC_HULL_STRONG = prove
 (`!s x:real^N.
       convex s /\ bounded s /\ ~(s = {}) /\ ~(vec 0 IN closure s) /\
       ~(x = vec 0) /\ ~(x IN frontier(conic hull s))
       ==> ?e. &0 < e /\
               !s'. convex s' /\ bounded s' /\ ~(s' = {}) /\ hausdist(s,s') < e
                    ==> ~(x IN frontier(conic hull s')) /\
                        (x IN conic hull s' <=> x IN conic hull s)`,
  let lemma = prove
   (`!a x:real^N s.
          convex s /\ &0 < a /\ ~(x = vec 0) /\ ~(s = {}) /\
          a * norm(x) < setdist({vec 0},s)
          ==> (x IN conic hull s <=>
               a % x IN convex hull (vec 0 INSERT s))`,
    ONCE_REWRITE_TAC[IMP_CONJ] THEN
    REWRITE_TAC[MESON[HULL_HULL; CONVEX_CONVEX_HULL; HULL_P]
     `(!s. convex s ==> p s) <=> (!s. p (convex hull s))`] THEN
    REWRITE_TAC[GSYM HULL_INSERT; CONVEX_HULL_EQ_EMPTY] THEN
    REPEAT STRIP_TAC THEN ASM_SIMP_TAC[CONVEX_HULL_INSERT_ALT] THEN
    REWRITE_TAC[VECTOR_MUL_RZERO; VECTOR_ADD_LID] THEN
    REWRITE_TAC[CONIC_HULL_EXPLICIT; IN_ELIM_THM] THEN
    EQ_TAC THEN REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
    MAP_EVERY X_GEN_TAC [`u:real`; `y:real^N`] THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[] THENL
     [EXISTS_TAC `a * u:real`; EXISTS_TAC `inv(a) * u:real`] THEN
    EXISTS_TAC `y:real^N` THEN ASM_REWRITE_TAC[VECTOR_MUL_ASSOC] THENL
     [ASM_SIMP_TAC[REAL_LE_MUL; REAL_LT_IMP_LE] THEN
      MATCH_MP_TAC(REAL_ARITH `abs x <= a ==> x <= a`) THEN
      MATCH_MP_TAC REAL_LE_RCANCEL_IMP THEN EXISTS_TAC `norm(y:real^N)` THEN
      CONJ_TAC THENL[ASM_MESON_TAC[NORM_POS_LT; VECTOR_MUL_EQ_0]; ALL_TAC] THEN
      REWRITE_TAC[GSYM NORM_MUL; GSYM VECTOR_MUL_ASSOC] THEN
      FIRST_X_ASSUM(SUBST1_TAC o SYM) THEN
      ASM_SIMP_TAC[NORM_MUL; real_abs; REAL_LT_IMP_LE; REAL_MUL_LID] THEN
      MATCH_MP_TAC REAL_LT_IMP_LE THEN
      FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ]
         REAL_LTE_TRANS)) THEN
      ONCE_REWRITE_TAC[NORM_ARITH `norm(x:real^N) = dist(vec 0,x)`] THEN
      MATCH_MP_TAC SETDIST_LE_DIST THEN ASM_REWRITE_TAC[IN_SING];
      ASM_SIMP_TAC[REAL_LE_INV_EQ; REAL_LE_MUL; REAL_LT_IMP_LE] THEN
      FIRST_X_ASSUM(MP_TAC o AP_TERM `(%) (inv a):real^N->real^N`) THEN
      ASM_SIMP_TAC[REAL_MUL_LINV; VECTOR_MUL_ASSOC; REAL_MUL_LINV;
                   VECTOR_MUL_LID; REAL_LT_IMP_NZ]]) in
  let clemma = prove
   (`!a x:real^N s.
        convex s /\ bounded s /\ ~(vec 0 IN closure s) /\
        &0 < a /\ ~(x = vec 0) /\ ~(s = {}) /\
        a * norm(x) < setdist({vec 0},s)
        ==> (x IN closure(conic hull s) <=>
             a % x IN closure(convex hull (vec 0 INSERT s)))`,
    REPEAT STRIP_TAC THEN
    MP_TAC(ISPECL [`a:real`; `x:real^N`; `closure s:real^N->bool`] lemma) THEN
    ASM_SIMP_TAC[SETDIST_CLOSURE; CLOSURE_EQ_EMPTY; CONVEX_CLOSURE] THEN
    ASM_SIMP_TAC[CLOSURE_CONIC_HULL] THEN
    ASM_SIMP_TAC[GSYM CONVEX_HULL_CLOSURE; BOUNDED_INSERT; CLOSURE_INSERT]) in
  let ilemma = prove
   (`!a x:real^N s.
       convex s /\ &0 < a /\ ~(x = vec 0) /\ ~(s = {}) /\
       a * norm(x) < setdist({vec 0},s)
       ==> (x IN interior(conic hull s) <=>
            a % x IN interior(convex hull (vec 0 INSERT s)))`,
    REPEAT STRIP_TAC THEN REWRITE_TAC[IN_INTERIOR] THEN
    SUBGOAL_THEN
      `?d. &0 < d /\
        !y. y IN ball(x:real^N,d) ==> a * norm y < setdist({vec 0:real^N},s)`
    STRIP_ASSUME_TAC THENL
     [EXISTS_TAC `setdist({vec 0:real^N},s) / a - norm(x:real^N)` THEN
      ASM_SIMP_TAC[REAL_LT_RDIV_EQ; IN_BALL; REAL_LT_SUB_LADD] THEN
      CONJ_TAC THENL [ASM_REAL_ARITH_TAC; X_GEN_TAC `y:real^N`] THEN
      MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ] REAL_LET_TRANS) THEN
      GEN_REWRITE_TAC RAND_CONV [REAL_MUL_SYM] THEN
      ASM_SIMP_TAC[REAL_LE_LMUL_EQ] THEN CONV_TAC NORM_ARITH;
      MATCH_MP_TAC(MESON[]
       `(!e. &0 < e <=> &0 < a * e) /\ (!e. &0 < e <=> &0 < e / a) /\
        (!e. a * e / a = e) /\ (!d e. a * d <= a * e <=> d <= e) /\
        ((!d e. d <= e ==> P e ==> P d) /\ (!d e. d <= e ==> Q e ==> Q d)) /\
        (!e. &0 < e ==> ?d. &0 < d /\ d <= e /\ (P d <=> Q(a * d)))
        ==> ((?e. &0 < e /\ P e) <=> (?e. &0 < e /\ Q e))`) THEN
      ASM_SIMP_TAC[BALL_SCALING; REAL_LT_MUL_EQ; REAL_LE_LMUL_EQ;
        REAL_LT_IMP_NZ; REAL_LT_RDIV_EQ; REAL_MUL_LZERO; REAL_DIV_LMUL] THEN
      CONJ_TAC THENL [MESON_TAC[SUBSET_BALL; SUBSET_TRANS]; ALL_TAC] THEN
      X_GEN_TAC `e:real` THEN DISCH_TAC THEN
      REWRITE_TAC[SUBSET; FORALL_IN_IMAGE] THEN
      EXISTS_TAC `min d (min e (norm(x:real^N)))` THEN
      ASM_REWRITE_TAC[REAL_LT_MIN; REAL_MIN_LE; REAL_LE_REFL; NORM_POS_LT] THEN
      MATCH_MP_TAC (MESON[]
       `(!x. P x ==> (Q x <=> R x))
        ==> ((!x. P x ==> Q x) <=> (!x. P x ==> R x))`) THEN
      X_GEN_TAC `y:real^N` THEN REWRITE_TAC[BALL_MIN_INTER; IN_INTER] THEN
      STRIP_TAC THEN MATCH_MP_TAC lemma THEN ASM_SIMP_TAC[] THEN
      UNDISCH_TAC `y IN ball(x:real^N,norm x)` THEN
      REWRITE_TAC[IN_BALL] THEN CONV_TAC NORM_ARITH]) in
  let flemma = prove
   (`!a x:real^N s.
       convex s /\ bounded s /\ ~(vec 0 IN closure s) /\
       &0 < a /\ ~(x = vec 0) /\ ~(s = {}) /\
       a * norm(x) < setdist({vec 0},s)
       ==> (x IN frontier(conic hull s) <=>
            a % x IN frontier(convex hull (vec 0 INSERT s)))`,
    REWRITE_TAC[frontier; IN_DIFF] THEN
    SIMP_TAC[GSYM ilemma; GSYM clemma]) in
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `&0 < setdist({vec 0:real^N},s)` ASSUME_TAC THENL
   [REWRITE_TAC[REAL_LT_LE; SETDIST_POS_LE] THEN
    ASM_MESON_TAC[SETDIST_EQ_0_SING];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `?a d. &0 < a /\ &0 < d /\
          a * norm(x:real^N) < setdist({vec 0:real^N},s) /\
          !s'. convex s' /\ bounded s' /\ ~(s' = {}) /\ hausdist(s,s') < d
               ==> a * norm(x) < setdist({vec 0:real^N},s')`
  STRIP_ASSUME_TAC THENL
   [EXISTS_TAC `setdist({vec 0:real^N},s) / &2 / norm(x:real^N)` THEN
    EXISTS_TAC `setdist({vec 0:real^N},s) / &2` THEN
    ASM_SIMP_TAC[REAL_HALF; REAL_DIV_RMUL; REAL_LT_IMP_NZ; NORM_POS_LT;
                 REAL_LT_DIV; REAL_ARITH `x / &2 < x <=> &0 < x`] THEN
    X_GEN_TAC `s':real^N->bool` THEN STRIP_TAC THEN
    MP_TAC(ISPECL [`{vec 0:real^N}`; `s':real^N->bool`; `s:real^N->bool`]
      SETDIST_HAUSDIST_TRIANGLE) THEN
    ASM_REWRITE_TAC[] THEN ONCE_REWRITE_TAC[HAUSDIST_SYM] THEN
    ASM_REAL_ARITH_TAC;
    ALL_TAC] THEN
  EXISTS_TAC `min (min d (setdist({vec 0:real^N},s)))
     (setdist({a % x:real^N},frontier (convex hull (vec 0 INSERT s))))` THEN
  ASM_REWRITE_TAC[REAL_LT_MIN] THEN CONJ_TAC THENL
   [REWRITE_TAC[REAL_ARITH `&0 < x <=> &0 <= x /\ ~(x = &0)`] THEN
    REWRITE_TAC[SETDIST_POS_LE; SETDIST_EQ_0_SING] THEN
    SIMP_TAC[CLOSURE_CLOSED; FRONTIER_CLOSED; FRONTIER_EQ_EMPTY] THEN
    ASM_SIMP_TAC[GSYM flemma; HAUSDIST_REFL] THEN
    SIMP_TAC[CONVEX_HULL_EQ_EMPTY; NOT_INSERT_EMPTY] THEN
    ASM_MESON_TAC[BOUNDED_CONVEX_HULL; BOUNDED_INSERT; NOT_BOUNDED_UNIV];
    ALL_TAC] THEN
  X_GEN_TAC `s':real^N->bool` THEN STRIP_TAC THEN
  MP_TAC(ISPECL
   [`convex hull ((vec 0:real^N) INSERT s)`;
    `convex hull ((vec 0:real^N) INSERT s')`; `a % x:real^N`]
        HAUSDIST_STILL_SAME_PLACE_STRONG) THEN
  ASM_REWRITE_TAC[CONVEX_CONVEX_HULL; BOUNDED_CONVEX_HULL_EQ;
                  BOUNDED_INSERT; CONVEX_HULL_EQ_EMPTY; NOT_INSERT_EMPTY] THEN
  ANTS_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ_ALT]
      REAL_LET_TRANS)) THEN
    W(MP_TAC o PART_MATCH (lhand o rand) HAUSDIST_CONVEX_HULLS o
      lhand o snd) THEN
    ASM_SIMP_TAC[BOUNDED_INSERT] THEN
    MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ_ALT] REAL_LE_TRANS) THEN
    W(MP_TAC o PART_MATCH (lhand o rand) HAUSDIST_INSERT_LE o
      lhand o snd) THEN
    ASM_SIMP_TAC[BOUNDED_INSERT] THEN
    MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ_ALT] REAL_LE_TRANS) THEN
    ASM_REWRITE_TAC[];
    ALL_TAC] THEN
  MP_TAC(ISPECL [`a:real`; `x:real^N`] lemma) THEN
  ASM_SIMP_TAC[HAUSDIST_REFL] THEN DISCH_THEN(K ALL_TAC) THEN
  DISCH_THEN(MP_TAC o el 1 o CONJUNCTS) THEN
  MP_TAC(ISPECL [`a:real`; `x:real^N`; `s':real^N->bool`] flemma) THEN
  ASM_SIMP_TAC[] THEN ANTS_TAC THENL [ALL_TAC; MESON_TAC[]] THEN
  MATCH_MP_TAC HAUSDIST_STILL_OUTSIDE THEN EXISTS_TAC `s:real^N->bool` THEN
  ASM_REWRITE_TAC[BOUNDED_CLOSURE_EQ; HAUSDIST_CLOSURE]);;

let HAUSDIST_STILL_SAME_PLACE_CONIC_HULL = prove
 (`!s x:real^N.
       convex s /\ bounded s /\ ~(s = {}) /\ ~(vec 0 IN closure s) /\
       ~(x IN frontier(conic hull s))
       ==> ?e. &0 < e /\
               !s'. convex s' /\ bounded s' /\ ~(s' = {}) /\ hausdist(s,s') < e
                    ==> (x IN conic hull s' <=> x IN conic hull s)`,
  REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `x:real^N = vec 0` THEN ASM_SIMP_TAC[CONIC_HULL_CONTAINS_0]
  THENL [MESON_TAC[REAL_LT_01]; ALL_TAC] THEN
  SUBGOAL_THEN `&0 < setdist({vec 0:real^N},s)` ASSUME_TAC THENL
   [REWRITE_TAC[REAL_LT_LE; SETDIST_POS_LE] THEN
    ASM_MESON_TAC[SETDIST_EQ_0_SING];
    MP_TAC(ISPECL [`s:real^N->bool`; `x:real^N`]
        HAUSDIST_STILL_SAME_PLACE_CONIC_HULL_STRONG) THEN
    ASM_REWRITE_TAC[] THEN MATCH_MP_TAC MONO_EXISTS THEN
    MESON_TAC[]]);;

let CONVEX_SYMDIFF_CLOSE_TO_FRONTIER = prove
 (`!s t:real^N->bool e.
        bounded s /\ convex s /\ ~(s = {}) /\
        bounded t /\ convex t /\ ~(t = {}) /\
        hausdist(s,t) < e
        ==> (s DIFF t) UNION (t DIFF s) SUBSET
            {u + v:real^N | u IN frontier s /\ v IN ball(vec 0,e)}`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN
  X_GEN_TAC `x:real^N` THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `t:real^N->bool`; `x:real^N`]
        HAUSDIST_STILL_SAME_PLACE) THEN
  ASM_REWRITE_TAC[] THEN
  GEN_REWRITE_TAC LAND_CONV [GSYM CONTRAPOS_THM] THEN
  REWRITE_TAC[REAL_NOT_LT] THEN MATCH_MP_TAC MONO_IMP THEN
  CONJ_TAC THENL [SET_TAC[]; ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `e:real` o MATCH_MP
   (REAL_ARITH `a <= b ==> !c. b < c ==> a < c`)) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(MP_TAC o MATCH_MP
   (ONCE_REWRITE_RULE[IMP_CONJ_ALT] (REWRITE_RULE[CONJ_ASSOC]
        REAL_SETDIST_LT_EXISTS))) THEN
  ASM_REWRITE_TAC[NOT_INSERT_EMPTY; FRONTIER_EQ_EMPTY] THEN
  ANTS_TAC THENL [ASM_MESON_TAC[NOT_BOUNDED_UNIV]; ALL_TAC] THEN
  REWRITE_TAC[IN_SING; RIGHT_EXISTS_AND_THM; UNWIND_THM2; GSYM CONJ_ASSOC] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `u:real^N` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN EXISTS_TAC `x - u:real^N` THEN
  ASM_REWRITE_TAC[IN_BALL_0; GSYM dist] THEN CONV_TAC VECTOR_ARITH);;

(* ------------------------------------------------------------------------- *)
(* Polytopes.                                                                *)
(* ------------------------------------------------------------------------- *)

let polytope = new_definition
 `polytope s <=> ?v. FINITE v /\ s = convex hull v`;;

let POLYTOPE_TRANSLATION_EQ = prove
 (`!a s. polytope (IMAGE (\x:real^N. a + x) s) <=> polytope s`,
  REWRITE_TAC[polytope] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [POLYTOPE_TRANSLATION_EQ];;

let POLYTOPE_LINEAR_IMAGE = prove
 (`!f:real^M->real^N p.
        linear f /\ polytope p ==> polytope(IMAGE f p)`,
  REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  REWRITE_TAC[polytope] THEN
  DISCH_THEN(X_CHOOSE_THEN `s:real^M->bool` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `IMAGE (f:real^M->real^N) s` THEN
  ASM_SIMP_TAC[CONVEX_HULL_LINEAR_IMAGE; FINITE_IMAGE]);;

let POLYTOPE_LINEAR_IMAGE_EQ = prove
 (`!f:real^M->real^N s.
        linear f /\ (!x y. f x = f y ==> x = y) /\ (!y. ?x. f x = y)
        ==> (polytope (IMAGE f s) <=> polytope s)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[polytope] THEN
  MP_TAC(ISPEC `f:real^M->real^N` QUANTIFY_SURJECTION_THM) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV)[th]) THEN
  MP_TAC(end_itlist CONJ
   (mapfilter (ISPEC `f:real^M->real^N`) (!invariant_under_linear))) THEN
  ASM_REWRITE_TAC[] THEN DISCH_TAC THEN ASM_REWRITE_TAC[]);;

let POLYTOPE_EMPTY = prove
 (`polytope {}`,
  REWRITE_TAC[polytope] THEN MESON_TAC[FINITE_EMPTY; CONVEX_HULL_EMPTY]);;

let POLYTOPE_NEGATIONS = prove
 (`!s:real^N->bool. polytope s ==> polytope(IMAGE (--) s)`,
  SIMP_TAC[POLYTOPE_LINEAR_IMAGE; LINEAR_NEGATION]);;

let POLYTOPE_CONVEX_HULL = prove
 (`!s. FINITE s ==> polytope(convex hull s)`,
  REWRITE_TAC[polytope] THEN MESON_TAC[]);;

let POLYTOPE_SEGMENT = prove
 (`!a b:real^N. polytope(segment[a,b])`,
  REPEAT GEN_TAC THEN REWRITE_TAC[polytope] THEN
  EXISTS_TAC `{a:real^N,b}` THEN
  ASM_REWRITE_TAC[SEGMENT_CONVEX_HULL; FINITE_INSERT; FINITE_EMPTY]);;

let POLYTOPE_PCROSS = prove
 (`!s:real^M->bool t:real^N->bool.
        polytope s /\ polytope t ==> polytope(s PCROSS t)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[polytope] THEN
  MESON_TAC[CONVEX_HULL_PCROSS; FINITE_PCROSS]);;

let POLYTOPE_PCROSS_EQ = prove
 (`!s:real^M->bool t:real^N->bool.
        polytope(s PCROSS t) <=>
        s = {} \/ t = {} \/ polytope s /\ polytope t`,
  REPEAT GEN_TAC THEN
  ASM_CASES_TAC `s:real^M->bool = {}` THEN
  ASM_REWRITE_TAC[PCROSS_EMPTY; POLYTOPE_EMPTY] THEN
  ASM_CASES_TAC `t:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[PCROSS_EMPTY; POLYTOPE_EMPTY] THEN
  EQ_TAC THEN REWRITE_TAC[POLYTOPE_PCROSS] THEN REPEAT STRIP_TAC THENL
   [MP_TAC(ISPECL [`fstcart:real^(M,N)finite_sum->real^M`;
                    `(s:real^M->bool) PCROSS (t:real^N->bool)`]
       POLYTOPE_LINEAR_IMAGE) THEN
    ASM_REWRITE_TAC[LINEAR_FSTCART];
    MP_TAC(ISPECL [`sndcart:real^(M,N)finite_sum->real^N`;
                   `(s:real^M->bool) PCROSS (t:real^N->bool)`]
       POLYTOPE_LINEAR_IMAGE) THEN
    ASM_REWRITE_TAC[LINEAR_SNDCART]] THEN
  MATCH_MP_TAC EQ_IMP THEN AP_TERM_TAC THEN
  REWRITE_TAC[EXTENSION; IN_IMAGE; EXISTS_PASTECART; PASTECART_IN_PCROSS;
              FSTCART_PASTECART; SNDCART_PASTECART] THEN
  ASM SET_TAC[]);;

let FACE_OF_POLYTOPE_POLYTOPE = prove
 (`!f s:real^N->bool. polytope s /\ f face_of s ==> polytope f`,
  REWRITE_TAC[polytope] THEN
  MESON_TAC[FINITE_SUBSET; FACE_OF_CONVEX_HULL_SUBSET; FINITE_IMP_COMPACT]);;

let FINITE_POLYTOPE_FACES = prove
 (`!s:real^N->bool. polytope s ==> FINITE {f | f face_of s}`,
  GEN_TAC THEN REWRITE_TAC[polytope; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `v:real^N->bool` THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC FINITE_SUBSET THEN
  EXISTS_TAC `IMAGE ((hull) convex) {t:real^N->bool | t SUBSET v}` THEN
  ASM_SIMP_TAC[FINITE_POWERSET; FINITE_IMAGE] THEN
  GEN_REWRITE_TAC I [SUBSET] THEN
  REWRITE_TAC[FORALL_IN_GSPEC; IN_IMAGE; IN_ELIM_THM] THEN
  ASM_MESON_TAC[FACE_OF_CONVEX_HULL_SUBSET; FINITE_IMP_COMPACT]);;

let FINITE_POLYTOPE_FACETS = prove
 (`!s:real^N->bool. polytope s ==> FINITE {f | f facet_of s}`,
  REWRITE_TAC[facet_of] THEN ONCE_REWRITE_TAC[SET_RULE
   `{x | P x /\ Q x} = {x | x IN {x | P x} /\ Q x}`] THEN
  SIMP_TAC[FINITE_RESTRICT; FINITE_POLYTOPE_FACES]);;

let POLYTOPE_SCALING = prove
 (`!c s:real^N->bool. polytope s ==> polytope (IMAGE (\x. c % x) s)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[polytope] THEN DISCH_THEN
   (X_CHOOSE_THEN `u:real^N->bool` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `IMAGE (\x:real^N. c % x) u` THEN
  ASM_SIMP_TAC[CONVEX_HULL_SCALING; FINITE_IMAGE]);;

let POLYTOPE_SCALING_EQ = prove
 (`!c s:real^N->bool.
     ~(c = &0) ==> (polytope (IMAGE (\x. c % x) s) <=> polytope s)`,
  REPEAT STRIP_TAC THEN EQ_TAC THEN REWRITE_TAC[POLYTOPE_SCALING] THEN
  DISCH_THEN(MP_TAC o SPEC `inv c:real` o MATCH_MP POLYTOPE_SCALING) THEN
  ASM_SIMP_TAC[GSYM IMAGE_o; o_DEF; VECTOR_MUL_ASSOC;
               REAL_MUL_LINV; VECTOR_MUL_LID; IMAGE_ID]);;

let POLYTOPE_SUMS = prove
 (`!s t:real^N->bool.
        polytope s /\ polytope t ==> polytope {x + y | x IN s /\ y IN t}`,
  REPEAT GEN_TAC THEN REWRITE_TAC[polytope] THEN DISCH_THEN(CONJUNCTS_THEN2
   (X_CHOOSE_THEN `u:real^N->bool` STRIP_ASSUME_TAC)
   (X_CHOOSE_THEN `v:real^N->bool` STRIP_ASSUME_TAC)) THEN
  EXISTS_TAC `{x + y:real^N | x IN u /\ y IN v}` THEN
  ASM_SIMP_TAC[FINITE_PRODUCT_DEPENDENT; CONVEX_HULL_SUMS]);;

let POLYTOPE_IMP_COMPACT = prove
 (`!s. polytope s ==> compact s`,
  SIMP_TAC[polytope; LEFT_IMP_EXISTS_THM; COMPACT_CONVEX_HULL;
           FINITE_IMP_COMPACT; FINITE_INSERT; FINITE_EMPTY]);;

let POLYTOPE_IMP_CONVEX = prove
 (`!s. polytope s ==> convex s`,
  SIMP_TAC[polytope; LEFT_IMP_EXISTS_THM; CONVEX_CONVEX_HULL]);;

let POLYTOPE_IMP_CLOSED = prove
 (`!s. polytope s ==> closed s`,
  SIMP_TAC[POLYTOPE_IMP_COMPACT; COMPACT_IMP_CLOSED]);;

let POLYTOPE_IMP_BOUNDED = prove
 (`!s. polytope s ==> bounded s`,
  SIMP_TAC[POLYTOPE_IMP_COMPACT; COMPACT_IMP_BOUNDED]);;

let POLYTOPE_INTERVAL = prove
 (`!a b. polytope(interval[a,b])`,
  REWRITE_TAC[polytope] THEN MESON_TAC[CLOSED_INTERVAL_AS_CONVEX_HULL]);;

let POLYTOPE_SING = prove
 (`!a. polytope {a}`,
  MESON_TAC[POLYTOPE_INTERVAL; INTERVAL_SING]);;

let POLYTOPE_1 = prove
 (`!s:real^1->bool. polytope s <=> ?a b. s = interval[a,b]`,
  MESON_TAC[IS_INTERVAL_COMPACT; POLYTOPE_IMP_COMPACT; POLYTOPE_IMP_CONVEX;
            IS_INTERVAL_CONVEX_1; POLYTOPE_INTERVAL]);;

let POLYTOPE_AFF_DIM_1 = prove
 (`!p:real^N->bool.
        polytope p /\ aff_dim p = &1 <=> ?a b. ~(a = b) /\ p = segment[a,b]`,
  GEN_TAC THEN EQ_TAC THEN REPEAT STRIP_TAC THEN
  ASM_REWRITE_TAC[POLYTOPE_SEGMENT; AFF_DIM_SEGMENT] THEN
  MP_TAC(ISPEC `p:real^N->bool` COMPACT_CONVEX_COLLINEAR_SEGMENT) THEN
  ASM_SIMP_TAC[COLLINEAR_AFF_DIM; INT_LE_REFL] THEN
  ASM_SIMP_TAC[POLYTOPE_IMP_COMPACT; POLYTOPE_IMP_CONVEX] THEN
  UNDISCH_TAC `aff_dim(p:real^N->bool) = &1` THEN
  ASM_CASES_TAC `p:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[AFF_DIM_EMPTY] THEN CONV_TAC INT_REDUCE_CONV THEN
  DISCH_TAC THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `a:real^N` THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `b:real^N` THEN
  ASM_CASES_TAC `a:real^N = b` THEN ASM_REWRITE_TAC[SEGMENT_REFL] THEN
  ASM_MESON_TAC[AFF_DIM_SING; INT_ARITH `~(&1:int = &0)`]);;

let FACE_OF_POLYTOPE_INSERT_EQ = prove
 (`!f s a:real^N.
         polytope s /\ ~(a IN affine hull s)
         ==> (f face_of convex hull (a INSERT s) <=>
              f face_of s \/
              (?f'. f' face_of s /\ f = convex hull (a INSERT f')))`,
  REPEAT GEN_TAC THEN REWRITE_TAC[IMP_CONJ; polytope] THEN
  DISCH_THEN(X_CHOOSE_THEN `c:real^N->bool` STRIP_ASSUME_TAC) THEN
  ASM_REWRITE_TAC[AFFINE_HULL_CONVEX_HULL] THEN DISCH_TAC THEN
  ONCE_REWRITE_TAC[SET_RULE `z INSERT i = {z} UNION i`] THEN
  REWRITE_TAC[GSYM HULL_UNION_RIGHT] THEN
  REWRITE_TAC[SET_RULE `{z} UNION i = z INSERT i`] THEN
  MP_TAC(ISPECL [`f:real^N->bool`; `c:real^N->bool`; `a:real^N`]
        FACE_OF_CONVEX_HULL_INSERT_EQ) THEN
  ASM_SIMP_TAC[]);;

(* ------------------------------------------------------------------------- *)
(* Approximation of bounded convex sets by polytopes.                        *)
(* ------------------------------------------------------------------------- *)

let CONVEX_INNER_APPROXIMATION = prove
 (`!s:real^N->bool e.
        bounded s /\ convex s /\ &0 < e
        ==> ?k. FINITE k /\ convex hull k SUBSET s /\
                hausdist(convex hull k,s) < e /\
                (k = {} ==> s = {})`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [EXISTS_TAC `{}:real^N->bool` THEN
    ASM_SIMP_TAC[FINITE_EMPTY; CONVEX_HULL_EMPTY; HAUSDIST_REFL; SUBSET_REFL];
    ALL_TAC] THEN
  MP_TAC(ISPEC `closure s:real^N->bool` COMPACT_EQ_HEINE_BOREL) THEN
  ASM_REWRITE_TAC[COMPACT_CLOSURE] THEN
  DISCH_THEN(MP_TAC o SPEC `{ball(x:real^N,e / &2) | x IN s}`) THEN
  REWRITE_TAC[FORALL_IN_GSPEC; OPEN_BALL] THEN ANTS_TAC THENL
   [REWRITE_TAC[SUBSET; UNIONS_GSPEC; IN_ELIM_THM; CLOSURE_APPROACHABLE] THEN
    X_GEN_TAC `x:real^N` THEN DISCH_THEN(MP_TAC o SPEC `e / &2`) THEN
    ASM_REWRITE_TAC[IN_BALL; REAL_HALF];
    ONCE_REWRITE_TAC[TAUT `p /\ q /\ r <=> q /\ p /\ r`] THEN
    REWRITE_TAC[SIMPLE_IMAGE; EXISTS_FINITE_SUBSET_IMAGE]] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `k:real^N->bool` THEN
  ASM_CASES_TAC `k:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[IMAGE_CLAUSES; UNIONS_0; SUBSET_EMPTY; CLOSURE_EQ_EMPTY] THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(TAUT `p /\ (p ==> q) ==> p /\ q`) THEN CONJ_TAC THENL
   [ASM_SIMP_TAC[HULL_MINIMAL]; DISCH_TAC] THEN
  FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (REAL_ARITH
   `&0 < e ==> x <= e / &2 ==> x < e`)) THEN
  MATCH_MP_TAC REAL_HAUSDIST_LE THEN
  ASM_REWRITE_TAC[CONVEX_HULL_EQ_EMPTY] THEN CONJ_TAC THENL
   [RULE_ASSUM_TAC(REWRITE_RULE[SUBSET]) THEN
    ASM_SIMP_TAC[SETDIST_SING_IN_SET] THEN ASM_REAL_ARITH_TAC;
    ALL_TAC] THEN
  X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN UNDISCH_TAC
   `closure s SUBSET UNIONS (IMAGE (\x:real^N. ball (x,e / &2)) k)` THEN
  REWRITE_TAC[SUBSET] THEN DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN
  ASM_SIMP_TAC[REWRITE_RULE[SUBSET] CLOSURE_SUBSET] THEN
  REWRITE_TAC[UNIONS_IMAGE; IN_ELIM_THM; IN_BALL] THEN
  ONCE_REWRITE_TAC[DIST_SYM] THEN
  DISCH_THEN(X_CHOOSE_THEN `y:real^N` STRIP_ASSUME_TAC) THEN
  TRANS_TAC REAL_LE_TRANS `dist(x:real^N,y)` THEN
  ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN MATCH_MP_TAC SETDIST_LE_DIST THEN
  ASM_SIMP_TAC[IN_SING; HULL_INC]);;

let CONVEX_OUTER_APPROXIMATION = prove
 (`!s:real^N->bool e.
        bounded s /\ convex s /\ &0 < e
        ==> ?k. FINITE k /\ s SUBSET convex hull k /\
                hausdist(convex hull k,s) < e`,
  REPEAT STRIP_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [EXISTS_TAC `{}:real^N->bool` THEN
    ASM_REWRITE_TAC[FINITE_EMPTY; EMPTY_SUBSET; HAUSDIST_EMPTY;
                    CONVEX_HULL_EMPTY];
    ALL_TAC] THEN
  MP_TAC(ISPECL [`{x + y:real^N | x IN s /\ y IN ball(vec 0,e / &2)}`;
                 `e / &2`] CONVEX_INNER_APPROXIMATION) THEN
  ASM_SIMP_TAC[CONVEX_SUMS; CONVEX_BALL; BOUNDED_SUMS; BOUNDED_BALL] THEN
  ASM_REWRITE_TAC[REAL_HALF; BALL_EQ_EMPTY; GSYM REAL_NOT_LT; SET_RULE
   `{f x y | x IN s /\ y IN t} = {} <=> s = {} \/ t = {}`] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `k:real^N->bool` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP (REWRITE_RULE[REAL_NOT_LE]
   (ONCE_REWRITE_RULE[GSYM CONTRAPOS_THM] REAL_LE_HAUSDIST))) THEN
  REWRITE_TAC[TAUT `~(p /\ q) <=> p ==> ~q`; RIGHT_FORALL_IMP_THM] THEN
  ASM_REWRITE_TAC[CONVEX_HULL_EQ_EMPTY; LEFT_FORALL_IMP_THM] THEN
  ASM_REWRITE_TAC[REAL_HALF; BALL_EQ_EMPTY; GSYM REAL_NOT_LT; SET_RULE
   `{f x y | x IN s /\ y IN t} = {} <=> s = {} \/ t = {}`] THEN
  REWRITE_TAC[DE_MORGAN_THM; REAL_NOT_LT; FORALL_AND_THM] THEN ANTS_TAC THENL
   [EXISTS_TAC `hausdist(convex hull k,
                      {x + y:real^N | x IN s /\ y IN ball(vec 0,e / &2)})` THEN
    X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
    MATCH_MP_TAC SETDIST_SING_LE_HAUSDIST THEN
    ASM_SIMP_TAC[BOUNDED_CONVEX_HULL; FINITE_IMP_BOUNDED] THEN
    ASM_SIMP_TAC[BOUNDED_SUMS; BOUNDED_BALL];
    ALL_TAC] THEN
  ANTS_TAC THENL
   [EXISTS_TAC `hausdist(convex hull k,
                      {x + y:real^N | x IN s /\ y IN ball(vec 0,e / &2)})` THEN
    X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
    ONCE_REWRITE_TAC[HAUSDIST_SYM] THEN
    MATCH_MP_TAC SETDIST_SING_LE_HAUSDIST THEN
    ASM_SIMP_TAC[BOUNDED_CONVEX_HULL; FINITE_IMP_BOUNDED] THEN
    ASM_SIMP_TAC[BOUNDED_SUMS; BOUNDED_BALL];
    REWRITE_TAC[TAUT `~p \/ q <=> p ==> q`] THEN DISCH_TAC] THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC SUBSET_SUMS_RCANCEL THEN
    EXISTS_TAC `ball(vec 0:real^N,e / &2)` THEN
    ASM_SIMP_TAC[COMPACT_IMP_CLOSED; COMPACT_CONVEX_HULL; FINITE_IMP_COMPACT;
      CONVEX_CONVEX_HULL; BALL_EQ_EMPTY; BOUNDED_BALL; REAL_NOT_LE] THEN
    ASM_REWRITE_TAC[REAL_HALF; SUBSET] THEN X_GEN_TAC `z:real^N` THEN
    DISCH_TAC THEN FIRST_X_ASSUM(MP_TAC o SPEC `z:real^N` o CONJUNCT2) THEN
    ASM_REWRITE_TAC[] THEN DISCH_THEN(MP_TAC o MATCH_MP
     (ONCE_REWRITE_RULE[IMP_CONJ_ALT] (REWRITE_RULE[CONJ_ASSOC]
        REAL_SETDIST_LT_EXISTS))) THEN
    ASM_REWRITE_TAC[NOT_INSERT_EMPTY; CONVEX_HULL_EQ_EMPTY; IN_SING] THEN
    REWRITE_TAC[IN_BALL_0; IN_ELIM_THM; GSYM CONJ_ASSOC] THEN
    REWRITE_TAC[RIGHT_EXISTS_AND_THM; UNWIND_THM2] THEN
    MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `y:real^N` THEN
    STRIP_TAC THEN ASM_REWRITE_TAC[] THEN EXISTS_TAC `z - y:real^N` THEN
    ASM_REWRITE_TAC[GSYM dist] THEN CONV_TAC VECTOR_ARITH;
    FIRST_ASSUM(MATCH_MP_TAC o MATCH_MP (REAL_ARITH
     `&0 < e ==> x <= e / &2 ==> x < e`)) THEN
    MATCH_MP_TAC REAL_HAUSDIST_LE THEN
    ASM_REWRITE_TAC[CONVEX_HULL_EQ_EMPTY] THEN CONJ_TAC THENL
     [X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [SUBSET]) THEN
      DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN
      ASM_REWRITE_TAC[IN_ELIM_THM] THEN ONCE_REWRITE_TAC[CONJ_SYM] THEN
      REWRITE_TAC[VECTOR_ARITH `x:real^N = z + y <=> x - z = y`] THEN
      REWRITE_TAC[UNWIND_THM1; IN_BALL_0; GSYM dist] THEN
      DISCH_THEN(X_CHOOSE_THEN `y:real^N` STRIP_ASSUME_TAC) THEN
      TRANS_TAC REAL_LE_TRANS `dist(x:real^N,y)` THEN
      ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN MATCH_MP_TAC SETDIST_LE_DIST THEN
      ASM_REWRITE_TAC[IN_SING];
      X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPEC `x:real^N` o CONJUNCT2) THEN
      ANTS_TAC THENL [ALL_TAC; REWRITE_TAC[REAL_LT_IMP_LE]] THEN
      REWRITE_TAC[IN_ELIM_THM] THEN EXISTS_TAC `x:real^N` THEN
      EXISTS_TAC `vec 0:real^N` THEN ASM_REWRITE_TAC[CENTRE_IN_BALL] THEN
      ASM_REWRITE_TAC[REAL_HALF; VECTOR_ADD_RID]]]);;

let CONVEX_INNER_POLYTOPE = prove
 (`!s:real^N->bool e.
        bounded s /\ convex s /\ &0 < e
        ==> ?p. polytope p /\ p SUBSET s /\ hausdist(p,s) < e /\
                (p = {} ==> s = {})`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  FIRST_ASSUM(X_CHOOSE_THEN `k:real^N->bool` STRIP_ASSUME_TAC o
        MATCH_MP CONVEX_INNER_APPROXIMATION) THEN
  EXISTS_TAC `convex hull k:real^N->bool` THEN
  ASM_SIMP_TAC[CONVEX_HULL_EQ_EMPTY; POLYTOPE_CONVEX_HULL]);;

let CONVEX_OUTER_POLYTOPE = prove
 (`!s:real^N->bool e.
        bounded s /\ convex s /\ &0 < e
        ==> ?p. polytope p /\ s SUBSET p /\ hausdist(p,s) < e`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  FIRST_ASSUM(X_CHOOSE_THEN `k:real^N->bool` STRIP_ASSUME_TAC o
        MATCH_MP CONVEX_OUTER_APPROXIMATION) THEN
  EXISTS_TAC `convex hull k:real^N->bool` THEN
  ASM_SIMP_TAC[CONVEX_HULL_EQ_EMPTY; POLYTOPE_CONVEX_HULL]);;

(* ------------------------------------------------------------------------- *)
(* Polyhedra.                                                                *)
(* ------------------------------------------------------------------------- *)

let polyhedron = new_definition
 `polyhedron s <=>
        ?f. FINITE f /\
            s = INTERS f /\
            (!h. h IN f ==> ?a b. ~(a = vec 0) /\ h = {x | a dot x <= b})`;;

let POLYHEDRON_INTER = prove
 (`!s t:real^N->bool.
        polyhedron s /\ polyhedron t ==> polyhedron (s INTER t)`,
  REPEAT GEN_TAC THEN REWRITE_TAC[polyhedron] THEN
  DISCH_THEN(CONJUNCTS_THEN2
   (X_CHOOSE_TAC `f:(real^N->bool)->bool`)
   (X_CHOOSE_TAC `g:(real^N->bool)->bool`)) THEN
  EXISTS_TAC `f UNION g:(real^N->bool)->bool` THEN
  ASM_REWRITE_TAC[SET_RULE `INTERS(f UNION g) = INTERS f INTER INTERS g`] THEN
  REWRITE_TAC[FINITE_UNION; IN_UNION] THEN
  REPEAT STRIP_TAC THEN ASM_SIMP_TAC[]);;

let POLYHEDRON_UNIV = prove
 (`polyhedron(:real^N)`,
  REWRITE_TAC[polyhedron] THEN EXISTS_TAC `{}:(real^N->bool)->bool` THEN
  REWRITE_TAC[INTERS_0; NOT_IN_EMPTY; FINITE_RULES]);;

let POLYHEDRON_POSITIVE_ORTHANT = prove
 (`polyhedron {x:real^N | !i. 1 <= i /\ i <= dimindex(:N) ==> &0 <= x$i}`,
  REWRITE_TAC[polyhedron] THEN
  EXISTS_TAC `IMAGE (\i. {x:real^N | &0 <= x$i}) (1..dimindex(:N))` THEN
  SIMP_TAC[FINITE_IMAGE; FINITE_NUMSEG; FORALL_IN_IMAGE] THEN CONJ_TAC THENL
   [GEN_REWRITE_TAC I [EXTENSION] THEN REWRITE_TAC[INTERS_IMAGE] THEN
    REWRITE_TAC[IN_ELIM_THM; IN_NUMSEG];
    X_GEN_TAC `k:num` THEN REWRITE_TAC[IN_NUMSEG] THEN STRIP_TAC THEN
    MAP_EVERY EXISTS_TAC [`--basis k:real^N`; `&0`] THEN
    ASM_SIMP_TAC[VECTOR_NEG_EQ_0; DOT_LNEG; DOT_BASIS; BASIS_NONZERO] THEN
    REWRITE_TAC[REAL_ARITH `--x <= &0 <=> &0 <= x`]]);;

let POLYHEDRON_INTERS = prove
 (`!f:(real^N->bool)->bool.
        FINITE f /\ (!s. s IN f ==> polyhedron s) ==> polyhedron(INTERS f)`,
  REWRITE_TAC[IMP_CONJ] THEN MATCH_MP_TAC FINITE_INDUCT_STRONG THEN
  REWRITE_TAC[NOT_IN_EMPTY; INTERS_0; POLYHEDRON_UNIV] THEN
  ASM_SIMP_TAC[INTERS_INSERT; FORALL_IN_INSERT; POLYHEDRON_INTER]);;

let POLYHEDRON_EMPTY = prove
 (`polyhedron({}:real^N->bool)`,
  REWRITE_TAC[polyhedron] THEN
  EXISTS_TAC `{{x:real^N | basis 1 dot x <= -- &1},
               {x | --(basis 1) dot x <= -- &1}}` THEN
  REWRITE_TAC[FINITE_INSERT; FINITE_EMPTY; INTERS_2; FORALL_IN_INSERT] THEN
  REWRITE_TAC[NOT_IN_EMPTY; INTER; IN_ELIM_THM; DOT_LNEG] THEN
  REWRITE_TAC[REAL_ARITH `~(a <= -- &1 /\ --a <= -- &1)`; EMPTY_GSPEC] THEN
  CONJ_TAC THENL
   [MAP_EVERY EXISTS_TAC [`basis 1:real^N`; `-- &1`];
    MAP_EVERY EXISTS_TAC [`--(basis 1):real^N`; `-- &1`]] THEN
  SIMP_TAC[VECTOR_NEG_EQ_0; BASIS_NONZERO; DOT_LNEG;
           DIMINDEX_GE_1; LE_REFL]);;

let POLYHEDRON_HALFSPACE_LE = prove
 (`!a b. polyhedron {x:real^N | a dot x <= b}`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `a:real^N = vec 0` THENL
   [ASM_SIMP_TAC[DOT_LZERO; SET_RULE `{x | p} = if p then UNIV else {}`] THEN
    COND_CASES_TAC THEN ASM_REWRITE_TAC[POLYHEDRON_EMPTY; POLYHEDRON_UNIV];
    REWRITE_TAC[polyhedron] THEN EXISTS_TAC `{{x:real^N | a dot x <= b}}` THEN
    REWRITE_TAC[FINITE_SING; INTERS_1; FORALL_IN_INSERT; NOT_IN_EMPTY] THEN
    MAP_EVERY EXISTS_TAC [`a:real^N`; `b:real`] THEN ASM_REWRITE_TAC[]]);;

let POLYHEDRON_HALFSPACE_GE = prove
 (`!a b. polyhedron {x:real^N | a dot x >= b}`,
  REWRITE_TAC[REAL_ARITH `a:real >= b <=> --a <= --b`] THEN
  REWRITE_TAC[GSYM DOT_LNEG; POLYHEDRON_HALFSPACE_LE]);;

let POLYHEDRON_HYPERPLANE = prove
 (`!a b. polyhedron {x:real^N | a dot x = b}`,
  REWRITE_TAC[REAL_ARITH `x:real = b <=> x <= b /\ x >= b`] THEN
  REWRITE_TAC[SET_RULE `{x | P x /\ Q x} = {x | P x} INTER {x | Q x}`] THEN
  SIMP_TAC[POLYHEDRON_INTER; POLYHEDRON_HALFSPACE_LE;
           POLYHEDRON_HALFSPACE_GE]);;

let AFFINE_IMP_POLYHEDRON = prove
 (`!s:real^N->bool. affine s ==> polyhedron s`,
  REPEAT STRIP_TAC THEN MP_TAC(ISPEC `s:real^N->bool`
    AFFINE_HULL_FINITE_INTERSECTION_HYPERPLANES) THEN
  ASM_SIMP_TAC[HULL_P; RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  STRIP_TAC THEN ASM_SIMP_TAC[] THEN
  MATCH_MP_TAC POLYHEDRON_INTERS THEN ASM_REWRITE_TAC[] THEN
  X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(SUBST1_TAC o CONJUNCT2) THEN
  REWRITE_TAC[POLYHEDRON_HYPERPLANE]);;

let POLYHEDRON_IMP_CLOSED = prove
 (`!s:real^N->bool. polyhedron s ==> closed s`,
  REWRITE_TAC[polyhedron; RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC CLOSED_INTERS THEN
  X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(SUBST1_TAC o CONJUNCT2) THEN
  REWRITE_TAC[CLOSED_HALFSPACE_LE]);;

let POLYHEDRON_IMP_CONVEX = prove
 (`!s:real^N->bool. polyhedron s ==> convex s`,
  REWRITE_TAC[polyhedron; RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  REPEAT STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC CONVEX_INTERS THEN
  X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(SUBST1_TAC o CONJUNCT2) THEN
  REWRITE_TAC[CONVEX_HALFSPACE_LE]);;

let POLYHEDRON_AFFINE_HULL = prove
 (`!s. polyhedron(affine hull s)`,
  SIMP_TAC[AFFINE_IMP_POLYHEDRON; AFFINE_AFFINE_HULL]);;

(* ------------------------------------------------------------------------- *)
(* Canonical polyedron representation making facial structure explicit.      *)
(* ------------------------------------------------------------------------- *)

let POLYHEDRON_INTER_AFFINE = prove
 (`!s. polyhedron s <=>
        ?f. FINITE f /\
            s = (affine hull s) INTER (INTERS f) /\
            (!h. h IN f
                 ==> ?a b. ~(a = vec 0) /\ h = {x:real^N | a dot x <= b})`,
  GEN_TAC THEN EQ_TAC THENL
   [REWRITE_TAC[polyhedron] THEN MATCH_MP_TAC MONO_EXISTS THEN
    GEN_TAC THEN STRIP_TAC THEN REPEAT CONJ_TAC THEN
    TRY(FIRST_ASSUM ACCEPT_TAC) THEN
    MATCH_MP_TAC(SET_RULE `s = t /\ s SUBSET u ==> s = u INTER t`) THEN
    REWRITE_TAC[HULL_SUBSET] THEN ASM_REWRITE_TAC[];
    STRIP_TAC THEN ONCE_ASM_REWRITE_TAC[] THEN
    MATCH_MP_TAC POLYHEDRON_INTER THEN REWRITE_TAC[POLYHEDRON_AFFINE_HULL] THEN
    MATCH_MP_TAC POLYHEDRON_INTERS THEN ASM_REWRITE_TAC[] THEN
    ASM_MESON_TAC[POLYHEDRON_HALFSPACE_LE]]);;

let POLYHEDRON_INTER_AFFINE_PARALLEL = prove
 (`!s:real^N->bool.
        polyhedron s <=>
        ?f. FINITE f /\
            s = (affine hull s) INTER (INTERS f) /\
            (!h. h IN f
                 ==> ?a b. ~(a = vec 0) /\ h = {x:real^N | a dot x <= b} /\
                           (!x. x IN affine hull s
                                ==> (x + a) IN affine hull s))`,
  GEN_TAC THEN REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN EQ_TAC THENL
   [ALL_TAC; MATCH_MP_TAC MONO_EXISTS THEN MESON_TAC[]] THEN
  DISCH_THEN(X_CHOOSE_THEN `f:(real^N->bool)->bool` MP_TAC) THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [DISCH_THEN(K ALL_TAC) THEN EXISTS_TAC `{}:(real^N->bool)->bool` THEN
    ASM_SIMP_TAC[AFFINE_HULL_EMPTY; INTER_EMPTY; NOT_IN_EMPTY; FINITE_EMPTY];
    ALL_TAC] THEN
  ASM_CASES_TAC `f:(real^N->bool)->bool = {}` THENL
   [ASM_REWRITE_TAC[NOT_IN_EMPTY; INTERS_0; INTER_UNIV] THEN
    DISCH_THEN(ASSUME_TAC o SYM o CONJUNCT2) THEN
    EXISTS_TAC `{}:(real^N->bool)->bool` THEN
    ASM_REWRITE_TAC[NOT_IN_EMPTY; INTERS_0; INTER_UNIV; FINITE_EMPTY];
    ALL_TAC] THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 (ASSUME_TAC o GSYM) MP_TAC)) THEN
  GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV)
   [RIGHT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[LEFT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`] THEN
  DISCH_THEN(ASSUME_TAC o GSYM) THEN
  SUBGOAL_THEN
   `!h. h IN f /\ ~(affine hull s SUBSET h)
        ==> ?a' b'. ~(a' = vec 0) /\
                  affine hull s INTER {x:real^N | a' dot x <= b'} =
                  affine hull s INTER h /\
                  !w. w IN affine hull s ==> (w + a') IN affine hull s`
  MP_TAC THENL
   [GEN_TAC THEN STRIP_TAC THEN
    FIRST_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
    REWRITE_TAC[ASSUME `(h:real^N->bool) IN f`] THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC SUBST1_TAC o GSYM) THEN
    MP_TAC(ISPECL [`affine hull s:real^N->bool`;
                   `(a:(real^N->bool)->real^N) h`;
                   `(b:(real^N->bool)->real) h`]
                AFFINE_PARALLEL_SLICE) THEN
    REWRITE_TAC[AFFINE_AFFINE_HULL] THEN MATCH_MP_TAC(TAUT
     `~p /\ ~q /\ (r ==> r') ==> (p \/ q \/ r ==> r')`) THEN
    ASM_SIMP_TAC[] THEN CONJ_TAC THENL [ALL_TAC; MESON_TAC[]] THEN
    DISCH_TAC THEN
    UNDISCH_TAC `~(s:real^N->bool = {})` THEN
    EXPAND_TAC "s" THEN REWRITE_TAC[GSYM INTERS_INSERT] THEN
    MATCH_MP_TAC(SET_RULE
     `!t. t SUBSET s /\ INTERS t = {} ==> INTERS s = {}`) THEN
    EXISTS_TAC `{affine hull s,h:real^N->bool}` THEN
    ASM_REWRITE_TAC[INTERS_2] THEN ASM SET_TAC[];
    ALL_TAC] THEN
  GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV) [RIGHT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[SKOLEM_THM; LEFT_IMP_EXISTS_THM] THEN
  FIRST_X_ASSUM(K ALL_TAC o SPEC `{}:real^N->bool`) THEN
  MAP_EVERY X_GEN_TAC
    [`a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`] THEN
  DISCH_TAC THEN
  EXISTS_TAC `IMAGE (\h:real^N->bool. {x:real^N | a h dot x <= b h})
                    {h | h IN f /\ ~(affine hull s SUBSET h)}` THEN
  ASM_SIMP_TAC[FINITE_IMAGE; FINITE_RESTRICT; FORALL_IN_IMAGE] THEN
  REWRITE_TAC[FORALL_IN_GSPEC] THEN CONJ_TAC THENL
   [ALL_TAC;
    X_GEN_TAC `h:real^N->bool` THEN STRIP_TAC THEN
    MAP_EVERY EXISTS_TAC
     [`(a:(real^N->bool)->real^N) h`; `(b:(real^N->bool)->real) h`] THEN
    ASM_MESON_TAC[]] THEN
  FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC LAND_CONV [GSYM th]) THEN
  GEN_REWRITE_TAC I [EXTENSION] THEN X_GEN_TAC `x:real^N` THEN
  REWRITE_TAC[INTERS_IMAGE; IN_INTER; IN_ELIM_THM] THEN
  ASM_CASES_TAC `(x:real^N) IN affine hull s` THEN
  ASM_REWRITE_TAC[IN_INTERS] THEN AP_TERM_TAC THEN ABS_TAC THEN
  ASM SET_TAC[]);;

let POLYHEDRON_INTER_AFFINE_PARALLEL_MINIMAL = prove
 (`!s. polyhedron s <=>
        ?f. FINITE f /\
            s = (affine hull s) INTER (INTERS f) /\
            (!h. h IN f
                 ==> ?a b. ~(a = vec 0) /\ h = {x:real^N | a dot x <= b} /\
                           (!x. x IN affine hull s
                                ==> (x + a) IN affine hull s)) /\
            !f'. f' PSUBSET f ==> s PSUBSET (affine hull s) INTER (INTERS f')`,
  GEN_TAC THEN REWRITE_TAC[POLYHEDRON_INTER_AFFINE_PARALLEL] THEN
  EQ_TAC THENL [ALL_TAC; MATCH_MP_TAC MONO_EXISTS THEN MESON_TAC[]] THEN
  GEN_REWRITE_TAC LAND_CONV
   [MESON[HAS_SIZE]
     `(?f. FINITE f /\ P f) <=> (?n f. f HAS_SIZE n /\ P f)`] THEN
  GEN_REWRITE_TAC LAND_CONV [num_WOP] THEN
  DISCH_THEN(X_CHOOSE_THEN `n:num` (CONJUNCTS_THEN2 MP_TAC ASSUME_TAC)) THEN
  MATCH_MP_TAC MONO_EXISTS THEN REWRITE_TAC[HAS_SIZE] THEN
  X_GEN_TAC `f:(real^N->bool)->bool` THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  CONJ_TAC THENL [FIRST_ASSUM ACCEPT_TAC; ALL_TAC] THEN
  X_GEN_TAC `f':(real^N->bool)->bool` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `CARD(f':(real^N->bool)->bool)`) THEN
  ANTS_TAC THENL [ASM_MESON_TAC[CARD_PSUBSET]; ALL_TAC] THEN
  REWRITE_TAC[NOT_EXISTS_THM; HAS_SIZE] THEN
  DISCH_THEN(MP_TAC o SPEC `f':(real^N->bool)->bool`) THEN
  MATCH_MP_TAC(TAUT `a /\ c /\ (~b ==> d) ==> ~(a /\ b /\ c) ==> d`) THEN
  CONJ_TAC THENL [ASM_MESON_TAC[PSUBSET; FINITE_SUBSET]; ALL_TAC] THEN
  CONJ_TAC THENL
   [REPEAT STRIP_TAC THEN FIRST_X_ASSUM MATCH_MP_TAC THEN ASM SET_TAC[];
    MATCH_MP_TAC(SET_RULE `s SUBSET t ==> ~(s = t) ==> s PSUBSET t`) THEN
    FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC LAND_CONV [th]) THEN
    ASM SET_TAC[]]);;

let POLYHEDRON_INTER_AFFINE_MINIMAL = prove
 (`!s. polyhedron s <=>
        ?f. FINITE f /\
            s = (affine hull s) INTER (INTERS f) /\
            (!h. h IN f
                 ==> ?a b. ~(a = vec 0) /\ h = {x:real^N | a dot x <= b}) /\
            !f'. f' PSUBSET f ==> s PSUBSET (affine hull s) INTER (INTERS f')`,
  GEN_TAC THEN EQ_TAC THENL
   [REWRITE_TAC[POLYHEDRON_INTER_AFFINE_PARALLEL_MINIMAL];
    REWRITE_TAC[POLYHEDRON_INTER_AFFINE]] THEN
  MATCH_MP_TAC MONO_EXISTS THEN SIMP_TAC[] THEN MESON_TAC[]);;

let RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT = prove
 (`!s:real^N->bool f a b.
        FINITE f /\
        s = affine hull s INTER INTERS f /\
        (!h. h IN f ==> ~(a h = vec 0) /\ h = {x | a h dot x <= b h}) /\
        (!f'. f' PSUBSET f ==> s PSUBSET affine hull s INTER INTERS f')
        ==> relative_interior s =
                {x | x IN s /\ !h. h IN f ==> a h dot x < b h}`,
  REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  DISCH_THEN(CONJUNCTS_THEN2 (ASSUME_TAC o SYM) STRIP_ASSUME_TAC) THEN
  GEN_REWRITE_TAC I [EXTENSION] THEN REWRITE_TAC[IN_ELIM_THM] THEN
  X_GEN_TAC `x:real^N` THEN EQ_TAC THENL
   [ALL_TAC;
    STRIP_TAC THEN ASM_REWRITE_TAC[RELATIVE_INTERIOR; IN_ELIM_THM] THEN
    EXISTS_TAC `INTERS {interior h | (h:real^N->bool) IN f}` THEN
    ASM_SIMP_TAC[SIMPLE_IMAGE; OPEN_INTERS; FINITE_IMAGE; OPEN_INTERIOR;
                 FORALL_IN_IMAGE; IN_INTERS] THEN
    CONJ_TAC THENL
     [X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
      REPEAT(FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`)) THEN
      ASM_REWRITE_TAC[] THEN REPEAT DISCH_TAC THEN
      FIRST_ASSUM(SUBST1_TAC o CONJUNCT2) THEN
      ASM_SIMP_TAC[INTERIOR_HALFSPACE_LE; IN_ELIM_THM];
      FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC RAND_CONV [SYM th]) THEN
      MATCH_MP_TAC(SET_RULE
       `(!s. s IN f ==> i s SUBSET s)
        ==> INTERS (IMAGE i f) INTER t SUBSET t INTER INTERS f`) THEN
      REWRITE_TAC[INTERIOR_SUBSET]]] THEN
  DISCH_TAC THEN
  FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_RELATIVE_INTERIOR]) THEN
  DISCH_TAC THEN ASM_REWRITE_TAC[] THEN X_GEN_TAC `i:real^N->bool` THEN
  DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (i:real^N->bool)`) THEN ANTS_TAC THENL
   [ASM SET_TAC[];
    REWRITE_TAC[PSUBSET_ALT; IN_INTER; IN_INTERS; IN_DELETE]] THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  DISCH_THEN(X_CHOOSE_THEN `z:real^N` STRIP_ASSUME_TAC) THEN
  SUBGOAL_THEN `(a:(real^N->bool)->real^N) i dot z > b i` ASSUME_TAC THENL
   [UNDISCH_TAC `~((z:real^N) IN s)` THEN
    FIRST_ASSUM(SUBST1_TAC o SYM) THEN REWRITE_TAC[IN_INTER; IN_INTERS] THEN
    ASM_REWRITE_TAC[REAL_ARITH `a:real > b <=> ~(a <= b)`] THEN ASM SET_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `~(z:real^N = x)` ASSUME_TAC THENL
   [ASM_MESON_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN
   `?l. &0 < l /\ l < &1 /\ (l % z + (&1 - l) % x:real^N) IN s`
  STRIP_ASSUME_TAC THENL
   [FIRST_ASSUM(X_CHOOSE_THEN `e:real` MP_TAC o CONJUNCT2) THEN
    REWRITE_TAC[SUBSET; IN_INTER; IN_BALL; dist] THEN STRIP_TAC THEN
    EXISTS_TAC `min (&1 / &2) (e / &2 / norm(z - x:real^N))` THEN
    REWRITE_TAC[REAL_MIN_LT; REAL_LT_MIN] THEN
    CONV_TAC REAL_RAT_REDUCE_CONV THEN
    ASM_SIMP_TAC[REAL_HALF; REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ] THEN
    FIRST_X_ASSUM MATCH_MP_TAC THEN CONJ_TAC THENL
     [REWRITE_TAC[VECTOR_ARITH
       `x - (l % z + (&1 - l) % x):real^N = --l % (z - x)`] THEN
      REWRITE_TAC[NORM_MUL; REAL_ABS_NEG] THEN
      ASM_SIMP_TAC[GSYM REAL_LT_RDIV_EQ; NORM_POS_LT; VECTOR_SUB_EQ] THEN
      MATCH_MP_TAC(REAL_ARITH
       `&0 < a /\ &0 < b /\ b < c ==> abs(min a b) < c`) THEN
      ASM_SIMP_TAC[REAL_HALF; REAL_LT_DIV; NORM_POS_LT; VECTOR_SUB_EQ] THEN
      REWRITE_TAC[REAL_LT_01; real_div; REAL_MUL_ASSOC] THEN
      MATCH_MP_TAC REAL_LT_RMUL THEN
      ASM_REWRITE_TAC[REAL_LT_INV_EQ; NORM_POS_LT; VECTOR_SUB_EQ] THEN
      UNDISCH_TAC `&0 < e` THEN REAL_ARITH_TAC;
      ONCE_REWRITE_TAC[VECTOR_ADD_SYM] THEN
      MATCH_MP_TAC(REWRITE_RULE[AFFINE_ALT] AFFINE_AFFINE_HULL) THEN
      ASM SET_TAC[]];
    ALL_TAC] THEN
  MATCH_MP_TAC REAL_LT_RCANCEL_IMP THEN EXISTS_TAC `&1 - l` THEN
  ASM_REWRITE_TAC[REAL_SUB_LT] THEN
  REWRITE_TAC[REAL_ARITH `a < b * (&1 - l) <=> l * b + a < b`] THEN
  MATCH_MP_TAC REAL_LTE_TRANS THEN EXISTS_TAC
   `l * (a:(real^N->bool)->real^N) i dot z + (a i dot x) * (&1 - l)` THEN
  ASM_SIMP_TAC[REAL_LT_RADD; REAL_LT_LMUL_EQ; GSYM real_gt] THEN
  ONCE_REWRITE_TAC[REAL_ARITH `a * (&1 - b) = (&1 - b) * a`] THEN
  REWRITE_TAC[GSYM DOT_RMUL; GSYM DOT_RADD] THEN ASM SET_TAC[]);;

let FACET_OF_POLYHEDRON_EXPLICIT = prove
 (`!s:real^N->bool f a b.
        FINITE f /\
        s = affine hull s INTER INTERS f /\
        (!h. h IN f ==> ~(a h = vec 0) /\ h = {x | a h dot x <= b h}) /\
        (!f'. f' PSUBSET f ==> s PSUBSET affine hull s INTER INTERS f')
        ==> !c. c facet_of s <=>
                ?h. h IN f /\ c = s INTER {x | a h dot x = b h}`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [ASM_REWRITE_TAC[INTER_EMPTY; AFFINE_HULL_EMPTY; SET_RULE `~(s PSUBSET s)`;
                    FACET_OF_EMPTY] THEN
    ASM_CASES_TAC `f:(real^N->bool)->bool = {}` THEN
    ASM_REWRITE_TAC[NOT_IN_EMPTY] THEN
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
    DISCH_THEN(X_CHOOSE_TAC `h:real^N->bool`) THEN DISCH_THEN
     (MP_TAC o SPEC `f DELETE (h:real^N->bool)` o last o CONJUNCTS) THEN
    ASM SET_TAC[];
    STRIP_TAC] THEN
  SUBGOAL_THEN `polyhedron(s:real^N->bool)` ASSUME_TAC THENL
   [REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
    REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
    ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP POLYHEDRON_IMP_CONVEX) THEN
  SUBGOAL_THEN
   `!h:real^N->bool.
       h IN f ==> (s INTER {x:real^N | a h dot x = b h}) facet_of s`
  (LABEL_TAC "face") THENL
   [REPEAT STRIP_TAC THEN REWRITE_TAC[facet_of] THEN CONJ_TAC THENL
     [MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN
      CONJ_TAC THENL
       [MATCH_MP_TAC POLYHEDRON_IMP_CONVEX THEN
        REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
        REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
        X_GEN_TAC `x:real^N` THEN FIRST_X_ASSUM SUBST1_TAC THEN
        REWRITE_TAC[IN_INTER; IN_INTERS] THEN
        DISCH_THEN(MP_TAC o SPEC `h:real^N->bool` o CONJUNCT2) THEN
        ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
        FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
        ASM_REWRITE_TAC[] THEN ASM SET_TAC[]];
      ALL_TAC] THEN
    MP_TAC(ISPEC `s:real^N->bool` RELATIVE_INTERIOR_EQ_EMPTY) THEN
    ASM_SIMP_TAC[] THEN REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] THEN
    DISCH_THEN(X_CHOOSE_TAC `x:real^N`) THEN
    FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_RELATIVE_INTERIOR]) THEN
    DISCH_TAC THEN
    FIRST_ASSUM(MP_TAC o SPEC `f DELETE (h:real^N->bool)`) THEN
    ANTS_TAC THENL
     [ASM SET_TAC[];
      REWRITE_TAC[PSUBSET_ALT; IN_INTER; IN_INTERS; IN_DELETE]] THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
    DISCH_THEN(X_CHOOSE_THEN `z:real^N` STRIP_ASSUME_TAC) THEN
    SUBGOAL_THEN `(a:(real^N->bool)->real^N) h dot z > b h` ASSUME_TAC THENL
     [UNDISCH_TAC `~((z:real^N) IN s)` THEN
      FIRST_ASSUM(SUBST1_TAC o SYM) THEN
      REWRITE_TAC[IN_INTER; IN_INTERS] THEN
      ASM_REWRITE_TAC[REAL_ARITH `a:real > b <=> ~(a <= b)`] THEN
      ASM SET_TAC[];
      ALL_TAC] THEN
    SUBGOAL_THEN `~(z:real^N = x)` ASSUME_TAC THENL
     [ASM_MESON_TAC[]; ALL_TAC] THEN
    MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                   `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
           RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT) THEN
    ASM_REWRITE_TAC[] THEN ANTS_TAC THENL
     [FIRST_ASSUM ACCEPT_TAC; ALL_TAC] THEN
    GEN_REWRITE_TAC LAND_CONV [EXTENSION] THEN
    DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN
    ASM_REWRITE_TAC[IN_ELIM_THM] THEN
    DISCH_THEN(fun th ->
      MP_TAC(SPEC `h:real^N->bool` th) THEN ASM_REWRITE_TAC[] THEN
      DISCH_TAC THEN ASSUME_TAC th) THEN
    SUBGOAL_THEN `(a:(real^N->bool)->real^N) h dot x < a h dot z`
    ASSUME_TAC THENL [ASM_REAL_ARITH_TAC; ALL_TAC] THEN
    ABBREV_TAC `l = (b h - (a:(real^N->bool)->real^N) h dot x) /
                    (a h dot z - a h dot x)` THEN
    SUBGOAL_THEN `&0 < l /\ l < &1` STRIP_ASSUME_TAC THENL
     [EXPAND_TAC "l" THEN
      ASM_SIMP_TAC[REAL_LT_LDIV_EQ; REAL_LT_RDIV_EQ; REAL_SUB_LT] THEN
      ASM_REAL_ARITH_TAC;
      ALL_TAC] THEN
    ABBREV_TAC `w:real^N = (&1 - l) % x + l % z:real^N` THEN
    SUBGOAL_THEN
     `!i. i IN f /\ ~(i = h) ==> (a:(real^N->bool)->real^N) i dot w < b i`
    ASSUME_TAC THENL
     [X_GEN_TAC `i:real^N->bool` THEN STRIP_TAC THEN EXPAND_TAC "w" THEN
      REWRITE_TAC[DOT_RADD; DOT_RMUL] THEN
      MATCH_MP_TAC(REAL_ARITH
       `(&1 - l) * x < (&1 - l) * z /\ l * y <= l * z
        ==> (&1 - l) * x + l * y < z`) THEN
      ASM_SIMP_TAC[REAL_LE_LMUL_EQ; REAL_LT_IMP_LE;
                   REAL_LT_LMUL_EQ; REAL_SUB_LT] THEN
      UNDISCH_TAC `!t:real^N->bool. t IN f /\ ~(t = h) ==> z IN t` THEN
      DISCH_THEN(MP_TAC o SPEC `i:real^N->bool`) THEN ASM SET_TAC[];
      ALL_TAC] THEN
    SUBGOAL_THEN `(a:(real^N->bool)->real^N) h dot w = b h` ASSUME_TAC THENL
     [EXPAND_TAC "w" THEN REWRITE_TAC[VECTOR_ARITH
         `(&1 - l) % x + l % z:real^N = x + l % (z - x)`] THEN
      EXPAND_TAC "l" THEN REWRITE_TAC[DOT_RADD; DOT_RSUB; DOT_RMUL] THEN
      ASM_SIMP_TAC[REAL_DIV_RMUL; REAL_LT_IMP_NE; REAL_SUB_0] THEN
      REAL_ARITH_TAC;
      ALL_TAC] THEN
    SUBGOAL_THEN `(w:real^N) IN s` ASSUME_TAC THENL
     [FIRST_ASSUM(fun th -> GEN_REWRITE_TAC RAND_CONV [th]) THEN
      REWRITE_TAC[IN_INTER; IN_INTERS] THEN CONJ_TAC THENL
       [EXPAND_TAC "w" THEN
        MATCH_MP_TAC(REWRITE_RULE[AFFINE_ALT] AFFINE_AFFINE_HULL) THEN
        ASM_REWRITE_TAC[] THEN MATCH_MP_TAC HULL_INC THEN
        ASM_MESON_TAC[RELATIVE_INTERIOR_SUBSET; SUBSET];
        ALL_TAC] THEN
      X_GEN_TAC `i:real^N->bool` THEN DISCH_TAC THEN
      ASM_CASES_TAC `i:real^N->bool = h` THENL
       [ASM SET_TAC[REAL_LE_REFL]; ALL_TAC] THEN
      SUBGOAL_THEN `convex(i:real^N->bool)` MP_TAC THENL
       [REPEAT(FIRST_X_ASSUM(MP_TAC o C MATCH_MP
         (ASSUME `(i:real^N->bool) IN f`))) THEN
        REPEAT(DISCH_THEN(fun th -> ONCE_REWRITE_TAC[th])) THEN
        REWRITE_TAC[CONVEX_HALFSPACE_LE];
        ALL_TAC] THEN
      REWRITE_TAC[CONVEX_ALT] THEN EXPAND_TAC "w" THEN
      DISCH_THEN MATCH_MP_TAC THEN
      ASM_SIMP_TAC[] THEN FIRST_X_ASSUM(MP_TAC o CONJUNCT1) THEN
      FIRST_ASSUM(fun t -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [t]) THEN
      REWRITE_TAC[IN_INTER; IN_INTERS] THEN ASM_SIMP_TAC[REAL_LT_IMP_LE];
      ALL_TAC] THEN
    CONJ_TAC THENL [ASM_MESON_TAC[]; ALL_TAC] THEN
    ONCE_REWRITE_TAC[GSYM AFF_DIM_AFFINE_HULL] THEN
    SUBGOAL_THEN
     `affine hull (s INTER {x | (a:(real^N->bool)->real^N) h dot x = b h}) =
      (affine hull s) INTER {x | a h dot x = b h}`
    SUBST1_TAC THENL
     [ALL_TAC;
      SIMP_TAC[AFF_DIM_AFFINE_INTER_HYPERPLANE; AFFINE_AFFINE_HULL] THEN
      COND_CASES_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
      COND_CASES_TAC THENL [ASM SET_TAC[REAL_LT_REFL]; REFL_TAC]] THEN
    MATCH_MP_TAC SUBSET_ANTISYM THEN REWRITE_TAC[SUBSET_INTER] THEN
    REPEAT CONJ_TAC THENL
     [MATCH_MP_TAC HULL_MONO THEN SET_TAC[];
      MATCH_MP_TAC(SET_RULE
       `s SUBSET affine hull t /\ affine hull t = t ==> s SUBSET t`) THEN
      REWRITE_TAC[AFFINE_HULL_EQ; AFFINE_HYPERPLANE] THEN
      MATCH_MP_TAC HULL_MONO THEN SET_TAC[];
      ALL_TAC] THEN
    REWRITE_TAC[SUBSET; IN_INTER; IN_ELIM_THM] THEN
    X_GEN_TAC `y:real^N` THEN STRIP_TAC THEN
    SUBGOAL_THEN
     `?t. &0 < t /\
          !j. j IN f /\ ~(j:real^N->bool = h)
              ==> t * (a j dot y - a j dot w) <= b j - a j dot (w:real^N)`
    STRIP_ASSUME_TAC THENL
     [ASM_CASES_TAC `f DELETE (h:real^N->bool) = {}` THENL
       [ASM_REWRITE_TAC[GSYM IN_DELETE; NOT_IN_EMPTY] THEN
        EXISTS_TAC `&1` THEN REWRITE_TAC[REAL_LT_01];
        ALL_TAC] THEN
      EXISTS_TAC `inf (IMAGE
       (\j. if &0 < a j dot y - a j dot (w:real^N)
            then (b j - a j dot w) / (a j dot y - a j dot w)
            else &1) (f DELETE (h:real^N->bool)))` THEN
      MATCH_MP_TAC(TAUT `a /\ (a ==> b) ==> a /\ b`) THEN CONJ_TAC THENL
       [ASM_SIMP_TAC[REAL_LT_INF_FINITE; FINITE_IMAGE; FINITE_DELETE;
                     IMAGE_EQ_EMPTY; FORALL_IN_IMAGE; IN_DELETE] THEN
        ONCE_REWRITE_TAC[COND_RAND] THEN ONCE_REWRITE_TAC[COND_RATOR] THEN
        ASM_SIMP_TAC[REAL_LT_DIV; REAL_SUB_LT; REAL_LT_01; COND_ID];
        REWRITE_TAC[REAL_SUB_LT] THEN DISCH_TAC] THEN
      X_GEN_TAC `j:real^N->bool` THEN STRIP_TAC THEN
      ASM_CASES_TAC `a j dot (w:real^N) < a(j:real^N->bool) dot y` THENL
       [ASM_SIMP_TAC[GSYM REAL_LE_RDIV_EQ; REAL_INF_LE_FINITE; REAL_SUB_LT;
                     FINITE_IMAGE; FINITE_DELETE; IMAGE_EQ_EMPTY] THEN
        REWRITE_TAC[EXISTS_IN_IMAGE] THEN EXISTS_TAC `j:real^N->bool` THEN
        ASM_REWRITE_TAC[IN_DELETE; REAL_LE_REFL];
        MATCH_MP_TAC(REAL_ARITH `&0 <= --x /\ &0 < y ==> x <= y`) THEN
        ASM_SIMP_TAC[REAL_SUB_LT; GSYM REAL_MUL_RNEG; REAL_LE_MUL_EQ] THEN
        ASM_REAL_ARITH_TAC];
      ALL_TAC] THEN
    ABBREV_TAC `c:real^N = (&1 - t) % w + t % y` THEN
    SUBGOAL_THEN `y:real^N = (&1 - inv t) % w + inv(t) % c` SUBST1_TAC THENL
     [EXPAND_TAC "c" THEN
      REWRITE_TAC[VECTOR_ADD_LDISTRIB; VECTOR_MUL_ASSOC] THEN
      ASM_SIMP_TAC[REAL_MUL_LINV; REAL_LT_IMP_NZ;
                REAL_FIELD `&0 < x ==> inv x * (&1 - x) = inv x - &1`] THEN
      VECTOR_ARITH_TAC;
      ALL_TAC] THEN
    MATCH_MP_TAC(REWRITE_RULE[AFFINE_ALT] AFFINE_AFFINE_HULL) THEN
    CONJ_TAC THEN MATCH_MP_TAC HULL_INC THEN
    ASM_REWRITE_TAC[IN_INTER; IN_ELIM_THM] THEN
    MATCH_MP_TAC(TAUT `b /\ (b ==> a) ==> a /\ b`) THEN CONJ_TAC THENL
     [EXPAND_TAC "c" THEN REWRITE_TAC[DOT_RADD; DOT_RMUL] THEN
      ASM_REWRITE_TAC[] THEN CONV_TAC REAL_RING;
      DISCH_TAC] THEN
    FIRST_ASSUM(fun t -> GEN_REWRITE_TAC RAND_CONV [t]) THEN
    REWRITE_TAC[IN_INTER; IN_INTERS] THEN CONJ_TAC THENL
     [EXPAND_TAC "c" THEN
      MATCH_MP_TAC(REWRITE_RULE[AFFINE_ALT] AFFINE_AFFINE_HULL) THEN
      ASM_SIMP_TAC[HULL_INC];
      ALL_TAC] THEN
    X_GEN_TAC `j:real^N->bool` THEN DISCH_TAC THEN
    FIRST_X_ASSUM(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC o C MATCH_MP
      (ASSUME `(j:real^N->bool) IN f`)) THEN
    DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[IN_ELIM_THM] THEN
    ASM_CASES_TAC `j:real^N->bool = h` THEN ASM_SIMP_TAC[REAL_EQ_IMP_LE] THEN
    EXPAND_TAC "c" THEN REWRITE_TAC[DOT_RADD; DOT_RMUL] THEN
    REWRITE_TAC[REAL_ARITH
     `(&1 - t) * x + t * y <= z <=> t * (y - x) <= z - x`] THEN
    ASM_SIMP_TAC[];
    ALL_TAC] THEN
  X_GEN_TAC `c:real^N->bool` THEN EQ_TAC THENL
   [ALL_TAC; STRIP_TAC THEN ASM_SIMP_TAC[]] THEN
  REWRITE_TAC[facet_of] THEN STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_CONVEX) THEN
  SUBGOAL_THEN `~(relative_interior(c:real^N->bool) = {})` MP_TAC THENL
   [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY]; ALL_TAC] THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] THEN
  DISCH_THEN(X_CHOOSE_TAC `x:real^N`) THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT) THEN
  ASM_REWRITE_TAC[] THEN ANTS_TAC THENL [FIRST_ASSUM ACCEPT_TAC; ALL_TAC] THEN
  GEN_REWRITE_TAC LAND_CONV [EXTENSION] THEN
  DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN ASM_REWRITE_TAC[IN_ELIM_THM] THEN
  SUBGOAL_THEN `~(c:real^N->bool = s)` ASSUME_TAC THENL
   [ASM_MESON_TAC[INT_ARITH`~(i:int = i - &1)`]; ALL_TAC] THEN
  SUBGOAL_THEN `~((x:real^N) IN relative_interior s)` ASSUME_TAC THENL
   [UNDISCH_TAC `~(c:real^N->bool = s)` THEN REWRITE_TAC[CONTRAPOS_THM] THEN
    DISCH_TAC THEN MATCH_MP_TAC FACE_OF_EQ THEN
    EXISTS_TAC `s:real^N->bool` THEN ASM_SIMP_TAC[FACE_OF_REFL] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `(x:real^N) IN s` MP_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o REWRITE_RULE[SUBSET] o MATCH_MP
       FACE_OF_IMP_SUBSET) THEN
    ASM_SIMP_TAC[REWRITE_RULE[SUBSET] RELATIVE_INTERIOR_SUBSET];
    ALL_TAC] THEN
  ASM_SIMP_TAC[] THEN DISCH_THEN(fun th -> ASSUME_TAC th THEN MP_TAC th) THEN
  FIRST_ASSUM(fun t -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [t]) THEN
  REWRITE_TAC[IN_INTER; IN_INTERS] THEN STRIP_TAC THEN
  REWRITE_TAC[NOT_FORALL_THM] THEN MATCH_MP_TAC MONO_EXISTS THEN
  X_GEN_TAC `i:real^N->bool` THEN REWRITE_TAC[NOT_IMP] THEN STRIP_TAC THEN
  ASM_REWRITE_TAC[] THEN
  SUBGOAL_THEN `(a:(real^N->bool)->real^N) i dot x = b i` ASSUME_TAC THENL
   [MATCH_MP_TAC(REAL_ARITH `x <= y /\ ~(x < y) ==> x = y`) THEN
    ASM_REWRITE_TAC[] THEN UNDISCH_THEN
     `!t:real^N->bool. t IN f ==> x IN t` (MP_TAC o SPEC `i:real^N->bool`) THEN
    ASM_REWRITE_TAC[] THEN FIRST_X_ASSUM(MP_TAC o CONJUNCT2 o C MATCH_MP
     (ASSUME `(i:real^N->bool) IN f`)) THEN SET_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `c SUBSET (s INTER {x:real^N | a(i:real^N->bool) dot x = b i})`
  ASSUME_TAC THENL
   [MATCH_MP_TAC SUBSET_OF_FACE_OF THEN EXISTS_TAC `s:real^N->bool` THEN
    ASM_SIMP_TAC[FACE_OF_IMP_SUBSET] THEN
    RULE_ASSUM_TAC(REWRITE_RULE[facet_of]) THEN ASM_SIMP_TAC[] THEN
    REWRITE_TAC[DISJOINT; GSYM MEMBER_NOT_EMPTY] THEN
    EXISTS_TAC `x:real^N` THEN ASM_REWRITE_TAC[IN_INTER; IN_ELIM_THM];
    ALL_TAC] THEN
  SUBGOAL_THEN `c face_of (s INTER {x:real^N | a(i:real^N->bool) dot x = b i})`
  ASSUME_TAC THENL
   [MP_TAC(ISPECL [`c:real^N->bool`; `s:real^N->bool`;
                   `s INTER {x:real^N | a(i:real^N->bool) dot x = b i}`]
                FACE_OF_FACE) THEN
    RULE_ASSUM_TAC(REWRITE_RULE[facet_of]) THEN ASM_SIMP_TAC[];
    ALL_TAC] THEN
  MATCH_MP_TAC(TAUT `(~p ==> F) ==> p`) THEN DISCH_TAC THEN
  SUBGOAL_THEN
   `aff_dim(c:real^N->bool) <
    aff_dim(s INTER {x:real^N | a(i:real^N->bool) dot x = b i})`
  MP_TAC THENL
   [MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
    ASM_SIMP_TAC[CONVEX_INTER; CONVEX_HYPERPLANE];
    RULE_ASSUM_TAC(REWRITE_RULE[facet_of]) THEN ASM_SIMP_TAC[INT_LT_REFL]]);;

let FACE_OF_POLYHEDRON_SUBSET_EXPLICIT = prove
 (`!s:real^N->bool f a b.
        FINITE f /\
        s = affine hull s INTER INTERS f /\
        (!h. h IN f ==> ~(a h = vec 0) /\ h = {x | a h dot x <= b h}) /\
        (!f'. f' PSUBSET f ==> s PSUBSET affine hull s INTER INTERS f')
        ==> !c. c face_of s /\ ~(c = {}) /\ ~(c = s)
                ==> ?h. h IN f /\ c SUBSET (s INTER {x | a h dot x = b h})`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `f:(real^N->bool)->bool = {}` THENL
   [DISCH_THEN(MP_TAC o SYM o CONJUNCT1 o CONJUNCT2) THEN
    ASM_REWRITE_TAC[INTERS_0; INTER_UNIV; AFFINE_HULL_EQ] THEN
    MESON_TAC[FACE_OF_AFFINE_TRIVIAL];
    ALL_TAC] THEN
  DISCH_THEN(fun th -> STRIP_ASSUME_TAC th THEN MP_TAC th) THEN
  DISCH_THEN(ASSUME_TAC o MATCH_MP FACET_OF_POLYHEDRON_EXPLICIT) THEN
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_CONVEX) THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
  SUBGOAL_THEN `polyhedron(s:real^N->bool)` ASSUME_TAC THENL
   [REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
    REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
    ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP POLYHEDRON_IMP_CONVEX) THEN
  SUBGOAL_THEN
   `!h:real^N->bool.
        h IN f ==> (s INTER {x:real^N | a h dot x = b h}) face_of s`
  ASSUME_TAC THENL
   [REPEAT STRIP_TAC THEN
    MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN CONJ_TAC THENL
     [MATCH_MP_TAC POLYHEDRON_IMP_CONVEX THEN
      REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
      REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
      X_GEN_TAC `x:real^N` THEN FIRST_X_ASSUM SUBST1_TAC THEN
      REWRITE_TAC[IN_INTER; IN_INTERS] THEN
      DISCH_THEN(MP_TAC o SPEC `h:real^N->bool` o CONJUNCT2) THEN
      ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
      ASM_REWRITE_TAC[] THEN ASM SET_TAC[]];
    ALL_TAC] THEN
  SUBGOAL_THEN `~(relative_interior(c:real^N->bool) = {})` MP_TAC THENL
   [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY]; ALL_TAC] THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] THEN
  DISCH_THEN(X_CHOOSE_TAC `x:real^N`) THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT) THEN
  ASM_REWRITE_TAC[] THEN ANTS_TAC THENL [FIRST_ASSUM ACCEPT_TAC; ALL_TAC] THEN
  GEN_REWRITE_TAC LAND_CONV [EXTENSION] THEN
  DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN ASM_REWRITE_TAC[IN_ELIM_THM] THEN
  SUBGOAL_THEN `~((x:real^N) IN relative_interior s)` ASSUME_TAC THENL
   [UNDISCH_TAC `~(c:real^N->bool = s)` THEN REWRITE_TAC[CONTRAPOS_THM] THEN
    DISCH_TAC THEN MATCH_MP_TAC FACE_OF_EQ THEN
    EXISTS_TAC `s:real^N->bool` THEN ASM_SIMP_TAC[FACE_OF_REFL] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `(x:real^N) IN s` MP_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o REWRITE_RULE[SUBSET] o MATCH_MP
       FACE_OF_IMP_SUBSET) THEN
    ASM_SIMP_TAC[REWRITE_RULE[SUBSET] RELATIVE_INTERIOR_SUBSET];
    ALL_TAC] THEN
  ASM_SIMP_TAC[] THEN DISCH_THEN(fun th -> ASSUME_TAC th THEN MP_TAC th) THEN
  FIRST_ASSUM(fun t -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [t]) THEN
  REWRITE_TAC[IN_INTER; IN_INTERS] THEN STRIP_TAC THEN
  REWRITE_TAC[NOT_FORALL_THM] THEN MATCH_MP_TAC MONO_EXISTS THEN
  X_GEN_TAC `i:real^N->bool` THEN REWRITE_TAC[NOT_IMP] THEN STRIP_TAC THEN
  ASM_REWRITE_TAC[] THEN
  SUBGOAL_THEN `(a:(real^N->bool)->real^N) i dot x = b i` ASSUME_TAC THENL
   [MATCH_MP_TAC(REAL_ARITH `x <= y /\ ~(x < y) ==> x = y`) THEN
    ASM_REWRITE_TAC[] THEN UNDISCH_THEN
     `!t:real^N->bool. t IN f ==> x IN t` (MP_TAC o SPEC `i:real^N->bool`) THEN
    ASM_REWRITE_TAC[] THEN FIRST_X_ASSUM(MP_TAC o CONJUNCT2 o C MATCH_MP
     (ASSUME `(i:real^N->bool) IN f`)) THEN SET_TAC[];
    ALL_TAC] THEN
  MATCH_MP_TAC SUBSET_OF_FACE_OF THEN EXISTS_TAC `s:real^N->bool` THEN
  ASM_SIMP_TAC[FACE_OF_IMP_SUBSET] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[facet_of]) THEN ASM_SIMP_TAC[] THEN
  REWRITE_TAC[DISJOINT; GSYM MEMBER_NOT_EMPTY] THEN
  EXISTS_TAC `x:real^N` THEN ASM_REWRITE_TAC[IN_INTER; IN_ELIM_THM]);;

let FACE_OF_POLYHEDRON_EXPLICIT = prove
 (`!s:real^N->bool f a b.
        FINITE f /\
        s = affine hull s INTER INTERS f /\
        (!h. h IN f ==> ~(a h = vec 0) /\ h = {x | a h dot x <= b h}) /\
        (!f'. f' PSUBSET f ==> s PSUBSET affine hull s INTER INTERS f')
        ==> !c. c face_of s /\ ~(c = {}) /\ ~(c = s)
                ==> c = INTERS {s INTER {x | a h dot x = b h} |h|
                                h IN f /\
                                c SUBSET (s INTER {x | a h dot x = b h})}`,
  let lemma = prove
   (`!t s. (!a. P a ==> t SUBSET s INTER INTERS {f x | P x})
           ==> t SUBSET INTERS {s INTER f x | P x}`,
    ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
    REWRITE_TAC[INTERS_IMAGE] THEN SET_TAC[]) in
  REPEAT GEN_TAC THEN
  DISCH_THEN(fun th -> STRIP_ASSUME_TAC th THEN MP_TAC th) THEN
  DISCH_THEN(ASSUME_TAC o MATCH_MP FACET_OF_POLYHEDRON_EXPLICIT) THEN
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_CONVEX) THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
  SUBGOAL_THEN `polyhedron(s:real^N->bool)` ASSUME_TAC THENL
   [REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
    REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
    ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP POLYHEDRON_IMP_CONVEX) THEN
  SUBGOAL_THEN
   `!h:real^N->bool.
        h IN f ==> (s INTER {x:real^N | a h dot x = b h}) face_of s`
  ASSUME_TAC THENL
   [REPEAT STRIP_TAC THEN
    MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN CONJ_TAC THENL
     [MATCH_MP_TAC POLYHEDRON_IMP_CONVEX THEN
      REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
      REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
      X_GEN_TAC `x:real^N` THEN FIRST_X_ASSUM SUBST1_TAC THEN
      REWRITE_TAC[IN_INTER; IN_INTERS] THEN
      DISCH_THEN(MP_TAC o SPEC `h:real^N->bool` o CONJUNCT2) THEN
      ASM_REWRITE_TAC[] THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
      ASM_REWRITE_TAC[] THEN ASM SET_TAC[]];
    ALL_TAC] THEN
  SUBGOAL_THEN `~(relative_interior(c:real^N->bool) = {})` MP_TAC THENL
   [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY]; ALL_TAC] THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `z:real^N` THEN DISCH_TAC THEN
  SUBGOAL_THEN `(z:real^N) IN s` ASSUME_TAC THENL
   [FIRST_X_ASSUM(MATCH_MP_TAC o REWRITE_RULE[SUBSET]) THEN
    MATCH_MP_TAC(REWRITE_RULE[SUBSET] RELATIVE_INTERIOR_SUBSET) THEN
    ASM_REWRITE_TAC[];
    ALL_TAC] THEN
  MATCH_MP_TAC FACE_OF_EQ THEN EXISTS_TAC `s:real^N->bool` THEN
  ASM_REWRITE_TAC[] THEN CONJ_TAC THENL
   [MATCH_MP_TAC FACE_OF_INTERS THEN ASM_SIMP_TAC[FORALL_IN_GSPEC] THEN
    ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN REWRITE_TAC[IMAGE_EQ_EMPTY] THEN
    REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_ELIM_THM] THEN
    MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                   `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         FACE_OF_POLYHEDRON_SUBSET_EXPLICIT) THEN
    ASM_REWRITE_TAC[] THEN ANTS_TAC THENL[FIRST_ASSUM ACCEPT_TAC; ALL_TAC] THEN
    DISCH_THEN MATCH_MP_TAC THEN ASM_REWRITE_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `{s INTER {x | a(h:real^N->bool) dot x = b h} |h|
     h IN f /\ c SUBSET (s INTER {x:real^N | a h dot x = b h})} =
    {s INTER {x | a(h:real^N->bool) dot x = b h} |h|
     h IN f /\ z IN s INTER {x:real^N | a h dot x = b h}}`
  SUBST1_TAC THENL
   [MATCH_MP_TAC(SET_RULE
     `(!x. P x <=> Q x) ==> {f x | P x} = {f x | Q x}`) THEN
    X_GEN_TAC `h:real^N->bool` THEN EQ_TAC THEN STRIP_TAC THEN
    ASM_REWRITE_TAC[] THENL
     [FIRST_X_ASSUM(MATCH_MP_TAC o REWRITE_RULE[SUBSET]) THEN
      MATCH_MP_TAC(REWRITE_RULE[SUBSET] RELATIVE_INTERIOR_SUBSET) THEN
      ASM_REWRITE_TAC[];
      MATCH_MP_TAC SUBSET_OF_FACE_OF THEN EXISTS_TAC `s:real^N->bool` THEN
      ASM_SIMP_TAC[] THEN ASM SET_TAC[]];
    ALL_TAC] THEN
  REWRITE_TAC[DISJOINT; GSYM MEMBER_NOT_EMPTY; IN_INTER] THEN
  EXISTS_TAC `z:real^N` THEN ASM_REWRITE_TAC[IN_ELIM_THM] THEN
  SUBGOAL_THEN
   `?e. &0 < e /\ !h. h IN f /\ a(h:real^N->bool) dot z < b h
                      ==> ball(z,e) SUBSET {w:real^N | a h dot w < b h}`
  (CHOOSE_THEN (CONJUNCTS_THEN2 ASSUME_TAC (LABEL_TAC "*"))) THENL
   [REWRITE_TAC[SET_RULE
     `(!h. P h ==> s SUBSET t h) <=> s SUBSET INTERS (IMAGE t {h | P h})`] THEN
    MATCH_MP_TAC(MESON[OPEN_CONTAINS_BALL]
     `open s /\ x IN s ==> ?e. &0 < e /\ ball(x,e) SUBSET s`) THEN
    SIMP_TAC[IN_INTERS; FORALL_IN_IMAGE; IN_ELIM_THM] THEN
    MATCH_MP_TAC OPEN_INTERS THEN
    ASM_SIMP_TAC[FORALL_IN_IMAGE; FINITE_IMAGE; FINITE_RESTRICT] THEN
    REWRITE_TAC[OPEN_HALFSPACE_LT];
    ALL_TAC] THEN
  ASM_REWRITE_TAC[IN_RELATIVE_INTERIOR] THEN
  ASM_SIMP_TAC[IN_INTERS; FORALL_IN_GSPEC; IN_ELIM_THM; IN_INTER] THEN
  EXISTS_TAC `e:real` THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC lemma THEN X_GEN_TAC `i:real^N->bool` THEN STRIP_TAC THEN
  FIRST_ASSUM(fun th -> GEN_REWRITE_TAC (RAND_CONV o LAND_CONV) [th]) THEN
  MATCH_MP_TAC(SET_RULE
   `ae SUBSET as /\ ae SUBSET hs /\
    b INTER hs SUBSET fs
    ==> (b INTER ae) SUBSET (as INTER fs) INTER hs`) THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC HULL_MONO THEN
    REWRITE_TAC[SUBSET; IN_INTERS; FORALL_IN_GSPEC] THEN ASM SET_TAC[];
    SIMP_TAC[SET_RULE `s SUBSET INTERS f <=> !t. t IN f ==> s SUBSET t`] THEN
    REWRITE_TAC[FORALL_IN_GSPEC] THEN X_GEN_TAC `j:real^N->bool` THEN
    STRIP_TAC THEN MATCH_MP_TAC HULL_MINIMAL THEN
    REWRITE_TAC[AFFINE_HYPERPLANE] THEN
    REWRITE_TAC[SUBSET; IN_INTERS; FORALL_IN_GSPEC] THEN ASM SET_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[SET_RULE `s SUBSET INTERS f <=> !t. t IN f ==> s SUBSET t`] THEN
  X_GEN_TAC `j:real^N->bool` THEN DISCH_TAC THEN
  SUBGOAL_THEN `(a:(real^N->bool)->real^N) j dot z <= b j` MP_TAC THENL
   [ASM SET_TAC[]; REWRITE_TAC[REAL_LE_LT]] THEN
  STRIP_TAC THENL [ASM SET_TAC[REAL_LT_IMP_LE]; ALL_TAC] THEN
  MATCH_MP_TAC(SET_RULE
  `(?s. s IN f /\ s SUBSET t) ==> u INTER INTERS f SUBSET t`) THEN
  REWRITE_TAC[EXISTS_IN_GSPEC] THEN EXISTS_TAC `j:real^N->bool` THEN
  ASM SET_TAC[REAL_LE_REFL]);;

(* ------------------------------------------------------------------------- *)
(* More general corollaries from the explicit representation.                *)
(* ------------------------------------------------------------------------- *)

let FACET_OF_POLYHEDRON = prove
 (`!s:real^N->bool c.
        polyhedron s /\ c facet_of s
        ==> ?a b. ~(a = vec 0) /\
                  s SUBSET {x | a dot x <= b} /\
                  c = s INTER {x | a dot x = b}`,
  REPEAT STRIP_TAC THEN FIRST_ASSUM
   (MP_TAC o GEN_REWRITE_RULE I [POLYHEDRON_INTER_AFFINE_MINIMAL]) THEN
  GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV)
   [RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  SIMP_TAC[LEFT_IMP_EXISTS_THM; RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
        FACET_OF_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[] THEN ASM_MESON_TAC[]; ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `c:real^N->bool`) THEN ASM_REWRITE_TAC[] THEN
  DISCH_THEN(X_CHOOSE_THEN `i:real^N->bool` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `(a:(real^N->bool)->real^N) i` THEN
  EXISTS_TAC `(b:(real^N->bool)->real) i` THEN ASM_SIMP_TAC[] THEN
  FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC LAND_CONV [th]) THEN
  MATCH_MP_TAC(SET_RULE `t SUBSET u ==> (s INTER t) SUBSET u`) THEN
  MATCH_MP_TAC(SET_RULE `t IN f ==> INTERS f SUBSET t`) THEN ASM_MESON_TAC[]);;

let FACE_OF_POLYHEDRON = prove
 (`!s:real^N->bool c.
        polyhedron s /\ c face_of s /\ ~(c = {}) /\ ~(c = s)
        ==> c = INTERS {f | f facet_of s /\ c SUBSET f}`,
  REPEAT STRIP_TAC THEN FIRST_ASSUM
   (MP_TAC o GEN_REWRITE_RULE I [POLYHEDRON_INTER_AFFINE_MINIMAL]) THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  SIMP_TAC[LEFT_IMP_EXISTS_THM; RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         FACET_OF_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[] THEN ASM_MESON_TAC[]; ALL_TAC] THEN
  DISCH_THEN(fun th -> REWRITE_TAC[th]) THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         FACE_OF_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[] THEN ASM_MESON_TAC[]; ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `c:real^N->bool`) THEN ASM_REWRITE_TAC[] THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC LAND_CONV [th]) THEN
  AP_TERM_TAC THEN GEN_REWRITE_TAC I [EXTENSION] THEN
  X_GEN_TAC `h:real^N->bool` THEN REWRITE_TAC[IN_ELIM_THM] THEN MESON_TAC[]);;

let FACE_OF_POLYHEDRON_SUBSET_FACET = prove
 (`!s:real^N->bool c.
        polyhedron s /\ c face_of s /\ ~(c = {}) /\ ~(c = s)
        ==> ?f. f facet_of s /\ c SUBSET f`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP FACE_OF_IMP_SUBSET) THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `c:real^N->bool`] FACE_OF_POLYHEDRON) THEN
  ASM_CASES_TAC `{f:real^N->bool | f facet_of s /\ c SUBSET f} = {}` THEN
  ASM SET_TAC[]);;

let FACE_OF_POLYHEDRON_FACE_OF_FACET = prove
 (`!s c:real^N->bool.
        polyhedron s /\ c face_of s /\ ~(c = {}) /\ ~(c = s)
        ==> ?f. c face_of f /\ f facet_of s`,
  REPEAT STRIP_TAC THEN MP_TAC(ISPECL [`s:real^N->bool`; `c:real^N->bool`]
        FACE_OF_POLYHEDRON_SUBSET_FACET) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC MONO_EXISTS THEN REPEAT STRIP_TAC THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC FACE_OF_SUBSET THEN
  EXISTS_TAC `s:real^N->bool` THEN ASM_SIMP_TAC[FACET_OF_IMP_SUBSET]);;

let EXPOSED_FACE_OF_POLYHEDRON = prove
 (`!s f:real^N->bool. polyhedron s ==> (f exposed_face_of s <=> f face_of s)`,
  REPEAT STRIP_TAC THEN EQ_TAC THENL [SIMP_TAC[exposed_face_of]; ALL_TAC] THEN
  DISCH_TAC THEN ASM_CASES_TAC `f:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[EMPTY_EXPOSED_FACE_OF] THEN
  ASM_CASES_TAC `f:real^N->bool = s` THEN
  ASM_SIMP_TAC[EXPOSED_FACE_OF_REFL; POLYHEDRON_IMP_CONVEX] THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:real^N->bool`] FACE_OF_POLYHEDRON) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN SUBST1_TAC THEN
  MATCH_MP_TAC EXPOSED_FACE_OF_INTERS THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; FORALL_IN_GSPEC] THEN
  ASM_SIMP_TAC[FACE_OF_POLYHEDRON_SUBSET_FACET; IN_ELIM_THM] THEN
  ASM_SIMP_TAC[exposed_face_of; FACET_OF_IMP_FACE_OF] THEN
  ASM_MESON_TAC[FACET_OF_POLYHEDRON]);;

let FACE_OF_POLYHEDRON_POLYHEDRON = prove
 (`!s:real^N->bool c. polyhedron s /\ c face_of s ==> polyhedron c`,
  REPEAT STRIP_TAC THEN FIRST_ASSUM
   (MP_TAC o GEN_REWRITE_RULE I [POLYHEDRON_INTER_AFFINE_MINIMAL]) THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  SIMP_TAC[LEFT_IMP_EXISTS_THM; RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         FACE_OF_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[] THEN ASM_MESON_TAC[]; ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `c:real^N->bool`) THEN ASM_REWRITE_TAC[] THEN
  ASM_CASES_TAC `c:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[POLYHEDRON_EMPTY] THEN
  ASM_CASES_TAC `c:real^N->bool = s` THEN ASM_REWRITE_TAC[] THEN
  DISCH_THEN SUBST1_TAC THEN MATCH_MP_TAC POLYHEDRON_INTERS THEN
  REWRITE_TAC[FORALL_IN_GSPEC] THEN
  ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
  ASM_SIMP_TAC[FINITE_IMAGE; FINITE_RESTRICT] THEN
  REPEAT STRIP_TAC THEN REWRITE_TAC[IMAGE_ID] THEN
  MATCH_MP_TAC POLYHEDRON_INTER THEN
  ASM_REWRITE_TAC[POLYHEDRON_HYPERPLANE]);;

let FINITE_POLYHEDRON_FACES = prove
 (`!s:real^N->bool. polyhedron s ==> FINITE {f | f face_of s}`,
  REPEAT STRIP_TAC THEN FIRST_ASSUM
   (MP_TAC o GEN_REWRITE_RULE I [POLYHEDRON_INTER_AFFINE_MINIMAL]) THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  SIMP_TAC[LEFT_IMP_EXISTS_THM; RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  STRIP_TAC THEN
  MATCH_MP_TAC(MESON[FINITE_DELETE]
   `!a b. FINITE (s DELETE a DELETE b) ==> FINITE s`) THEN
  MAP_EVERY EXISTS_TAC [`{}:real^N->bool`; `s:real^N->bool`] THEN
  MATCH_MP_TAC FINITE_SUBSET THEN
  EXISTS_TAC
   `{INTERS {s INTER {x:real^N | a(h:real^N->bool) dot x = b h} | h | h IN f'}
    |f'| f' SUBSET f}` THEN
  GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [SIMPLE_IMAGE_GEN] THEN
  ASM_SIMP_TAC[FINITE_POWERSET; FINITE_IMAGE] THEN
  GEN_REWRITE_TAC I [SUBSET] THEN REWRITE_TAC[IN_DELETE; IN_ELIM_THM] THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
         FACE_OF_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL [ASM_REWRITE_TAC[] THEN ASM_MESON_TAC[]; ALL_TAC] THEN
  MATCH_MP_TAC MONO_FORALL THEN X_GEN_TAC `c:real^N->bool` THEN
  DISCH_THEN(fun th -> STRIP_TAC THEN MP_TAC th) THEN ASM_REWRITE_TAC[] THEN
  DISCH_TAC THEN EXISTS_TAC
   `{h:real^N->bool |
     h IN f /\ c SUBSET s INTER {x:real^N | a h dot x = b h}}` THEN
  CONJ_TAC THENL [SET_TAC[]; ALL_TAC] THEN
  ASM_REWRITE_TAC[IN_ELIM_THM] THEN FIRST_ASSUM ACCEPT_TAC);;

let FINITE_POLYHEDRON_EXPOSED_FACES = prove
 (`!s:real^N->bool. polyhedron s ==> FINITE {f | f exposed_face_of s}`,
  SIMP_TAC[EXPOSED_FACE_OF_POLYHEDRON; FINITE_POLYHEDRON_FACES]);;

let FINITE_POLYHEDRON_EXTREME_POINTS = prove
 (`!s:real^N->bool. polyhedron s ==> FINITE {v | v extreme_point_of s}`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM FACE_OF_SING] THEN
  ONCE_REWRITE_TAC[SET_RULE `{v} face_of s <=> {v} IN {f | f face_of s}`] THEN
  MATCH_MP_TAC FINITE_FINITE_PREIMAGE THEN
  ASM_SIMP_TAC[FINITE_POLYHEDRON_FACES] THEN X_GEN_TAC `f:real^N->bool` THEN
  DISCH_TAC THEN ASM_CASES_TAC `!a:real^N. ~({a} = f)` THEN
  ASM_REWRITE_TAC[EMPTY_GSPEC; FINITE_EMPTY] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [NOT_FORALL_THM]) THEN
  REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  GEN_TAC THEN DISCH_THEN(SUBST1_TAC o SYM) THEN
  REWRITE_TAC[SET_RULE `{v | {v} = {a}} = {a}`; FINITE_SING]);;

let FINITE_POLYHEDRON_FACETS = prove
 (`!s:real^N->bool. polyhedron s ==> FINITE {f | f facet_of s}`,
  REWRITE_TAC[facet_of] THEN ONCE_REWRITE_TAC[SET_RULE
   `{x | P x /\ Q x} = {x | x IN {x | P x} /\ Q x}`] THEN
  SIMP_TAC[FINITE_RESTRICT; FINITE_POLYHEDRON_FACES]);;

let RELATIVE_INTERIOR_OF_POLYHEDRON = prove
 (`!s:real^N->bool.
        polyhedron s
        ==> relative_interior s = s DIFF UNIONS {f | f facet_of s}`,
  REPEAT STRIP_TAC THEN FIRST_ASSUM
   (MP_TAC o GEN_REWRITE_RULE I [POLYHEDRON_INTER_AFFINE_MINIMAL]) THEN
  GEN_REWRITE_TAC (LAND_CONV o TOP_DEPTH_CONV)
   [RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  SIMP_TAC[LEFT_IMP_EXISTS_THM; RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  STRIP_TAC THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
        FACET_OF_POLYHEDRON_EXPLICIT) THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `f:(real^N->bool)->bool`;
                 `a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`]
        RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT) THEN
  ASM_REWRITE_TAC[] THEN
  ANTS_TAC THENL [ASM_MESON_TAC[]; DISCH_THEN SUBST1_TAC] THEN
  ANTS_TAC THENL [ASM_MESON_TAC[]; DISCH_TAC] THEN
  ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(SET_RULE
   `(!x. x IN s ==> P x \/ x IN t) /\ (!x. x IN t ==> ~P x)
    ==> {x | x IN s /\ P x} = s DIFF t`) THEN
  REWRITE_TAC[FORALL_IN_UNIONS] THEN
  REWRITE_TAC[RIGHT_FORALL_IMP_THM; IMP_CONJ; FORALL_IN_GSPEC] THEN
  CONJ_TAC THENL
   [X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
    REWRITE_TAC[IN_UNIONS; IN_ELIM_THM] THEN
    REWRITE_TAC[LEFT_AND_EXISTS_THM; TAUT `(a /\ b) /\ c <=> b /\ a /\ c`] THEN
    ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN
    ASM_REWRITE_TAC[UNWIND_THM2; IN_ELIM_THM; IN_INTER] THEN
    MATCH_MP_TAC(SET_RULE
     `(!x. P x ==> Q x \/ R x) ==> (!x. P x ==> Q x) \/ (?x. P x /\ R x)`) THEN
    X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
    REWRITE_TAC[GSYM REAL_LE_LT] THEN
    SUBGOAL_THEN `(x:real^N) IN INTERS f` MP_TAC THENL
     [ASM SET_TAC[]; ALL_TAC] THEN
    REWRITE_TAC[IN_INTERS] THEN
    DISCH_THEN(MP_TAC o SPEC `h:real^N->bool`) THEN
    SUBGOAL_THEN `h = {x:real^N | a h dot x <= b h}` MP_TAC THENL
     [ASM_MESON_TAC[]; ASM_REWRITE_TAC[] THEN SET_TAC[]];
    X_GEN_TAC `h:real^N->bool` THEN
    DISCH_THEN(X_CHOOSE_THEN `g:real^N->bool` STRIP_ASSUME_TAC) THEN
    X_GEN_TAC `x:real^N` THEN ASM_REWRITE_TAC[IN_INTER; IN_ELIM_THM] THEN
    ASM_MESON_TAC[REAL_LT_REFL]]);;

let RELATIVE_BOUNDARY_OF_POLYHEDRON = prove
 (`!s:real^N->bool.
        polyhedron s
        ==> s DIFF relative_interior s = UNIONS {f | f facet_of s}`,
  REPEAT STRIP_TAC THEN ASM_SIMP_TAC[RELATIVE_INTERIOR_OF_POLYHEDRON] THEN
  MATCH_MP_TAC(SET_RULE `f SUBSET s ==> s DIFF (s DIFF f) = f`) THEN
  REWRITE_TAC[SUBSET; FORALL_IN_UNIONS; IN_ELIM_THM] THEN
  MESON_TAC[FACET_OF_IMP_SUBSET; SUBSET]);;

let RELATIVE_FRONTIER_OF_POLYHEDRON = prove
 (`!s:real^N->bool.
        polyhedron s ==> relative_frontier s = UNIONS {f | f facet_of s}`,
  SIMP_TAC[relative_frontier; POLYHEDRON_IMP_CLOSED; CLOSURE_CLOSED] THEN
  REWRITE_TAC[RELATIVE_BOUNDARY_OF_POLYHEDRON]);;

let RELATIVE_FRONTIER_OF_POLYHEDRON_ALT = prove
 (`!s:real^N->bool.
        polyhedron s
        ==> relative_frontier s = UNIONS {f | f face_of s /\ ~(f = s)}`,
  ASM_SIMP_TAC[RELATIVE_FRONTIER_OF_CONVEX_CLOSED;
               POLYHEDRON_IMP_CLOSED; POLYHEDRON_IMP_CONVEX]);;

let FACETS_OF_POLYHEDRON_EXPLICIT_DISTINCT = prove
 (`!s:real^N->bool f a b.
        FINITE f /\
        s = affine hull s INTER INTERS f /\
        (!h. h IN f ==> ~(a h = vec 0) /\ h = {x | a h dot x <= b h}) /\
        (!f'. f' PSUBSET f ==> s PSUBSET affine hull s INTER INTERS f')
        ==> !h1 h2. h1 IN f /\ h2 IN f /\
                    s INTER {x | a h1 dot x = b h1} =
                    s INTER {x | a h2 dot x = b h2}
                    ==> h1 = h2`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THENL
   [ASM_REWRITE_TAC[AFFINE_HULL_EMPTY; INTER_EMPTY; PSUBSET_IRREFL] THEN
    ASM_CASES_TAC `f:(real^N->bool)->bool = {}` THEN
    ASM_REWRITE_TAC[NOT_IN_EMPTY] THEN
    ASM_MESON_TAC[SET_RULE `~(s = {}) ==> {} PSUBSET s`];
    STRIP_TAC] THEN
  SUBGOAL_THEN `polyhedron(s:real^N->bool)` ASSUME_TAC THENL
   [REWRITE_TAC[POLYHEDRON_INTER_AFFINE] THEN
    REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN ASM_MESON_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN `~(relative_interior s:real^N->bool = {})` MP_TAC THENL
   [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY; POLYHEDRON_IMP_CONVEX];
    REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_ELIM_THM] THEN
    DISCH_THEN(X_CHOOSE_THEN `z:real^N` MP_TAC)] THEN
  DISCH_THEN(fun th -> ASSUME_TAC th THEN MP_TAC th) THEN
  MP_TAC(ISPECL
    [`s:real^N->bool`; `f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
     `b:(real^N->bool)->real`] RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[] THEN ASM_MESON_TAC[]; DISCH_THEN SUBST1_TAC] THEN
  REWRITE_TAC[IN_ELIM_THM] THEN REPEAT STRIP_TAC THEN
  MATCH_MP_TAC(TAUT `(~p ==> F) ==> p`) THEN DISCH_TAC THEN
  FIRST_ASSUM(MP_TAC o SPEC `f DELETE (h2:real^N->bool)`) THEN
  ANTS_TAC THENL [ASM SET_TAC[]; REWRITE_TAC[PSUBSET_ALT]] THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC (X_CHOOSE_THEN `x:real^N` MP_TAC)) THEN
  REWRITE_TAC[IN_INTER; IN_INTERS; IN_DELETE] THEN STRIP_TAC THEN
  MP_TAC(ISPECL [`segment[x:real^N,z]`; `s:real^N->bool`]
        CONNECTED_INTER_RELATIVE_FRONTIER) THEN
  PURE_REWRITE_TAC[relative_frontier] THEN ANTS_TAC THENL
   [REWRITE_TAC[CONNECTED_SEGMENT; GSYM MEMBER_NOT_EMPTY] THEN
    REPEAT CONJ_TAC THENL
     [ASM_MESON_TAC[CONVEX_CONTAINS_SEGMENT; AFFINE_AFFINE_HULL;
                    HULL_INC; AFFINE_IMP_CONVEX];
      EXISTS_TAC `z:real^N` THEN ASM_REWRITE_TAC[IN_INTER; ENDS_IN_SEGMENT];
      EXISTS_TAC `x:real^N` THEN ASM_REWRITE_TAC[IN_DIFF; ENDS_IN_SEGMENT]];
    ALL_TAC] THEN
  PURE_REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] THEN
  ASM_SIMP_TAC[POLYHEDRON_IMP_CLOSED; CLOSURE_CLOSED;
         LEFT_IMP_EXISTS_THM; IN_INTER] THEN
  X_GEN_TAC `y:real^N` THEN DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  DISCH_THEN(fun th -> STRIP_ASSUME_TAC(REWRITE_RULE[IN_DIFF] th) THEN
        MP_TAC th) THEN
  ASM_SIMP_TAC[RELATIVE_BOUNDARY_OF_POLYHEDRON] THEN
  MP_TAC(ISPECL
    [`s:real^N->bool`; `f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
     `b:(real^N->bool)->real`] FACET_OF_POLYHEDRON_EXPLICIT) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[] THEN ASM_MESON_TAC[];
    DISCH_THEN(fun th -> ONCE_REWRITE_TAC[th])] THEN
  REWRITE_TAC[SET_RULE `{y | ?x. x IN s /\ y = f x} = IMAGE f s`] THEN
  REWRITE_TAC[UNIONS_IMAGE; IN_ELIM_THM; IN_INTER] THEN
  DISCH_THEN(X_CHOOSE_THEN `h:real^N->bool` STRIP_ASSUME_TAC) THEN
  SUBGOAL_THEN
   `?k:real^N->bool. k IN f /\ ~(k = h2) /\ a k dot (y:real^N) = b k`
  STRIP_ASSUME_TAC THENL
   [ASM_CASES_TAC `h:real^N->bool = h2` THENL
     [EXISTS_TAC `h1:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
      UNDISCH_TAC `s INTER {x:real^N | a(h1:real^N->bool) dot x = b h1} =
                   s INTER {x | a h2 dot x = b h2}` THEN
      REWRITE_TAC[EXTENSION; IN_INTER; IN_ELIM_THM] THEN ASM_MESON_TAC[];
      ASM_MESON_TAC[]];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `(a:(real^N->bool)->real^N) k dot z < b k /\ a k dot x <= b k`
  STRIP_ASSUME_TAC THENL [ASM_SIMP_TAC[] THEN ASM SET_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN `y IN segment(x:real^N,z)` MP_TAC THENL
   [ASM_REWRITE_TAC[IN_OPEN_SEGMENT_ALT] THEN ASM_MESON_TAC[];
    REWRITE_TAC[IN_SEGMENT] THEN STRIP_TAC] THEN
  UNDISCH_TAC `(a:(real^N->bool)->real^N) k dot y = b k` THEN
  ASM_REWRITE_TAC[DOT_RADD; DOT_RMUL] THEN
  MATCH_MP_TAC(REAL_ARITH
   `(&1 - u) * x <= (&1 - u) * b /\ u * y < u * b
    ==> ~((&1 - u) * x + u * y = b)`) THEN
  ASM_SIMP_TAC[REAL_LT_LMUL_EQ; REAL_LE_LMUL_EQ; REAL_SUB_LT]);;

let POLYHEDRON_MINIMAL_LEMMA = prove
 (`!f s:real^N->bool.
        FINITE f /\
        affine hull s INTER INTERS f = s
        ==> ?f'. FINITE f' /\ f' SUBSET f /\
                 affine hull s INTER INTERS f' = s /\
                 (!f''. f'' PSUBSET f'
                        ==> s PSUBSET affine hull s INTER INTERS f'')`,
  REPEAT GEN_TAC THEN
  WF_INDUCT_TAC `CARD(f:(real^N->bool)->bool)` THEN STRIP_TAC THEN
  ASM_CASES_TAC
   `!f'. f' PSUBSET f
         ==> (s:real^N->bool) PSUBSET affine hull s INTER INTERS f'`
  THENL [ASM_MESON_TAC[SUBSET_REFL]; ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [NOT_FORALL_THM]) THEN
  REWRITE_TAC[NOT_IMP; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `f':(real^N->bool)->bool` THEN STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `f':(real^N->bool)->bool`) THEN
  ASM_SIMP_TAC[CARD_PSUBSET] THEN ANTS_TAC THENL
   [CONJ_TAC THENL [ASM_MESON_TAC[FINITE_SUBSET; PSUBSET]; ALL_TAC] THEN
    MATCH_MP_TAC(SET_RULE `t SUBSET s /\ ~(t PSUBSET s) ==> s = t`) THEN
    ASM_REWRITE_TAC[] THEN
    TRANS_TAC SUBSET_TRANS `affine hull s INTER INTERS f:real^N->bool` THEN
    CONJ_TAC THENL [ASM_REWRITE_TAC[SUBSET_REFL]; ASM SET_TAC[]];
    MATCH_MP_TAC MONO_EXISTS THEN SIMP_TAC[] THEN ASM SET_TAC[]]);;

let POLYHEDRON = prove
 (`!s. polyhedron s <=>
        ?f. FINITE f /\
            affine hull s INTER INTERS f = s /\
            (!f'. f' PSUBSET f ==> s PSUBSET affine hull s INTER INTERS f') /\
            (!h. h IN f
                 ==> (?a:real^N b. ~(a = vec 0) /\ h = {x | a dot x <= b}))`,
  GEN_TAC THEN REWRITE_TAC[polyhedron] THEN EQ_TAC THENL
   [DISCH_THEN(X_CHOOSE_THEN `f:(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
    MP_TAC(ISPECL [`f:(real^N->bool)->bool`; `s:real^N->bool`]
        POLYHEDRON_MINIMAL_LEMMA) THEN
    ANTS_TAC THENL
     [CONJ_TAC THENL [FIRST_ASSUM ACCEPT_TAC; ALL_TAC] THEN
      MATCH_MP_TAC(SET_RULE
       `s SUBSET t /\ u = s ==> t INTER u = s`) THEN
      REWRITE_TAC[HULL_SUBSET] THEN ASM_MESON_TAC[];
      MATCH_MP_TAC MONO_EXISTS THEN SIMP_TAC[] THEN ASM SET_TAC[]];
    DISCH_THEN(X_CHOOSE_THEN `f':(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
    MP_TAC(ISPEC `affine hull s:real^N->bool` AFFINE_IMP_POLYHEDRON) THEN
    REWRITE_TAC[polyhedron; AFFINE_AFFINE_HULL] THEN
    DISCH_THEN(X_CHOOSE_THEN `f'':(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
    EXISTS_TAC `f' UNION f'':(real^N->bool)->bool` THEN
    ASM_REWRITE_TAC[FINITE_UNION; FORALL_IN_UNION; INTERS_UNION] THEN
    ASM SET_TAC[]]);;

(* ------------------------------------------------------------------------- *)
(* A characterization of polyhedra as having finitely many faces.            *)
(* ------------------------------------------------------------------------- *)

let POLYHEDRON_EQ_FINITE_EXPOSED_FACES = prove
 (`!s:real^N->bool.
    polyhedron s <=> closed s /\ convex s /\ FINITE {f | f exposed_face_of s}`,
  GEN_TAC THEN EQ_TAC THEN STRIP_TAC THEN
  ASM_SIMP_TAC[POLYHEDRON_IMP_CLOSED; POLYHEDRON_IMP_CONVEX;
               FINITE_POLYHEDRON_EXPOSED_FACES] THEN
  ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[POLYHEDRON_EMPTY] THEN
  ABBREV_TAC
   `f = {h:real^N->bool | h exposed_face_of s /\ ~(h = {}) /\ ~(h = s)}` THEN
  SUBGOAL_THEN `FINITE(f:(real^N->bool)->bool)` ASSUME_TAC THENL
   [EXPAND_TAC "f" THEN
    ONCE_REWRITE_TAC[SET_RULE
     `{x | P x /\ Q x} = {x | x IN {x | P x} /\ Q x}`] THEN
    ASM_SIMP_TAC[FINITE_RESTRICT];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `!h:real^N->bool.
        h IN f
        ==> h face_of s /\
            ?a b. ~(a = vec 0) /\
                  s SUBSET {x | a dot x <= b} /\
                  h = s INTER {x | a dot x = b}`
  MP_TAC THENL
   [EXPAND_TAC "f" THEN REWRITE_TAC[EXPOSED_FACE_OF; IN_ELIM_THM] THEN
    MESON_TAC[];
    ALL_TAC] THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM; FORALL_AND_THM;
              TAUT `a ==> b /\ c <=> (a ==> b) /\ (a ==> c)`] THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  DISCH_THEN(X_CHOOSE_THEN `a:(real^N->bool)->real^N` MP_TAC) THEN
  DISCH_THEN(X_CHOOSE_THEN `b:(real^N->bool)->real` STRIP_ASSUME_TAC) THEN
  SUBGOAL_THEN
   `s = affine hull s INTER
        INTERS {{x:real^N | a(h:real^N->bool) dot x <= b h} | h IN f}`
  SUBST1_TAC THENL
   [ALL_TAC;
    MATCH_MP_TAC POLYHEDRON_INTER THEN REWRITE_TAC[POLYHEDRON_AFFINE_HULL] THEN
    MATCH_MP_TAC POLYHEDRON_INTERS THEN ONCE_REWRITE_TAC[SIMPLE_IMAGE] THEN
    ASM_SIMP_TAC[FINITE_IMAGE; FORALL_IN_IMAGE; POLYHEDRON_HALFSPACE_LE]] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN
  REWRITE_TAC[SUBSET_INTER; HULL_SUBSET;
              SET_RULE `s SUBSET INTERS f <=> !h. h IN f ==> s SUBSET h`] THEN
  ASM_REWRITE_TAC[FORALL_IN_GSPEC] THEN
  REWRITE_TAC[SUBSET; IN_INTER; IN_INTERS; FORALL_IN_GSPEC] THEN
  X_GEN_TAC `p:real^N` THEN REWRITE_TAC[IN_ELIM_THM] THEN DISCH_TAC THEN
  MATCH_MP_TAC(TAUT `(~p ==> F) ==> p`) THEN DISCH_TAC THEN
  SUBGOAL_THEN `~(relative_interior(s:real^N->bool) = {})` MP_TAC THENL
   [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY];
    GEN_REWRITE_TAC LAND_CONV [GSYM MEMBER_NOT_EMPTY] THEN
    DISCH_THEN(X_CHOOSE_TAC `c:real^N`)] THEN
  SUBGOAL_THEN
   `?x:real^N. x IN segment[c,p] /\ x IN (s DIFF relative_interior s)`
  MP_TAC THENL
   [MP_TAC(ISPEC `segment[c:real^N,p]` CONNECTED_OPEN_IN) THEN
    REWRITE_TAC[CONNECTED_SEGMENT; NOT_EXISTS_THM] THEN
    DISCH_THEN(MP_TAC o SPECL
     [`segment[c:real^N,p] INTER relative_interior s`;
      `segment[c:real^N,p] INTER (UNIV DIFF s)`]) THEN
    ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN
    REWRITE_TAC[IN_DIFF; NOT_EXISTS_THM] THEN DISCH_TAC THEN
    REPEAT CONJ_TAC THENL
     [MATCH_MP_TAC OPEN_IN_SUBTOPOLOGY_INTER_SUBSET THEN
      EXISTS_TAC `affine hull s:real^N->bool` THEN
      SIMP_TAC[OPEN_IN_RELATIVE_INTERIOR; TOPSPACE_EUCLIDEAN_SUBTOPOLOGY;
        OPEN_IN_SUBTOPOLOGY_REFL; SUBSET_UNIV; OPEN_IN_INTER;
        TOPSPACE_EUCLIDEAN] THEN
      REWRITE_TAC[SEGMENT_CONVEX_HULL] THEN MATCH_MP_TAC HULL_MINIMAL THEN
      SIMP_TAC[AFFINE_IMP_CONVEX; AFFINE_AFFINE_HULL] THEN
      ASM_REWRITE_TAC[INSERT_SUBSET; EMPTY_SUBSET] THEN
      ASM_MESON_TAC[RELATIVE_INTERIOR_SUBSET; HULL_INC; SUBSET];
      REWRITE_TAC[OPEN_IN_OPEN] THEN EXISTS_TAC `(:real^N) DIFF s` THEN
      ASM_REWRITE_TAC[GSYM closed];
     MP_TAC(ISPEC `s:real^N->bool` RELATIVE_INTERIOR_SUBSET) THEN ASM SET_TAC[];
     MP_TAC(ISPEC `s:real^N->bool` RELATIVE_INTERIOR_SUBSET) THEN SET_TAC[];
      REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_INTER] THEN
      ASM_MESON_TAC[ENDS_IN_SEGMENT];
      REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_DIFF; IN_INTER; IN_UNIV] THEN
      ASM_MESON_TAC[ENDS_IN_SEGMENT]];
    REWRITE_TAC[IN_SEGMENT; LEFT_AND_EXISTS_THM] THEN
    ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN
    REWRITE_TAC[GSYM CONJ_ASSOC; RIGHT_EXISTS_AND_THM; UNWIND_THM2] THEN
    DISCH_THEN(X_CHOOSE_THEN `l:real` MP_TAC) THEN
    ASM_CASES_TAC `l = &0` THEN
    ASM_REWRITE_TAC[VECTOR_ADD_RID; VECTOR_MUL_LZERO; REAL_SUB_RZERO;
                    VECTOR_MUL_LID; IN_DIFF] THEN
    ASM_CASES_TAC `l = &1` THEN
    ASM_REWRITE_TAC[VECTOR_ADD_LID; VECTOR_MUL_LZERO; REAL_SUB_REFL;
                    VECTOR_MUL_LID; IN_DIFF] THEN
    ASM_REWRITE_TAC[REAL_LE_LT] THEN STRIP_TAC] THEN
  ABBREV_TAC `x:real^N = (&1 - l) % c + l % p` THEN
  SUBGOAL_THEN `?h:real^N->bool. h IN f /\ x IN h` STRIP_ASSUME_TAC THENL
   [MP_TAC(ISPECL [`s:real^N->bool`; `(&1 - l) % c + l % p:real^N`]
      SUPPORTING_HYPERPLANE_RELATIVE_FRONTIER) THEN
    REWRITE_TAC[relative_frontier; IN_DIFF] THEN
    ASM_SIMP_TAC[REWRITE_RULE[SUBSET] CLOSURE_SUBSET] THEN
    DISCH_THEN(X_CHOOSE_THEN `d:real^N` STRIP_ASSUME_TAC) THEN
    EXPAND_TAC "f" THEN
    EXISTS_TAC `s INTER {y:real^N | d dot y = d dot x}` THEN
    ASM_REWRITE_TAC[IN_INTER; IN_ELIM_THM] THEN REPEAT CONJ_TAC THENL
     [MATCH_MP_TAC EXPOSED_FACE_OF_INTER_SUPPORTING_HYPERPLANE_GE THEN
      ASM_SIMP_TAC[real_ge; REWRITE_RULE[SUBSET] CLOSURE_SUBSET];
      ASM SET_TAC[];
      REWRITE_TAC[EXTENSION; IN_INTER; IN_ELIM_THM] THEN
      DISCH_THEN(MP_TAC o SPEC `c:real^N`) THEN
      ASM_MESON_TAC[SUBSET; REAL_LT_REFL; RELATIVE_INTERIOR_SUBSET]];
    ALL_TAC] THEN
  SUBGOAL_THEN `{y:real^N | a(h:real^N->bool) dot y = b h} face_of
                {y | a h dot y <= b h}`
  MP_TAC THENL
   [MATCH_MP_TAC(MESON[]
     `(t INTER s) face_of t /\ t INTER s = s ==> s face_of t`) THEN
    CONJ_TAC THENL
     [MATCH_MP_TAC FACE_OF_INTER_SUPPORTING_HYPERPLANE_LE THEN
      REWRITE_TAC[IN_ELIM_THM; CONVEX_HALFSPACE_LE];
      SET_TAC[REAL_LE_REFL]];
    ALL_TAC] THEN
  REWRITE_TAC[face_of] THEN
  DISCH_THEN(MP_TAC o SPECL [`c:real^N`; `p:real^N`; `x:real^N`] o
        CONJUNCT2 o CONJUNCT2) THEN
  ASM_SIMP_TAC[IN_ELIM_THM; NOT_IMP; GSYM CONJ_ASSOC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP (REWRITE_RULE[SUBSET]
      RELATIVE_INTERIOR_SUBSET)) THEN
  REPEAT CONJ_TAC THENL
   [ASM SET_TAC[];
    ASM SET_TAC[];
    REWRITE_TAC[IN_SEGMENT] THEN ASM SET_TAC[];
    STRIP_TAC] THEN
  MP_TAC(ISPECL [`s:real^N->bool`; `h:real^N->bool`; `s:real^N->bool`]
        SUBSET_OF_FACE_OF) THEN
  ASM SET_TAC[]);;

let POLYHEDRON_EQ_FINITE_FACES = prove
 (`!s:real^N->bool.
        polyhedron s <=>
        closed s /\ convex s /\ FINITE {f | f face_of s}`,
  GEN_TAC THEN EQ_TAC THEN STRIP_TAC THEN
  ASM_SIMP_TAC[POLYHEDRON_IMP_CLOSED; POLYHEDRON_IMP_CONVEX;
               FINITE_POLYHEDRON_FACES] THEN
  REWRITE_TAC[POLYHEDRON_EQ_FINITE_EXPOSED_FACES] THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC FINITE_SUBSET THEN
  EXISTS_TAC `{f:real^N->bool | f face_of s}` THEN
  ASM_REWRITE_TAC[] THEN
  SIMP_TAC[SUBSET; IN_ELIM_THM; exposed_face_of]);;

let POLYHEDRON_TRANSLATION_EQ = prove
 (`!a s. polyhedron (IMAGE (\x:real^N. a + x) s) <=> polyhedron s`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[POLYHEDRON_EQ_FINITE_FACES] THEN
  REWRITE_TAC[CLOSED_TRANSLATION_EQ] THEN AP_TERM_TAC THEN
  REWRITE_TAC[CONVEX_TRANSLATION_EQ] THEN AP_TERM_TAC THEN
  MP_TAC(ISPEC `IMAGE (\x:real^N. a + x)` QUANTIFY_SURJECTION_THM) THEN
  REWRITE_TAC[SURJECTIVE_IMAGE; EXISTS_REFL;
    VECTOR_ARITH `a + x:real^N = y <=> x = y - a`] THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th]) THEN
  REWRITE_TAC[FACE_OF_TRANSLATION_EQ] THEN
  MATCH_MP_TAC FINITE_IMAGE_INJ_EQ THEN
  MATCH_MP_TAC(MESON[]
   `(!x y. Q x y ==> R x y) ==> (!x y. P x /\ P y /\ Q x y ==> R x y)`) THEN
  REWRITE_TAC[INJECTIVE_IMAGE] THEN VECTOR_ARITH_TAC);;

add_translation_invariants [POLYHEDRON_TRANSLATION_EQ];;

let POLYHEDRON_LINEAR_IMAGE_EQ = prove
 (`!f:real^M->real^N s.
        linear f /\ (!x y. f x = f y ==> x = y) /\ (!y. ?x. f x = y)
        ==> (polyhedron (IMAGE f s) <=> polyhedron s)`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[POLYHEDRON_EQ_FINITE_FACES] THEN
  BINOP_TAC THENL
   [ASM_MESON_TAC[CLOSED_INJECTIVE_LINEAR_IMAGE_EQ]; ALL_TAC] THEN
  BINOP_TAC THENL [ASM_MESON_TAC[CONVEX_LINEAR_IMAGE_EQ]; ALL_TAC] THEN
  MP_TAC(ISPEC `IMAGE (f:real^M->real^N)` QUANTIFY_SURJECTION_THM) THEN
  ASM_REWRITE_TAC[SURJECTIVE_IMAGE] THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th]) THEN
  MP_TAC(ISPEC `f:real^M->real^N` FACE_OF_LINEAR_IMAGE) THEN
  ASM_REWRITE_TAC[] THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC FINITE_IMAGE_INJ_EQ THEN
  FIRST_ASSUM(ASSUME_TAC o GEN_REWRITE_RULE I [GSYM INJECTIVE_IMAGE]) THEN
  ASM_REWRITE_TAC[IMP_CONJ]);;

add_linear_invariants [POLYHEDRON_LINEAR_IMAGE_EQ];;

let POLYHEDRON_NEGATIONS = prove
 (`!s:real^N->bool. polyhedron s ==> polyhedron(IMAGE (--) s)`,
  GEN_TAC THEN MATCH_MP_TAC EQ_IMP THEN CONV_TAC SYM_CONV THEN
  MATCH_MP_TAC POLYHEDRON_LINEAR_IMAGE_EQ THEN
  REWRITE_TAC[VECTOR_ARITH `--x:real^N = y <=> x = --y`; EXISTS_REFL] THEN
  REWRITE_TAC[LINEAR_NEGATION] THEN VECTOR_ARITH_TAC);;

let POLYHEDRON_LINEAR_PREIMAGE = prove
 (`!f:real^M->real^N s.
        linear f /\ polyhedron s ==> polyhedron {x | f x IN s}`,
  let lemma = prove
   (`{x | f x IN INTERS s} = INTERS {{x | f x IN c} | c IN s}`,
    REWRITE_TAC[INTERS_GSPEC] THEN SET_TAC[]) in
  REPEAT GEN_TAC THEN
  GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [polyhedron] THEN
  STRIP_TAC THEN FIRST_X_ASSUM SUBST1_TAC THEN
  ONCE_REWRITE_TAC[lemma] THEN MATCH_MP_TAC POLYHEDRON_INTERS THEN
  ASM_SIMP_TAC[SIMPLE_IMAGE; FINITE_IMAGE; FORALL_IN_IMAGE] THEN
  X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
  ASM_REWRITE_TAC[] THEN STRIP_TAC THEN ASM_REWRITE_TAC[IN_ELIM_THM] THEN
  FIRST_X_ASSUM(fun th ->
    ONCE_REWRITE_TAC[GSYM(MATCH_MP ADJOINT_CLAUSES th)]) THEN
  REWRITE_TAC[POLYHEDRON_HALFSPACE_LE]);;

(* ------------------------------------------------------------------------- *)
(* Relation between polytopes and polyhedra.                                 *)
(* ------------------------------------------------------------------------- *)

let POLYTOPE_EQ_BOUNDED_POLYHEDRON = prove
 (`!s:real^N->bool. polytope s <=> polyhedron s /\ bounded s`,
  GEN_TAC THEN EQ_TAC THENL
   [SIMP_TAC[FINITE_POLYTOPE_FACES; POLYHEDRON_EQ_FINITE_FACES;
             POLYTOPE_IMP_CLOSED; POLYTOPE_IMP_CONVEX; POLYTOPE_IMP_BOUNDED];
    STRIP_TAC THEN REWRITE_TAC[polytope] THEN
    EXISTS_TAC `{v:real^N | v extreme_point_of s}` THEN
    ASM_SIMP_TAC[FINITE_POLYHEDRON_EXTREME_POINTS] THEN
    MATCH_MP_TAC KREIN_MILMAN_MINKOWSKI THEN
    ASM_SIMP_TAC[COMPACT_EQ_BOUNDED_CLOSED; POLYHEDRON_IMP_CLOSED;
                 POLYHEDRON_IMP_CONVEX]]);;

let POLYTOPE_INTER = prove
 (`!s t. polytope s /\ polytope t ==> polytope(s INTER t)`,
  SIMP_TAC[POLYTOPE_EQ_BOUNDED_POLYHEDRON; POLYHEDRON_INTER; BOUNDED_INTER]);;

let POLYTOPE_INTER_POLYHEDRON = prove
 (`!s t:real^N->bool. polytope s /\ polyhedron t ==> polytope(s INTER t)`,
  SIMP_TAC[POLYTOPE_EQ_BOUNDED_POLYHEDRON; POLYHEDRON_INTER] THEN
  MESON_TAC[BOUNDED_SUBSET; INTER_SUBSET]);;

let POLYHEDRON_INTER_POLYTOPE = prove
 (`!s t:real^N->bool. polyhedron s /\ polytope t ==> polytope(s INTER t)`,
  SIMP_TAC[POLYTOPE_EQ_BOUNDED_POLYHEDRON; POLYHEDRON_INTER] THEN
  MESON_TAC[BOUNDED_SUBSET; INTER_SUBSET]);;

let POLYTOPE_IMP_POLYHEDRON = prove
 (`!p. polytope p ==> polyhedron p`,
  SIMP_TAC[POLYTOPE_EQ_BOUNDED_POLYHEDRON]);;

let POLYTOPE_FACET_EXISTS = prove
 (`!p:real^N->bool. polytope p /\ &0 < aff_dim p ==> ?f. f facet_of p`,
  GEN_TAC THEN ASM_CASES_TAC `p:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[AFF_DIM_EMPTY] THEN CONV_TAC INT_REDUCE_CONV THEN
  STRIP_TAC THEN
  MP_TAC(ISPEC `p:real^N->bool` EXTREME_POINT_EXISTS_CONVEX) THEN
  ASM_SIMP_TAC[POLYTOPE_IMP_COMPACT; POLYTOPE_IMP_CONVEX] THEN
  DISCH_THEN(X_CHOOSE_TAC `v:real^N`) THEN
  MP_TAC(ISPECL [`p:real^N->bool`; `{v:real^N}`]
    FACE_OF_POLYHEDRON_SUBSET_FACET) THEN
  ANTS_TAC THENL [ALL_TAC; MESON_TAC[]] THEN
  ASM_SIMP_TAC[POLYTOPE_IMP_POLYHEDRON; FACE_OF_SING; NOT_INSERT_EMPTY] THEN
  ASM_MESON_TAC[AFF_DIM_SING; INT_LT_REFL]);;

let POLYHEDRON_INTERVAL = prove
 (`!a b. polyhedron(interval[a,b])`,
  MESON_TAC[POLYTOPE_IMP_POLYHEDRON; POLYTOPE_INTERVAL]);;

let POLYHEDRON_CONVEX_HULL = prove
 (`!s. FINITE s ==> polyhedron(convex hull s)`,
  SIMP_TAC[POLYTOPE_CONVEX_HULL; POLYTOPE_IMP_POLYHEDRON]);;

(* ------------------------------------------------------------------------- *)
(* Polytope is union of convex hulls of facets plus any point inside.        *)
(* ------------------------------------------------------------------------- *)

let POLYTOPE_UNION_CONVEX_HULL_FACETS = prove
 (`!s p:real^N->bool.
        polytope p /\ &0 < aff_dim p /\ ~(s = {}) /\ s SUBSET p
        ==> p = UNIONS { convex hull (s UNION f) | f facet_of p}`,
  let lemma = SET_RULE `{f x | p x} = {y | ?x. p x /\ y = f x}` in
  MATCH_MP_TAC SET_PROVE_CASES THEN REWRITE_TAC[] THEN
  X_GEN_TAC `a:real^N` THEN ONCE_REWRITE_TAC[lemma] THEN
  GEOM_ORIGIN_TAC `a:real^N` THEN ONCE_REWRITE_TAC[GSYM lemma] THEN
  X_GEN_TAC `s:real^N->bool` THEN DISCH_THEN(K ALL_TAC) THEN
  MP_TAC(SET_RULE `(vec 0:real^N) IN (vec 0 INSERT s)`) THEN
  SPEC_TAC(`(vec 0:real^N) INSERT s`,`s:real^N->bool`) THEN
  X_GEN_TAC `s:real^N->bool` THEN DISCH_TAC THEN
  X_GEN_TAC `p:real^N->bool` THEN STRIP_TAC THEN
  FIRST_ASSUM(STRIP_ASSUME_TAC o
   GEN_REWRITE_RULE I [POLYTOPE_EQ_BOUNDED_POLYHEDRON]) THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [ALL_TAC;
    REWRITE_TAC[SUBSET; FORALL_IN_UNIONS; IMP_CONJ] THEN
    REWRITE_TAC[FORALL_IN_GSPEC; RIGHT_FORALL_IMP_THM] THEN
    X_GEN_TAC `f:real^N->bool` THEN DISCH_TAC THEN
    REWRITE_TAC[GSYM SUBSET] THEN MATCH_MP_TAC SUBSET_TRANS THEN
    EXISTS_TAC `convex hull p:real^N->bool` THEN CONJ_TAC THENL
     [MATCH_MP_TAC HULL_MONO THEN
      FIRST_ASSUM(MP_TAC o MATCH_MP FACET_OF_IMP_SUBSET) THEN ASM SET_TAC[];
      ASM_MESON_TAC[CONVEX_HULL_EQ; POLYHEDRON_IMP_CONVEX; SUBSET_REFL]]] THEN
  REWRITE_TAC[SUBSET] THEN X_GEN_TAC `v:real^N` THEN DISCH_TAC THEN
  ASM_CASES_TAC `v:real^N = vec 0` THENL
   [MP_TAC(ISPEC `p:real^N->bool` POLYTOPE_FACET_EXISTS) THEN
    ASM_REWRITE_TAC[IN_UNIONS; EXISTS_IN_GSPEC] THEN
    MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC THEN DISCH_TAC THEN
    ASM_REWRITE_TAC[] THEN ASM_MESON_TAC[HULL_INC; IN_UNION];
    ALL_TAC] THEN
  SUBGOAL_THEN `?t. &1 < t /\ ~((t % v:real^N) IN p)` STRIP_ASSUME_TAC THENL
   [FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [BOUNDED_POS]) THEN
    DISCH_THEN(X_CHOOSE_THEN `B:real` STRIP_ASSUME_TAC) THEN
    EXISTS_TAC `max (&2) ((B + &1) / norm (v:real^N))` THEN
    CONJ_TAC THENL [REAL_ARITH_TAC; ALL_TAC] THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o
     GEN_REWRITE_RULE BINDER_CONV [GSYM CONTRAPOS_THM]) THEN
    ASM_SIMP_TAC[NORM_MUL; GSYM REAL_LE_RDIV_EQ; NORM_POS_LT] THEN
    MATCH_MP_TAC(REAL_ARITH `a < b ==> ~(abs(max (&2) b) <= a)`) THEN
    ASM_SIMP_TAC[REAL_LT_DIV2_EQ; NORM_POS_LT] THEN REAL_ARITH_TAC;
    ALL_TAC] THEN
  SUBGOAL_THEN `(vec 0:real^N) IN p` ASSUME_TAC THENL
   [ASM SET_TAC[]; ALL_TAC] THEN
  MP_TAC(ISPECL [`segment[vec 0,t % v:real^N] INTER p`; `vec 0:real^N`]
        DISTANCE_ATTAINS_SUP) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[COMPACT_INTER_CLOSED; POLYHEDRON_IMP_CLOSED; COMPACT_SEGMENT;
                 GSYM MEMBER_NOT_EMPTY; IN_INTER] THEN
    ASM_MESON_TAC[ENDS_IN_SEGMENT];
    REWRITE_TAC[IN_INTER; GSYM CONJ_ASSOC; IMP_CONJ] THEN
    REWRITE_TAC[segment; FORALL_IN_GSPEC; EXISTS_IN_GSPEC] THEN
    REWRITE_TAC[VECTOR_MUL_RZERO; VECTOR_ADD_LID; DIST_0] THEN
    REWRITE_TAC[IMP_IMP; GSYM CONJ_ASSOC; NORM_MUL; REAL_MUL_ASSOC] THEN
    ASM_SIMP_TAC[REAL_LE_RMUL_EQ; NORM_POS_LT; LEFT_IMP_EXISTS_THM;
                 REAL_ARITH `&1 < t ==> &0 < abs t`] THEN
    X_GEN_TAC `u:real` THEN
    ASM_CASES_TAC `u = &1` THEN ASM_REWRITE_TAC[VECTOR_MUL_LID] THEN
    REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    ASM_SIMP_TAC[real_abs] THEN DISCH_TAC] THEN
  SUBGOAL_THEN `inv(t) <= u` ASSUME_TAC THENL
   [FIRST_X_ASSUM MATCH_MP_TAC THEN
    ASM_SIMP_TAC[REAL_INV_LE_1; REAL_LT_IMP_LE; REAL_LE_INV_EQ;
                 REAL_ARITH `&1 < t ==> &0 <= t`] THEN
    ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_LINV; VECTOR_MUL_LID;
                 REAL_ARITH `&1 < t ==> ~(t = &0)`];
    ALL_TAC] THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP (REAL_ARITH `&1 < t ==> &0 < t`)) THEN
  SUBGOAL_THEN `&0 < u /\ u < &1` STRIP_ASSUME_TAC THENL
   [ASM_REWRITE_TAC[REAL_LT_LE] THEN
    DISCH_THEN(SUBST_ALL_TAC o SYM) THEN
    UNDISCH_TAC `inv t <= &0` THEN REWRITE_TAC[REAL_NOT_LE] THEN
    ASM_REWRITE_TAC[REAL_LT_INV_EQ];
    ALL_TAC] THEN
  MATCH_MP_TAC(SET_RULE `!t. t SUBSET s /\ x IN t ==> x IN s`) THEN
  EXISTS_TAC `convex hull {vec 0:real^N,u % t % v}` THEN CONJ_TAC THENL
   [ALL_TAC;
    REWRITE_TAC[CONVEX_HULL_2; VECTOR_MUL_RZERO; VECTOR_ADD_LID] THEN
    REWRITE_TAC[IN_ELIM_THM] THEN
    MAP_EVERY EXISTS_TAC [`&1 - inv(u * t)`; `inv(u * t):real`] THEN
    REWRITE_TAC[REAL_ARITH `&1 - x + x = &1`; REAL_SUB_LE; REAL_LE_INV_EQ] THEN
    ASM_SIMP_TAC[REAL_LE_MUL; REAL_LT_IMP_LE; VECTOR_MUL_ASSOC] THEN
    ASM_SIMP_TAC[GSYM REAL_MUL_ASSOC; REAL_ENTIRE; REAL_MUL_LINV;
                 REAL_LT_IMP_NZ; VECTOR_MUL_LID] THEN
    MATCH_MP_TAC REAL_INV_LE_1 THEN ASM_SIMP_TAC[GSYM REAL_LE_LDIV_EQ] THEN
    ASM_REWRITE_TAC[real_div; REAL_MUL_LID]] THEN
  SUBGOAL_THEN
   `(u % t % v:real^N) IN (p DIFF relative_interior p)`
  MP_TAC THENL
   [ALL_TAC;
    ASM_SIMP_TAC[RELATIVE_INTERIOR_OF_POLYHEDRON] THEN
    DISCH_THEN(MP_TAC o MATCH_MP (SET_RULE
     `x IN s DIFF (s DIFF t) ==> x IN t`)) THEN
    REWRITE_TAC[IN_UNIONS; EXISTS_IN_GSPEC] THEN
    DISCH_THEN(X_CHOOSE_THEN `f:real^N->bool` STRIP_ASSUME_TAC) THEN
    MATCH_MP_TAC(SET_RULE
     `(?s. s IN f /\ t SUBSET s) ==> t SUBSET UNIONS f`) THEN
    REWRITE_TAC[EXISTS_IN_GSPEC] THEN EXISTS_TAC `f:real^N->bool` THEN
    ASM_SIMP_TAC[SUBSET_HULL; CONVEX_CONVEX_HULL] THEN
    ASM_SIMP_TAC[HULL_INC; IN_UNION; INSERT_SUBSET; EMPTY_SUBSET]] THEN
  ASM_REWRITE_TAC[IN_DIFF; IN_RELATIVE_INTERIOR] THEN
  DISCH_THEN(X_CHOOSE_THEN `e:real` (CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  REWRITE_TAC[SUBSET; IN_BALL; IN_INTER; dist] THEN
  ABBREV_TAC `k = min (e / &2 / norm(t % v:real^N)) (&1 - u)` THEN
  SUBGOAL_THEN `&0 < k` ASSUME_TAC THENL
   [EXPAND_TAC "k" THEN REWRITE_TAC[REAL_LT_MIN] THEN
    ASM_REWRITE_TAC[REAL_SUB_LT] THEN MATCH_MP_TAC REAL_LT_DIV THEN
    ASM_SIMP_TAC[REAL_HALF; NORM_POS_LT; VECTOR_MUL_EQ_0; REAL_LT_IMP_NZ];
    ALL_TAC] THEN
  DISCH_THEN(MP_TAC o SPEC `(u + k) % t % v:real^N`) THEN
  REWRITE_TAC[VECTOR_ARITH `u % x - (u + k) % x:real^N = --k % x`] THEN
  ONCE_REWRITE_TAC[NORM_MUL] THEN REWRITE_TAC[REAL_ABS_NEG; NOT_IMP] THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC(REAL_ARITH `&0 < e /\ x <= e / &2 ==> x < e`) THEN
    ASM_SIMP_TAC[GSYM REAL_LE_RDIV_EQ; NORM_POS_LT; VECTOR_MUL_EQ_0;
                 REAL_LT_IMP_NZ] THEN
    ASM_SIMP_TAC[real_abs; REAL_LT_IMP_LE] THEN
    EXPAND_TAC "k" THEN REAL_ARITH_TAC;
    ASM_SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC] THEN
    REPEAT(MATCH_MP_TAC SPAN_MUL) THEN ASM_SIMP_TAC[SPAN_SUPERSET];
    DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `u + k:real`) THEN
    ASM_REWRITE_TAC[NOT_IMP] THEN
    MATCH_MP_TAC(REAL_ARITH
     `&0 <= u /\ &0 < x /\ x <= &1 - u
      ==> (&0 <= u + x /\ u + x <= &1) /\ ~(u + x <= u)`) THEN
    ASM_REWRITE_TAC[] THEN EXPAND_TAC "k" THEN REAL_ARITH_TAC]);;

(* ------------------------------------------------------------------------- *)
(* Finitely generated cone is polyhedral, and hence closed.                  *)
(* ------------------------------------------------------------------------- *)

let POLYHEDRON_CONVEX_CONE_HULL = prove
 (`!s:real^N->bool. FINITE s ==> polyhedron(convex_cone hull s)`,
  GEN_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THEN DISCH_TAC THENL
   [ASM_REWRITE_TAC[CONVEX_CONE_HULL_EMPTY] THEN
    ASM_SIMP_TAC[POLYTOPE_IMP_POLYHEDRON; POLYTOPE_SING];
    ALL_TAC] THEN
  SUBGOAL_THEN
    `polyhedron(convex hull ((vec 0:real^N) INSERT s))`
  MP_TAC THENL
   [MATCH_MP_TAC POLYTOPE_IMP_POLYHEDRON THEN
    REWRITE_TAC[polytope] THEN ASM_MESON_TAC[FINITE_INSERT];
    REWRITE_TAC[polyhedron] THEN
    DISCH_THEN(X_CHOOSE_THEN `f:(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
    RULE_ASSUM_TAC(REWRITE_RULE[SKOLEM_THM; RIGHT_IMP_EXISTS_THM]) THEN
    FIRST_X_ASSUM(X_CHOOSE_THEN `a:(real^N->bool)->real^N` MP_TAC) THEN
    DISCH_THEN(X_CHOOSE_TAC `b:(real^N->bool)->real`)] THEN
  SUBGOAL_THEN `~(f:(real^N->bool)->bool = {})` ASSUME_TAC THENL
   [DISCH_THEN SUBST_ALL_TAC THEN FIRST_X_ASSUM(MP_TAC o
     GEN_REWRITE_RULE RAND_CONV [INTERS_0]) THEN
    DISCH_THEN(MP_TAC o AP_TERM `bounded:(real^N->bool)->bool`) THEN
    ASM_SIMP_TAC[NOT_BOUNDED_UNIV; BOUNDED_CONVEX_HULL; FINITE_IMP_BOUNDED;
                 FINITE_INSERT; FINITE_EMPTY];
    ALL_TAC] THEN
  EXISTS_TAC `{h:real^N->bool | h IN f /\ b h = &0}` THEN
  ASM_SIMP_TAC[FINITE_RESTRICT; IN_ELIM_THM] THEN CONJ_TAC THENL
   [ALL_TAC;
    X_GEN_TAC `h:real^N->bool` THEN STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
    ASM_REWRITE_TAC[] THEN DISCH_TAC THEN ONCE_ASM_REWRITE_TAC[] THEN
    MAP_EVERY EXISTS_TAC
     [`(a:(real^N->bool)->real^N) h`; `(b:(real^N->bool)->real) h`] THEN
    ASM_REWRITE_TAC[]] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [MATCH_MP_TAC HULL_MINIMAL THEN CONJ_TAC THENL
     [MATCH_MP_TAC SUBSET_TRANS THEN
      EXISTS_TAC `convex hull ((vec 0:real^N) INSERT s)` THEN CONJ_TAC THENL
       [SIMP_TAC[SUBSET; HULL_INC; IN_INSERT]; ASM_REWRITE_TAC[]] THEN
      MATCH_MP_TAC(SET_RULE `s SUBSET t ==> INTERS t SUBSET INTERS s`) THEN
      SET_TAC[];
      MATCH_MP_TAC CONVEX_CONE_INTERS THEN
      X_GEN_TAC `h:real^N->bool` THEN REWRITE_TAC[IN_ELIM_THM] THEN
      STRIP_TAC THEN FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN
      ASM_REWRITE_TAC[] THEN DISCH_THEN(SUBST1_TAC o CONJUNCT2) THEN
      REWRITE_TAC[CONVEX_CONE_HALFSPACE_LE]];
    ALL_TAC] THEN
  REWRITE_TAC[SUBSET; IN_INTERS; IN_ELIM_THM] THEN X_GEN_TAC `x:real^N` THEN
  DISCH_TAC THEN
  SUBGOAL_THEN `!h:real^N->bool. h IN f ==> ?t. &0 < t /\ (t % x) IN h`
  MP_TAC THENL
   [X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN
    ASM_CASES_TAC `(b:(real^N->bool)->real) h = &0` THENL
     [EXISTS_TAC `&1` THEN ASM_SIMP_TAC[REAL_LT_01; VECTOR_MUL_LID];
      ALL_TAC] THEN
    SUBGOAL_THEN `&0 < (b:(real^N->bool)->real) h` ASSUME_TAC THENL
     [ASM_REWRITE_TAC[REAL_LT_LE] THEN
      FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [EXTENSION]) THEN
      DISCH_THEN(MP_TAC o SPEC `vec 0:real^N`) THEN
      SIMP_TAC[HULL_INC; IN_INSERT; IN_INTERS] THEN
      DISCH_THEN(MP_TAC o SPEC `h:real^N->bool`) THEN ASM_REWRITE_TAC[] THEN
      SUBGOAL_THEN `h = {x:real^N | a h dot x <= b h}`
       (fun th -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [th])
      THENL [ASM_MESON_TAC[]; REWRITE_TAC[IN_ELIM_THM; DOT_RZERO]];
      ALL_TAC] THEN
    SUBGOAL_THEN `(vec 0:real^N) IN interior h` MP_TAC THENL
     [SUBGOAL_THEN `h = {x:real^N | a h dot x <= b h}` SUBST1_TAC THENL
       [ASM_MESON_TAC[];
        ASM_SIMP_TAC[INTERIOR_HALFSPACE_LE; IN_ELIM_THM; DOT_RZERO]];
      REWRITE_TAC[IN_INTERIOR; SUBSET; IN_BALL_0; LEFT_IMP_EXISTS_THM] THEN
      X_GEN_TAC `e:real` THEN STRIP_TAC THEN
      ASM_CASES_TAC `x:real^N = vec 0` THENL
       [EXISTS_TAC `&1` THEN
        ASM_SIMP_TAC[VECTOR_MUL_RZERO; REAL_LT_01; NORM_0];
        EXISTS_TAC `e / &2 / norm(x:real^N)` THEN
        ASM_SIMP_TAC[REAL_HALF; REAL_LT_DIV; NORM_POS_LT] THEN
        FIRST_X_ASSUM MATCH_MP_TAC THEN
        REWRITE_TAC[NORM_MUL; REAL_ABS_DIV; REAL_ABS_NUM; REAL_ABS_NORM] THEN
        ASM_SIMP_TAC[REAL_DIV_RMUL; NORM_EQ_0] THEN ASM_REAL_ARITH_TAC]];
    ALL_TAC] THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `t:(real^N->bool)->real` THEN DISCH_TAC THEN
  SUBGOAL_THEN `x:real^N = inv(inf(IMAGE t (f:(real^N->bool)->bool))) %
                           inf(IMAGE t f) % x`
  SUBST1_TAC THENL
   [GEN_REWRITE_TAC LAND_CONV [GSYM VECTOR_MUL_LID] THEN
    REWRITE_TAC[VECTOR_MUL_ASSOC] THEN AP_THM_TAC THEN AP_TERM_TAC THEN
    CONV_TAC SYM_CONV THEN MATCH_MP_TAC REAL_MUL_LINV THEN
    MATCH_MP_TAC REAL_LT_IMP_NZ THEN
    ASM_SIMP_TAC[REAL_LT_INF_FINITE; FINITE_IMAGE; IMAGE_EQ_EMPTY] THEN
    ASM_SIMP_TAC[FORALL_IN_IMAGE];
    ALL_TAC] THEN
  MATCH_MP_TAC(REWRITE_RULE[conic] CONIC_CONVEX_CONE_HULL) THEN
  ASM_SIMP_TAC[REAL_LE_INV_EQ; REAL_LE_INF_FINITE; FINITE_IMAGE;
               IMAGE_EQ_EMPTY; REAL_LT_IMP_LE; FORALL_IN_IMAGE] THEN
  MATCH_MP_TAC(SET_RULE `!s t. s SUBSET t /\ x IN s ==> x IN t`) THEN
  EXISTS_TAC `convex hull ((vec 0:real^N) INSERT s)` THEN CONJ_TAC THENL
   [MATCH_MP_TAC HULL_MINIMAL THEN
    REWRITE_TAC[CONVEX_CONVEX_CONE_HULL] THEN
    ASM_SIMP_TAC[INSERT_SUBSET; HULL_SUBSET; CONVEX_CONE_HULL_CONTAINS_0];
    ASM_REWRITE_TAC[IN_INTERS] THEN X_GEN_TAC `h:real^N->bool` THEN
    DISCH_TAC THEN
    SUBGOAL_THEN `inf(IMAGE (t:(real^N->bool)->real) f) % x:real^N =
                  (&1 - inf(IMAGE t f) / t h) % vec 0 +
                  (inf(IMAGE t f) / t h) % t h % x`
    SUBST1_TAC THENL
     [ASM_SIMP_TAC[VECTOR_MUL_ASSOC; VECTOR_MUL_RZERO; VECTOR_ADD_LID;
                   REAL_DIV_RMUL; REAL_LT_IMP_NZ];
      ALL_TAC] THEN
    MATCH_MP_TAC IN_CONVEX_SET THEN
    ASM_SIMP_TAC[REAL_LE_RDIV_EQ; REAL_LE_LDIV_EQ] THEN
    REWRITE_TAC[REAL_MUL_LZERO; REAL_MUL_LID] THEN
    ASM_SIMP_TAC[REAL_INF_LE_FINITE; REAL_LE_INF_FINITE;
                 FINITE_IMAGE; IMAGE_EQ_EMPTY] THEN
    ASM_REWRITE_TAC[FORALL_IN_IMAGE; EXISTS_IN_IMAGE] THEN
    ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN REPEAT CONJ_TAC THENL
     [SUBGOAL_THEN `h = {x:real^N | a h dot x <= b h}` SUBST1_TAC THENL
       [ASM_MESON_TAC[]; ASM_SIMP_TAC[CONVEX_HALFSPACE_LE]];
      SUBGOAL_THEN `(vec 0:real^N) IN convex hull (vec 0 INSERT s)` MP_TAC
      THENL [SIMP_TAC[HULL_INC; IN_INSERT]; ALL_TAC] THEN
      ASM_REWRITE_TAC[IN_INTERS] THEN ASM_MESON_TAC[];
      ASM SET_TAC[REAL_LE_REFL]]]);;

let CLOSED_CONVEX_CONE_HULL = prove
 (`!s:real^N->bool. FINITE s ==> closed(convex_cone hull s)`,
  MESON_TAC[POLYHEDRON_IMP_CLOSED; POLYHEDRON_CONVEX_CONE_HULL]);;

let POLYHEDRON_CONVEX_CONE_HULL_POLYTOPE = prove
 (`!s:real^N->bool. polytope s ==> polyhedron(convex_cone hull s)`,
  GEN_TAC THEN REWRITE_TAC[polytope; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:real^N->bool` THEN STRIP_TAC THEN
  ASM_CASES_TAC `c:real^N->bool = {}` THEN
  ASM_SIMP_TAC[CONVEX_HULL_EMPTY; CONVEX_CONE_HULL_EMPTY;
               POLYTOPE_IMP_POLYHEDRON; POLYTOPE_SING] THEN
  ASM_SIMP_TAC[CONVEX_CONE_HULL_SEPARATE_NONEMPTY; CONVEX_HULL_EQ_EMPTY] THEN
  REWRITE_TAC[HULL_HULL] THEN
  ASM_SIMP_TAC[GSYM CONVEX_CONE_HULL_SEPARATE_NONEMPTY; CONVEX_HULL_EQ_EMPTY;
               POLYHEDRON_CONVEX_CONE_HULL]);;

let POLYHEDRON_CONIC_HULL_POLYTOPE = prove
 (`!s:real^N->bool. polytope s ==> polyhedron(conic hull s)`,
  GEN_TAC THEN  REWRITE_TAC[polytope; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:real^N->bool` THEN STRIP_TAC THEN
  ASM_CASES_TAC `c:real^N->bool = {}` THEN
  ASM_SIMP_TAC[POLYHEDRON_EMPTY; CONVEX_HULL_EMPTY; CONIC_HULL_EMPTY] THEN
  ASM_SIMP_TAC[GSYM CONVEX_CONE_HULL_SEPARATE_NONEMPTY] THEN
  ASM_SIMP_TAC[POLYHEDRON_CONVEX_CONE_HULL]);;

let CLOSED_CONIC_HULL_STRONG = prove
 (`!s:real^N->bool.
    vec 0 IN relative_interior s \/ polytope s \/ compact s /\ ~(vec 0 IN s)
    ==> closed(conic hull s)`,
  REPEAT STRIP_TAC THEN ASM_SIMP_TAC[CLOSED_CONIC_HULL] THEN
  MATCH_MP_TAC POLYHEDRON_IMP_CLOSED THEN
  ASM_SIMP_TAC[POLYHEDRON_CONIC_HULL_POLYTOPE]);;

let CLOSED_CONVEX_CONE_HULL_STRONG = prove
 (`!s:real^N->bool.
        FINITE s \/
        polytope s \/
        vec 0 IN relative_interior (convex hull s) \/
        compact s /\ ~(vec 0 IN convex hull s)
        ==> closed(convex_cone hull s)`,
  REPEAT GEN_TAC THEN ASM_CASES_TAC `s:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[CONVEX_CONE_HULL_EMPTY; CLOSED_SING] THEN
  DISCH_THEN(DISJ_CASES_THEN MP_TAC) THENL
   [ASM_MESON_TAC[CLOSED_CONVEX_CONE_HULL]; ALL_TAC] THEN
  ASM_SIMP_TAC[CONVEX_CONE_HULL_SEPARATE_NONEMPTY] THEN
  DISCH_THEN(fun th ->
    MATCH_MP_TAC CLOSED_CONIC_HULL_STRONG THEN MP_TAC th) THEN
  MESON_TAC[COMPACT_CONVEX_HULL; HULL_P; POLYTOPE_IMP_CONVEX]);;

(* ------------------------------------------------------------------------- *)
(* And conversely, a polyhedral cone is finitely generated.                  *)
(* ------------------------------------------------------------------------- *)

let FINITELY_GENERATED_CONIC_POLYHEDRON = prove
 (`!s:real^N->bool.
        polyhedron s /\ conic s /\ ~(s = {})
        ==> ?c. FINITE c /\ s = convex_cone hull c`,
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `?p:real^N->bool. polytope p /\ vec 0 IN interior p`
  STRIP_ASSUME_TAC THENL
   [EXISTS_TAC `interval[--vec 1:real^N,vec 1:real^N]` THEN
    REWRITE_TAC[POLYTOPE_INTERVAL; INTERIOR_CLOSED_INTERVAL] THEN
    SIMP_TAC[IN_INTERVAL; VECTOR_NEG_COMPONENT; VEC_COMPONENT] THEN
    CONV_TAC REAL_RAT_REDUCE_CONV;
    ALL_TAC] THEN
  SUBGOAL_THEN `polytope(s INTER p:real^N->bool)` MP_TAC THENL
   [REWRITE_TAC[POLYTOPE_EQ_BOUNDED_POLYHEDRON] THEN
    ASM_SIMP_TAC[BOUNDED_INTER; POLYTOPE_IMP_BOUNDED]THEN
    ASM_SIMP_TAC[POLYHEDRON_INTER; POLYTOPE_IMP_POLYHEDRON];
    REWRITE_TAC[polytope] THEN MATCH_MP_TAC MONO_EXISTS] THEN
  X_GEN_TAC `c:real^N->bool` THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [ALL_TAC;
    ASM_SIMP_TAC[SUBSET_HULL; POLYHEDRON_IMP_CONVEX; convex_cone] THEN
    MATCH_MP_TAC SUBSET_TRANS THEN EXISTS_TAC `s INTER p:real^N->bool` THEN
    REWRITE_TAC[INTER_SUBSET] THEN ASM_REWRITE_TAC[HULL_SUBSET]] THEN
  REWRITE_TAC[SUBSET] THEN X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
  SUBGOAL_THEN `?t. &0 < t /\ (t % x:real^N) IN p` STRIP_ASSUME_TAC THENL
   [FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [IN_INTERIOR]) THEN
    REWRITE_TAC[SUBSET; IN_BALL_0; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `e:real` THEN STRIP_TAC THEN
    ASM_CASES_TAC `x:real^N = vec 0` THENL
     [EXISTS_TAC `&1` THEN ASM_REWRITE_TAC[VECTOR_MUL_RZERO; REAL_LT_01] THEN
      ASM_SIMP_TAC[NORM_0];
      EXISTS_TAC `e / &2 / norm(x:real^N)` THEN
      ASM_SIMP_TAC[REAL_HALF; REAL_LT_DIV; NORM_POS_LT] THEN
      FIRST_X_ASSUM MATCH_MP_TAC THEN
      REWRITE_TAC[NORM_MUL; REAL_ABS_DIV; REAL_ABS_NORM; REAL_ABS_NUM] THEN
      ASM_SIMP_TAC[REAL_DIV_RMUL; NORM_EQ_0] THEN ASM_REAL_ARITH_TAC];
    ALL_TAC] THEN
  SUBGOAL_THEN `x:real^N = inv t % t % x` SUBST1_TAC THENL
   [ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_LINV; VECTOR_MUL_LID;
                 REAL_LT_IMP_NZ];
    ALL_TAC] THEN
  MATCH_MP_TAC(REWRITE_RULE[conic] CONIC_CONVEX_CONE_HULL) THEN
  ASM_SIMP_TAC[REAL_LE_INV_EQ; REAL_LT_IMP_LE] THEN
  MATCH_MP_TAC(SET_RULE `!s. x IN s /\ s SUBSET t ==> x IN t`) THEN
  EXISTS_TAC `convex hull c:real^N->bool` THEN
  REWRITE_TAC[CONVEX_HULL_SUBSET_CONVEX_CONE_HULL] THEN
  FIRST_X_ASSUM(SUBST1_TAC o SYM) THEN ASM_REWRITE_TAC[IN_INTER] THEN
  FIRST_X_ASSUM(MATCH_MP_TAC o GEN_REWRITE_RULE I [conic]) THEN
  ASM_SIMP_TAC[REAL_LT_IMP_LE]);;

(* ------------------------------------------------------------------------- *)
(* Decomposition of polyhedron into cone plus polytope and more corollaries. *)
(* ------------------------------------------------------------------------- *)

let POLYHEDRON_POLYTOPE_SUMS = prove
 (`!s t:real^N->bool.
    polyhedron s /\ polytope t ==> polyhedron {x + y | x IN s /\ y IN t}`,
  REPEAT STRIP_TAC THEN
  REWRITE_TAC[POLYHEDRON_EQ_FINITE_EXPOSED_FACES] THEN REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC CLOSED_COMPACT_SUMS THEN
    ASM_SIMP_TAC[POLYHEDRON_IMP_CLOSED; POLYTOPE_IMP_COMPACT];
    MATCH_MP_TAC CONVEX_SUMS THEN
    ASM_SIMP_TAC[POLYHEDRON_IMP_CONVEX; POLYTOPE_IMP_CONVEX];
    MATCH_MP_TAC FINITE_SUBSET THEN
    EXISTS_TAC `{ {x + y:real^N | x IN k /\ y IN l} |
                  k exposed_face_of s /\ l exposed_face_of t}` THEN
    CONJ_TAC THENL
     [ONCE_REWRITE_TAC[SET_RULE `k exposed_face_of s <=>
                                 k IN {f | f exposed_face_of s}`] THEN
      MATCH_MP_TAC FINITE_PRODUCT_DEPENDENT THEN
      ASM_SIMP_TAC[FINITE_POLYHEDRON_EXPOSED_FACES;
                   POLYTOPE_IMP_POLYHEDRON];
      REWRITE_TAC[SUBSET; IN_ELIM_THM; GSYM CONJ_ASSOC] THEN
      REPEAT STRIP_TAC THEN MATCH_MP_TAC EXPOSED_FACE_OF_SUMS THEN
      ASM_SIMP_TAC[POLYHEDRON_IMP_CONVEX; POLYTOPE_IMP_CONVEX]]]);;

let POLYHEDRON_AS_CONE_PLUS_CONV = prove
 (`!s:real^N->bool.
        polyhedron s <=> ?t u. FINITE t /\ FINITE u /\
                               s = {x + y | x IN convex_cone hull t /\
                                            y IN convex hull u}`,
  REPEAT GEN_TAC THEN EQ_TAC THENL
   [REWRITE_TAC[polyhedron; LEFT_IMP_EXISTS_THM];
    STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
    MATCH_MP_TAC POLYHEDRON_POLYTOPE_SUMS THEN
    ASM_SIMP_TAC[POLYTOPE_CONVEX_HULL; POLYHEDRON_CONVEX_CONE_HULL]] THEN
  REWRITE_TAC[polyhedron; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `f:(real^N->bool)->bool` THEN
  DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  DISCH_THEN(CONJUNCTS_THEN2 (ASSUME_TAC o SYM) MP_TAC) THEN
  GEN_REWRITE_TAC (LAND_CONV o REDEPTH_CONV) [RIGHT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[SKOLEM_THM; LEFT_IMP_EXISTS_THM] THEN MAP_EVERY X_GEN_TAC
   [`a:(real^N->bool)->real^N`; `b:(real^N->bool)->real`] THEN
  ONCE_REWRITE_TAC[MESON[] `h = {x | P x} <=> {x | P x} = h`] THEN
  DISCH_TAC THEN
  ABBREV_TAC
   `s':real^(N,1)finite_sum->bool =
        {x | &0 <= drop(sndcart x) /\
             !h:real^N->bool.
                h IN f ==> a h dot (fstcart x) <= b h * drop(sndcart x)}` THEN
  SUBGOAL_THEN
   `?t u. FINITE t /\ FINITE u /\
          (!y:real^(N,1)finite_sum. y IN t ==> drop(sndcart y) = &0) /\
          (!y. y IN u ==> drop(sndcart y) = &1) /\
          s' = convex_cone hull (t UNION u)`
  STRIP_ASSUME_TAC THENL
   [MP_TAC(ISPEC `s':real^(N,1)finite_sum->bool`
        FINITELY_GENERATED_CONIC_POLYHEDRON) THEN
    ANTS_TAC THENL
     [EXPAND_TAC "s'" THEN REPEAT CONJ_TAC THENL
       [REWRITE_TAC[polyhedron] THEN
        EXISTS_TAC
         `{ x:real^(N,1)finite_sum |
            pastecart (vec 0) (--vec 1) dot x <= &0} INSERT
          { {x | pastecart (a h) (--lift(b h)) dot x <= &0} |
            (h:real^N->bool) IN f}` THEN
        REWRITE_TAC[FINITE_INSERT; INTERS_INSERT; SIMPLE_IMAGE] THEN
        ASM_SIMP_TAC[FINITE_IMAGE; FORALL_IN_INSERT; FORALL_IN_IMAGE] THEN
        REPEAT CONJ_TAC THENL
         [EXPAND_TAC "s'" THEN
          REWRITE_TAC[EXTENSION; IN_ELIM_THM; FORALL_PASTECART; IN_INTER;
           DOT_PASTECART; INTERS_IMAGE; FSTCART_PASTECART;
           SNDCART_PASTECART; DOT_1; GSYM drop; DROP_NEG; LIFT_DROP] THEN
          REWRITE_TAC[DROP_VEC; DOT_LZERO; REAL_MUL_LNEG; GSYM real_sub] THEN
          REWRITE_TAC[REAL_MUL_LID; REAL_ARITH `x - y <= &0 <=> x <= y`];
          EXISTS_TAC `pastecart (vec 0) (--vec 1):real^(N,1)finite_sum` THEN
          EXISTS_TAC `&0` THEN
          REWRITE_TAC[PASTECART_EQ_VEC; VECTOR_NEG_EQ_0; VEC_EQ] THEN
          ARITH_TAC;
          X_GEN_TAC `h:real^N->bool` THEN DISCH_TAC THEN MAP_EVERY EXISTS_TAC
           [`pastecart (a(h:real^N->bool)) (--lift(b h)):real^(N,1)finite_sum`;
            `&0`] THEN
          ASM_SIMP_TAC[PASTECART_EQ_VEC]];
        REWRITE_TAC[conic; IN_ELIM_THM; FSTCART_CMUL; SNDCART_CMUL] THEN
        SIMP_TAC[DROP_CMUL; DOT_RMUL; REAL_LE_MUL] THEN
        MESON_TAC[REAL_LE_LMUL; REAL_MUL_AC];
        REWRITE_TAC[GSYM MEMBER_NOT_EMPTY] THEN
        EXISTS_TAC `vec 0:real^(N,1)finite_sum` THEN
        REWRITE_TAC[IN_ELIM_THM; FSTCART_VEC; SNDCART_VEC] THEN
        REWRITE_TAC[DROP_VEC; DOT_RZERO; REAL_LE_REFL; REAL_MUL_RZERO]];
      DISCH_THEN(X_CHOOSE_THEN `c:real^(N,1)finite_sum->bool`
        STRIP_ASSUME_TAC) THEN
      MAP_EVERY EXISTS_TAC
       [`{x:real^(N,1)finite_sum | x IN c /\ drop(sndcart x) = &0}`;
        `IMAGE (\x. inv(drop(sndcart x)) % x)
           {x:real^(N,1)finite_sum | x IN c /\ ~(drop(sndcart x) = &0)}`] THEN
      ASM_SIMP_TAC[FINITE_IMAGE; FINITE_RESTRICT; FORALL_IN_IMAGE] THEN
      SIMP_TAC[IN_ELIM_THM; SNDCART_CMUL; DROP_CMUL; REAL_MUL_LINV] THEN
      SUBGOAL_THEN
       `!x:real^(N,1)finite_sum. x IN c ==> &0 <= drop(sndcart x)`
      ASSUME_TAC THENL
       [GEN_TAC THEN DISCH_TAC THEN
        SUBGOAL_THEN `(x:real^(N,1)finite_sum) IN s'` MP_TAC THENL
         [ASM_MESON_TAC[HULL_INC]; EXPAND_TAC "s'"] THEN
        SIMP_TAC[IN_ELIM_THM];
        ALL_TAC] THEN
      MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THEN
      MATCH_MP_TAC HULL_MINIMAL THEN
      REWRITE_TAC[CONVEX_CONE_CONVEX_CONE_HULL; UNION_SUBSET] THEN
      SIMP_TAC[SUBSET; IN_ELIM_THM; HULL_INC; FORALL_IN_IMAGE] THEN
      X_GEN_TAC `x:real^(N,1)finite_sum` THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPEC `x:real^(N,1)finite_sum`) THEN
      ASM_SIMP_TAC[CONVEX_CONE_HULL_MUL; HULL_INC; REAL_LE_INV_EQ] THEN
      ASM_REWRITE_TAC[REAL_ARITH `&0 <= x <=> x = &0 \/ &0 < x`] THEN
      STRIP_TAC THENL
       [MATCH_MP_TAC HULL_INC THEN ASM_REWRITE_TAC[IN_UNION; IN_ELIM_THM];
        SUBGOAL_THEN
         `x:real^(N,1)finite_sum =
                drop(sndcart x) % inv(drop(sndcart x)) % x`
        SUBST1_TAC THENL
         [ASM_SIMP_TAC[VECTOR_MUL_ASSOC; REAL_MUL_RINV; REAL_LT_IMP_NZ] THEN
          REWRITE_TAC[VECTOR_MUL_LID];
          MATCH_MP_TAC CONVEX_CONE_HULL_MUL THEN
          ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN MATCH_MP_TAC HULL_INC THEN
          REWRITE_TAC[IN_UNION] THEN DISJ2_TAC THEN
          REWRITE_TAC[IN_IMAGE] THEN EXISTS_TAC `x:real^(N,1)finite_sum` THEN
          ASM_SIMP_TAC[IN_ELIM_THM; REAL_LT_IMP_NZ]]]];
    EXISTS_TAC `IMAGE fstcart (t:real^(N,1)finite_sum->bool)` THEN
    EXISTS_TAC `IMAGE fstcart (u:real^(N,1)finite_sum->bool)` THEN
    ASM_SIMP_TAC[FINITE_IMAGE] THEN
    SUBGOAL_THEN `s = {x:real^N | pastecart x (vec 1:real^1) IN s'}`
    SUBST1_TAC THENL
     [MAP_EVERY EXPAND_TAC ["s"; "s'"] THEN
      REWRITE_TAC[IN_ELIM_THM; SNDCART_PASTECART; DROP_VEC; REAL_POS] THEN
      GEN_REWRITE_TAC I [EXTENSION] THEN
      REWRITE_TAC[FSTCART_PASTECART; IN_ELIM_THM; IN_INTERS; REAL_MUL_RID] THEN
      ASM SET_TAC[];
      ASM_REWRITE_TAC[CONVEX_CONE_HULL_UNION]] THEN
    REWRITE_TAC[EXTENSION; IN_ELIM_THM] THEN X_GEN_TAC `z:real^N` THEN
    SIMP_TAC[CONVEX_CONE_HULL_LINEAR_IMAGE; CONVEX_HULL_LINEAR_IMAGE;
             LINEAR_FSTCART] THEN
    REWRITE_TAC[GSYM CONJ_ASSOC; RIGHT_EXISTS_AND_THM] THEN
    REWRITE_TAC[EXISTS_IN_IMAGE] THEN
    AP_TERM_TAC THEN GEN_REWRITE_TAC I [FUN_EQ_THM] THEN
    X_GEN_TAC `a:real^(N,1)finite_sum` THEN REWRITE_TAC[] THEN
    MATCH_MP_TAC(TAUT `(p ==> (q <=> r)) ==> (p /\ q <=> p /\ r)`) THEN
    DISCH_TAC THEN AP_TERM_TAC THEN GEN_REWRITE_TAC I [FUN_EQ_THM] THEN
    X_GEN_TAC `b:real^(N,1)finite_sum` THEN REWRITE_TAC[PASTECART_EQ] THEN
    REWRITE_TAC[FSTCART_PASTECART; SNDCART_PASTECART; FSTCART_ADD;
                SNDCART_ADD] THEN
    ASM_CASES_TAC `fstcart(a:real^(N,1)finite_sum) +
                   fstcart(b:real^(N,1)finite_sum) = z` THEN
    ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN `sndcart(a:real^(N,1)finite_sum) = vec 0` SUBST1_TAC THENL
     [UNDISCH_TAC `(a:real^(N,1)finite_sum) IN convex_cone hull t` THEN
      SPEC_TAC(`a:real^(N,1)finite_sum`,`a:real^(N,1)finite_sum`) THEN
      MATCH_MP_TAC HULL_INDUCT THEN ASM_SIMP_TAC[GSYM DROP_EQ; DROP_VEC] THEN
      REWRITE_TAC[convex_cone; convex; conic; IN_ELIM_THM] THEN
      SIMP_TAC[SNDCART_ADD; SNDCART_CMUL; DROP_ADD; DROP_CMUL] THEN
      REWRITE_TAC[REAL_MUL_RZERO; REAL_ADD_RID; GSYM MEMBER_NOT_EMPTY] THEN
      EXISTS_TAC `vec 0:real^(N,1)finite_sum` THEN
      REWRITE_TAC[IN_ELIM_THM; SNDCART_VEC; DROP_VEC];
      REWRITE_TAC[VECTOR_ADD_LID]] THEN
    ASM_CASES_TAC `u:real^(N,1)finite_sum->bool = {}` THENL
     [ASM_REWRITE_TAC[CONVEX_CONE_HULL_EMPTY; CONVEX_HULL_EMPTY] THEN
      REWRITE_TAC[IN_SING; NOT_IN_EMPTY] THEN
      DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
      ASM_REWRITE_TAC[SNDCART_VEC; VEC_EQ] THEN ARITH_TAC;
      ALL_TAC] THEN
    ASM_SIMP_TAC[CONVEX_CONE_HULL_CONVEX_HULL_NONEMPTY; IN_ELIM_THM] THEN
    SUBGOAL_THEN
     `!y:real^(N,1)finite_sum. y IN convex hull u ==> sndcart y = vec 1`
     (LABEL_TAC "*")
    THENL
     [MATCH_MP_TAC HULL_INDUCT THEN ASM_SIMP_TAC[GSYM DROP_EQ; DROP_VEC] THEN
      REWRITE_TAC[convex; IN_ELIM_THM] THEN
      SIMP_TAC[SNDCART_ADD; SNDCART_CMUL; DROP_ADD; DROP_CMUL] THEN
      SIMP_TAC[REAL_MUL_RID];
      ALL_TAC] THEN
    EQ_TAC THEN REWRITE_TAC[LEFT_AND_EXISTS_THM; LEFT_IMP_EXISTS_THM] THENL
     [MAP_EVERY X_GEN_TAC [`c:real`; `d:real^(N,1)finite_sum`] THEN
      DISCH_THEN(CONJUNCTS_THEN2 STRIP_ASSUME_TAC MP_TAC) THEN
      ASM_SIMP_TAC[SNDCART_CMUL; VECTOR_MUL_EQ_0; VECTOR_ARITH
       `x:real^N = c % x <=> (c - &1) % x = vec 0`] THEN
      ASM_SIMP_TAC[REAL_SUB_0; VEC_EQ; ARITH_EQ; VECTOR_MUL_LID];
      DISCH_TAC THEN ASM_SIMP_TAC[] THEN EXISTS_TAC `&1` THEN
      ASM_REWRITE_TAC[REAL_POS; VECTOR_MUL_LID] THEN ASM_MESON_TAC[]]]);;

let POLYHEDRON_LINEAR_IMAGE = prove
 (`!f:real^M->real^N s.
        linear f /\ polyhedron s ==> polyhedron(IMAGE f s)`,
  REPEAT GEN_TAC THEN DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
  REWRITE_TAC[POLYHEDRON_AS_CONE_PLUS_CONV; LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC [`t:real^M->bool`; `u:real^M->bool`] THEN STRIP_TAC THEN
  EXISTS_TAC `IMAGE (f:real^M->real^N) t` THEN
  EXISTS_TAC `IMAGE (f:real^M->real^N) u` THEN
  ASM_SIMP_TAC[FINITE_IMAGE] THEN
  ASM_SIMP_TAC[CONVEX_CONE_HULL_LINEAR_IMAGE; CONVEX_HULL_LINEAR_IMAGE] THEN
  REWRITE_TAC[EXTENSION; IN_IMAGE; IN_ELIM_THM] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP LINEAR_ADD) THEN MESON_TAC[]);;

let POLYHEDRON_SUMS = prove
 (`!s t:real^N->bool.
    polyhedron s /\ polyhedron t ==> polyhedron {x + y | x IN s /\ y IN t}`,
  REPEAT GEN_TAC THEN REWRITE_TAC[POLYHEDRON_AS_CONE_PLUS_CONV] THEN
  REWRITE_TAC[LEFT_AND_EXISTS_THM; LEFT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM; LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC
   [`t1:real^N->bool`; `u1:real^N->bool`;
    `t2:real^N->bool`; `u2:real^N->bool`] THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  EXISTS_TAC `t1 UNION t2:real^N->bool` THEN
  EXISTS_TAC `{u + v:real^N | u IN u1 /\ v IN u2}` THEN
  REWRITE_TAC[CONVEX_CONE_HULL_UNION; CONVEX_HULL_SUMS] THEN
  ASM_SIMP_TAC[FINITE_PRODUCT_DEPENDENT; FINITE_UNION] THEN
  REWRITE_TAC[SET_RULE
   `{h x y | x IN {f a b | P a /\ Q b} /\
             y IN {g a b | R a /\ S b}} =
    {h (f a b) (g c d) | P a /\ Q b /\ R c /\ S d}`] THEN
  REWRITE_TAC[EXTENSION; IN_ELIM_THM] THEN MESON_TAC[VECTOR_ADD_AC]);;

let POLYHEDRAL_CONVEX_CONE = prove
 (`!s:real^N->bool.
        polyhedron s /\ convex_cone s <=>
        ?k. FINITE k /\ s = convex_cone hull k`,
  GEN_TAC THEN EQ_TAC THENL
   [ALL_TAC; MESON_TAC[POLYHEDRON_CONVEX_CONE_HULL;
                       CONVEX_CONE_CONVEX_CONE_HULL]] THEN
  STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [POLYHEDRON_AS_CONE_PLUS_CONV]) THEN
  REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  MAP_EVERY X_GEN_TAC [`k:real^N->bool`; `c:real^N->bool`] THEN
  ASM_CASES_TAC `c:real^N->bool = {}` THENL
   [ASM_REWRITE_TAC[CONVEX_HULL_EMPTY; NOT_IN_EMPTY] THEN
    REWRITE_TAC[SET_RULE `{f x y | x,y | F} = {}`] THEN
    ASM_MESON_TAC[CONVEX_CONE_NONEMPTY];
    DISCH_THEN(STRIP_ASSUME_TAC o GSYM)] THEN
  EXISTS_TAC `k UNION c:real^N->bool` THEN
  ASM_REWRITE_TAC[FINITE_UNION] THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
  CONJ_TAC THENL
   [EXPAND_TAC "s" THEN REWRITE_TAC[SUBSET; FORALL_IN_GSPEC] THEN
    REPEAT STRIP_TAC THEN MATCH_MP_TAC CONVEX_CONE_HULL_ADD THEN
    CONJ_TAC THEN FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
     `x IN s ==> s SUBSET t ==> x IN t`)) THEN
    MESON_TAC[HULL_MONO; SUBSET_UNION; SUBSET_TRANS;
        CONVEX_HULL_SUBSET_CONVEX_CONE_HULL];
    MATCH_MP_TAC HULL_MINIMAL THEN
    CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[]]] THEN
  REWRITE_TAC[UNION_SUBSET] THEN REWRITE_TAC[SUBSET] THEN
  CONJ_TAC THEN X_GEN_TAC `x:real^N` THEN DISCH_TAC THENL
   [ALL_TAC;
    EXPAND_TAC "s" THEN REWRITE_TAC[IN_ELIM_THM] THEN
    MAP_EVERY EXISTS_TAC [`vec 0:real^N`; `x:real^N`] THEN
    ASM_SIMP_TAC[HULL_INC; VECTOR_ADD_LID; CONVEX_CONE_HULL_CONTAINS_0]] THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP POLYHEDRON_IMP_CLOSED) THEN
  DISCH_THEN(MP_TAC o MATCH_MP CLOSED_APPROACHABLE) THEN
  DISCH_THEN(fun th -> GEN_REWRITE_TAC I [GSYM th]) THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  DISCH_THEN(X_CHOOSE_TAC `y:real^N`) THEN REWRITE_TAC[LIMPT_APPROACHABLE] THEN
  X_GEN_TAC `e:real` THEN DISCH_TAC THEN
  EXISTS_TAC `e / (norm y + &1) % ((norm y + &1) / e % x + y):real^N` THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC CONVEX_CONE_MUL THEN
    ASM_SIMP_TAC[REAL_LE_DIV; REAL_LE_ADD; NORM_POS_LE; REAL_POS;
                 REAL_LT_IMP_LE] THEN
    EXPAND_TAC "s" THEN REWRITE_TAC[IN_ELIM_THM] THEN MAP_EVERY EXISTS_TAC
     [`(norm(y:real^N) + &1) / e % x:real^N`; `y:real^N`] THEN
    ASM_SIMP_TAC[HULL_INC] THEN MATCH_MP_TAC CONVEX_CONE_HULL_MUL THEN
    ASM_SIMP_TAC[HULL_INC] THEN MATCH_MP_TAC REAL_LE_DIV THEN
    ASM_SIMP_TAC[REAL_LT_IMP_LE] THEN CONV_TAC NORM_ARITH;
    REWRITE_TAC[VECTOR_ADD_LDISTRIB; VECTOR_MUL_ASSOC] THEN
    ASM_SIMP_TAC[NORM_POS_LE; VECTOR_MUL_LID; REAL_FIELD
     `&0 <= y /\ &0 < e ==> e / (y + &1) * (y + &1) / e = &1`] THEN
    REWRITE_TAC[NORM_ARITH `dist(x + e:real^N,x) = norm e`] THEN
    REWRITE_TAC[NORM_MUL; REAL_ABS_DIV] THEN
    MATCH_MP_TAC(REAL_ARITH
     `&0 < e /\ e * z / y < e * &1 ==> abs e / y * z < e`) THEN
    ASM_SIMP_TAC[REAL_LT_LMUL_EQ; REAL_LT_LDIV_EQ;
                 NORM_ARITH `&0 < abs(norm(y:real^N) + &1)`] THEN
    REAL_ARITH_TAC]);;

(* ------------------------------------------------------------------------- *)
(* Farkas's lemma (2 variants) and stronger separation for polyhedra.        *)
(* ------------------------------------------------------------------------- *)

let FARKAS_LEMMA = prove
 (`!A:real^N^M b.
        (?x:real^N.
            A ** x = b /\
            (!i. 1 <= i /\ i <= dimindex(:N) ==> &0 <= x$i)) <=>
        ~(?y:real^M.
            b dot y < &0 /\
            (!i. 1 <= i /\ i <= dimindex(:N) ==> &0 <= (transp A ** y)$i))`,
  REPEAT STRIP_TAC THEN MATCH_MP_TAC(TAUT
   `(q ==> ~p) /\ (~p ==> q) ==> (p <=> ~q)`) THEN
  CONJ_TAC THENL
   [REPEAT STRIP_TAC THEN
    SUBGOAL_THEN `y dot ((A:real^N^M) ** x - b) = &0` MP_TAC THENL
     [ASM_REWRITE_TAC[VECTOR_SUB_REFL; DOT_RZERO]; ALL_TAC] THEN
    RULE_ASSUM_TAC(ONCE_REWRITE_RULE[DOT_SYM]) THEN
    REWRITE_TAC[DOT_RSUB; REAL_SUB_0] THEN
    FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (REAL_ARITH
     `y < &0 ==> &0 <= x ==> ~(x = y)`)) THEN
    ONCE_REWRITE_TAC[GSYM DOT_LMUL_MATRIX] THEN
    REWRITE_TAC[VECTOR_MATRIX_MUL_TRANSP; dot] THEN
    MATCH_MP_TAC SUM_POS_LE THEN
    ASM_SIMP_TAC[REAL_LE_MUL; IN_NUMSEG; FINITE_NUMSEG];
    DISCH_TAC THEN MP_TAC(ISPECL
     [`{(A:real^N^M) ** (x:real^N) |
        !i. 1 <= i /\ i <= dimindex(:N) ==> &0 <= x$i}`;
      `b:real^M`] SEPARATING_HYPERPLANE_CLOSED_POINT) THEN
    REWRITE_TAC[FORALL_IN_GSPEC] THEN ANTS_TAC THENL
     [REWRITE_TAC[IN_ELIM_THM; CONJ_ASSOC] THEN
      CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[]] THEN
      ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
      SIMP_TAC[CONVEX_POSITIVE_ORTHANT; CONVEX_LINEAR_IMAGE;
               MATRIX_VECTOR_MUL_LINEAR] THEN
      MATCH_MP_TAC POLYHEDRON_IMP_CLOSED THEN
      MATCH_MP_TAC POLYHEDRON_LINEAR_IMAGE THEN
      REWRITE_TAC[MATRIX_VECTOR_MUL_LINEAR; POLYHEDRON_POSITIVE_ORTHANT];
      MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `y:real^M` THEN
      DISCH_THEN(X_CHOOSE_THEN `c:real` STRIP_ASSUME_TAC) THEN
      ONCE_REWRITE_TAC[DOT_SYM] THEN
      FIRST_ASSUM(MP_TAC o SPEC `vec 0:real^N`) THEN
      REWRITE_TAC[MATRIX_VECTOR_MUL_RZERO; DOT_RZERO] THEN
      REWRITE_TAC[real_gt; VEC_COMPONENT; REAL_LE_REFL] THEN
      DISCH_TAC THEN CONJ_TAC THENL [ASM_REAL_ARITH_TAC; ALL_TAC] THEN
      X_GEN_TAC `k:num` THEN STRIP_TAC THEN
      ONCE_REWRITE_TAC[GSYM REAL_NOT_LT] THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPEC
       `c / (transp(A:real^N^M) ** (y:real^M))$k % basis k:real^N`) THEN
      ASM_SIMP_TAC[VECTOR_MUL_COMPONENT; BASIS_COMPONENT] THEN
      ONCE_REWRITE_TAC[GSYM DOT_LMUL_MATRIX] THEN
      ASM_SIMP_TAC[DOT_RMUL; DOT_BASIS; VECTOR_MATRIX_MUL_TRANSP] THEN
      ASM_SIMP_TAC[REAL_FIELD `y < &0 ==> x / y * y = x`] THEN
      REWRITE_TAC[REAL_LT_REFL; real_gt] THEN
      GEN_TAC THEN COND_CASES_TAC THEN
      ASM_REWRITE_TAC[REAL_MUL_RZERO; REAL_LE_REFL; REAL_MUL_RID] THEN
      ONCE_REWRITE_TAC[REAL_ARITH `x / y:real = --x * -- inv y`] THEN
      MATCH_MP_TAC REAL_LE_MUL THEN
      REWRITE_TAC[REAL_ARITH `&0 <= --x <=> ~(&0 < x)`; REAL_LT_INV_EQ] THEN
      ASM_REAL_ARITH_TAC]]);;

let FARKAS_LEMMA_ALT = prove
 (`!A:real^N^M b.
        (?x:real^N.
            (!i. 1 <= i /\ i <= dimindex(:M) ==> (A ** x)$i <= b$i)) <=>
        ~(?y:real^M.
            (!i. 1 <= i /\ i <= dimindex(:M) ==> &0 <= y$i) /\
            y ** A = vec 0 /\ b dot y < &0)`,
  REPEAT GEN_TAC THEN
  MATCH_MP_TAC(TAUT `~(p /\ q) /\ (~p ==> q) ==> (p <=> ~q)`) THEN
  REPEAT STRIP_TAC THENL
   [SUBGOAL_THEN `&0 <= (b - (A:real^N^M) ** x) dot y` MP_TAC THENL
     [REWRITE_TAC[dot] THEN MATCH_MP_TAC SUM_POS_LE THEN
      REWRITE_TAC[FINITE_NUMSEG; IN_NUMSEG] THEN
      REPEAT STRIP_TAC THEN MATCH_MP_TAC REAL_LE_MUL THEN
      ASM_SIMP_TAC[VECTOR_SUB_COMPONENT; REAL_SUB_LE];
      REWRITE_TAC[DOT_LSUB; REAL_SUB_LE] THEN REWRITE_TAC[REAL_NOT_LE] THEN
      GEN_REWRITE_TAC RAND_CONV [DOT_SYM] THEN
      REWRITE_TAC[GSYM DOT_LMUL_MATRIX] THEN
      ASM_REWRITE_TAC[DOT_LZERO]];
    MP_TAC(ISPECL
     [`{(A:real^N^M) ** (x:real^N) + s |x,s|
        !i. 1 <= i /\ i <= dimindex(:M) ==> &0 <= s$i}`;
      `b:real^M`] SEPARATING_HYPERPLANE_CLOSED_POINT) THEN
    REWRITE_TAC[FORALL_IN_GSPEC] THEN ANTS_TAC THENL
     [REWRITE_TAC[IN_ELIM_THM; CONJ_ASSOC] THEN CONJ_TAC THENL
       [ONCE_REWRITE_TAC[SET_RULE
         `{f x + y | x,y | P y} =
          {z + y | z,y | z IN IMAGE (f:real^M->real^N) (:real^M) /\
                         y IN {w | P w}}`] THEN
        SIMP_TAC[CONVEX_SUMS; CONVEX_POSITIVE_ORTHANT; CONVEX_LINEAR_IMAGE;
                 MATRIX_VECTOR_MUL_LINEAR; CONVEX_UNIV] THEN
        MATCH_MP_TAC POLYHEDRON_IMP_CLOSED THEN
        MATCH_MP_TAC POLYHEDRON_SUMS THEN
        ASM_SIMP_TAC[POLYHEDRON_LINEAR_IMAGE; POLYHEDRON_UNIV;
          MATRIX_VECTOR_MUL_LINEAR; POLYHEDRON_POSITIVE_ORTHANT];
        POP_ASSUM MP_TAC THEN REWRITE_TAC[CONTRAPOS_THM] THEN
        MATCH_MP_TAC MONO_EXISTS THEN REPEAT STRIP_TAC THEN
        ASM_SIMP_TAC[VECTOR_ADD_COMPONENT; REAL_LE_ADDR]];
      MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `y:real^M` THEN
      DISCH_THEN(X_CHOOSE_THEN `c:real` STRIP_ASSUME_TAC) THEN
      ONCE_REWRITE_TAC[DOT_SYM] THEN
      FIRST_ASSUM(MP_TAC o SPECL [`vec 0:real^N`; `vec 0:real^M`]) THEN
      REWRITE_TAC[MATRIX_VECTOR_MUL_RZERO; VECTOR_ADD_RID; DOT_RZERO] THEN
      REWRITE_TAC[real_gt; VEC_COMPONENT; REAL_LE_REFL] THEN
      DISCH_TAC THEN REWRITE_TAC[CONJ_ASSOC] THEN
      CONJ_TAC THENL [ALL_TAC; ASM_REAL_ARITH_TAC] THEN CONJ_TAC THENL
       [X_GEN_TAC `k:num` THEN STRIP_TAC THEN
        ONCE_REWRITE_TAC[GSYM REAL_NOT_LT] THEN DISCH_TAC THEN
        FIRST_X_ASSUM(MP_TAC o SPECL
         [`vec 0:real^N`; `--c / --((y:real^M)$k) % basis k:real^M`]) THEN
        ASM_SIMP_TAC[MATRIX_VECTOR_MUL_RZERO; VECTOR_ADD_LID;
                     DOT_RMUL; DOT_BASIS; REAL_FIELD
                      `y < &0 ==> c / --y * y = --c`] THEN
        SIMP_TAC[REAL_NEG_NEG; REAL_LT_REFL; VECTOR_MUL_COMPONENT; real_gt] THEN
        ASM_SIMP_TAC[BASIS_COMPONENT] THEN REPEAT STRIP_TAC THEN
        COND_CASES_TAC THEN
        ASM_REWRITE_TAC[REAL_MUL_RZERO; REAL_MUL_RID; REAL_LE_REFL] THEN
        MATCH_MP_TAC REAL_LE_DIV THEN ASM_REAL_ARITH_TAC;
        FIRST_X_ASSUM(MP_TAC o SPECL
         [`c / norm((y:real^M) ** (A:real^N^M)) pow 2 %
           (transp A ** y)`; `vec 0:real^M`]) THEN
        SIMP_TAC[VEC_COMPONENT; REAL_LE_REFL; VECTOR_ADD_RID] THEN
        ONCE_REWRITE_TAC[GSYM DOT_LMUL_MATRIX] THEN
        REWRITE_TAC[GSYM VECTOR_MATRIX_MUL_TRANSP; DOT_RMUL] THEN
        ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN DISCH_TAC THEN
        ASM_SIMP_TAC[REAL_DIV_RMUL; NORM_POW_2; DOT_EQ_0] THEN
        REAL_ARITH_TAC]]]);;

let SEPARATING_HYPERPLANE_POLYHEDRA = prove
 (`!s t:real^N->bool.
        polyhedron s /\ polyhedron t /\ ~(s = {}) /\ ~(t = {}) /\ DISJOINT s t
        ==> ?a b. ~(a = vec 0) /\
                  (!x. x IN s ==> a dot x < b) /\
                  (!x. x IN t ==> a dot x > b)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPEC `{x + y:real^N | x IN s /\ y IN IMAGE (--) t}`
        SEPARATING_HYPERPLANE_CLOSED_0) THEN
  ANTS_TAC THENL
   [ASM_SIMP_TAC[CONVEX_SUMS; CONVEX_NEGATIONS; POLYHEDRON_IMP_CONVEX] THEN
    CONJ_TAC THENL
     [MATCH_MP_TAC POLYHEDRON_IMP_CLOSED THEN
      MATCH_MP_TAC POLYHEDRON_SUMS THEN ASM_SIMP_TAC[POLYHEDRON_NEGATIONS];
      REWRITE_TAC[IN_IMAGE; IN_ELIM_THM] THEN
      REWRITE_TAC[VECTOR_ARITH `y = --x:real^N <=> --y = x`] THEN
      REWRITE_TAC[UNWIND_THM1] THEN ONCE_REWRITE_TAC[CONJ_SYM] THEN
      REWRITE_TAC[VECTOR_ARITH `vec 0:real^N = x + y <=> y = --x`] THEN
      REWRITE_TAC[UNWIND_THM2; VECTOR_NEG_NEG] THEN ASM SET_TAC[]];
    REWRITE_TAC[FORALL_IN_GSPEC; IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN
    REWRITE_TAC[FORALL_IN_IMAGE; GSYM VECTOR_SUB; LEFT_IMP_EXISTS_THM] THEN
    MAP_EVERY X_GEN_TAC [`a:real^N`; `k:real`] THEN
    REWRITE_TAC[RIGHT_IMP_FORALL_THM; IMP_IMP; DOT_RSUB] THEN STRIP_TAC THEN
    EXISTS_TAC `--a:real^N` THEN ASM_REWRITE_TAC[VECTOR_NEG_EQ_0] THEN
    MP_TAC(ISPEC `IMAGE (\x:real^N. a dot x) s` INF) THEN
    MP_TAC(ISPEC `IMAGE (\x:real^N. a dot x) t` SUP) THEN
    ASM_REWRITE_TAC[FORALL_IN_IMAGE; IMAGE_EQ_EMPTY] THEN
    MAP_EVERY ABBREV_TAC
     [`u = inf(IMAGE (\x:real^N. a dot x) s)`;
      `v = sup(IMAGE (\x:real^N. a dot x) t)`] THEN
    ANTS_TAC THENL
     [MP_TAC(GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]
        (ASSUME `~(s:real^N->bool = {})`)) THEN
      DISCH_THEN(X_CHOOSE_TAC `z:real^N`) THEN
      EXISTS_TAC `a dot (z:real^N) - k` THEN
      X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPECL [`z:real^N`; `x:real^N`]) THEN
      ASM_REWRITE_TAC[] THEN REAL_ARITH_TAC;
      STRIP_TAC] THEN
    ANTS_TAC THENL
     [MP_TAC(GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]
        (ASSUME `~(t:real^N->bool = {})`)) THEN
      DISCH_THEN(X_CHOOSE_TAC `z:real^N`) THEN
      EXISTS_TAC `a dot (z:real^N) + k` THEN
      X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
      FIRST_X_ASSUM(MP_TAC o SPECL [`x:real^N`; `z:real^N`]) THEN
      ASM_REWRITE_TAC[] THEN REAL_ARITH_TAC;
      STRIP_TAC] THEN
    SUBGOAL_THEN `k <= u - v` ASSUME_TAC THENL
     [REWRITE_TAC[REAL_LE_SUB_LADD] THEN EXPAND_TAC "u" THEN
      MATCH_MP_TAC REAL_LE_INF THEN
      ASM_REWRITE_TAC[IMAGE_EQ_EMPTY; FORALL_IN_IMAGE] THEN
      GEN_TAC THEN DISCH_TAC THEN
      ONCE_REWRITE_TAC[REAL_ARITH `k + v <= u <=> v <= u - k`] THEN
      EXPAND_TAC "v" THEN MATCH_MP_TAC REAL_SUP_LE THEN
      ASM_REWRITE_TAC[IMAGE_EQ_EMPTY; FORALL_IN_IMAGE] THEN
      ASM_MESON_TAC[REAL_ARITH `x - y > k ==> y <= x - k`];
      EXISTS_TAC `--((u + v) / &2)` THEN REWRITE_TAC[real_gt] THEN
      REWRITE_TAC[DOT_LNEG; REAL_LT_NEG2] THEN REPEAT STRIP_TAC THENL
       [MATCH_MP_TAC REAL_LTE_TRANS THEN EXISTS_TAC `u:real`;
        MATCH_MP_TAC REAL_LET_TRANS THEN EXISTS_TAC `v:real`] THEN
      ASM_SIMP_TAC[] THEN ASM_REAL_ARITH_TAC]]);;

(* ------------------------------------------------------------------------- *)
(* Relative and absolute frontier of a polytope.                             *)
(* ------------------------------------------------------------------------- *)

let RELATIVE_BOUNDARY_OF_CONVEX_HULL = prove
 (`!s:real^N->bool.
        ~affine_dependent s
        ==> (convex hull s) DIFF relative_interior(convex hull s) =
            UNIONS { convex hull (s DELETE a) | a | a IN s}`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP AFFINE_INDEPENDENT_IMP_FINITE) THEN
  REPEAT_TCL DISJ_CASES_THEN MP_TAC (ARITH_RULE
    `CARD(s:real^N->bool) = 0 \/ CARD s = 1 \/ 2 <= CARD s`)
  THENL
   [ASM_SIMP_TAC[CARD_EQ_0; CONVEX_HULL_EMPTY] THEN SET_TAC[];
    DISCH_TAC THEN MP_TAC(HAS_SIZE_CONV `(s:real^N->bool) HAS_SIZE 1`) THEN
    ASM_SIMP_TAC[HAS_SIZE; LEFT_IMP_EXISTS_THM; CONVEX_HULL_SING] THEN
    REWRITE_TAC[RELATIVE_INTERIOR_SING; DIFF_EQ_EMPTY] THEN
    REPEAT STRIP_TAC THEN CONV_TAC SYM_CONV THEN REWRITE_TAC[EMPTY_UNIONS] THEN
    REWRITE_TAC[FORALL_IN_GSPEC; IN_SING; FORALL_UNWIND_THM2] THEN
    REWRITE_TAC[CONVEX_HULL_EQ_EMPTY] THEN SET_TAC[];
    DISCH_TAC THEN
    ASM_SIMP_TAC[POLYHEDRON_CONVEX_HULL; RELATIVE_BOUNDARY_OF_POLYHEDRON] THEN
    ASM_SIMP_TAC[FACET_OF_CONVEX_HULL_AFFINE_INDEPENDENT_ALT] THEN
    SET_TAC[]]);;

let RELATIVE_FRONTIER_OF_CONVEX_HULL = prove
 (`!s:real^N->bool.
        ~affine_dependent s
        ==> relative_frontier(convex hull s) =
            UNIONS { convex hull (s DELETE a) | a | a IN s}`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP AFFINE_INDEPENDENT_IMP_FINITE) THEN
  ASM_SIMP_TAC[relative_frontier; GSYM RELATIVE_BOUNDARY_OF_CONVEX_HULL] THEN
  AP_THM_TAC THEN AP_TERM_TAC THEN MATCH_MP_TAC CLOSURE_CLOSED THEN
  ASM_SIMP_TAC[COMPACT_IMP_CLOSED; FINITE_IMP_COMPACT; COMPACT_CONVEX_HULL]);;

let FRONTIER_OF_CONVEX_HULL = prove
 (`!s:real^N->bool.
        s HAS_SIZE (dimindex(:N) + 1)
        ==> frontier(convex hull s) =
               UNIONS { convex hull (s DELETE a) | a | a IN s}`,
  REWRITE_TAC[HAS_SIZE] THEN REPEAT STRIP_TAC THEN
  ASM_CASES_TAC `affine_dependent(s:real^N->bool)` THENL
   [REWRITE_TAC[frontier] THEN MATCH_MP_TAC EQ_TRANS THEN
    EXISTS_TAC `(convex hull s:real^N->bool) DIFF {}` THEN CONJ_TAC THENL
     [BINOP_TAC THEN
      ASM_SIMP_TAC[INTERIOR_CONVEX_HULL_EQ_EMPTY; frontier; HAS_SIZE] THEN
      MATCH_MP_TAC CLOSURE_CLOSED THEN
      ASM_SIMP_TAC[CLOSURE_CLOSED; COMPACT_IMP_CLOSED; COMPACT_CONVEX_HULL;
                   FINITE_IMP_COMPACT; FINITE_INSERT; FINITE_EMPTY];
      REWRITE_TAC[DIFF_EMPTY] THEN MATCH_MP_TAC SUBSET_ANTISYM THEN
      CONJ_TAC THENL
       [GEN_REWRITE_TAC LAND_CONV [CARATHEODORY_AFF_DIM] THEN
        ONCE_REWRITE_TAC[SIMPLE_IMAGE] THEN
        GEN_REWRITE_TAC I [SUBSET] THEN
        REWRITE_TAC[IN_ELIM_THM; UNIONS_IMAGE] THEN
        X_GEN_TAC `x:real^N` THEN
        DISCH_THEN(X_CHOOSE_THEN `t:real^N->bool` STRIP_ASSUME_TAC) THEN
        MP_TAC(ISPEC `s:real^N->bool` AFFINE_INDEPENDENT_IFF_CARD) THEN
        ASM_REWRITE_TAC[GSYM INT_OF_NUM_ADD] THEN
        REWRITE_TAC[INT_ARITH `(x + &1) - &1:int = x`] THEN DISCH_TAC THEN
        SUBGOAL_THEN `(t:real^N->bool) PSUBSET s` ASSUME_TAC THENL
         [ASM_REWRITE_TAC[PSUBSET] THEN
          DISCH_THEN(MP_TAC o AP_TERM `CARD:(real^N->bool)->num`) THEN
          MATCH_MP_TAC(ARITH_RULE `t:num < s ==> t = s ==> F`) THEN
          ASM_REWRITE_TAC[ARITH_RULE `x < n + 1 <=> x <= n`] THEN
          REWRITE_TAC[GSYM INT_OF_NUM_LE] THEN MATCH_MP_TAC INT_LE_TRANS THEN
          EXISTS_TAC `aff_dim(s:real^N->bool) + &1` THEN
          ASM_REWRITE_TAC[] THEN MATCH_MP_TAC(INT_ARITH
           `s:int <= n /\ ~(s = n) ==> s + &1 <= n`) THEN
          ASM_REWRITE_TAC[AFF_DIM_LE_UNIV];
          SUBGOAL_THEN `?a:real^N. a IN s /\ ~(a IN t)` MP_TAC THENL
           [ASM SET_TAC[]; MATCH_MP_TAC MONO_EXISTS] THEN
          X_GEN_TAC `a:real^N` THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
          SUBGOAL_THEN
           `(convex hull t) SUBSET convex hull (s DELETE (a:real^N))`
          MP_TAC THENL
           [MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[]; ASM SET_TAC[]]];
        ONCE_REWRITE_TAC[SIMPLE_IMAGE] THEN REWRITE_TAC[UNIONS_IMAGE] THEN
        REWRITE_TAC[SUBSET; IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN
        ONCE_REWRITE_TAC[SWAP_FORALL_THM] THEN
        REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; GSYM SUBSET] THEN
        REPEAT STRIP_TAC THEN MATCH_MP_TAC HULL_MONO THEN SET_TAC[]]];
    MATCH_MP_TAC EQ_TRANS THEN
    EXISTS_TAC
     `(convex hull s) DIFF relative_interior(convex hull s):real^N->bool` THEN
    CONJ_TAC THENL
     [ASM_SIMP_TAC[GSYM RELATIVE_BOUNDARY_OF_CONVEX_HULL; frontier] THEN
      BINOP_TAC THENL
       [MATCH_MP_TAC CLOSURE_CLOSED THEN
        ASM_SIMP_TAC[CLOSURE_CLOSED; COMPACT_IMP_CLOSED; COMPACT_CONVEX_HULL;
                     FINITE_IMP_COMPACT; FINITE_INSERT; FINITE_EMPTY];
        CONV_TAC SYM_CONV THEN MATCH_MP_TAC RELATIVE_INTERIOR_INTERIOR THEN
        REWRITE_TAC[AFFINE_HULL_CONVEX_HULL] THEN
        REWRITE_TAC[GSYM AFF_DIM_EQ_FULL] THEN
        FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I
          [AFFINE_INDEPENDENT_IFF_CARD]) THEN
        ASM_REWRITE_TAC[GSYM INT_OF_NUM_ADD] THEN INT_ARITH_TAC];
      ASM_SIMP_TAC[RELATIVE_BOUNDARY_OF_POLYHEDRON;
                   POLYHEDRON_CONVEX_HULL; FINITE_INSERT; FINITE_EMPTY] THEN
      ASM_SIMP_TAC[FACET_OF_CONVEX_HULL_AFFINE_INDEPENDENT_ALT] THEN
      REWRITE_TAC[ARITH_RULE `2 <= n + 1 <=> 1 <= n`; DIMINDEX_GE_1] THEN
      ASM SET_TAC[]]]);;

(* ------------------------------------------------------------------------- *)
(* Special case of a triangle.                                               *)
(* ------------------------------------------------------------------------- *)

let RELATIVE_BOUNDARY_OF_TRIANGLE = prove
 (`!a b c:real^N.
        ~collinear {a,b,c}
        ==> convex hull {a,b,c} DIFF relative_interior(convex hull {a,b,c}) =
            segment[a,b] UNION segment[b,c] UNION segment[c,a]`,
  REPEAT STRIP_TAC THEN
  ONCE_REWRITE_TAC[SET_RULE `s UNION t UNION u = t UNION u UNION s`] THEN
  FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE RAND_CONV
   [COLLINEAR_3_EQ_AFFINE_DEPENDENT]) THEN
  REWRITE_TAC[DE_MORGAN_THM; SEGMENT_CONVEX_HULL] THEN STRIP_TAC THEN
  ASM_SIMP_TAC[RELATIVE_BOUNDARY_OF_CONVEX_HULL] THEN
  ONCE_REWRITE_TAC[SIMPLE_IMAGE] THEN
  REWRITE_TAC[IMAGE_CLAUSES; UNIONS_INSERT; UNIONS_0; UNION_EMPTY] THEN
  REPEAT BINOP_TAC THEN REWRITE_TAC[] THEN ASM SET_TAC[]);;

let RELATIVE_FRONTIER_OF_TRIANGLE = prove
 (`!a b c:real^N.
        ~collinear {a,b,c}
        ==> relative_frontier(convex hull {a,b,c}) =
            segment[a,b] UNION segment[b,c] UNION segment[c,a]`,
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[GSYM RELATIVE_BOUNDARY_OF_TRIANGLE; relative_frontier] THEN
  AP_THM_TAC THEN AP_TERM_TAC THEN MATCH_MP_TAC CLOSURE_CLOSED THEN
  ASM_SIMP_TAC[COMPACT_IMP_CLOSED; FINITE_IMP_COMPACT; COMPACT_CONVEX_HULL;
               FINITE_INSERT; FINITE_EMPTY]);;

let FRONTIER_OF_TRIANGLE = prove
 (`!a b c:real^2.
        frontier(convex hull {a,b,c}) =
            segment[a,b] UNION segment[b,c] UNION segment[c,a]`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[SEGMENT_CONVEX_HULL] THEN
  ONCE_REWRITE_TAC[SET_RULE `s UNION t UNION u = t UNION u UNION s`] THEN
  MAP_EVERY (fun t -> ASM_CASES_TAC t THENL
   [ASM_REWRITE_TAC[INSERT_AC; UNION_ACI] THEN
    SIMP_TAC[GSYM SEGMENT_CONVEX_HULL; frontier; CLOSURE_SEGMENT;
             INTERIOR_SEGMENT; DIMINDEX_2; LE_REFL; DIFF_EMPTY] THEN
    REWRITE_TAC[CONVEX_HULL_SING] THEN
    REWRITE_TAC[SET_RULE `s = s UNION {a} <=> a IN s`;
                SET_RULE `s = {a} UNION s <=> a IN s`] THEN
    REWRITE_TAC[ENDS_IN_SEGMENT];
    ALL_TAC])
   [`b:real^2 = a`; `c:real^2 = a`; `c:real^2 = b`] THEN
  SUBGOAL_THEN `{a:real^2,b,c} HAS_SIZE (dimindex(:2) + 1)` ASSUME_TAC THENL
   [SIMP_TAC[HAS_SIZE; CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY] THEN
    ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; DIMINDEX_2] THEN
    CONV_TAC NUM_REDUCE_CONV;
    ASM_SIMP_TAC[FRONTIER_OF_CONVEX_HULL] THEN
    ONCE_REWRITE_TAC[SIMPLE_IMAGE] THEN
    REWRITE_TAC[IMAGE_CLAUSES; UNIONS_INSERT; UNIONS_0; UNION_EMPTY] THEN
    REPEAT BINOP_TAC THEN REWRITE_TAC[] THEN ASM SET_TAC[]]);;

let INSIDE_OF_TRIANGLE = prove
 (`!a b c:real^2.
        inside(segment[a,b] UNION segment[b,c] UNION segment[c,a]) =
                interior(convex hull {a,b,c})`,
  REPEAT GEN_TAC THEN REWRITE_TAC[GSYM FRONTIER_OF_TRIANGLE] THEN
  MATCH_MP_TAC INSIDE_FRONTIER_EQ_INTERIOR THEN
  REWRITE_TAC[CONVEX_CONVEX_HULL] THEN MATCH_MP_TAC BOUNDED_CONVEX_HULL THEN
  MATCH_MP_TAC FINITE_IMP_BOUNDED THEN
  REWRITE_TAC[FINITE_INSERT; FINITE_EMPTY]);;

let INTERIOR_OF_TRIANGLE = prove
 (`!a b c:real^2.
        interior(convex hull {a,b,c}) =
        (convex hull {a,b,c}) DIFF
        (segment[a,b] UNION segment[b,c] UNION segment[c,a])`,
  REPEAT GEN_TAC THEN REWRITE_TAC[GSYM FRONTIER_OF_TRIANGLE; frontier] THEN
  MATCH_MP_TAC(SET_RULE `i SUBSET s /\ c = s ==> i = s DIFF (c DIFF i)`) THEN
  REWRITE_TAC[INTERIOR_SUBSET] THEN MATCH_MP_TAC CLOSURE_CONVEX_HULL THEN
  SIMP_TAC[FINITE_IMP_COMPACT; FINITE_INSERT; FINITE_EMPTY]);;

(* ------------------------------------------------------------------------- *)
(* A ridge is the intersection of precisely two facets.                      *)
(* ------------------------------------------------------------------------- *)

let POLYHEDRON_RIDGE_TWO_FACETS = prove
 (`!p:real^N->bool r.
    polyhedron p /\ r face_of p /\ ~(r = {}) /\ aff_dim r = aff_dim p - &2
    ==> ?f1 f2. f1 face_of p /\ aff_dim f1 = aff_dim p - &1 /\
                f2 face_of p /\ aff_dim f2 = aff_dim p - &1 /\
                 ~(f1 = f2) /\ r SUBSET f1 /\ r SUBSET f2 /\ f1 INTER f2 = r /\
                !f. f face_of p /\ aff_dim f = aff_dim p - &1 /\ r SUBSET f
                    ==> f = f1 \/ f = f2`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`p:real^N->bool`; `r:real^N->bool`] FACE_OF_POLYHEDRON) THEN
  ANTS_TAC THENL [ASM_MESON_TAC[INT_ARITH `~(p:int = p - &2)`]; ALL_TAC] THEN
  SUBGOAL_THEN `&2 <= aff_dim(p:real^N->bool)` ASSUME_TAC THENL
   [MP_TAC(ISPEC `r:real^N->bool` AFF_DIM_GE) THEN
    MP_TAC(ISPEC `r:real^N->bool` AFF_DIM_EQ_MINUS1) THEN
    ASM_REWRITE_TAC[] THEN INT_ARITH_TAC;
    ALL_TAC] THEN
  SUBGOAL_THEN
   `{f:real^N->bool | f facet_of p /\ r SUBSET f} =
    {f | f face_of p /\ aff_dim f = aff_dim p - &1 /\ r SUBSET f}`
  SUBST1_TAC THENL
   [GEN_REWRITE_TAC I [EXTENSION] THEN
    ASM_REWRITE_TAC[IN_ELIM_THM; facet_of] THEN
    X_GEN_TAC `f:real^N->bool` THEN
    ASM_CASES_TAC `f:real^N->bool = {}` THEN
    ASM_REWRITE_TAC[AFF_DIM_EMPTY; GSYM CONJ_ASSOC] THEN ASM_INT_ARITH_TAC;
    DISCH_THEN(MP_TAC o SYM)] THEN
  ASM_CASES_TAC
   `{f:real^N->bool | f face_of p /\ aff_dim f = aff_dim p - &1 /\ r SUBSET f}
    = {}`
  THENL
   [ASM_REWRITE_TAC[INTERS_0] THEN DISCH_THEN(ASSUME_TAC o SYM) THEN
    UNDISCH_TAC `aff_dim(r:real^N->bool) = aff_dim(p:real^N->bool) - &2` THEN
    ASM_REWRITE_TAC[AFF_DIM_UNIV; DIMINDEX_3] THEN
    MP_TAC(ISPEC `p:real^N->bool` AFF_DIM_LE_UNIV) THEN INT_ARITH_TAC;
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  REWRITE_TAC[LEFT_IMP_EXISTS_THM; IN_ELIM_THM] THEN
  X_GEN_TAC `f1:real^N->bool` THEN STRIP_TAC THEN
  ASM_CASES_TAC
   `{f:real^N->bool | f face_of p /\ aff_dim f = aff_dim p - &1 /\ r SUBSET f}
    = {f1}`
  THENL
   [ASM_REWRITE_TAC[INTERS_1] THEN
    ASM_MESON_TAC[INT_ARITH `~(x - &2:int = x - &1)`];
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP (SET_RULE
   `~(s = {a}) ==> a IN s ==> ?b. ~(b = a) /\ b IN s`)) THEN
  ASM_REWRITE_TAC[IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `f2:real^N->bool` THEN STRIP_TAC THEN
  ASM_CASES_TAC
   `{f:real^N->bool | f face_of p /\ aff_dim f = aff_dim p - &1 /\ r SUBSET f}
    = {f1,f2}`
  THENL
   [ASM_REWRITE_TAC[INTERS_2] THEN DISCH_TAC THEN
    MAP_EVERY EXISTS_TAC [`f1:real^N->bool`; `f2:real^N->bool`] THEN
    ASM_REWRITE_TAC[] THEN ASM SET_TAC[];
    ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o MATCH_MP (SET_RULE
   `~(s = {a,b})
    ==> a IN s /\ b IN s ==> ?c. ~(c = a) /\ ~(c = b) /\ c IN s`)) THEN
  ASM_REWRITE_TAC[IN_ELIM_THM; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `f3:real^N->bool` THEN STRIP_TAC THEN DISCH_TAC THEN
  UNDISCH_TAC `aff_dim(r:real^N->bool) = aff_dim(p:real^N->bool) - &2` THEN
  MATCH_MP_TAC(TAUT `~p ==> p ==> q`) THEN
  MATCH_MP_TAC(INT_ARITH `~(p - &2:int <= x:int) ==> ~(x = p - &2)`) THEN
  DISCH_TAC THEN SUBGOAL_THEN
   `~(f1:real^N->bool = {}) /\
    ~(f2:real^N->bool = {}) /\
    ~(f3:real^N->bool = {})`
  STRIP_ASSUME_TAC THENL
   [REPEAT CONJ_TAC THEN DISCH_THEN SUBST_ALL_TAC THEN
    RULE_ASSUM_TAC(REWRITE_RULE[AFF_DIM_EMPTY]) THEN ASM_INT_ARITH_TAC;
    ALL_TAC] THEN
  MP_TAC(ISPEC `p:real^N->bool` POLYHEDRON_INTER_AFFINE_PARALLEL_MINIMAL) THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  ASM_REWRITE_TAC[NOT_EXISTS_THM] THEN MAP_EVERY X_GEN_TAC
   [`f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN
  REWRITE_TAC[VECTOR_ARITH `vec 0:real^N = v <=> v = vec 0`] THEN
  STRIP_TAC THEN MP_TAC(ISPECL
   [`p:real^N->bool`; `f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] FACET_OF_POLYHEDRON_EXPLICIT) THEN
  ASM_SIMP_TAC[] THEN DISCH_THEN(fun th ->
    MP_TAC(SPEC `f1:real^N->bool` th) THEN
    MP_TAC(SPEC `f2:real^N->bool` th) THEN
    MP_TAC(SPEC `f3:real^N->bool` th)) THEN
  ASM_REWRITE_TAC[facet_of] THEN
  DISCH_THEN(X_CHOOSE_THEN `h3:real^N->bool` (STRIP_ASSUME_TAC o GSYM)) THEN
  DISCH_THEN(X_CHOOSE_THEN `h2:real^N->bool` (STRIP_ASSUME_TAC o GSYM)) THEN
  DISCH_THEN(X_CHOOSE_THEN `h1:real^N->bool` (STRIP_ASSUME_TAC o GSYM)) THEN
  SUBGOAL_THEN `~((a:(real^N->bool)->real^N) h1 = a h2) /\
                 ~(a h2 = a h3) /\ ~(a h1 = a h3)`
  STRIP_ASSUME_TAC THENL
   [REPEAT CONJ_TAC THENL
     [DISJ_CASES_TAC(REAL_ARITH
       `b(h1:real^N->bool) <= b h2 \/ b h2 <= b h1`)
      THENL
       [FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h2:real^N->bool)`);
        FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h1:real^N->bool)`)] THEN
      (ANTS_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
       MATCH_MP_TAC(SET_RULE `(p ==> s = t) ==> s PSUBSET t ==> ~p`) THEN
       DISCH_TAC THEN
       FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC LAND_CONV [SYM th]) THEN
       AP_TERM_TAC)
      THENL
       [SUBGOAL_THEN `f DELETE h2 = h1 INSERT (f DIFF {h1,h2}) /\
                      f = (h2:real^N->bool) INSERT h1 INSERT (f DIFF {h1,h2})`
         (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC];
        SUBGOAL_THEN `f DELETE h1 = h2 INSERT (f DIFF {h1,h2}) /\
                      f = (h1:real^N->bool) INSERT h2 INSERT (f DIFF {h1,h2})`
         (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC]] THEN
      REWRITE_TAC[INTERS_INSERT] THEN MATCH_MP_TAC(SET_RULE
       `b SUBSET a ==> a INTER b INTER s = b INTER s`) THEN
      FIRST_X_ASSUM(fun th ->
       MP_TAC(SPEC `h1:real^N->bool` th) THEN
       MP_TAC(SPEC `h2:real^N->bool` th)) THEN
      ASM_REWRITE_TAC[IMP_IMP] THEN
      DISCH_THEN(fun th -> ONCE_REWRITE_TAC[GSYM th]) THEN
      REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN ASM_REAL_ARITH_TAC;
      DISJ_CASES_TAC(REAL_ARITH
       `b(h2:real^N->bool) <= b h3 \/ b h3 <= b h2`)
      THENL
       [FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h3:real^N->bool)`);
        FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h2:real^N->bool)`)] THEN
      (ANTS_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
       MATCH_MP_TAC(SET_RULE `(p ==> s = t) ==> s PSUBSET t ==> ~p`) THEN
       DISCH_TAC THEN
       FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC LAND_CONV [SYM th]) THEN
       AP_TERM_TAC)
      THENL
       [SUBGOAL_THEN `f DELETE h3 = h2 INSERT (f DIFF {h2,h3}) /\
                      f = (h3:real^N->bool) INSERT h2 INSERT (f DIFF {h2,h3})`
         (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC];
        SUBGOAL_THEN `f DELETE h2 = h3 INSERT (f DIFF {h2,h3}) /\
                      f = (h2:real^N->bool) INSERT h3 INSERT (f DIFF {h2,h3})`
         (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC]] THEN
      REWRITE_TAC[INTERS_INSERT] THEN MATCH_MP_TAC(SET_RULE
       `b SUBSET a ==> a INTER b INTER s = b INTER s`) THEN
      FIRST_X_ASSUM(fun th ->
       MP_TAC(SPEC `h2:real^N->bool` th) THEN
       MP_TAC(SPEC `h3:real^N->bool` th)) THEN
      ASM_REWRITE_TAC[IMP_IMP] THEN
      DISCH_THEN(fun th -> ONCE_REWRITE_TAC[GSYM th]) THEN
      REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN ASM_REAL_ARITH_TAC;
      DISJ_CASES_TAC(REAL_ARITH
       `b(h1:real^N->bool) <= b h3 \/ b h3 <= b h1`)
      THENL
       [FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h3:real^N->bool)`);
        FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h1:real^N->bool)`)] THEN
      (ANTS_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
       MATCH_MP_TAC(SET_RULE `(p ==> s = t) ==> s PSUBSET t ==> ~p`) THEN
       DISCH_TAC THEN
       FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC LAND_CONV [SYM th]) THEN
       AP_TERM_TAC)
      THENL
       [SUBGOAL_THEN `f DELETE h3 = h1 INSERT (f DIFF {h1,h3}) /\
                      f = (h3:real^N->bool) INSERT h1 INSERT (f DIFF {h1,h3})`
         (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC];
        SUBGOAL_THEN `f DELETE h1 = h3 INSERT (f DIFF {h1,h3}) /\
                      f = (h1:real^N->bool) INSERT h3 INSERT (f DIFF {h1,h3})`
         (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC]] THEN
      REWRITE_TAC[INTERS_INSERT] THEN MATCH_MP_TAC(SET_RULE
       `b SUBSET a ==> a INTER b INTER s = b INTER s`) THEN
      FIRST_X_ASSUM(fun th ->
       MP_TAC(SPEC `h1:real^N->bool` th) THEN
       MP_TAC(SPEC `h3:real^N->bool` th)) THEN
      ASM_REWRITE_TAC[IMP_IMP] THEN
      DISCH_THEN(fun th -> ONCE_REWRITE_TAC[GSYM th]) THEN
      REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN ASM_REAL_ARITH_TAC];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `~({x | a h1 dot x <= b h1} INTER {x | a h2 dot x <= b h2}
      SUBSET {x | a h3 dot x <= b h3}) /\
    ~({x | a h1 dot x <= b h1} INTER {x | a h3 dot x <= b h3}
      SUBSET {x | a h2 dot x <= b h2}) /\
    ~({x | a h2 dot x <= b h2} INTER {x | a h3 dot x <= b h3}
      SUBSET {x:real^N | a(h1:real^N->bool) dot x <= b h1})`
  MP_TAC THENL
   [ASM_SIMP_TAC[] THEN REPEAT STRIP_TAC THENL
     [FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h3:real^N->bool)`);
      FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h2:real^N->bool)`);
      FIRST_X_ASSUM(MP_TAC o SPEC `f DELETE (h1:real^N->bool)`)] THEN
    (ANTS_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
     FIRST_X_ASSUM(fun th -> GEN_REWRITE_TAC
       (LAND_CONV o LAND_CONV) [SYM th]) THEN
     MATCH_MP_TAC(SET_RULE `s = t ==> s PSUBSET t ==> F`) THEN
     AP_TERM_TAC)
    THENL
     [SUBGOAL_THEN
       `f DELETE (h3:real^N->bool) = h1 INSERT h2 INSERT (f DELETE h3) /\
        f =  h1 INSERT h2 INSERT h3 INSERT (f DELETE h3)`
       (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC];
      SUBGOAL_THEN
       `f DELETE (h2:real^N->bool) = h1 INSERT h3 INSERT (f DELETE h2) /\
        f =  h2 INSERT h1 INSERT h3 INSERT (f DELETE h2)`
       (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC];
      SUBGOAL_THEN
       `f DELETE (h1:real^N->bool) = h2 INSERT h3 INSERT (f DELETE h1) /\
        f =  h1 INSERT h2 INSERT h3 INSERT (f DELETE h1)`
       (fun th -> ONCE_REWRITE_TAC[th]) THENL [ASM SET_TAC[]; ALL_TAC]] THEN
    REWRITE_TAC[INTERS_INSERT] THEN REWRITE_TAC[GSYM INTER_ASSOC] THEN
    AP_THM_TAC THEN AP_TERM_TAC THEN ASM SET_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `?w. (a:(real^N->bool)->real^N) h1 dot w < b h1 /\
        a h2 dot w < b h2 /\ a h3 dot w < b h3`
   (CHOOSE_THEN MP_TAC)
  THENL
   [SUBGOAL_THEN `~(relative_interior p :real^N->bool = {})` MP_TAC THENL
     [ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY; POLYHEDRON_IMP_CONVEX] THEN
      ASM SET_TAC[];
      ALL_TAC] THEN
    MP_TAC(ISPECL
     [`p:real^N->bool`; `f:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
      `b:(real^N->bool)->real`] RELATIVE_INTERIOR_POLYHEDRON_EXPLICIT) THEN
    ASM_SIMP_TAC[] THEN DISCH_THEN(K ALL_TAC) THEN
    REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_ELIM_THM] THEN
    MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC THEN
    DISCH_THEN(MP_TAC o CONJUNCT2) THEN ASM_SIMP_TAC[];
    ALL_TAC] THEN
  SUBGOAL_THEN
   `!x. x IN r ==> (a h1) dot (x:real^N) = b h1 /\
                   (a h2) dot x = b h2 /\
                   (a (h3:real^N->bool)) dot x = b h3`
  MP_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN `?z:real^N. z IN r` CHOOSE_TAC THENL
   [ASM SET_TAC[]; ALL_TAC] THEN
  MAP_EVERY UNDISCH_TAC
   [`~((a:(real^N->bool)->real^N) h1 = a h2)`;
    `~((a:(real^N->bool)->real^N) h1 = a h3)`;
    `~((a:(real^N->bool)->real^N) h2 = a h3)`;
    `aff_dim(p:real^N->bool) - &2 <= aff_dim(r:real^N->bool)`] THEN
  MAP_EVERY (fun t ->
    FIRST_X_ASSUM(fun th -> MP_TAC(SPEC t th) THEN ASM_REWRITE_TAC[] THEN
                            ASSUME_TAC th) THEN
    DISCH_THEN(MP_TAC o SPEC `z:real^N` o CONJUNCT2 o CONJUNCT2))
   [`h1:real^N->bool`; `h2:real^N->bool`; `h3:real^N->bool`] THEN
  SUBGOAL_THEN `(z:real^N) IN (affine hull p)` ASSUME_TAC THENL
   [MATCH_MP_TAC HULL_INC THEN ASM SET_TAC[];
    ASM_REWRITE_TAC[]] THEN
  UNDISCH_TAC `(z:real^N) IN (affine hull p)` THEN
  SUBGOAL_THEN `(a h1) dot (z:real^N) = b h1 /\
                (a h2) dot z = b h2 /\
                (a (h3:real^N->bool)) dot z = b h3`
  (REPEAT_TCL CONJUNCTS_THEN (SUBST1_TAC o SYM))
  THENL [ASM SET_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN `(r:real^N->bool) SUBSET affine hull p` MP_TAC THENL
   [ASM_MESON_TAC[FACE_OF_IMP_SUBSET; HULL_SUBSET; SUBSET_TRANS]; ALL_TAC] THEN
  SUBGOAL_THEN
   `~((a:(real^N->bool)->real^N) h1 = vec 0) /\
    ~((a:(real^N->bool)->real^N) h2 = vec 0) /\
    ~((a:(real^N->bool)->real^N) h3 = vec 0)`
  MP_TAC THENL [ASM_SIMP_TAC[]; ALL_TAC] THEN
  UNDISCH_TAC `(z:real^N) IN r` THEN POP_ASSUM_LIST(K ALL_TAC) THEN
  MAP_EVERY SPEC_TAC
   [`(a:(real^N->bool)->real^N) h1`,`a1:real^N`;
    `(a:(real^N->bool)->real^N) h2`,`a2:real^N`;
    `(a:(real^N->bool)->real^N) h3`,`a3:real^N`] THEN
  REPEAT GEN_TAC THEN
  GEN_GEOM_ORIGIN_TAC `z:real^N` ["a1"; "a2"; "a3"] THEN
  REWRITE_TAC[VECTOR_ADD_RID; VECTOR_ADD_LID] THEN
  REWRITE_TAC[DOT_RADD; IMAGE_CLAUSES;
   REAL_ARITH `a + b:real <= a <=> b <= &0`;
   REAL_ARITH `a + b:real < a <=> b < &0`;
   REAL_ARITH `a + b:real = a <=> b = &0`] THEN

  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `aff_dim(p:real^N->bool) = &(dim p)` SUBST_ALL_TAC THENL
   [ASM_SIMP_TAC[AFF_DIM_DIM_0; HULL_INC]; ALL_TAC] THEN
  SUBGOAL_THEN `aff_dim(r:real^N->bool) = &(dim r)` SUBST_ALL_TAC THENL
   [ASM_SIMP_TAC[AFF_DIM_DIM_0; HULL_INC]; ALL_TAC] THEN
  RULE_ASSUM_TAC(REWRITE_RULE[INT_OF_NUM_ADD; INT_OF_NUM_LE;
    INT_ARITH `p - &2:int <= q <=> p <= q + &2`]) THEN
  MP_TAC(ISPECL
   [`{a1:real^N,a2,a3}`; `r:real^N->bool`] DIM_ORTHOGONAL_SUM) THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM] THEN
  ASM_SIMP_TAC[FORALL_IN_INSERT; NOT_IN_EMPTY] THEN
  FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (ARITH_RULE
    `p <= r + 2 ==> u <= p /\ 3 <= t ==> ~(u = t + r)`)) THEN
  SUBGOAL_THEN `affine hull p :real^N->bool = span p` SUBST_ALL_TAC THENL
   [ASM_MESON_TAC[AFFINE_HULL_EQ_SPAN]; ALL_TAC] THEN
  CONJ_TAC THENL
   [GEN_REWRITE_TAC RAND_CONV [GSYM DIM_SPAN] THEN
    MATCH_MP_TAC DIM_SUBSET THEN ASM SET_TAC[];
    ALL_TAC] THEN
  MP_TAC(ISPEC `{a1:real^N,a2,a3}` DEPENDENT_BIGGERSET_GENERAL) THEN
  SIMP_TAC[CARD_CLAUSES; FINITE_INSERT; FINITE_EMPTY; ARITH] THEN
  ASM_REWRITE_TAC[IN_INSERT; NOT_IN_EMPTY; ARITH] THEN
  GEN_REWRITE_TAC LAND_CONV [GSYM CONTRAPOS_THM] THEN
  REWRITE_TAC[ARITH_RULE `~(3 > x) <=> 3 <= x`] THEN
  DISCH_THEN MATCH_MP_TAC THEN
  REWRITE_TAC[dependent; EXISTS_IN_INSERT; NOT_IN_EMPTY] THEN
  ASM_REWRITE_TAC[DELETE_INSERT; EMPTY_DELETE] THEN
  REWRITE_TAC[SPAN_2; IN_ELIM_THM; IN_UNIV] THEN
  POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o rev) THEN
  W(fun (asl,w) -> let fv = frees w
                   and av = [`a1:real^N`; `a2:real^N`; `a3:real^N`] in
     MAP_EVERY (fun t -> SPEC_TAC(t,t)) (subtract fv av @ av)) THEN
  REWRITE_TAC[LEFT_FORALL_IMP_THM] THEN
  MATCH_MP_TAC(MESON[]
   `(!a1 a2 a3. P a1 a2 a3 ==> P a2 a1 a3 /\ P a3 a1 a2) /\
    (!a1 a2 a3. Q a1 a2 a3 ==> ~(P a1 a2 a3))
    ==> !a3 a2 a1. P a1 a2 a3
                   ==> ~(Q a1 a2 a3 \/ Q a2 a1 a3 \/ Q a3 a1 a2)`) THEN
  CONJ_TAC THENL
   [REPEAT GEN_TAC THEN MATCH_MP_TAC(TAUT
     `(p ==> q) /\ (p ==> r) ==> p ==> q /\ r`) THEN
    CONJ_TAC THEN REPEAT(MATCH_MP_TAC MONO_EXISTS THEN GEN_TAC) THEN
    REWRITE_TAC[CONJ_ACI] THEN DISCH_TAC THEN ASM_REWRITE_TAC[] THEN
    ASM SET_TAC[];
    ALL_TAC] THEN
  REPEAT GEN_TAC THEN DISCH_THEN
   (X_CHOOSE_THEN `u:real` (X_CHOOSE_TAC `v:real`)) THEN
  REWRITE_TAC[NOT_EXISTS_THM] THEN REPEAT GEN_TAC THEN
  ASM_CASES_TAC `u = &0` THENL
   [ASM_REWRITE_TAC[VECTOR_ADD_LID; VECTOR_MUL_LZERO] THEN
    REPEAT_TCL DISJ_CASES_THEN ASSUME_TAC (REAL_ARITH
     `v = &0 \/ &0 < v \/ &0 < --v`)
    THENL
     [ASM_REWRITE_TAC[VECTOR_MUL_LZERO];
      REWRITE_TAC[DOT_LMUL; REAL_ARITH `a * b <= &0 <=> &0 <= a * --b`] THEN
      ASM_SIMP_TAC[REAL_LE_MUL_EQ] THEN
      REWRITE_TAC[SUBSET; IN_ELIM_THM; IN_INTER] THEN REAL_ARITH_TAC;
      REWRITE_TAC[DOT_LMUL; REAL_ARITH `a * b < &0 <=> &0 < --a * b`] THEN
      ASM_SIMP_TAC[REAL_LT_MUL_EQ] THEN REAL_ARITH_TAC];
    ALL_TAC] THEN
  ASM_CASES_TAC `v = &0` THENL
   [ASM_REWRITE_TAC[VECTOR_ADD_RID; VECTOR_MUL_LZERO] THEN
    REPEAT_TCL DISJ_CASES_THEN ASSUME_TAC (REAL_ARITH
     `u = &0 \/ &0 < u \/ &0 < --u`)
    THENL
     [ASM_REWRITE_TAC[VECTOR_MUL_LZERO];
      REWRITE_TAC[DOT_LMUL; REAL_ARITH `a * b <= &0 <=> &0 <= a * --b`] THEN
      ASM_SIMP_TAC[REAL_LE_MUL_EQ] THEN
      REWRITE_TAC[SUBSET; IN_ELIM_THM; IN_INTER] THEN REAL_ARITH_TAC;
      REWRITE_TAC[DOT_LMUL; REAL_ARITH `a * b < &0 <=> &0 < --a * b`] THEN
      ASM_SIMP_TAC[REAL_LT_MUL_EQ] THEN REAL_ARITH_TAC];
    ALL_TAC] THEN
  STRIP_TAC THEN
  SUBGOAL_THEN
   `&0 < u /\ &0 < v \/ &0 < u /\ &0 < --v \/
    &0 < --u /\ &0 < v \/ &0 < --u /\ &0 < --v`
  STRIP_ASSUME_TAC THENL
   [ASM_REAL_ARITH_TAC;
    UNDISCH_TAC
     `~({x | a2 dot x <= &0} INTER {x | a3 dot x <= &0} SUBSET
        {x:real^N | a1 dot x <= &0})` THEN
    ASM_REWRITE_TAC[SUBSET; IN_INTER; IN_ELIM_THM] THEN
    REWRITE_TAC[DOT_LADD; DOT_LMUL] THEN
    REWRITE_TAC[REAL_ARITH `x <= &0 <=> &0 <= --x`] THEN
    REWRITE_TAC[REAL_NEG_ADD; GSYM REAL_MUL_RNEG] THEN
    ASM_SIMP_TAC[REAL_LE_MUL; REAL_LE_ADD; REAL_LT_IMP_LE];
    UNDISCH_TAC
     `~({x | a1 dot x <= &0} INTER {x | a3 dot x <= &0} SUBSET
        {x:real^N | a2 dot x <= &0})` THEN
    ASM_REWRITE_TAC[SUBSET; IN_INTER; IN_ELIM_THM] THEN
    GEN_TAC THEN REWRITE_TAC[DOT_LADD; DOT_LMUL] THEN
    MATCH_MP_TAC(REAL_ARITH
     `(&0 < u * a2 <=> &0 < a2) /\ (&0 < --v * a3 <=> &0 < a3)
      ==> u * a2 + v * a3 <= &0 /\ a3 <= &0 ==> a2 <= &0`) THEN
    ASM_SIMP_TAC[REAL_LT_MUL_EQ];
    UNDISCH_TAC
     `~({x | a1 dot x <= &0} INTER {x | a2 dot x <= &0} SUBSET
        {x:real^N | a3 dot x <= &0})` THEN
    ASM_REWRITE_TAC[SUBSET; IN_INTER; IN_ELIM_THM] THEN
    GEN_TAC THEN REWRITE_TAC[DOT_LADD; DOT_LMUL] THEN
    MATCH_MP_TAC(REAL_ARITH
     `(&0 < --u * a2 <=> &0 < a2) /\ (&0 < v * a3 <=> &0 < a3)
      ==> u * a2 + v * a3 <= &0 /\ a2 <= &0 ==> a3 <= &0`) THEN
    ASM_SIMP_TAC[REAL_LT_MUL_EQ];
    UNDISCH_TAC `(a1:real^N) dot w < &0` THEN
    ASM_REWRITE_TAC[DOT_LADD; DOT_LMUL] THEN
    MATCH_MP_TAC(REAL_ARITH
     `&0 < --u * --a /\ &0 < --v * --b ==> ~(u * a + v * b < &0)`) THEN
    CONJ_TAC THEN MATCH_MP_TAC REAL_LT_MUL THEN ASM_REAL_ARITH_TAC]);;

(* ------------------------------------------------------------------------- *)
(* Lower bounds on then number of 0 and n-1 dimensional faces.               *)
(* ------------------------------------------------------------------------- *)

let POLYTOPE_VERTEX_LOWER_BOUND = prove
 (`!p:real^N->bool.
        polytope p ==> aff_dim p + &1 <= &(CARD {v | v extreme_point_of p})`,
  REPEAT STRIP_TAC THEN
  MATCH_MP_TAC INT_LE_TRANS THEN
  EXISTS_TAC `aff_dim(convex hull {v:real^N | v extreme_point_of p}) + &1` THEN
  CONJ_TAC THENL
   [ASM_SIMP_TAC[GSYM KREIN_MILMAN_MINKOWSKI; POLYTOPE_IMP_CONVEX;
                 POLYTOPE_IMP_COMPACT; INT_LE_REFL];
    REWRITE_TAC[AFF_DIM_CONVEX_HULL; GSYM INT_LE_SUB_LADD] THEN
    MATCH_MP_TAC AFF_DIM_LE_CARD THEN
    MATCH_MP_TAC FINITE_POLYHEDRON_EXTREME_POINTS THEN
    ASM_SIMP_TAC[POLYTOPE_IMP_POLYHEDRON]]);;

let POLYTOPE_FACET_LOWER_BOUND = prove
 (`!p:real^N->bool.
        polytope p /\ ~(aff_dim p = &0)
        ==> aff_dim p + &1 <= &(CARD {f | f facet_of p})`,
  GEN_TAC THEN ASM_CASES_TAC `p:real^N->bool = {}` THEN
  ASM_SIMP_TAC[AFF_DIM_EMPTY; FACET_OF_EMPTY; EMPTY_GSPEC; CARD_CLAUSES] THEN
  CONV_TAC INT_REDUCE_CONV THEN STRIP_TAC THEN
  SUBGOAL_THEN
   `?n. {f:real^N->bool | f facet_of p} HAS_SIZE n /\ aff_dim p + &1 <= &n`
    (fun th -> MESON_TAC[th; HAS_SIZE]) THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
  DISCH_THEN(X_CHOOSE_THEN `z:real^N` MP_TAC) THEN
  POP_ASSUM_LIST(MP_TAC o end_itlist CONJ o rev) THEN
  GEOM_ORIGIN_TAC `z:real^N` THEN REPEAT GEN_TAC THEN REPEAT STRIP_TAC THEN
  EXISTS_TAC `CARD {f:real^N->bool | f facet_of p}` THEN
  ASM_SIMP_TAC[FINITE_POLYTOPE_FACETS; HAS_SIZE] THEN
  UNDISCH_TAC `~(aff_dim(p:real^N->bool) = &0)` THEN
  ASM_SIMP_TAC[AFF_DIM_DIM_0; HULL_INC; INT_OF_NUM_ADD; INT_OF_NUM_LE] THEN
  REWRITE_TAC[INT_OF_NUM_EQ] THEN DISCH_TAC THEN
  MP_TAC(ISPEC `p:real^N->bool` POLYHEDRON_INTER_AFFINE_PARALLEL_MINIMAL) THEN
  ASM_SIMP_TAC[POLYTOPE_IMP_POLYHEDRON] THEN
  REWRITE_TAC[RIGHT_IMP_EXISTS_THM; SKOLEM_THM] THEN
  REWRITE_TAC[RIGHT_AND_EXISTS_THM; LEFT_AND_EXISTS_THM] THEN
  ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN MAP_EVERY X_GEN_TAC
   [`H:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] THEN
  ONCE_REWRITE_TAC[EQ_SYM_EQ] THEN
  REWRITE_TAC[VECTOR_ARITH `vec 0:real^N = v <=> v = vec 0`] THEN
  ASM_SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC] THEN
  STRIP_TAC THEN MP_TAC(ISPECL
   [`p:real^N->bool`; `H:(real^N->bool)->bool`; `a:(real^N->bool)->real^N`;
    `b:(real^N->bool)->real`] FACET_OF_POLYHEDRON_EXPLICIT) THEN
  ASM_SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC] THEN DISCH_THEN(K ALL_TAC) THEN
  SUBGOAL_THEN `!h:real^N->bool. h IN H ==> &0 <= b h` ASSUME_TAC THENL
   [UNDISCH_TAC `(vec 0:real^N) IN p` THEN EXPAND_TAC "p" THEN
    REWRITE_TAC[IN_INTER; IN_INTERS] THEN DISCH_THEN(MP_TAC o CONJUNCT2) THEN
    MATCH_MP_TAC MONO_FORALL THEN X_GEN_TAC `h:real^N->bool` THEN
    ASM_CASES_TAC `(h:real^N->bool) IN H` THEN ASM_REWRITE_TAC[] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `h:real^N->bool`) THEN ASM_REWRITE_TAC[] THEN
    DISCH_THEN(fun t -> GEN_REWRITE_TAC (LAND_CONV o RAND_CONV) [GSYM t]) THEN
    REWRITE_TAC[IN_ELIM_THM; DOT_RZERO];
    ALL_TAC] THEN
  MATCH_MP_TAC LE_TRANS THEN
  EXISTS_TAC `(CARD(H:(real^N->bool)->bool))` THEN CONJ_TAC THENL
   [MATCH_MP_TAC(ARITH_RULE `~(h <= a) ==> a + 1 <= h`) THEN DISCH_TAC THEN
    ASM_CASES_TAC `H:(real^N->bool)->bool = {}` THENL
     [UNDISCH_THEN `H:(real^N->bool)->bool = {}` SUBST_ALL_TAC THEN
      RULE_ASSUM_TAC(REWRITE_RULE[INTERS_0; INTER_UNIV]) THEN
      UNDISCH_TAC `~(dim(p:real^N->bool) = 0)` THEN
      REWRITE_TAC[DIM_EQ_0] THEN EXPAND_TAC "p" THEN
      REWRITE_TAC[ASSUME `H:(real^N->bool)->bool = {}`; INTERS_0] THEN
      REWRITE_TAC[INTER_UNIV] THEN
      ASM_CASES_TAC `?n:real^N. n IN span p /\ ~(n = vec 0)` THENL
       [ALL_TAC; ASM SET_TAC[]] THEN
      FIRST_X_ASSUM(CHOOSE_THEN STRIP_ASSUME_TAC) THEN
      FIRST_ASSUM(MP_TAC o MATCH_MP POLYTOPE_IMP_BOUNDED) THEN
      REWRITE_TAC[BOUNDED_POS] THEN DISCH_THEN(X_CHOOSE_THEN `B:real`
       (CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
      DISCH_THEN(MP_TAC o SPEC `(B + &1) / norm n % n:real^N`) THEN
      ANTS_TAC THENL [ASM_MESON_TAC[SPAN_MUL]; ALL_TAC] THEN
      REWRITE_TAC[NORM_MUL; REAL_ABS_DIV; REAL_ABS_NORM] THEN
      ASM_SIMP_TAC[REAL_DIV_RMUL; NORM_EQ_0] THEN REAL_ARITH_TAC;
      ALL_TAC] THEN
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM MEMBER_NOT_EMPTY]) THEN
    DISCH_THEN(X_CHOOSE_TAC `h:real^N->bool`) THEN
    SUBGOAL_THEN
     `span(IMAGE (a:(real^N->bool)->real^N) (H DELETE h))
      PSUBSET span(p)`
    MP_TAC THENL
     [REWRITE_TAC[PSUBSET] THEN CONJ_TAC THENL
       [MATCH_MP_TAC SPAN_SUBSET_SUBSPACE THEN
        REWRITE_TAC[SUBSPACE_SPAN; SUBSET; FORALL_IN_IMAGE; IN_DELETE] THEN
        ASM_MESON_TAC[SPAN_ADD; SPAN_SUPERSET; VECTOR_ADD_LID];
        DISCH_THEN(MP_TAC o AP_TERM `dim:(real^N->bool)->num`) THEN
        REWRITE_TAC[DIM_SPAN] THEN FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP
         (ARITH_RULE `h <= p ==> h':num < h ==> ~(h' = p)`)) THEN
        MATCH_MP_TAC LET_TRANS THEN
        EXISTS_TAC `CARD(IMAGE (a:(real^N->bool)->real^N) (H DELETE h))` THEN
        ASM_SIMP_TAC[DIM_LE_CARD; FINITE_DELETE; FINITE_IMAGE] THEN
        MATCH_MP_TAC LET_TRANS THEN
        EXISTS_TAC `CARD(H DELETE (h:real^N->bool))` THEN
        ASM_SIMP_TAC[CARD_IMAGE_LE; FINITE_DELETE] THEN
        ASM_SIMP_TAC[CARD_DELETE; ARITH_RULE `n - 1 < n <=> ~(n = 0)`] THEN
        ASM_SIMP_TAC[CARD_EQ_0] THEN ASM SET_TAC[]];
      DISCH_THEN(MP_TAC o MATCH_MP ORTHOGONAL_TO_SUBSPACE_EXISTS_GEN)] THEN
    REWRITE_TAC[NOT_EXISTS_THM] THEN X_GEN_TAC `n:real^N` THEN STRIP_TAC THEN
    FIRST_ASSUM(MP_TAC o MATCH_MP POLYTOPE_IMP_BOUNDED) THEN
    REWRITE_TAC[BOUNDED_POS] THEN
    DISCH_THEN(X_CHOOSE_THEN `B:real` (CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
    DISJ_CASES_TAC(REAL_ARITH
     `&0 <= (a:(real^N->bool)->real^N) h dot n \/
      &0 <= --((a:(real^N->bool)->real^N) h dot n)`)
    THENL
     [DISCH_THEN(MP_TAC o SPEC `--(B + &1) / norm(n) % n:real^N`);
      DISCH_THEN(MP_TAC o SPEC `(B + &1) / norm(n) % n:real^N`)] THEN
    (ASM_SIMP_TAC[NORM_MUL; REAL_ABS_DIV; REAL_ABS_NORM;
                  REAL_DIV_RMUL; NORM_EQ_0; REAL_ABS_NEG;
                  REAL_ARITH `~(abs(B + &1) <= B)`] THEN
     EXPAND_TAC "p" THEN REWRITE_TAC[IN_INTER; IN_INTERS] THEN
     ASM_SIMP_TAC[SPAN_MUL] THEN X_GEN_TAC `k:real^N->bool` THEN
     DISCH_TAC THEN
     SUBGOAL_THEN `k = {x:real^N | a k dot x <= b k}` SUBST1_TAC THENL
      [ASM_SIMP_TAC[]; ALL_TAC] THEN
     ASM_CASES_TAC `k:real^N->bool = h` THEN
     ASM_REWRITE_TAC[IN_ELIM_THM; DOT_RMUL] THENL
      [ALL_TAC;
       MATCH_MP_TAC(REAL_ARITH `x = &0 /\ &0 <= y ==> x <= y`) THEN
       ASM_SIMP_TAC[REAL_ENTIRE] THEN DISJ2_TAC THEN
       FIRST_X_ASSUM(MP_TAC o SPEC `(a:(real^N->bool)->real^N) k`) THEN
       REWRITE_TAC[orthogonal; DOT_SYM] THEN DISCH_THEN MATCH_MP_TAC THEN
       MATCH_MP_TAC SPAN_SUPERSET THEN ASM SET_TAC[]]) THENL
     [MATCH_MP_TAC(REAL_ARITH `&0 <= --x * y /\ &0 <= z ==> x * y <= z`);
      MATCH_MP_TAC(REAL_ARITH `&0 <= x * --y /\ &0 <= z ==> x * y <= z`)] THEN
    ASM_SIMP_TAC[] THEN MATCH_MP_TAC REAL_LE_MUL THEN
    REWRITE_TAC[REAL_ARITH `--a / b:real = --(a / b)`; REAL_NEG_NEG] THEN
    ASM_SIMP_TAC[REAL_LE_RDIV_EQ; NORM_POS_LT] THEN ASM_REAL_ARITH_TAC;
    REWRITE_TAC[SET_RULE `{f | ?h. h IN s /\ f = g h} = IMAGE g s`] THEN
    MATCH_MP_TAC(ARITH_RULE `m:num = n ==> n <= m`) THEN
    MATCH_MP_TAC CARD_IMAGE_INJ THEN ASM_REWRITE_TAC[] THEN
    MATCH_MP_TAC FACETS_OF_POLYHEDRON_EXPLICIT_DISTINCT THEN
    ASM_SIMP_TAC[AFFINE_HULL_EQ_SPAN; HULL_INC]]);;

(* ------------------------------------------------------------------------- *)
(* The notion of n-simplex where n is an integer >= -1.                      *)
(* ------------------------------------------------------------------------- *)

parse_as_infix("simplex",(12,"right"));;

let simplex = new_definition
 `n simplex s <=> ?c. ~(affine_dependent c) /\
                      &(CARD c):int = n + &1 /\
                      s = convex hull c`;;

let SIMPLEX_TRANSLATION_EQ = prove
 (`!a:real^N s n. n simplex (IMAGE (\x. a + x) s) <=> n simplex s`,
  REWRITE_TAC[simplex] THEN
  ONCE_REWRITE_TAC[MESON[HAS_SIZE; AFFINE_INDEPENDENT_IMP_FINITE]
   `~affine_dependent c /\ P(CARD c) <=>
    ~affine_dependent c /\ ?n. c HAS_SIZE n /\ P n`] THEN
  GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [SIMPLEX_TRANSLATION_EQ];;

let SIMPLEX_LINEAR_IMAGE_EQ = prove
 (`!f:real^M->real^N s n.
        linear f /\ (!x y. f x = f y ==> x = y)
        ==> (n simplex (IMAGE f s) <=> n simplex s)`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN REWRITE_TAC[simplex] THEN
  ONCE_REWRITE_TAC[MESON[HAS_SIZE; AFFINE_INDEPENDENT_IMP_FINITE]
   `~affine_dependent c /\ P(CARD c) <=>
    ~affine_dependent c /\ ?n. c HAS_SIZE n /\ P n`]  THEN
  MATCH_MP_TAC(MESON[]
   `!f. (!a. P(f a) <=> Q a) /\ (!b. P b ==> ?a. b = f a)
        ==> ((?b. P b) <=> (?a. Q a))`) THEN
  EXISTS_TAC `IMAGE (f:real^M->real^N)` THEN CONJ_TAC THENL
   [POP_ASSUM MP_TAC THEN REWRITE_TAC[RIGHT_IMP_FORALL_THM] THEN
    MAP_EVERY (fun x -> SPEC_TAC(x,x))
     [`n:num`; `s:real^N->bool`; `f:real^M->real^N`] THEN
    GEOM_TRANSFORM_TAC[];
    X_GEN_TAC `d:real^N->bool` THEN STRIP_TAC THEN
    EXISTS_TAC `{x | (f:real^M->real^N) x IN d}` THEN
    SUBGOAL_THEN `(d:real^N->bool) SUBSET convex hull d` MP_TAC THENL
     [REWRITE_TAC[HULL_SUBSET]; ASM SET_TAC[]]]);;

add_linear_invariants [SIMPLEX_LINEAR_IMAGE_EQ];;

let SIMPLEX = prove
 (`n simplex s <=> ?c. FINITE c /\
                       ~(affine_dependent c) /\
                       &(CARD c):int = n + &1 /\
                       s = convex hull c`,
  REWRITE_TAC[simplex] THEN MESON_TAC[AFFINE_INDEPENDENT_IMP_FINITE]);;

let SIMPLEX_CONVEX_HULL = prove
 (`!c:real^N->bool n.
    ~affine_dependent c /\ &(CARD c) = n + &1 ==> n simplex (convex hull c)`,
  REWRITE_TAC[simplex] THEN MESON_TAC[]);;

let CONVEX_SIMPLEX = prove
 (`!n s. n simplex s ==> convex s`,
  REWRITE_TAC[simplex] THEN MESON_TAC[CONVEX_CONVEX_HULL]);;

let COMPACT_SIMPLEX = prove
 (`!n s. n simplex s ==> compact s`,
  REWRITE_TAC[SIMPLEX] THEN
  MESON_TAC[FINITE_IMP_COMPACT; COMPACT_CONVEX_HULL]);;

let CLOSED_SIMPLEX = prove
 (`!s n. n simplex s ==> closed s`,
  MESON_TAC[COMPACT_SIMPLEX; COMPACT_IMP_CLOSED]);;

let SIMPLEX_IMP_POLYTOPE = prove
 (`!n s. n simplex s ==> polytope s`,
  REWRITE_TAC[simplex; polytope] THEN
  MESON_TAC[AFFINE_INDEPENDENT_IMP_FINITE]);;

let SIMPLEX_IMP_POLYHEDRON = prove
 (`!s n. n simplex s ==> polyhedron s`,
  MESON_TAC[SIMPLEX_IMP_POLYTOPE; POLYTOPE_IMP_POLYHEDRON]);;

let SIMPLEX_IMP_CONVEX = prove
 (`!s:real^N->bool n. n simplex s ==> convex s`,
  MESON_TAC[SIMPLEX_IMP_POLYTOPE; POLYTOPE_IMP_CONVEX]);;

let SIMPLEX_IMP_COMPACT = prove
 (`!s:real^N->bool n. n simplex s ==> compact s`,
  MESON_TAC[SIMPLEX_IMP_POLYTOPE; POLYTOPE_IMP_COMPACT]);;

let SIMPLEX_IMP_CLOSED = prove
 (`!s:real^N->bool n. n simplex s ==> closed s`,
  MESON_TAC[SIMPLEX_IMP_POLYTOPE; POLYTOPE_IMP_CLOSED]);;

let SIMPLEX_DIM_GE = prove
 (`!n s. n simplex s ==> -- &1 <= n`,
  REWRITE_TAC[simplex] THEN INT_ARITH_TAC);;

let SIMPLEX_EMPTY = prove
 (`!n. n simplex {} <=> n = -- &1`,
  GEN_TAC THEN REWRITE_TAC[SIMPLEX] THEN
  GEN_REWRITE_TAC (LAND_CONV o ONCE_DEPTH_CONV) [EQ_SYM_EQ] THEN
  REWRITE_TAC[CONVEX_HULL_EQ_EMPTY; CONJ_ASSOC] THEN
  ONCE_REWRITE_TAC[CONJ_SYM] THEN REWRITE_TAC[UNWIND_THM2] THEN
  REWRITE_TAC[FINITE_EMPTY; CARD_CLAUSES; AFFINE_INDEPENDENT_EMPTY] THEN
  INT_ARITH_TAC);;

let SIMPLEX_MINUS_1 = prove
 (`!s. (-- &1) simplex s <=> s = {}`,
  GEN_TAC THEN REWRITE_TAC[SIMPLEX; INT_ADD_LINV; INT_OF_NUM_EQ] THEN
  ONCE_REWRITE_TAC[TAUT `a /\ b <=> ~(a ==> ~b)`] THEN
  SIMP_TAC[CARD_EQ_0] THEN REWRITE_TAC[NOT_IMP] THEN
  ONCE_REWRITE_TAC[TAUT `a /\ b /\ c /\ d <=> c /\ a /\ b /\ d`] THEN
  REWRITE_TAC[UNWIND_THM2; FINITE_EMPTY; AFFINE_INDEPENDENT_EMPTY] THEN
  REWRITE_TAC[CONVEX_HULL_EMPTY]);;

let AFF_DIM_SIMPLEX = prove
 (`!s n. n simplex s ==> aff_dim s = n`,
  REWRITE_TAC[simplex; INT_ARITH `x:int = n + &1 <=> n = x - &1`] THEN
  REPEAT STRIP_TAC THEN
  ASM_SIMP_TAC[AFF_DIM_CONVEX_HULL; AFF_DIM_AFFINE_INDEPENDENT]);;

let SIMPLEX_EXTREME_POINTS = prove
 (`!n s:real^N->bool.
       n simplex s
       ==> FINITE {v | v extreme_point_of s} /\
           ~(affine_dependent {v | v extreme_point_of s}) /\
           &(CARD {v | v extreme_point_of s}) = n + &1 /\
           s = convex hull {v | v extreme_point_of s}`,
  REPEAT GEN_TAC THEN REWRITE_TAC[SIMPLEX; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:real^N->bool` THEN DISCH_THEN(STRIP_ASSUME_TAC o GSYM) THEN
  SUBGOAL_THEN `{v:real^N | v extreme_point_of s} = c`
   (fun th -> ASM_REWRITE_TAC[th]) THEN
  FIRST_X_ASSUM(SUBST1_TAC o SYM) THEN
  MATCH_MP_TAC(SET_RULE `s SUBSET t /\ ~(s PSUBSET t) ==> s = t`) THEN
  REWRITE_TAC[SUBSET; IN_ELIM_THM; EXTREME_POINT_OF_CONVEX_HULL] THEN
  ABBREV_TAC `c' = {v:real^N | v extreme_point_of (convex hull c)}` THEN
  DISCH_TAC THEN
  SUBGOAL_THEN `convex hull c:real^N->bool = convex hull c'` ASSUME_TAC THENL
   [EXPAND_TAC "c'" THEN MATCH_MP_TAC KREIN_MILMAN_MINKOWSKI THEN
    REWRITE_TAC[CONVEX_CONVEX_HULL] THEN MATCH_MP_TAC COMPACT_CONVEX_HULL THEN
    ASM_MESON_TAC[HAS_SIZE; FINITE_IMP_COMPACT];
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [PSUBSET_MEMBER]) THEN
    DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
    DISCH_THEN(X_CHOOSE_THEN `a:real^N` STRIP_ASSUME_TAC) THEN
    FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE RAND_CONV [affine_dependent]) THEN
    REWRITE_TAC[] THEN EXISTS_TAC `a:real^N` THEN ASM_REWRITE_TAC[] THEN
    SUBGOAL_THEN `(a:real^N) IN convex hull c'` MP_TAC THENL
     [ASM_MESON_TAC[HULL_INC]; ALL_TAC] THEN
    DISCH_THEN(MP_TAC o MATCH_MP (REWRITE_RULE[SUBSET]
      CONVEX_HULL_SUBSET_AFFINE_HULL)) THEN
    SUBGOAL_THEN `c' SUBSET (c DELETE (a:real^N))` MP_TAC THENL
     [ASM SET_TAC[]; ASM_MESON_TAC[HULL_MONO; SUBSET]]]);;

let SIMPLEX_FACE_OF_SIMPLEX = prove
 (`!n s f:real^N->bool.
        n simplex s /\ f face_of s ==> ?m. m <= n /\ m simplex f`,
  REPEAT STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [SIMPLEX]) THEN
  REWRITE_TAC[HAS_SIZE; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:real^N->bool` THEN STRIP_TAC THEN
  FIRST_X_ASSUM SUBST_ALL_TAC THEN
  SUBGOAL_THEN `?c':real^N->bool. c' SUBSET c /\ f = convex hull c'`
  STRIP_ASSUME_TAC THENL
   [ASM_SIMP_TAC[FACE_OF_CONVEX_HULL_SUBSET; FINITE_IMP_COMPACT]; ALL_TAC] THEN
  EXISTS_TAC `&(CARD(c':real^N->bool)) - &1:int` THEN ASM_REWRITE_TAC[] THEN
  CONJ_TAC THENL
   [FIRST_X_ASSUM(MP_TAC o MATCH_MP (REWRITE_RULE[IMP_CONJ] CARD_SUBSET)) THEN
    ASM_REWRITE_TAC[GSYM INT_OF_NUM_LE] THEN INT_ARITH_TAC;
    REWRITE_TAC[simplex] THEN EXISTS_TAC `c':real^N->bool` THEN
    ASM_REWRITE_TAC[INT_ARITH `a - &1 + &1:int = a`] THEN
    ASM_MESON_TAC[AFFINE_DEPENDENT_MONO]]);;

let FACE_OF_SIMPLEX_SUBSET = prove
 (`!n s f:real^N->bool.
        n simplex s /\ f face_of s
        ==> ?c. c SUBSET {x | x extreme_point_of s} /\ f = convex hull c`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP SIMPLEX_EXTREME_POINTS) THEN
  ABBREV_TAC `c = {x:real^N | x extreme_point_of s}` THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC)) THEN
  DISCH_THEN SUBST_ALL_TAC THEN
  RULE_ASSUM_TAC(REWRITE_RULE[HAS_SIZE]) THEN
  ASM_MESON_TAC[FACE_OF_CONVEX_HULL_SUBSET; FINITE_IMP_COMPACT]);;

let SUBSET_FACE_OF_SIMPLEX = prove
 (`!s n c:real^N->bool.
      n simplex s /\ c SUBSET {x | x extreme_point_of s}
      ==> (convex hull c) face_of s`,
  REPEAT STRIP_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP SIMPLEX_EXTREME_POINTS) THEN
  REWRITE_TAC[HAS_SIZE] THEN
  REPEAT(DISCH_THEN(CONJUNCTS_THEN2 STRIP_ASSUME_TAC MP_TAC)) THEN
  DISCH_THEN SUBST1_TAC THEN MATCH_MP_TAC FACE_OF_CONVEX_HULLS THEN
  ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(SET_RULE `!t. u SUBSET t /\ DISJOINT s t ==> DISJOINT s u`) THEN
  EXISTS_TAC `affine hull ({v:real^N | v extreme_point_of s} DIFF c)` THEN
  REWRITE_TAC[CONVEX_HULL_SUBSET_AFFINE_HULL] THEN
  MATCH_MP_TAC DISJOINT_AFFINE_HULL THEN
  EXISTS_TAC `{v:real^N | v extreme_point_of s}` THEN
  ASM_REWRITE_TAC[] THEN SET_TAC[]);;

let FACES_OF_SIMPLEX = prove
 (`!n s. n simplex s
         ==> {f | f face_of s} =
             {convex hull c | c SUBSET {v | v extreme_point_of s}}`,
  REPEAT STRIP_TAC THEN GEN_REWRITE_TAC I [EXTENSION] THEN
  REWRITE_TAC[IN_ELIM_THM] THEN
  ASM_MESON_TAC[FACE_OF_SIMPLEX_SUBSET; SUBSET_FACE_OF_SIMPLEX]);;

let HAS_SIZE_FACES_OF_SIMPLEX = prove
 (`!n s:real^N->bool.
        n simplex s
        ==> {f | f face_of s} HAS_SIZE 2 EXP (num_of_int(n + &1))`,
  REPEAT GEN_TAC THEN DISCH_TAC THEN
  FIRST_ASSUM(SUBST1_TAC o MATCH_MP FACES_OF_SIMPLEX) THEN
  FIRST_X_ASSUM(STRIP_ASSUME_TAC o GSYM o MATCH_MP SIMPLEX_EXTREME_POINTS) THEN
  ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN MATCH_MP_TAC HAS_SIZE_IMAGE_INJ THEN
  REWRITE_TAC[IN_ELIM_THM] THEN CONJ_TAC THENL
   [REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ];
    MATCH_MP_TAC HAS_SIZE_POWERSET THEN
    ASM_REWRITE_TAC[HAS_SIZE; NUM_OF_INT_OF_NUM]] THEN
  SUBGOAL_THEN
   `!a b. a SUBSET {v:real^N | v extreme_point_of s} /\
          b SUBSET {v | v extreme_point_of s} /\
          convex hull a SUBSET convex hull b
          ==> a SUBSET b`
   (fun th -> MESON_TAC[th]) THEN
  REPEAT STRIP_TAC THEN REWRITE_TAC[SUBSET] THEN X_GEN_TAC `x:real^N` THEN
  DISCH_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE RAND_CONV [affine_dependent]) THEN
  REWRITE_TAC[NOT_EXISTS_THM] THEN DISCH_THEN(MP_TAC o SPEC `x:real^N`) THEN
  ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN DISCH_TAC THEN REWRITE_TAC[] THEN
  CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
  MATCH_MP_TAC(SET_RULE
   `!s t u. x IN s /\ s SUBSET t /\ t SUBSET u /\ u SUBSET v ==> x IN v`) THEN
  MAP_EVERY EXISTS_TAC
   [`convex hull a:real^N->bool`; `convex hull b:real^N->bool`;
    `affine hull b:real^N->bool`] THEN
  ASM_SIMP_TAC[HULL_INC; CONVEX_HULL_SUBSET_AFFINE_HULL] THEN
  MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[]);;

let FINITE_FACES_OF_SIMPLEX = prove
 (`!n s. n simplex s ==> FINITE {f | f face_of s}`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(MP_TAC o MATCH_MP HAS_SIZE_FACES_OF_SIMPLEX) THEN
  SIMP_TAC[HAS_SIZE]);;

let CARD_FACES_OF_SIMPLEX = prove
 (`!n s. n simplex s ==> CARD {f | f face_of s} = 2 EXP (num_of_int(n + &1))`,
  REPEAT GEN_TAC THEN
  DISCH_THEN(MP_TAC o MATCH_MP HAS_SIZE_FACES_OF_SIMPLEX) THEN
  SIMP_TAC[HAS_SIZE]);;

let CHOOSE_SIMPLEX = prove
 (`!n. --(&1) <= n /\ n <= &(dimindex(:N)) ==> ?s:real^N->bool. n simplex s`,
  X_GEN_TAC `d:int` THEN
  REWRITE_TAC[INT_ARITH `--(&1):int <= n <=> n = --(&1) \/ &0 <= n`] THEN
  DISCH_THEN(CONJUNCTS_THEN2 DISJ_CASES_TAC MP_TAC) THENL
   [ASM_MESON_TAC[SIMPLEX_EMPTY]; ALL_TAC] THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM INT_OF_NUM_EXISTS]) THEN
  DISCH_THEN(X_CHOOSE_THEN `n:num` SUBST1_TAC) THEN
  REWRITE_TAC[INT_OF_NUM_LE; GSYM DIM_UNIV] THEN DISCH_TAC THEN
  FIRST_ASSUM(MP_TAC o MATCH_MP CHOOSE_SUBSPACE_OF_SUBSPACE) THEN
  DISCH_THEN(X_CHOOSE_THEN `s:real^N->bool` STRIP_ASSUME_TAC) THEN
  MP_TAC(ISPEC `s:real^N->bool` BASIS_EXISTS) THEN
  ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `c:real^N->bool` THEN STRIP_TAC THEN
  EXISTS_TAC `convex hull ((vec 0:real^N) INSERT c)` THEN
  REWRITE_TAC[simplex] THEN EXISTS_TAC `(vec 0:real^N) INSERT c` THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP INDEPENDENT_NONZERO) THEN
  FIRST_ASSUM(ASSUME_TAC o MATCH_MP INDEPENDENT_IMP_FINITE) THEN
  ASM_SIMP_TAC[CARD_CLAUSES; GSYM INT_OF_NUM_SUC] THEN
  ASM_SIMP_TAC[INDEPENDENT_IMP_AFFINE_DEPENDENT_0] THEN
  ASM_MESON_TAC[HAS_SIZE]);;

let CHOOSE_SURROUNDING_SIMPLEX = prove
 (`!a:real^N n.
        &0 <= n /\ n <= &(dimindex (:N))
        ==>  ?s. n simplex s /\ a IN relative_interior s`,
  REPEAT STRIP_TAC THEN MP_TAC(ISPEC `n:int` CHOOSE_SIMPLEX) THEN
  ANTS_TAC THENL [ASM_INT_ARITH_TAC; ALL_TAC] THEN
  DISCH_THEN(X_CHOOSE_TAC `c:real^N->bool`) THEN
  SUBGOAL_THEN `~(relative_interior c:real^N->bool = {})` MP_TAC THENL
   [FIRST_ASSUM(ASSUME_TAC o MATCH_MP SIMPLEX_IMP_CONVEX) THEN
    ASM_SIMP_TAC[RELATIVE_INTERIOR_EQ_EMPTY] THEN DISCH_TAC THEN
    FIRST_X_ASSUM(MP_TAC o MATCH_MP AFF_DIM_SIMPLEX) THEN
    ASM_REWRITE_TAC[AFF_DIM_EMPTY] THEN ASM_INT_ARITH_TAC;
    REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; LEFT_IMP_EXISTS_THM] THEN
    X_GEN_TAC `b:real^N` THEN STRIP_TAC THEN
    EXISTS_TAC `IMAGE (\x:real^N. (a - b) + x) c` THEN
    ASM_REWRITE_TAC[SIMPLEX_TRANSLATION_EQ; RELATIVE_INTERIOR_TRANSLATION] THEN
    REWRITE_TAC[IN_IMAGE] THEN EXISTS_TAC `b:real^N` THEN
    ASM_REWRITE_TAC[] THEN CONV_TAC VECTOR_ARITH]);;

let CHOOSE_SURROUNDING_SIMPLEX_FULL = prove
 (`!a:real^N. ?s. &(dimindex(:N)) simplex s /\ a IN interior s`,
  GEN_TAC THEN MP_TAC(ISPECL [`a:real^N`; `&(dimindex(:N)):int`]
    CHOOSE_SURROUNDING_SIMPLEX) THEN
  REWRITE_TAC[INT_POS; INT_LE_REFL] THEN MATCH_MP_TAC MONO_EXISTS THEN
  ASM_MESON_TAC[RELATIVE_INTERIOR_INTERIOR; AFF_DIM_EQ_FULL;
                AFF_DIM_SIMPLEX]);;

let CHOOSE_POLYTOPE = prove
 (`!n. --(&1) <= n /\ n <= &(dimindex(:N))
       ==> ?s:real^N->bool. polytope s /\ aff_dim s = n`,
  MESON_TAC[CHOOSE_SIMPLEX; SIMPLEX_IMP_POLYTOPE; AFF_DIM_SIMPLEX]);;

let SIMPLEX_SING = prove
 (`!n a:real^N. n simplex {a} <=> n = &0`,
  REPEAT GEN_TAC THEN EQ_TAC THENL
   [DISCH_THEN(MP_TAC o MATCH_MP AFF_DIM_SIMPLEX) THEN
    REWRITE_TAC[AFF_DIM_SING; EQ_SYM_EQ];
    DISCH_THEN SUBST1_TAC THEN REWRITE_TAC[simplex] THEN
    EXISTS_TAC `{a:real^N}` THEN
    REWRITE_TAC[AFFINE_INDEPENDENT_1; CONVEX_HULL_SING] THEN
    REWRITE_TAC[CARD_SING; INT_ADD_LID]]);;

let SIMPLEX_ZERO = prove
 (`!s:real^N->bool. &0 simplex s <=> ?a. s = {a}`,
  GEN_TAC THEN EQ_TAC THENL [ALL_TAC; MESON_TAC[SIMPLEX_SING]] THEN
  REWRITE_TAC[simplex; INT_ADD_LID; INT_OF_NUM_EQ] THEN
  DISCH_THEN(X_CHOOSE_THEN `t:real^N->bool` STRIP_ASSUME_TAC) THEN
  MP_TAC(HAS_SIZE_CONV `(t:real^N->bool) HAS_SIZE 1`) THEN
  ASM_SIMP_TAC[AFFINE_INDEPENDENT_IMP_FINITE; HAS_SIZE] THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[CONVEX_HULL_SING] THEN MESON_TAC[]);;

let SIMPLEX_SEGMENT_CASES = prove
 (`!a b:real^N. (if a = b then &0 else &1) simplex segment[a,b]`,
  REPEAT GEN_TAC THEN COND_CASES_TAC THEN
  ASM_REWRITE_TAC[SEGMENT_REFL; SIMPLEX_SING] THEN
  REWRITE_TAC[simplex] THEN EXISTS_TAC `{a:real^N,b}` THEN
  ASM_REWRITE_TAC[SEGMENT_CONVEX_HULL; AFFINE_INDEPENDENT_2] THEN
  ASM_SIMP_TAC[CARD_CLAUSES; FINITE_SING; IN_SING; CARD_SING] THEN
  REWRITE_TAC[GSYM INT_OF_NUM_SUC] THEN INT_ARITH_TAC);;

let SIMPLEX_SEGMENT = prove
 (`!a b. ?n. n simplex segment[a,b]`,
  MESON_TAC[SIMPLEX_SEGMENT_CASES]);;

let POLYTOPE_LOWDIM_IMP_SIMPLEX = prove
 (`!p:real^N->bool. polytope p /\ aff_dim p <= &1 ==> ?n. n simplex p`,
  GEN_TAC THEN ASM_CASES_TAC `p:real^N->bool = {}` THEN
  ASM_REWRITE_TAC[SIMPLEX_EMPTY; EXISTS_REFL; GSYM COLLINEAR_AFF_DIM] THEN
  STRIP_TAC THEN
  MP_TAC(ISPEC `p:real^N->bool` COMPACT_CONVEX_COLLINEAR_SEGMENT) THEN
  ASM_SIMP_TAC[POLYTOPE_IMP_CONVEX; POLYTOPE_IMP_COMPACT] THEN
  MESON_TAC[SIMPLEX_SEGMENT]);;

let SIMPLEX_INSERT_DIMPLUS1 = prove
 (`!n s a:real^N.
        n simplex s /\ ~(a IN affine hull s)
        ==> (n + &1) simplex (convex hull (a INSERT s))`,
  REPEAT STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [simplex]) THEN
  DISCH_THEN(X_CHOOSE_THEN `k:real^N->bool` STRIP_ASSUME_TAC) THEN
  REWRITE_TAC[simplex] THEN EXISTS_TAC `(a:real^N) INSERT k` THEN
  UNDISCH_TAC `~((a:real^N) IN affine hull s)` THEN
  ASM_SIMP_TAC[AFFINE_HULL_CONVEX_HULL; AFFINE_INDEPENDENT_INSERT] THEN
  ASM_CASES_TAC `(a:real^N) IN k` THENL [ASM_MESON_TAC[HULL_INC]; ALL_TAC] THEN
  ASM_SIMP_TAC[CARD_CLAUSES; AFFINE_INDEPENDENT_IMP_FINITE] THEN
  DISCH_TAC THEN ASM_REWRITE_TAC[GSYM INT_OF_NUM_SUC] THEN
  ONCE_REWRITE_TAC[SET_RULE `a INSERT s = {a} UNION s`] THEN
  REWRITE_TAC[GSYM HULL_UNION_RIGHT]);;

let SIMPLEX_INSERT = prove
 (`!s a:real^N.
        (?n. n simplex s) /\ ~(a IN affine hull s)
        ==> ?n. n simplex (convex hull (a INSERT s))`,
  MESON_TAC[SIMPLEX_INSERT_DIMPLUS1]);;

let SIMPLEX_ALT = prove
 (`!s:real^N->bool i.
        i simplex s <=>
          convex s /\ compact s /\
          FINITE {v | v extreme_point_of s} /\
          &(CARD {v | v extreme_point_of s}) = i + &1 /\
          ~affine_dependent {v | v extreme_point_of s}`,
  REPEAT GEN_TAC THEN EQ_TAC THENL
   [MESON_TAC[SIMPLEX_EXTREME_POINTS; SIMPLEX_IMP_CONVEX; SIMPLEX_IMP_COMPACT];
    STRIP_TAC THEN REWRITE_TAC[simplex] THEN
    EXISTS_TAC `{v:real^N | v extreme_point_of s}` THEN
    ASM_MESON_TAC[KREIN_MILMAN_MINKOWSKI]]);;

let SIMPLEX_ALT1 = prove
 (`!s:real^N->bool.
        (&n - &1) simplex s <=>
          convex s /\ compact s /\
          {v | v extreme_point_of s} HAS_SIZE n /\
          ~affine_dependent {v | v extreme_point_of s}`,
  REWRITE_TAC[SIMPLEX_ALT; INT_SUB_ADD; INT_OF_NUM_EQ; HAS_SIZE] THEN
  CONV_TAC TAUT);;

let SIMPLEX_0_NOT_IN_AFFINE_HULL = prove
 (`!s:real^N->bool.
        (&n - &1) simplex s /\ ~(vec 0 IN affine hull s) <=>
        convex s /\ compact s /\
        {v | v extreme_point_of s} HAS_SIZE n /\
        independent {v | v extreme_point_of s}`,
  GEN_TAC THEN
  MP_TAC(ISPEC `s:real^N->bool` KREIN_MILMAN_MINKOWSKI) THEN
  REWRITE_TAC[independent; DEPENDENT_AFFINE_DEPENDENT_CASES;
              SIMPLEX_ALT1] THEN
  MESON_TAC[AFFINE_HULL_CONVEX_HULL]);;

(* ------------------------------------------------------------------------- *)
(* Simplicial complexes and triangulations.                                  *)
(* ------------------------------------------------------------------------- *)

let simplicial_complex = new_definition
 `simplicial_complex c <=>
        FINITE c /\
        (!s. s IN c ==> ?n. n simplex s) /\
        (!f s. s IN c /\ f face_of s ==> f IN c) /\
        (!s s'. s IN c /\ s' IN c
                ==> (s INTER s') face_of s /\ (s INTER s') face_of s')`;;

let triangulation = new_definition
 `triangulation(tr:(real^N->bool)->bool) <=>
        FINITE tr /\
        (!t. t IN tr ==> ?n. n simplex t) /\
        (!t t'. t IN tr /\ t' IN tr
                ==> (t INTER t') face_of t /\ (t INTER t') face_of t')`;;

let SIMPLICIAL_COMPLEX_TRANSLATION = prove
 (`!a:real^N tr.
   simplicial_complex(IMAGE (IMAGE (\x. a + x)) tr) <=> simplicial_complex tr`,
  REWRITE_TAC[simplicial_complex] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [SIMPLICIAL_COMPLEX_TRANSLATION];;

let SIMPLICIAL_COMPLEX_LINEAR_IMAGE = prove
 (`!f:real^M->real^N tr.
       linear f /\ (!x y. f x = f y ==> x = y) /\ (!y. ?x. f x = y)
       ==> (simplicial_complex(IMAGE (IMAGE f) tr) <=> simplicial_complex tr)`,
  REWRITE_TAC[simplicial_complex] THEN GEOM_TRANSFORM_TAC[]);;

add_linear_invariants [SIMPLICIAL_COMPLEX_LINEAR_IMAGE];;

let TRIANGULATION_TRANSLATION = prove
 (`!a:real^N tr.
        triangulation(IMAGE (IMAGE (\x. a + x)) tr) <=> triangulation tr`,
  REWRITE_TAC[triangulation] THEN GEOM_TRANSLATE_TAC[]);;

add_translation_invariants [TRIANGULATION_TRANSLATION];;

let TRIANGULATION_LINEAR_IMAGE = prove
 (`!f:real^M->real^N tr.
        linear f /\ (!x y. f x = f y ==> x = y) /\ (!y. ?x. f x = y)
        ==> (triangulation(IMAGE (IMAGE f) tr) <=> triangulation tr)`,
  REWRITE_TAC[triangulation] THEN GEOM_TRANSFORM_TAC[]);;

add_linear_invariants [TRIANGULATION_LINEAR_IMAGE];;

let SIMPLICIAL_COMPLEX_IMP_TRIANGULATION = prove
 (`!tr. simplicial_complex tr ==> triangulation tr`,
  REWRITE_TAC[triangulation; simplicial_complex] THEN MESON_TAC[]);;

let TRIANGULATION_SUBSET = prove
 (`!tr:(real^N->bool)->bool tr'.
        triangulation tr /\ tr' SUBSET tr ==> triangulation tr'`,
  REWRITE_TAC[triangulation] THEN
  MESON_TAC[SUBSET; FINITE_SUBSET]);;

let TRIANGULATION_UNION = prove
 (`!tr1 tr2.
        triangulation(tr1 UNION tr2) <=>
        triangulation tr1 /\ triangulation tr2 /\
        (!s t. s IN tr1 /\ t IN tr2
               ==> s INTER t face_of s /\ s INTER t face_of t)`,
  REWRITE_TAC[triangulation; FINITE_UNION; IN_UNION] THEN
  MESON_TAC[INTER_COMM]);;

let TRIANGULATION_INTER_SIMPLEX = prove
 (`!tr t t':real^N->bool.
        triangulation tr /\ t IN tr /\ t' IN tr
        ==> t INTER t' = convex hull ({x | x extreme_point_of t} INTER
                                      {x | x extreme_point_of t'})`,
  REWRITE_TAC[triangulation] THEN REPEAT STRIP_TAC THEN
  FIRST_X_ASSUM(MP_TAC o SPECL [`t:real^N->bool`; `t':real^N->bool`]) THEN
  ASM_REWRITE_TAC[] THEN STRIP_TAC THEN
  FIRST_X_ASSUM(fun th -> MAP_EVERY (MP_TAC o C SPEC th)
   [`t:real^N->bool`; `t':real^N->bool`]) THEN
  ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `m:int` THEN DISCH_TAC THEN X_GEN_TAC `n:int` THEN DISCH_TAC THEN
  MP_TAC(ISPECL [`m:int`; `t':real^N->bool`;
                 `t INTER t':real^N->bool`] FACE_OF_SIMPLEX_SUBSET) THEN
  MP_TAC(ISPECL [`n:int`; `t:real^N->bool`;
                 `t INTER t':real^N->bool`] FACE_OF_SIMPLEX_SUBSET) THEN
  ASM_SIMP_TAC[] THEN
  DISCH_THEN(X_CHOOSE_THEN `d:real^N->bool` (STRIP_ASSUME_TAC o GSYM)) THEN
  DISCH_THEN(X_CHOOSE_THEN `d':real^N->bool` (STRIP_ASSUME_TAC o GSYM)) THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL
   [ALL_TAC;
    MATCH_MP_TAC HULL_MINIMAL THEN
    CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[CONVEX_INTER; CONVEX_SIMPLEX]] THEN
    SIMP_TAC[SUBSET; IN_INTER; IN_ELIM_THM; extreme_point_of]] THEN
  MATCH_MP_TAC SUBSET_TRANS THEN
  EXISTS_TAC `convex hull {x:real^N | x extreme_point_of (t INTER t')}` THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC(SET_RULE `s = t ==> s SUBSET t`) THEN
    MATCH_MP_TAC KREIN_MILMAN_MINKOWSKI THEN
    ASM_MESON_TAC[COMPACT_INTER; CONVEX_INTER; COMPACT_SIMPLEX; CONVEX_SIMPLEX];
    MATCH_MP_TAC HULL_MONO THEN REWRITE_TAC[SUBSET_INTER] THEN CONJ_TAC THENL
     [SUBST1_TAC(SYM(ASSUME `convex hull d:real^N->bool = t INTER t'`));
      SUBST1_TAC(SYM(ASSUME `convex hull d':real^N->bool = t INTER t'`))] THEN
    REWRITE_TAC[SUBSET; IN_ELIM_THM] THEN GEN_TAC THEN
    DISCH_THEN(MP_TAC o MATCH_MP EXTREME_POINT_OF_CONVEX_HULL) THEN
    ASM SET_TAC[]]);;

let TRIANGULATION_SIMPLICIAL_COMPLEX = prove
 (`!tr. triangulation tr
        ==> simplicial_complex {f:real^N->bool | ?t. t IN tr /\ f face_of t}`,
  let lemma = prove
   (`{f | ?t. t IN tr /\ P f t} = UNIONS (IMAGE (\t. {f | P f t}) tr)`,
    GEN_REWRITE_TAC I [EXTENSION] THEN
    REWRITE_TAC[IN_ELIM_THM; IN_UNIONS; IN_IMAGE; LEFT_AND_EXISTS_THM] THEN
    ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN
    REWRITE_TAC[GSYM CONJ_ASSOC; UNWIND_THM2; IN_ELIM_THM]) in
  REWRITE_TAC[triangulation; simplicial_complex] THEN
  REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
  REWRITE_TAC[IN_ELIM_THM] THEN GEN_TAC THEN
  REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
  REWRITE_TAC[RIGHT_IMP_FORALL_THM; IMP_IMP] THEN STRIP_TAC THEN
  REPEAT CONJ_TAC THENL
   [REWRITE_TAC[lemma] THEN ASM_SIMP_TAC[FINITE_UNIONS; FINITE_IMAGE] THEN
    ASM_REWRITE_TAC[FORALL_IN_IMAGE] THEN
    ASM_MESON_TAC[FINITE_FACES_OF_SIMPLEX];
    ASM_MESON_TAC[SIMPLEX_FACE_OF_SIMPLEX];
    ASM_MESON_TAC[FACE_OF_TRANS];
    ASM_MESON_TAC[FACE_OF_INTER_SUBFACE]]);;

let TRIANGULATION_SIMPLEX_FACES = prove
 (`!s:real^N->bool n d.
        n simplex s ==> triangulation {c | c face_of s /\ aff_dim c = d}`,
  REPEAT GEN_TAC THEN REWRITE_TAC[triangulation; IN_ELIM_THM] THEN
  STRIP_TAC THEN REPEAT CONJ_TAC THENL
   [ONCE_REWRITE_TAC[SET_RULE
     `{x | P x /\ Q x} = {x | x IN {y | P y} /\ Q x}`] THEN
    MATCH_MP_TAC FINITE_RESTRICT THEN
    MATCH_MP_TAC FINITE_POLYTOPE_FACES THEN
    ASM_MESON_TAC[SIMPLEX_IMP_POLYTOPE];
    ASM_MESON_TAC[SIMPLEX_FACE_OF_SIMPLEX];
    REPEAT STRIP_TAC THEN MATCH_MP_TAC FACE_OF_SUBSET THEN
    EXISTS_TAC `s:real^N->bool` THEN ASM_SIMP_TAC[FACE_OF_INTER] THEN
    ASM_SIMP_TAC[FACE_OF_IMP_SUBSET; INTER_SUBSET]]);;

let TRIANGULATION_SIMPLEX_FACETS = prove
 (`!s:real^N->bool n. n simplex s ==> triangulation {c | c facet_of s}`,
  REPEAT STRIP_TAC THEN REWRITE_TAC[facet_of] THEN
  MATCH_MP_TAC TRIANGULATION_SUBSET THEN EXISTS_TAC
   `{c:real^N->bool | c face_of s /\ aff_dim c = aff_dim s - &1}` THEN
  CONJ_TAC THENL [ALL_TAC; SET_TAC[]] THEN
  MATCH_MP_TAC TRIANGULATION_SIMPLEX_FACES THEN ASM_MESON_TAC[]);;

let CELL_COMPLEX_DISJOINT_RELATIVE_INTERIORS = prove
 (`!c d:real^N->bool.
        c INTER d face_of c /\ c INTER d face_of d /\ ~(c = d)
        ==> relative_interior c INTER relative_interior d = {}`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPEC `c INTER d:real^N->bool`FACE_OF_DISJOINT_RELATIVE_INTERIOR) THEN
  DISCH_THEN(fun th ->
    MP_TAC(SPEC `d:real^N->bool` th) THEN
    MP_TAC(SPEC `c:real^N->bool` th)) THEN
  ASM_REWRITE_TAC[] THEN
  MAP_EVERY (MP_TAC o C ISPEC RELATIVE_INTERIOR_SUBSET)
   [`c:real^N->bool`; `d:real^N->bool`] THEN
  ASM SET_TAC[]);;

let TRIANGULATION_DISJOINT_RELATIVE_INTERIORS = prove
 (`!t c d:real^N->bool.
        triangulation t /\ c IN t /\ d IN t /\ ~(c = d)
        ==> relative_interior c INTER relative_interior d = {}`,
  REWRITE_TAC[triangulation] THEN
  MESON_TAC[CELL_COMPLEX_DISJOINT_RELATIVE_INTERIORS]);;

let SIMPLICIAL_COMPLEX_DISJOINT_RELATIVE_INTERIORS = prove
 (`!t c d:real^N->bool.
        simplicial_complex t /\ c IN t /\ d IN t /\ ~(c = d)
        ==> relative_interior c INTER relative_interior d = {}`,
  MESON_TAC[TRIANGULATION_DISJOINT_RELATIVE_INTERIORS;
            SIMPLICIAL_COMPLEX_IMP_TRIANGULATION]);;

let NOT_IN_AFFINE_HULL_SURFACE_TRIANGULATION = prove
 (`!t u z. convex u /\ bounded u /\ z IN interior u /\
           triangulation t /\ UNIONS t SUBSET frontier u
           ==> !c:real^N->bool. c IN t ==> ~(z IN affine hull c)`,
  REPEAT GEN_TAC THEN GEOM_ORIGIN_TAC `z:real^N` THEN REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`closure u:real^N->bool`; `c:real^N->bool`]
        CONVEX_RELATIVE_BOUNDARY_SUBSET_OF_PROPER_FACE) THEN
  ASM_SIMP_TAC[CONVEX_RELATIVE_INTERIOR_CLOSURE; CONVEX_CLOSURE] THEN
  REWRITE_TAC[GSYM relative_frontier; CLOSURE_EQ_EMPTY; NOT_IMP] THEN
  REPEAT CONJ_TAC THENL
   [ASM_MESON_TAC[INTERIOR_EMPTY; NOT_IN_EMPTY];
    ASM_MESON_TAC[triangulation; SIMPLEX_IMP_CONVEX];
    MP_TAC(ISPEC `u:real^N->bool` RELATIVE_FRONTIER_NONEMPTY_INTERIOR) THEN
    ASM SET_TAC[];
    DISCH_THEN(X_CHOOSE_THEN `k:real^N->bool` STRIP_ASSUME_TAC)] THEN
  MP_TAC(ISPECL [`closure u:real^N->bool`; `k:real^N->bool`]
   AFFINE_HULL_FACE_OF_DISJOINT_RELATIVE_INTERIOR) THEN
  ASM_SIMP_TAC[CONVEX_RELATIVE_INTERIOR_CLOSURE; CONVEX_CLOSURE] THEN
  REWRITE_TAC[GSYM MEMBER_NOT_EMPTY; IN_INTER] THEN
  EXISTS_TAC `vec 0:real^N` THEN
  ASM_SIMP_TAC[REWRITE_RULE[SUBSET] INTERIOR_SUBSET_RELATIVE_INTERIOR] THEN
  ASM_MESON_TAC[SUBSET; HULL_MONO]);;

let TRIANGULATION_SUBFACES = prove
 (`!tr:(real^N->bool)->bool tr'.
        triangulation tr /\ (!c'. c' IN tr' ==> ?c. c IN tr /\ c' face_of c)
        ==> triangulation tr'`,
  REPEAT GEN_TAC THEN REWRITE_TAC[triangulation] THEN STRIP_TAC THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC FINITE_SUBSET THEN
    EXISTS_TAC `UNIONS {{f:real^N->bool | f face_of c} | c IN tr}` THEN
    REWRITE_TAC[FINITE_UNIONS; SIMPLE_IMAGE; FORALL_IN_IMAGE] THEN
    ASM_SIMP_TAC[FINITE_IMAGE] THEN
    CONJ_TAC THENL [ASM_MESON_TAC[FINITE_FACES_OF_SIMPLEX]; ALL_TAC] THEN
    REWRITE_TAC[UNIONS_IMAGE] THEN ASM SET_TAC[];
    ASM_MESON_TAC[SIMPLEX_FACE_OF_SIMPLEX];
    ASM_MESON_TAC[FACE_OF_INTER_SUBFACE]]);;

(* ------------------------------------------------------------------------- *)
(* Subdividing a cell complex (not necessarily simplicial).                  *)
(* ------------------------------------------------------------------------- *)

let CELL_COMPLEX_SUBDIVISION_EXISTS = prove
 (`!m:(real^N->bool)->bool d e.
     &0 < e /\
     FINITE m /\
     (!c. c IN m ==> polytope c) /\
     (!c. c IN m ==> aff_dim c <= d) /\
     (!c1 c2. c1 IN m /\ c2 IN m
              ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
     ==> ?m'. (!c. c IN m' ==> diameter c < e) /\
              UNIONS m' = UNIONS m /\
              FINITE m' /\
              (!c. c IN m' ==> ?d. d IN m /\ c SUBSET d) /\
              (!c x. c IN m /\ x IN c
                     ==> ?d. d IN m' /\ x IN d /\ d SUBSET c) /\
              (!c. c IN m' ==> polytope c) /\
              (!c. c IN m' ==> aff_dim c <= d) /\
              (!c1 c2. c1 IN m' /\ c2 IN m'
                       ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)`,
  let lemma1 = prove
   (`a < abs(x - y)
     ==> &0 < a
         ==> ?n. integer n /\ (x < n * a /\ n * a < y \/
                               y <  n * a /\ n * a < x)`,
    REPEAT STRIP_TAC THEN
    ASM_SIMP_TAC[GSYM REAL_LT_LDIV_EQ; GSYM REAL_LT_RDIV_EQ] THEN
    MATCH_MP_TAC INTEGER_EXISTS_BETWEEN_ABS_LT THEN
    REWRITE_TAC[real_div; GSYM REAL_SUB_RDISTRIB; REAL_ABS_MUL] THEN
    ASM_SIMP_TAC[REAL_ABS_INV; REAL_ARITH `&0 < x ==> abs x = x`] THEN
    ASM_SIMP_TAC[GSYM real_div; REAL_LT_RDIV_EQ;
                 REAL_MUL_LID; REAL_LT_IMP_LE])
  and lemma2 = prove
   (`!m:(real^N->bool)->bool d.
        FINITE m /\
        (!c. c IN m ==> polytope c) /\
        (!c. c IN m ==> aff_dim c <= d) /\
        (!c1 c2. c1 IN m /\ c2 IN m
                 ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
        ==> !i. FINITE i
                ==> ?m'. UNIONS m' = UNIONS m /\
                         FINITE m' /\
                         (!c. c IN m' ==> ?d. d IN m /\ c SUBSET d) /\
                         (!c x. c IN m /\ x IN c
                                ==> ?d. d IN m' /\ x IN d /\ d SUBSET c) /\
                         (!c. c IN m' ==> polytope c) /\
                         (!c. c IN m' ==> aff_dim c <= d) /\
                         (!c1 c2. c1 IN m' /\ c2 IN m'
                                  ==> c1 INTER c2 face_of c1 /\
                                      c1 INTER c2 face_of c2) /\
                         (!c x y. c IN m' /\ x IN c /\ y IN c
                                  ==> !a b. (a,b) IN i
                                            ==> a dot x <= b /\ a dot y <= b \/
                                                a dot x >= b /\ a dot y >= b)`,
    REPEAT GEN_TAC THEN STRIP_TAC THEN MATCH_MP_TAC FINITE_INDUCT_STRONG THEN
    REWRITE_TAC[NOT_IN_EMPTY; FORALL_PAIR_THM] THEN CONJ_TAC THENL
     [EXISTS_TAC `m:(real^N->bool)->bool` THEN ASM_REWRITE_TAC[] THEN
      MESON_TAC[SUBSET_REFL];
      ALL_TAC] THEN
    MAP_EVERY X_GEN_TAC [`a:real^N`; `b:real`; `i:(real^N#real)->bool`] THEN
    GEN_REWRITE_TAC I [IMP_CONJ] THEN
    DISCH_THEN(X_CHOOSE_THEN `n:(real^N->bool)->bool` MP_TAC) THEN
    DISCH_THEN(CONJUNCTS_THEN2 (SUBST1_TAC o SYM) MP_TAC) THEN
    POP_ASSUM_LIST(K ALL_TAC) THEN REPEAT STRIP_TAC THEN
    EXISTS_TAC `{c INTER {x:real^N | a dot x <= b} | c IN n} UNION
                {c INTER {x:real^N | a dot x >= b} | c IN n}` THEN
    REPEAT CONJ_TAC THENL
     [REWRITE_TAC[UNIONS_UNION; GSYM INTER_UNIONS; GSYM UNION_OVER_INTER] THEN
      MATCH_MP_TAC(SET_RULE `(!x. x IN s) ==> t INTER s = t`) THEN
      REWRITE_TAC[IN_UNION; IN_ELIM_THM] THEN REAL_ARITH_TAC;
      ASM_SIMP_TAC[FINITE_UNION; SIMPLE_IMAGE; FINITE_IMAGE];
      REWRITE_TAC[FORALL_IN_UNION; FORALL_IN_GSPEC] THEN
      ASM_MESON_TAC[SUBSET_TRANS; INTER_SUBSET];
      REWRITE_TAC[EXISTS_IN_UNION; EXISTS_IN_GSPEC] THEN
      MAP_EVERY X_GEN_TAC [`c:real^N->bool`; `x:real^N`] THEN STRIP_TAC THEN
      REWRITE_TAC[OR_EXISTS_THM] THEN
      UNDISCH_THEN
       `!c x:real^N. c IN m /\ x IN c ==> ?d. d IN n /\ x IN d /\ d SUBSET c`
       (MP_TAC o SPECL [`c:real^N->bool`; `x:real^N`]) THEN
      ASM_REWRITE_TAC[] THEN MATCH_MP_TAC MONO_EXISTS THEN
      SIMP_TAC[IN_INTER; IN_ELIM_THM] THEN REPEAT STRIP_TAC THEN
      MP_TAC(ISPECL [`(a:real^N) dot x`; `b:real`] REAL_LE_TOTAL) THEN
      REWRITE_TAC[real_ge] THEN ASM SET_TAC[];
      REWRITE_TAC[IN_UNION; IN_ELIM_THM] THEN REPEAT STRIP_TAC THEN
      ASM_SIMP_TAC[POLYTOPE_INTER_POLYHEDRON; POLYHEDRON_HALFSPACE_LE;
                   POLYHEDRON_HALFSPACE_GE];
      REWRITE_TAC[IN_UNION; IN_ELIM_THM] THEN REPEAT STRIP_TAC THEN
      ASM_MESON_TAC[INT_LE_TRANS; AFF_DIM_SUBSET; INTER_SUBSET];
      REWRITE_TAC[IN_UNION; IN_ELIM_THM] THEN REPEAT STRIP_TAC THEN
      ASM_REWRITE_TAC[] THEN
      ONCE_REWRITE_TAC[SET_RULE
      `(s INTER t) INTER (s' INTER t') = (s INTER s') INTER (t INTER t')`] THEN
      MATCH_MP_TAC FACE_OF_INTER_INTER THEN ASM_SIMP_TAC[] THEN
      SIMP_TAC[SET_RULE `s INTER s = s`; FACE_OF_REFL; CONVEX_HALFSPACE_LE;
               CONVEX_HALFSPACE_GE] THEN
      REWRITE_TAC[INTER; IN_ELIM_THM; HYPERPLANE_FACE_OF_HALFSPACE_LE;
                  HYPERPLANE_FACE_OF_HALFSPACE_GE;
                  REAL_ARITH `a <= b /\ a >= b <=> a = b`;
                  REAL_ARITH `a >= b /\ a <= b <=> a = b`];
      REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; IN_UNION; FORALL_AND_THM;
                  IN_INSERT;
                  TAUT `p \/ q ==> r <=> (p ==> r) /\ (q ==> r)`] THEN
      REWRITE_TAC[FORALL_IN_GSPEC; IN_INTER; IN_ELIM_THM; PAIR_EQ] THEN
      SIMP_TAC[] THEN ASM_MESON_TAC[]]) in
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN `bounded(UNIONS m:real^N->bool)` MP_TAC THENL
   [ASM_SIMP_TAC[BOUNDED_UNIONS; POLYTOPE_IMP_BOUNDED]; ALL_TAC] THEN
  REWRITE_TAC[BOUNDED_POS_LT; LEFT_IMP_EXISTS_THM] THEN
  X_GEN_TAC `B:real` THEN REWRITE_TAC[] THEN STRIP_TAC THEN
  MP_TAC(ISPECL [`--B / (e / &2 / &(dimindex(:N)))`;
                 `B / (e / &2 / &(dimindex(:N)))`] FINITE_INTSEG) THEN
  ASM_SIMP_TAC[REAL_LE_LDIV_EQ; REAL_LE_RDIV_EQ; REAL_HALF;
               REAL_LT_DIV; REAL_OF_NUM_LT; DIMINDEX_GE_1; LE_1] THEN
  REWRITE_TAC[REAL_BOUNDS_LE] THEN ABBREV_TAC
   `k = {i | integer i /\ abs(i * e / &2 / &(dimindex(:N))) <= B}` THEN
  DISCH_TAC THEN
  MP_TAC(ISPECL [`m:(real^N->bool)->bool`; `d:int`] lemma2) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(MP_TAC o SPEC
   `{ (basis i:real^N,j * e / &2 / &(dimindex(:N))) |
      i IN 1..dimindex(:N) /\ j IN k}`) THEN
  ASM_SIMP_TAC[FINITE_PRODUCT_DEPENDENT; FINITE_NUMSEG] THEN
  MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `n:(real^N->bool)->bool` THEN
  STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
  X_GEN_TAC `c:real^N->bool` THEN DISCH_TAC THEN
  MATCH_MP_TAC(REAL_ARITH `&0 < e /\ x <= e / &2 ==> x < e`) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC DIAMETER_LE THEN
  CONJ_TAC THENL [ASM_REAL_ARITH_TAC; ALL_TAC] THEN
  MAP_EVERY X_GEN_TAC [`x:real^N`; `y:real^N`] THEN STRIP_TAC THEN
  W(MP_TAC o PART_MATCH lhand NORM_LE_L1 o lhand o snd) THEN
  MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ_ALT] REAL_LE_TRANS) THEN
  MATCH_MP_TAC SUM_BOUND_GEN THEN
  REWRITE_TAC[FINITE_NUMSEG; CARD_NUMSEG_1; NUMSEG_EMPTY] THEN
  REWRITE_TAC[NOT_LT; DIMINDEX_GE_1; IN_NUMSEG; VECTOR_SUB_COMPONENT] THEN
  X_GEN_TAC `i:num` THEN STRIP_TAC THEN REWRITE_TAC[GSYM REAL_NOT_LT] THEN
  DISCH_THEN(MP_TAC o MATCH_MP lemma1) THEN
  ASM_SIMP_TAC[REAL_HALF; REAL_LT_DIV;
               REAL_OF_NUM_LT; DIMINDEX_GE_1; LE_1] THEN
  DISCH_THEN(X_CHOOSE_THEN `j:real` (CONJUNCTS_THEN ASSUME_TAC)) THEN
  FIRST_X_ASSUM(MP_TAC o SPECL [`c:real^N->bool`; `x:real^N`; `y:real^N`]) THEN
  ASM_REWRITE_TAC[] THEN DISCH_THEN(MP_TAC o
    SPECL [`basis i:real^N`; `j * e / &2 / &(dimindex(:N))`]) THEN
  ASM_SIMP_TAC[DOT_BASIS; IN_ELIM_THM; NOT_IMP] THEN
  CONJ_TAC THENL [ALL_TAC; ASM_REAL_ARITH_TAC] THEN
  MAP_EVERY EXISTS_TAC [`i:num`; `j:real`] THEN ASM_REWRITE_TAC[IN_NUMSEG] THEN
  EXPAND_TAC "k" THEN ASM_REWRITE_TAC[IN_ELIM_THM] THEN
  FIRST_X_ASSUM DISJ_CASES_TAC THEN FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP
   (REAL_ARITH `a < x /\ x < b
                ==> abs a <= c /\ abs b <= c ==> abs x <= c`)) THEN
  CONJ_TAC THEN
  W(MP_TAC o PART_MATCH lhand COMPONENT_LE_NORM o lhand o snd) THEN
  ASM_REWRITE_TAC[] THEN
  MATCH_MP_TAC(REWRITE_RULE[IMP_CONJ_ALT] REAL_LE_TRANS) THEN
  MATCH_MP_TAC REAL_LT_IMP_LE THEN FIRST_X_ASSUM MATCH_MP_TAC THEN
  ASM SET_TAC[]);;

(* ------------------------------------------------------------------------- *)
(* Refining a cell complex to a simplicial complex.                          *)
(* ------------------------------------------------------------------------- *)

let SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX_LOWDIM = prove
 (`!m:(real^N->bool)->bool d.
        FINITE m /\
        (!c. c IN m ==> polytope c) /\
        (!c. c IN m ==> aff_dim c <= d) /\
        (!c1 c2. c1 IN m /\ c2 IN m
                 ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
        ==> ?t. simplicial_complex t /\
                (!k. k IN t ==> aff_dim k <= d) /\
                UNIONS t = UNIONS m /\
                (!c. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f) /\
                (!k. k IN t ==> ?c. c IN m /\ k SUBSET c)`,
  let lemma1 = prove
   (`!s t u z:real^N.
          convex s /\ convex t /\ convex u /\ z IN relative_interior s /\
          t SUBSET relative_frontier s /\ u SUBSET relative_frontier s
          ==> convex hull (z INSERT t) INTER convex hull (z INSERT u) =
              convex hull (z INSERT (t INTER u))`,
    REPEAT STRIP_TAC THEN REWRITE_TAC[GSYM SUBSET_ANTISYM_EQ] THEN
    REWRITE_TAC[SUBSET_INTER] THEN
    SIMP_TAC[HULL_MONO; INTER_SUBSET; SET_RULE
     `s SUBSET t ==> z INSERT s SUBSET z INSERT t`] THEN
    REWRITE_TAC[CONVEX_HULL_INSERT_SEGMENTS] THEN
    ASM_CASES_TAC `t:real^N->bool = {}` THEN
    ASM_REWRITE_TAC[INTER_EMPTY; INTER_SUBSET] THEN
    ASM_CASES_TAC `u:real^N->bool = {}` THEN
    ASM_REWRITE_TAC[INTER_EMPTY; INTER_SUBSET] THEN
    REWRITE_TAC[SUBSET; IN_INTER; UNIONS_GSPEC; IN_ELIM_THM] THEN
    ASM_SIMP_TAC[HULL_P] THEN
    X_GEN_TAC `x:real^N` THEN DISCH_THEN(CONJUNCTS_THEN2
     (X_CHOOSE_THEN `v:real^N` STRIP_ASSUME_TAC)
     (X_CHOOSE_THEN `w:real^N` STRIP_ASSUME_TAC)) THEN
    ASM_CASES_TAC `v:real^N = w` THENL
     [COND_CASES_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
      REWRITE_TAC[IN_ELIM_THM] THEN EXISTS_TAC `w:real^N` THEN
      ASM_REWRITE_TAC[] THEN MATCH_MP_TAC HULL_INC THEN ASM SET_TAC[];
      ASM_CASES_TAC `x:real^N = z` THENL
       [COND_CASES_TAC THEN ASM_REWRITE_TAC[IN_SING; IN_ELIM_THM] THEN
        REWRITE_TAC[ENDS_IN_SEGMENT] THEN
        ASM_MESON_TAC[MEMBER_NOT_EMPTY; CONVEX_HULL_EQ_EMPTY];
        MATCH_MP_TAC(TAUT `F ==> p`)]] THEN
    SUBGOAL_THEN `~(v:real^N = z) /\ ~(w:real^N = z)`
    STRIP_ASSUME_TAC THENL
     [ASM_MESON_TAC[relative_frontier; SUBSET; IN_DIFF]; ALL_TAC] THEN
    MP_TAC(ISPECL
     [`v:real^N`; `z:real^N`; `x:real^N`; `w:real^N`]
          COLLINEAR_3_TRANS) THEN
    ASM_REWRITE_TAC[NOT_IMP] THEN CONJ_TAC THENL
     [REPEAT(FIRST_X_ASSUM(MP_TAC o MATCH_MP BETWEEN_IMP_COLLINEAR o
         GEN_REWRITE_RULE I [GSYM BETWEEN_IN_SEGMENT])) THEN
      SIMP_TAC[INSERT_AC];
      ONCE_REWRITE_TAC[SET_RULE `{a,b,c} = {b,a,c}`] THEN
      REWRITE_TAC[COLLINEAR_BETWEEN_CASES]] THEN
    DISCH_THEN(DISJ_CASES_THEN MP_TAC) THENL
     [RULE_ASSUM_TAC(REWRITE_RULE[GSYM BETWEEN_IN_SEGMENT]) THEN
      ASM_MESON_TAC[BETWEEN_SYM; BETWEEN_TRANS; BETWEEN_TRANS_2;
                    BETWEEN_ANTISYM];
      REWRITE_TAC[BETWEEN_IN_SEGMENT]] THEN
    STRIP_TAC THENL
     [MP_TAC(ISPECL [`s:real^N->bool`; `z:real^N`; `w:real^N`]
          IN_RELATIVE_INTERIOR_CLOSURE_CONVEX_SEGMENT) THEN
      ASM_REWRITE_TAC[NOT_IMP] THEN CONJ_TAC THENL
       [ASM_MESON_TAC[relative_frontier; SUBSET; IN_DIFF];
        REWRITE_TAC[SUBSET] THEN DISCH_THEN(MP_TAC o SPEC `v:real^N`)] THEN
      REWRITE_TAC[NOT_IMP] THEN ONCE_REWRITE_TAC[SEGMENT_SYM] THEN
      ONCE_REWRITE_TAC[segment] THEN
      ASM_REWRITE_TAC[IN_DIFF; IN_INSERT; NOT_IN_EMPTY] THEN
      ASM_MESON_TAC[relative_frontier; SUBSET; IN_DIFF];
      MP_TAC(ISPECL [`s:real^N->bool`; `z:real^N`; `v:real^N`]
          IN_RELATIVE_INTERIOR_CLOSURE_CONVEX_SEGMENT) THEN
      ASM_REWRITE_TAC[NOT_IMP] THEN CONJ_TAC THENL
       [ASM_MESON_TAC[relative_frontier; SUBSET; IN_DIFF];
        REWRITE_TAC[SUBSET] THEN DISCH_THEN(MP_TAC o SPEC `w:real^N`)] THEN
      REWRITE_TAC[NOT_IMP] THEN ONCE_REWRITE_TAC[segment] THEN
      ASM_REWRITE_TAC[IN_DIFF; IN_INSERT; NOT_IN_EMPTY] THEN
      ASM_MESON_TAC[relative_frontier; SUBSET; IN_DIFF]]) in
  let lemma2 = prove
   (`!n m:(real^N->bool)->bool.
          FINITE m /\
          (!c. c IN m ==> polytope c) /\
          (!c. c IN m ==> aff_dim c <= &n) /\
          (!c f. c IN m /\ f face_of c ==> f IN m) /\
          (!c1 c2. c1 IN m /\ c2 IN m
                   ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
          ==> ?t. simplicial_complex t /\
                  (!k. k IN t ==> aff_dim k <= &n) /\
                  UNIONS t = UNIONS m /\
                  (!c. c IN m
                       ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f) /\
                  (!k. k IN t ==> ?c. c IN m /\ k SUBSET c)`,
    MATCH_MP_TAC num_WF THEN X_GEN_TAC `n:num` THEN DISCH_TAC THEN
    X_GEN_TAC `m:(real^N->bool)->bool` THEN STRIP_TAC THEN
    ASM_CASES_TAC `n <= 1` THENL
     [EXISTS_TAC `m:(real^N->bool)->bool` THEN
      ASM_REWRITE_TAC[simplicial_complex] THEN CONJ_TAC THENL
       [REPEAT STRIP_TAC THEN MATCH_MP_TAC POLYTOPE_LOWDIM_IMP_SIMPLEX THEN
        ASM_MESON_TAC[INT_OF_NUM_LE; INT_LE_TRANS];
        MESON_TAC[SING_SUBSET; UNIONS_1; FINITE_SING; SUBSET_REFL]];
      RULE_ASSUM_TAC(REWRITE_RULE[NOT_LE]) THEN
      FIRST_ASSUM(ASSUME_TAC o MATCH_MP (ARITH_RULE
       `1 < n ==> ~(n = 0)`))] THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `n - 1`) THEN
    ASM_REWRITE_TAC[ARITH_RULE `n - 1 < n <=> ~(n = 0)`] THEN
    ABBREV_TAC `sk = {c:real^N->bool | c IN m /\ aff_dim c < &n}` THEN
    DISCH_THEN(MP_TAC o SPEC `sk:(real^N->bool)->bool`) THEN
    ASM_SIMP_TAC[GSYM INT_OF_NUM_SUB; LT_IMP_LE] THEN
    REWRITE_TAC[INT_ARITH `x:int <= y - &1 <=> x < y`] THEN ANTS_TAC THENL
     [EXPAND_TAC "sk" THEN
      CONJ_TAC THENL [ASM_SIMP_TAC[FINITE_RESTRICT]; ALL_TAC] THEN
      REWRITE_TAC[IN_ELIM_THM] THEN
      REPLICATE_TAC 2 (CONJ_TAC THENL [ASM_MESON_TAC[]; ALL_TAC]) THEN
      CONJ_TAC THENL [ALL_TAC; ASM_MESON_TAC[]] THEN
      ASM_MESON_TAC[FACE_OF_IMP_SUBSET; AFF_DIM_SUBSET; INT_LET_TRANS];
      DISCH_THEN(X_CHOOSE_THEN `sc:(real^N->bool)->bool`
        STRIP_ASSUME_TAC)] THEN
    SUBGOAL_THEN
     `?t. simplicial_complex t /\
         (!k. k IN t ==> aff_dim k <= &n) /\
         (!c. c IN m ==> (?f. f SUBSET t /\ c = UNIONS f)) /\
         (!k. k IN t ==> (?c:real^N->bool. c IN m /\ k SUBSET c))`
    MP_TAC THENL
     [ALL_TAC;
      MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t:(real^N->bool)->bool` THEN
      ASM_CASES_TAC `FINITE(t:(real^N->bool)->bool)` THENL
       [ALL_TAC; ASM_MESON_TAC[simplicial_complex]] THEN
      REPLICATE_TAC 2 (MATCH_MP_TAC MONO_AND THEN REWRITE_TAC[]) THEN
      MATCH_MP_TAC(TAUT
       `(q /\ r ==> p) /\ (q ==> q')
        ==> q /\ r ==> p /\ q' /\ r`) THEN
      CONJ_TAC THENL [SET_TAC[]; ASM_MESON_TAC[FINITE_SUBSET]]] THEN
    FIRST_ASSUM(STRIP_ASSUME_TAC o
      GEN_REWRITE_RULE I [simplicial_complex]) THEN
    REWRITE_TAC[simplicial_complex; GSYM CONJ_ASSOC] THEN
    ABBREV_TAC `fat = {c:real^N->bool | c IN m /\ aff_dim c = &n}` THEN
    SUBGOAL_THEN
     `(!c:real^N->bool. c IN fat ==> polytope c) /\
      (!c. c IN fat ==> convex c) /\
      (!c. c IN fat ==> closed c) /\
      (!c. c IN fat ==> (@z. z IN relative_interior c) IN relative_interior c)`
    STRIP_ASSUME_TAC THENL
     [MATCH_MP_TAC(TAUT
        `(p ==> q /\ r) /\ p /\ (q ==> s) ==> p /\ q /\ r /\ s`) THEN
      REPEAT CONJ_TAC THENL
       [MESON_TAC[POLYTOPE_IMP_CONVEX; POLYTOPE_IMP_CLOSED];
        ASM SET_TAC[];
        REPEAT STRIP_TAC THEN CONV_TAC SELECT_CONV THEN
        ASM_SIMP_TAC[MEMBER_NOT_EMPTY; RELATIVE_INTERIOR_EQ_EMPTY] THEN
        UNDISCH_TAC `(c:real^N->bool) IN fat` THEN EXPAND_TAC "fat" THEN
        ONCE_REWRITE_TAC[GSYM CONTRAPOS_THM] THEN SIMP_TAC[IN_ELIM_THM] THEN
        REWRITE_TAC[AFF_DIM_EMPTY] THEN INT_ARITH_TAC];
      ALL_TAC] THEN
    SUBGOAL_THEN
     `!k. k IN sc ==> ?t. ~affine_dependent t /\
                          CARD t <= n /\ aff_dim k < &n /\
                          k:real^N->bool = convex hull t`
     (LABEL_TAC "*")
    THENL
     [REPEAT STRIP_TAC THEN
      SUBGOAL_THEN `?r. r simplex (k:real^N->bool)` CHOOSE_TAC THENL
       [ASM SET_TAC[]; ALL_TAC] THEN
      ASM_CASES_TAC `r = aff_dim(k:real^N->bool)` THENL
       [ALL_TAC; ASM_MESON_TAC[AFF_DIM_SIMPLEX]] THEN
      FIRST_ASSUM(MP_TAC o GEN_REWRITE_RULE I [simplex]) THEN
      MATCH_MP_TAC MONO_EXISTS THEN ASM_REWRITE_TAC[] THEN
      X_GEN_TAC `t:real^N->bool` THEN SIMP_TAC[] THEN
      REPEAT STRIP_TAC THENL [ALL_TAC; ASM_MESON_TAC[]] THEN
      ASM_REWRITE_TAC[GSYM INT_OF_NUM_LE] THEN
      MATCH_MP_TAC(INT_ARITH `x:int < n ==> x + &1 <= n`) THEN
      ASM_MESON_TAC[];
      ALL_TAC] THEN
    SUBGOAL_THEN
      `!c k. c IN fat /\ k IN sc /\ k SUBSET relative_frontier c
             ==> affine hull k INTER relative_interior c:real^N->bool = {}`
      (LABEL_TAC "-")
    THENL
     [REPEAT STRIP_TAC THEN
      SUBGOAL_THEN
       `?f:real^N->bool. f face_of c /\ ~(f = c) /\ k SUBSET f`
      STRIP_ASSUME_TAC THENL
       [SUBGOAL_THEN
         `?l:real^N->bool. l IN sk /\ k SUBSET l`
        STRIP_ASSUME_TAC THENL [ASM MESON_TAC[]; ALL_TAC] THEN
        EXISTS_TAC `l INTER c:real^N->bool` THEN
        CONJ_TAC THENL [ASM SET_TAC[]; ASM_REWRITE_TAC[SUBSET_INTER]] THEN
        CONJ_TAC THENL
         [MATCH_MP_TAC(MESON[INT_LT_REFL]
           `aff_dim s < aff_dim t ==> ~(s = t)`) THEN
          TRANS_TAC INT_LET_TRANS `aff_dim(l:real^N->bool)` THEN
          SIMP_TAC[AFF_DIM_SUBSET; INTER_SUBSET] THEN ASM SET_TAC[];
          TRANS_TAC SUBSET_TRANS `relative_frontier c:real^N->bool` THEN
          ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN ASM SET_TAC[]];
        MP_TAC(ISPECL [`c:real^N->bool`; `f:real^N->bool`]
          AFFINE_HULL_FACE_OF_DISJOINT_RELATIVE_INTERIOR) THEN
        ASM_SIMP_TAC[] THEN MATCH_MP_TAC(SET_RULE
         `s SUBSET t ==> t INTER u = {} ==> s INTER u = {}`) THEN
        ASM_SIMP_TAC[HULL_MONO]];
      ALL_TAC] THEN
    EXISTS_TAC
     `sc UNION { convex hull ((@z:real^N. z IN relative_interior c) INSERT k) |
                 c IN fat /\ k IN sc /\ k SUBSET relative_frontier c}` THEN
    REPEAT CONJ_TAC THENL
     [ASM_REWRITE_TAC[FINITE_UNION] THEN
      REWRITE_TAC[SET_RULE
       `A /\ x IN s /\ P x <=> A /\ x IN (s INTER {x | P x})`] THEN
      MATCH_MP_TAC FINITE_PRODUCT_DEPENDENT THEN
      ASM_SIMP_TAC[FINITE_INTER] THEN EXPAND_TAC "fat" THEN
      ASM_SIMP_TAC[FINITE_RESTRICT];
      ASM_REWRITE_TAC[FORALL_IN_UNION; FORALL_IN_GSPEC] THEN
      MAP_EVERY X_GEN_TAC [`c:real^N->bool`; `k:real^N->bool`] THEN
      STRIP_TAC THEN MATCH_MP_TAC SIMPLEX_INSERT THEN
      ASM_SIMP_TAC[] THEN REMOVE_THEN "-"
       (MP_TAC o SPECL [`c:real^N->bool`; `k:real^N->bool`]) THEN
      ASM_REWRITE_TAC[] THEN MATCH_MP_TAC(SET_RULE
         `z IN r ==> a INTER r = {} ==> ~(z IN a)`) THEN
      ASM_SIMP_TAC[];
      REWRITE_TAC[FORALL_IN_UNION; IMP_CONJ] THEN
      X_GEN_TAC `f:real^N->bool` THEN
      CONJ_TAC THENL [ASM_MESON_TAC[IN_UNION]; ALL_TAC] THEN
      REWRITE_TAC[FORALL_IN_GSPEC] THEN
      MAP_EVERY X_GEN_TAC [`c:real^N->bool`; `k:real^N->bool`] THEN
      STRIP_TAC THEN
      ABBREV_TAC `z:real^N = @z. z IN relative_interior c` THEN
      SUBGOAL_THEN `(z:real^N) IN relative_interior c` ASSUME_TAC THENL
       [ASM_MESON_TAC[]; ALL_TAC] THEN
      REMOVE_THEN "*" (MP_TAC o SPEC `k:real^N->bool`) THEN
      ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
      X_GEN_TAC `i:real^N->bool` THEN SIMP_TAC[] THEN
      DISCH_THEN(STRIP_ASSUME_TAC o GSYM) THEN
      ONCE_REWRITE_TAC[SET_RULE `z INSERT i = {z} UNION i`] THEN
      REWRITE_TAC[GSYM HULL_UNION_RIGHT] THEN
      REWRITE_TAC[SET_RULE `{z} UNION i = z INSERT i`] THEN
      SUBGOAL_THEN `~((z:real^N) IN affine hull i)` ASSUME_TAC THENL
       [REMOVE_THEN "-"
         (MP_TAC o SPECL [`c:real^N->bool`; `k:real^N->bool`]) THEN
        ASM_REWRITE_TAC[] THEN MATCH_MP_TAC(SET_RULE
         `a SUBSET a' /\ z IN r ==> a' INTER r = {} ==> ~(z IN a)`) THEN
        EXPAND_TAC "k" THEN
        ASM_REWRITE_TAC[SUBSET_REFL; AFFINE_HULL_CONVEX_HULL];
        ALL_TAC] THEN
      FIRST_ASSUM(ASSUME_TAC o MATCH_MP AFFINE_INDEPENDENT_IMP_FINITE) THEN
      DISCH_TAC THEN
      MP_TAC(ISPECL [`(z:real^N) INSERT i`; `f:real^N->bool`]
          FACE_OF_CONVEX_HULL_SUBSET) THEN
      ASM_SIMP_TAC[COMPACT_INSERT; FINITE_IMP_COMPACT] THEN
      DISCH_THEN(X_CHOOSE_THEN `j:real^N->bool` (STRIP_ASSUME_TAC o GSYM)) THEN
      REWRITE_TAC[IN_UNION; IN_ELIM_THM] THEN
      ASM_CASES_TAC `(z:real^N) IN j` THENL
       [DISJ2_TAC THEN MAP_EVERY EXISTS_TAC
         [`c:real^N->bool`; `convex hull (j DELETE (z:real^N))`] THEN
        ASM_REWRITE_TAC[] THEN REPEAT CONJ_TAC THENL
         [FIRST_ASSUM MATCH_MP_TAC THEN EXISTS_TAC `k:real^N->bool` THEN
          ASM_REWRITE_TAC[] THEN EXPAND_TAC "k" THEN
          ASM_SIMP_TAC[FACE_OF_CONVEX_HULL_AFFINE_INDEPENDENT] THEN
          EXISTS_TAC `j DELETE (z:real^N)` THEN ASM SET_TAC[];
          TRANS_TAC SUBSET_TRANS `k:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
          EXPAND_TAC "k" THEN MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[];
          ONCE_REWRITE_TAC[SET_RULE `z INSERT i = {z} UNION i`] THEN
          REWRITE_TAC[GSYM HULL_UNION_RIGHT] THEN
          REWRITE_TAC[SET_RULE `{z} UNION i = z INSERT i`] THEN
          EXPAND_TAC "f" THEN AP_TERM_TAC THEN ASM SET_TAC[]];
        DISJ1_TAC THEN FIRST_ASSUM MATCH_MP_TAC THEN
        EXISTS_TAC `k:real^N->bool` THEN ASM_REWRITE_TAC[] THEN
        EXPAND_TAC "k" THEN
        ASM_SIMP_TAC[FACE_OF_CONVEX_HULL_AFFINE_INDEPENDENT] THEN
        EXISTS_TAC `j:real^N->bool` THEN ASM SET_TAC[]];
        REWRITE_TAC[IN_UNION] THEN MATCH_MP_TAC(MESON[]
         `(!x y. R x y ==> R y x) /\
          (!x y. P x /\ P y ==> R x y) /\
          (!x y. P x /\ Q y ==> R x y) /\
          (!x y. Q x /\ Q y ==> R x y)
          ==> !x y. (P x \/ Q x) /\ (P y \/ Q y) ==> R x y`) THEN
        CONJ_TAC THENL [MESON_TAC[INTER_COMM]; ASM_REWRITE_TAC[]] THEN
        REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FORALL_IN_GSPEC] THEN
        REWRITE_TAC[IMP_IMP; RIGHT_IMP_FORALL_THM] THEN CONJ_TAC THENL
         [MAP_EVERY X_GEN_TAC
           [`l:real^N->bool`; `c:real^N->bool`; `k:real^N->bool`] THEN
          STRIP_TAC THEN
          ABBREV_TAC `z:real^N = @z. z IN relative_interior c` THEN
          SUBGOAL_THEN `(z:real^N) IN relative_interior c` ASSUME_TAC THENL
           [ASM_MESON_TAC[]; ALL_TAC] THEN
          SUBGOAL_THEN
           `l INTER convex hull (z INSERT k):real^N->bool =
            l INTER convex hull k`
          SUBST1_TAC THENL
           [MATCH_MP_TAC INTER_CONVEX_HULL_INSERT_RELATIVE_EXTERIOR THEN
            EXISTS_TAC `c:real^N->bool` THEN ASM_SIMP_TAC[] THEN
            CONJ_TAC THENL
             [TRANS_TAC SUBSET_TRANS `relative_frontier c:real^N->bool` THEN
              ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN
              ASM SET_TAC[];
              ALL_TAC] THEN
            SUBGOAL_THEN `?d:real^N->bool. d IN sk /\ l SUBSET d` MP_TAC THENL
             [ASM_MESON_TAC[]; REWRITE_TAC[LEFT_IMP_EXISTS_THM]] THEN
            X_GEN_TAC `d:real^N->bool` THEN
            DISCH_THEN(CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THEN
            MATCH_MP_TAC(SET_RULE
             `d INTER s = {} ==> l SUBSET d ==> DISJOINT l s`) THEN
            MATCH_MP_TAC(SET_RULE
             `relative_interior c SUBSET c /\
              (c INTER d) INTER relative_interior c = {}
              ==> d INTER relative_interior c = {}`) THEN
            REWRITE_TAC[RELATIVE_INTERIOR_SUBSET] THEN
            MATCH_MP_TAC FACE_OF_DISJOINT_RELATIVE_INTERIOR THEN
            CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
            MATCH_MP_TAC(MESON[INT_LT_REFL]
            `aff_dim s < aff_dim t ==> ~(s = t)`) THEN
           TRANS_TAC INT_LET_TRANS `aff_dim(d:real^N->bool)` THEN
           SIMP_TAC[AFF_DIM_SUBSET; INTER_SUBSET] THEN ASM SET_TAC[];
           ALL_TAC] THEN
         SUBGOAL_THEN `convex hull k:real^N->bool = k` SUBST1_TAC THENL
          [MATCH_MP_TAC HULL_P THEN MATCH_MP_TAC POLYTOPE_IMP_CONVEX THEN
           MATCH_MP_TAC SIMPLEX_IMP_POLYTOPE THEN ASM SET_TAC[];
           ALL_TAC] THEN
         CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
         TRANS_TAC FACE_OF_TRANS `k:real^N->bool` THEN
         CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
         REMOVE_THEN "*" (MP_TAC o SPEC `k:real^N->bool`) THEN
         ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
         X_GEN_TAC `i:real^N->bool` THEN
         DISCH_THEN(STRIP_ASSUME_TAC o GSYM) THEN
         SUBGOAL_THEN `~((z:real^N) IN affine hull i)` ASSUME_TAC THENL
          [REMOVE_THEN "-"
            (MP_TAC o SPECL [`c:real^N->bool`; `k:real^N->bool`]) THEN
           ASM_REWRITE_TAC[] THEN MATCH_MP_TAC(SET_RULE
            `a SUBSET a' /\ z IN r ==> a' INTER r = {} ==> ~(z IN a)`) THEN
           EXPAND_TAC "k" THEN
           ASM_REWRITE_TAC[SUBSET_REFL; AFFINE_HULL_CONVEX_HULL];
           ALL_TAC] THEN
          EXPAND_TAC "k" THEN
          ONCE_REWRITE_TAC[SET_RULE `z INSERT i = {z} UNION i`] THEN
          REWRITE_TAC[GSYM HULL_UNION_RIGHT] THEN
          REWRITE_TAC[SET_RULE `{z} UNION i = z INSERT i`]  THEN
          ASM_SIMP_TAC[FACE_OF_CONVEX_HULL_AFFINE_INDEPENDENT;
                       AFFINE_INDEPENDENT_INSERT] THEN
          EXISTS_TAC `i:real^N->bool` THEN ASM SET_TAC[];
          ALL_TAC] THEN
       MAP_EVERY X_GEN_TAC
        [`c:real^N->bool`; `k:real^N->bool`;
         `d:real^N->bool`; `l:real^N->bool`] THEN
       STRIP_TAC THEN
       ABBREV_TAC `z:real^N = @z. z IN relative_interior c` THEN
       SUBGOAL_THEN `(z:real^N) IN relative_interior c` ASSUME_TAC THENL
        [ASM_MESON_TAC[]; ALL_TAC] THEN
       ASM_CASES_TAC `d:real^N->bool = c` THENL
        [FIRST_X_ASSUM SUBST_ALL_TAC THEN ASM_REWRITE_TAC[];
         ABBREV_TAC `w:real^N = @z. z IN relative_interior d` THEN
         SUBGOAL_THEN `(w:real^N) IN relative_interior d` ASSUME_TAC THENL
          [ASM_MESON_TAC[]; ALL_TAC] THEN
         SUBGOAL_THEN
          `convex hull (z INSERT k) INTER
           convex hull (w INSERT l):real^N->bool =
           convex hull (z INSERT k) INTER convex hull l`
         SUBST1_TAC THENL
          [MATCH_MP_TAC INTER_CONVEX_HULL_INSERT_RELATIVE_EXTERIOR THEN
           EXISTS_TAC `d:real^N->bool` THEN ASM_SIMP_TAC[] THEN
           CONJ_TAC THENL
            [TRANS_TAC SUBSET_TRANS `relative_frontier d:real^N->bool` THEN
             ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN
             ASM SET_TAC[];
             ALL_TAC] THEN
           MATCH_MP_TAC(SET_RULE
            `!c. s SUBSET c /\ c INTER d = {} ==> DISJOINT s d`) THEN
           EXISTS_TAC `c:real^N->bool` THEN CONJ_TAC THENL
            [MATCH_MP_TAC HULL_MINIMAL THEN ASM_SIMP_TAC[INSERT_SUBSET] THEN
             CONJ_TAC THENL
              [ASM_MESON_TAC[RELATIVE_INTERIOR_SUBSET; SUBSET]; ALL_TAC] THEN
             TRANS_TAC SUBSET_TRANS `relative_frontier c:real^N->bool` THEN
             ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN SET_TAC[];
             ALL_TAC] THEN
           MATCH_MP_TAC(SET_RULE
            `relative_interior c SUBSET c /\
             (c INTER d) INTER relative_interior c = {}
             ==> d INTER relative_interior c = {}`) THEN
           REWRITE_TAC[RELATIVE_INTERIOR_SUBSET] THEN
           MATCH_MP_TAC FACE_OF_DISJOINT_RELATIVE_INTERIOR THEN
           CONJ_TAC THENL [ASM SET_TAC[]; DISCH_TAC] THEN
           SUBGOAL_THEN
             `~(aff_dim (d:real^N->bool) = aff_dim (c:real^N->bool))`
           ASSUME_TAC THENL [ALL_TAC; ASM SET_TAC[]] THEN
           MATCH_MP_TAC INT_LT_IMP_NE THEN EXPAND_TAC "d" THEN
           MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
           CONJ_TAC THENL [ALL_TAC; ASM SET_TAC[]] THEN
           MATCH_MP_TAC POLYTOPE_IMP_CONVEX THEN ASM SET_TAC[];
           ALL_TAC] THEN
         SUBGOAL_THEN `convex hull l:real^N->bool = l` SUBST1_TAC THENL
          [MATCH_MP_TAC HULL_P THEN MATCH_MP_TAC POLYTOPE_IMP_CONVEX THEN
           MATCH_MP_TAC SIMPLEX_IMP_POLYTOPE THEN ASM SET_TAC[];
           ALL_TAC] THEN
         SUBGOAL_THEN
          `convex hull (z INSERT k) INTER l:real^N->bool =
           convex hull k INTER l`
         SUBST1_TAC THENL
          [ONCE_REWRITE_TAC[INTER_COMM] THEN
           MATCH_MP_TAC INTER_CONVEX_HULL_INSERT_RELATIVE_EXTERIOR THEN
           EXISTS_TAC `c:real^N->bool` THEN ASM_SIMP_TAC[] THEN
           CONJ_TAC THENL
            [TRANS_TAC SUBSET_TRANS `relative_frontier c:real^N->bool` THEN
             ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN
             ASM SET_TAC[];
             ALL_TAC] THEN
           MATCH_MP_TAC(SET_RULE
            `!c. s SUBSET c /\ c INTER d = {} ==> DISJOINT s d`) THEN
           EXISTS_TAC `d:real^N->bool` THEN CONJ_TAC THENL
            [TRANS_TAC SUBSET_TRANS `relative_frontier d:real^N->bool` THEN
             ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN SET_TAC[];
             ALL_TAC] THEN
           MATCH_MP_TAC(SET_RULE
            `relative_interior c SUBSET c /\
             (c INTER d) INTER relative_interior c = {}
             ==> d INTER relative_interior c = {}`) THEN
           REWRITE_TAC[RELATIVE_INTERIOR_SUBSET] THEN
           MATCH_MP_TAC FACE_OF_DISJOINT_RELATIVE_INTERIOR THEN
           CONJ_TAC THENL [ASM SET_TAC[]; DISCH_TAC] THEN
           SUBGOAL_THEN
            `~(aff_dim (c:real^N->bool) = aff_dim (d:real^N->bool))`
           ASSUME_TAC THENL [ALL_TAC; ASM SET_TAC[]] THEN
           MATCH_MP_TAC INT_LT_IMP_NE THEN EXPAND_TAC "c" THEN
           MATCH_MP_TAC FACE_OF_AFF_DIM_LT THEN
           CONJ_TAC THENL [ALL_TAC; ASM SET_TAC[]] THEN
           MATCH_MP_TAC POLYTOPE_IMP_CONVEX THEN ASM SET_TAC[];
           ALL_TAC] THEN
         SUBGOAL_THEN `convex hull k:real^N->bool = k` SUBST1_TAC THENL
          [MATCH_MP_TAC HULL_P THEN MATCH_MP_TAC POLYTOPE_IMP_CONVEX THEN
           MATCH_MP_TAC SIMPLEX_IMP_POLYTOPE THEN ASM SET_TAC[];
           ALL_TAC] THEN
         CONJ_TAC THEN MATCH_MP_TAC FACE_OF_TRANS THENL
          [EXISTS_TAC `k:real^N->bool`; EXISTS_TAC `l:real^N->bool`] THEN
         (CONJ_TAC THENL [ASM_MESON_TAC[]; ALL_TAC]) THENL
          [REMOVE_THEN "*" (MP_TAC o SPEC `k:real^N->bool`);
           REMOVE_THEN "*" (MP_TAC o SPEC `l:real^N->bool`)] THEN
         ASM_REWRITE_TAC[LEFT_IMP_EXISTS_THM] THEN
         X_GEN_TAC `i:real^N->bool` THEN
         DISCH_THEN(STRIP_ASSUME_TAC o GSYM) THEN
         FIRST_ASSUM(SUBST1_TAC o SYM) THEN
         ONCE_REWRITE_TAC[SET_RULE `z INSERT i = {z} UNION i`] THEN
         REWRITE_TAC[GSYM HULL_UNION_RIGHT] THEN
         REWRITE_TAC[SET_RULE `{z} UNION i = z INSERT i`] THEN
         W(MP_TAC o PART_MATCH (lhand o rand)
           FACE_OF_CONVEX_HULL_AFFINE_INDEPENDENT o snd) THEN
         (ANTS_TAC THENL
           [ALL_TAC;
            DISCH_THEN SUBST1_TAC THEN EXISTS_TAC `i:real^N->bool` THEN
            ASM SET_TAC[]]) THEN
         MATCH_MP_TAC AFFINE_INDEPENDENT_INSERT THEN ASM_REWRITE_TAC[] THENL
          [REMOVE_THEN "-"
            (MP_TAC o SPECL [`c:real^N->bool`; `k:real^N->bool`]);
           REMOVE_THEN "-"
            (MP_TAC o SPECL [`d:real^N->bool`; `l:real^N->bool`])] THEN
         ASM_REWRITE_TAC[] THEN MATCH_MP_TAC(SET_RULE
          `a SUBSET a' /\ z IN r ==> a' INTER r = {} ==> ~(z IN a)`) THEN
         FIRST_ASSUM(SUBST1_TAC o SYM) THEN
         ASM_REWRITE_TAC[SUBSET_REFL; AFFINE_HULL_CONVEX_HULL]] THEN
       CONJ_TAC THEN
       MP_TAC(ISPEC `c:real^N->bool` lemma1) THEN DISCH_THEN(fun th ->
         W(MP_TAC o PART_MATCH (lhand o rand) th o lhand o snd)) THEN
       ASM_REWRITE_TAC[] THEN
       (ANTS_TAC THENL
         [ASM_SIMP_TAC[] THEN CONJ_TAC THEN
          MATCH_MP_TAC POLYTOPE_IMP_CONVEX THEN
          MATCH_MP_TAC SIMPLEX_IMP_POLYTOPE THEN ASM SET_TAC[];
          DISCH_THEN SUBST1_TAC] THEN
        W(MP_TAC o PART_MATCH (lhand o rand) FACE_OF_POLYTOPE_INSERT_EQ o
          snd) THEN
        ANTS_TAC THENL
         [ALL_TAC;
          DISCH_THEN SUBST1_TAC THEN DISJ2_TAC THEN
          EXISTS_TAC `k INTER l:real^N->bool` THEN
          ASM_MESON_TAC[]] THEN
        CONJ_TAC THENL
         [MATCH_MP_TAC SIMPLEX_IMP_POLYTOPE THEN ASM SET_TAC[];
          ASM_MESON_TAC[MEMBER_NOT_EMPTY; IN_INTER]]);
       ASM_SIMP_TAC[FORALL_IN_UNION; INT_LT_IMP_LE] THEN
       REWRITE_TAC[FORALL_IN_GSPEC] THEN
       REWRITE_TAC[AFF_DIM_CONVEX_HULL; AFF_DIM_INSERT] THEN
       REPEAT STRIP_TAC THEN COND_CASES_TAC THEN
       ASM_SIMP_TAC[INT_LT_IMP_LE; INT_ARITH `k:int < n ==> k + &1 <= n`];
       X_GEN_TAC `c:real^N->bool` THEN DISCH_TAC THEN
       ASM_CASES_TAC `(c:real^N->bool) IN sk` THENL
        [ASM_MESON_TAC[SUBSET; IN_UNION]; ALL_TAC] THEN
       SUBGOAL_THEN `(c:real^N->bool) IN fat` ASSUME_TAC THENL
        [EXPAND_TAC "fat" THEN ASM_REWRITE_TAC[IN_ELIM_THM] THEN
         MATCH_MP_TAC(INT_ARITH `x:int <= n /\ ~(x < n) ==> x = n`) THEN
         ASM SET_TAC[];
         ALL_TAC] THEN
       EXISTS_TAC
        `{ convex hull ((@z:real^N. z IN relative_interior c) INSERT k) |k|
           k IN sc /\ k SUBSET relative_frontier c}` THEN
       CONJ_TAC THENL
        [GEN_REWRITE_TAC I [SUBSET] THEN REWRITE_TAC[FORALL_IN_GSPEC] THEN
         X_GEN_TAC `k:real^N->bool` THEN STRIP_TAC THEN
         REWRITE_TAC[IN_UNION] THEN DISJ2_TAC THEN
         REWRITE_TAC[IN_ELIM_THM] THEN ASM_MESON_TAC[];
         ALL_TAC] THEN
       REWRITE_TAC[GSYM(ONCE_REWRITE_RULE[CONJ_SYM] SUBSET_ANTISYM_EQ)] THEN
       CONJ_TAC THEN GEN_REWRITE_TAC I [SUBSET] THENL
        [REWRITE_TAC[FORALL_IN_UNIONS; FORALL_IN_GSPEC; IMP_CONJ;
                     RIGHT_FORALL_IMP_THM] THEN
         X_GEN_TAC `k:real^N->bool` THEN REPEAT DISCH_TAC THEN
         REWRITE_TAC[GSYM SUBSET] THEN MATCH_MP_TAC HULL_MINIMAL THEN
         ASM_SIMP_TAC[INSERT_SUBSET] THEN CONJ_TAC THENL
          [ASM_MESON_TAC[RELATIVE_INTERIOR_SUBSET; SUBSET]; ALL_TAC] THEN
         TRANS_TAC SUBSET_TRANS `relative_frontier c:real^N->bool` THEN
         ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN SET_TAC[];
         ALL_TAC] THEN
       X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
       REWRITE_TAC[UNIONS_GSPEC; IN_ELIM_THM] THEN
       ABBREV_TAC `z:real^N = @z. z IN relative_interior c` THEN
       SUBGOAL_THEN `(z:real^N) IN relative_interior c` ASSUME_TAC THENL
        [ASM_MESON_TAC[]; ALL_TAC] THEN
       MP_TAC(ISPECL [`c:real^N->bool`; `z:real^N`; `x:real^N`]
          SEGMENT_TO_RELATIVE_FRONTIER) THEN
       ANTS_TAC THENL
        [ASM_SIMP_TAC[POLYTOPE_IMP_BOUNDED] THEN
         DISCH_THEN(MP_TAC o AP_TERM `aff_dim:(real^N->bool)->int` o
          CONJUNCT2) THEN
         REWRITE_TAC[AFF_DIM_SING] THEN DISCH_TAC THEN
         UNDISCH_TAC `(c:real^N->bool) IN fat` THEN EXPAND_TAC "fat" THEN
         ASM_REWRITE_TAC[IN_ELIM_THM; INT_OF_NUM_EQ];
         DISCH_THEN(X_CHOOSE_THEN `y:real^N` STRIP_ASSUME_TAC)] THEN
       MP_TAC(SPEC `c:real^N->bool` RELATIVE_FRONTIER_OF_POLYHEDRON_ALT) THEN
       ANTS_TAC THENL [ASM_SIMP_TAC[POLYTOPE_IMP_POLYHEDRON]; ALL_TAC] THEN
       DISCH_THEN(MP_TAC o AP_TERM `\s. (y:real^N) IN s`) THEN
       ASM_REWRITE_TAC[IN_UNIONS; IN_ELIM_THM] THEN
       DISCH_THEN(X_CHOOSE_THEN `f:real^N->bool` STRIP_ASSUME_TAC) THEN
       SUBGOAL_THEN
        `?g. FINITE g /\ g SUBSET sc /\ f:real^N->bool = UNIONS g`
       MP_TAC THENL
        [FIRST_X_ASSUM MATCH_MP_TAC THEN EXPAND_TAC "sk" THEN
         REWRITE_TAC[IN_ELIM_THM] THEN
         CONJ_TAC THENL [ASM_MESON_TAC[]; ALL_TAC] THEN
         MP_TAC(ISPECL [`f:real^N->bool`; `c:real^N->bool`]
           FACE_OF_AFF_DIM_LT) THEN
         ASM SET_TAC[];
         DISCH_TAC THEN
         SUBGOAL_THEN `?k:real^N->bool. k IN sc /\ y IN k /\ k SUBSET f`
         MP_TAC THENL [ASM SET_TAC[]; MATCH_MP_TAC MONO_EXISTS]] THEN
       X_GEN_TAC `k:real^N->bool` THEN STRIP_TAC THEN ASM_REWRITE_TAC[] THEN
       CONJ_TAC THENL
        [ASM_MESON_TAC[FACE_OF_SUBSET_RELATIVE_FRONTIER; SUBSET_TRANS];
         ALL_TAC] THEN
       FIRST_X_ASSUM(MATCH_MP_TAC o MATCH_MP (SET_RULE
        `x IN s ==> s SUBSET t ==> x IN t`)) THEN
       REWRITE_TAC[SEGMENT_CONVEX_HULL] THEN
       MATCH_MP_TAC HULL_MONO THEN ASM SET_TAC[];
       REWRITE_TAC[FORALL_IN_UNION; FORALL_IN_GSPEC] THEN
       CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
       MAP_EVERY X_GEN_TAC [`c:real^N->bool`; `k:real^N->bool`] THEN
       STRIP_TAC THEN EXISTS_TAC `c:real^N->bool` THEN
       CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
       MATCH_MP_TAC HULL_MINIMAL THEN ASM_SIMP_TAC[INSERT_SUBSET] THEN
       CONJ_TAC THENL
        [ASM_MESON_TAC[RELATIVE_INTERIOR_SUBSET; SUBSET]; ALL_TAC] THEN
       TRANS_TAC SUBSET_TRANS `relative_frontier c:real^N->bool` THEN
       ASM_SIMP_TAC[relative_frontier; CLOSURE_CLOSED] THEN SET_TAC[]]) in
  REPEAT GEN_TAC THEN ASM_CASES_TAC `&0:int <= d` THENL
   [FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [GSYM INT_OF_NUM_EXISTS]) THEN
    DISCH_THEN(X_CHOOSE_THEN `n:num` SUBST1_TAC) THEN STRIP_TAC THEN
    MP_TAC(ISPECL
      [`n:num`; `UNIONS {{f:real^N->bool | f face_of c} | c IN m}`]
      lemma2) THEN
    REWRITE_TAC[IMP_CONJ; RIGHT_FORALL_IMP_THM; FINITE_UNIONS;
                FORALL_IN_UNIONS; FORALL_IN_GSPEC; EXISTS_IN_UNIONS] THEN
    ANTS_TAC THENL [ASM_SIMP_TAC[SIMPLE_IMAGE; FINITE_IMAGE]; ALL_TAC] THEN
    ANTS_TAC THENL [ASM_MESON_TAC[FINITE_POLYTOPE_FACES]; ALL_TAC] THEN
    ANTS_TAC THENL [ASM_MESON_TAC[FACE_OF_POLYTOPE_POLYTOPE]; ALL_TAC] THEN
    ANTS_TAC THENL
     [ASM_MESON_TAC[FACE_OF_IMP_SUBSET; AFF_DIM_SUBSET; INT_LE_TRANS];
      ALL_TAC] THEN
    ANTS_TAC THENL
     [REWRITE_TAC[UNIONS_GSPEC; IN_ELIM_THM] THEN ASM_MESON_TAC[FACE_OF_TRANS];
      ALL_TAC] THEN
    ANTS_TAC THENL [ASM_MESON_TAC[FACE_OF_INTER_SUBFACE]; ALL_TAC] THEN
    MATCH_MP_TAC MONO_EXISTS THEN X_GEN_TAC `t:(real^N->bool)->bool` THEN
    ONCE_REWRITE_TAC[SWAP_EXISTS_THM] THEN REWRITE_TAC[EXISTS_IN_GSPEC] THEN
    REWRITE_TAC[IN_ELIM_THM] THEN STRIP_TAC THEN
    REPLICATE_TAC 2 (CONJ_TAC THENL [ASM_REWRITE_TAC[]; ALL_TAC]) THEN
    MATCH_MP_TAC(TAUT `(q ==> p) /\ q ==> p /\ q`) THEN
    CONJ_TAC THENL [SET_TAC[]; ALL_TAC] THEN CONJ_TAC THENL
     [ASM_MESON_TAC[FACE_OF_REFL; POLYTOPE_IMP_CONVEX];
      ASM_MESON_TAC[FACE_OF_IMP_SUBSET; SUBSET_TRANS]];
    STRIP_TAC THEN EXISTS_TAC `m:(real^N->bool)->bool` THEN
    ASM_REWRITE_TAC[simplicial_complex] THEN CONJ_TAC THENL
     [SUBGOAL_THEN `!c:real^N->bool. c IN m ==> c = {}`
       (fun th -> SIMP_TAC[th; IMP_CONJ; SIMPLEX_EMPTY; FACE_OF_EMPTY] THEN
                  MESON_TAC[th]) THEN
      ASM_MESON_TAC[INT_LE_TRANS; AFF_DIM_POS_LE];
      CONJ_TAC THENL [ALL_TAC; MESON_TAC[SUBSET_REFL]] THEN
      MESON_TAC[SING_SUBSET; UNIONS_1; FINITE_SING]]]);;

let SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX = prove
 (`!m:(real^N->bool)->bool.
        FINITE m /\
        (!c. c IN m ==> polytope c) /\
        (!c1 c2. c1 IN m /\ c2 IN m
                 ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
        ==> ?t. simplicial_complex t /\
                UNIONS t = UNIONS m /\
                (!c. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f) /\
                (!k. k IN t ==> ?c. c IN m /\ k SUBSET c)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`m:(real^N->bool)->bool`; `&(dimindex(:N)):int`]
        SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX_LOWDIM) THEN
  ASM_REWRITE_TAC[AFF_DIM_LE_UNIV]);;

let FINE_SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX = prove
 (`!m:(real^N->bool)->bool e.
        &0 < e /\ FINITE m /\
        (!c. c IN m ==> polytope c) /\
        (!c1 c2. c1 IN m /\ c2 IN m
                 ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
        ==> ?t. simplicial_complex t /\
                (!k. k IN t ==> diameter k < e) /\
                UNIONS t = UNIONS m /\
                (!c. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f) /\
                (!k. k IN t ==> ?c. c IN m /\ k SUBSET c)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`m:(real^N->bool)->bool`; `&(dimindex(:N)):int`; `e:real`]
        CELL_COMPLEX_SUBDIVISION_EXISTS) THEN
  ASM_REWRITE_TAC[AFF_DIM_LE_UNIV] THEN
  DISCH_THEN(X_CHOOSE_THEN `n:(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
  MP_TAC(ISPEC `n:(real^N->bool)->bool`
   SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX) THEN
  ASM_REWRITE_TAC[] THEN MATCH_MP_TAC MONO_EXISTS THEN
  X_GEN_TAC `t:(real^N->bool)->bool` THEN STRIP_TAC THEN
  ASM_REWRITE_TAC[] THEN REPEAT CONJ_TAC THENL
   [ASM_MESON_TAC[REAL_LET_TRANS; DIAMETER_SUBSET; SIMPLEX_IMP_POLYTOPE;
                  POLYTOPE_IMP_BOUNDED];
    ALL_TAC;
    ASM_MESON_TAC[SUBSET_TRANS]] THEN
  X_GEN_TAC `c:real^N->bool` THEN DISCH_TAC THEN
  EXISTS_TAC `{k:real^N->bool | k IN t /\ k SUBSET c}` THEN
  RULE_ASSUM_TAC(REWRITE_RULE[simplicial_complex]) THEN
  ASM_SIMP_TAC[FINITE_RESTRICT; SUBSET_RESTRICT] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN ONCE_REWRITE_TAC[SUBSET] THEN
  REWRITE_TAC[FORALL_IN_UNIONS; FORALL_IN_GSPEC] THEN
  CONJ_TAC THENL [REWRITE_TAC[UNIONS_GSPEC]; SET_TAC[]] THEN
  REWRITE_TAC[IN_ELIM_THM] THEN X_GEN_TAC `x:real^N` THEN STRIP_TAC THEN
  SUBGOAL_THEN `?d. d IN n /\ (x:real^N) IN d /\ d SUBSET c`
  STRIP_ASSUME_TAC THENL [ASM_MESON_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN `?f. FINITE f /\ f SUBSET t /\ d:real^N->bool = UNIONS f`
  STRIP_ASSUME_TAC THENL [ASM_MESON_TAC[]; ALL_TAC] THEN
  SUBGOAL_THEN `(x:real^N) IN UNIONS f` MP_TAC THENL
   [ASM SET_TAC[]; REWRITE_TAC[IN_UNIONS]] THEN
  MATCH_MP_TAC MONO_EXISTS THEN ASM SET_TAC[]);;

(* ------------------------------------------------------------------------- *)
(* Some results on cell division with full-dimensional cells only.           *)
(* ------------------------------------------------------------------------- *)

let REGULAR_CLOSED_UNIONS_FAT_CELLS_UNIV = prove
 (`!s u:real^N->bool.
        closure(interior u) = u /\
        FINITE s /\ (!c. c IN s ==> closed c /\ convex c) /\ UNIONS s = u
        ==> UNIONS {c | c IN s /\ ~(interior c = {})} = u`,
  let lemma = prove
   (`!s t:real^N->bool.
          closed t /\
          closure(interior(s UNION t)) = s UNION t /\
          closure(interior s) = s /\ closure(interior t) = {}
          ==> s UNION t = s`,
    REPEAT STRIP_TAC THEN
    MP_TAC(ISPECL [`s:real^N->bool`; `t:real^N->bool`]
        CLOSURE_INTERIOR_UNION_CLOSED) THEN
    ANTS_TAC THENL [ASM_MESON_TAC[CLOSED_CLOSURE]; ALL_TAC] THEN
    ASM_REWRITE_TAC[] THEN SET_TAC[]) in
  REPEAT STRIP_TAC THEN
  SUBGOAL_THEN
   `u = UNIONS {c | c IN s /\ ~(interior c = {})} UNION
        UNIONS {c:real^N->bool | c IN s /\ interior c = {}}`
  SUBST1_TAC THENL
   [REWRITE_TAC[GSYM UNIONS_UNION] THEN EXPAND_TAC "u" THEN AP_TERM_TAC THEN
    SET_TAC[];
    ALL_TAC] THEN
  CONV_TAC SYM_CONV THEN MATCH_MP_TAC lemma THEN
  ASM_REWRITE_TAC[GSYM UNIONS_UNION; SET_RULE
   `{x | x IN s /\ ~P x} UNION {x | x IN s /\ P x} = s`] THEN
  REPEAT CONJ_TAC THENL
   [MATCH_MP_TAC CLOSED_UNIONS THEN
    ASM_SIMP_TAC[FINITE_RESTRICT; IN_ELIM_THM];
    MATCH_MP_TAC REGULAR_CLOSED_UNIONS THEN
    ASM_SIMP_TAC[FINITE_RESTRICT; IN_ELIM_THM; CONVEX_CLOSURE_INTERIOR;
                 CLOSURE_EQ];
    REWRITE_TAC[CLOSURE_EQ_EMPTY] THEN
    MATCH_MP_TAC NOWHERE_DENSE_COUNTABLE_UNIONS_CLOSED THEN
    ASM_SIMP_TAC[FINITE_IMP_COUNTABLE; FINITE_RESTRICT; IN_ELIM_THM]]);;

let CONVEX_UNIONS_FULLDIM_CELLS = prove
 (`!s u:real^N->bool.
        FINITE s /\ (!c. c IN s ==> closed c /\ convex c) /\
        UNIONS s = u /\ convex u
        ==> UNIONS {c | c IN s /\ aff_dim c = aff_dim u} = u`,
  REPEAT STRIP_TAC THEN SUBGOAL_THEN `closed(u:real^N->bool)` ASSUME_TAC THENL
   [ASM_MESON_TAC[CLOSED_UNIONS]; ALL_TAC] THEN
  MATCH_MP_TAC SUBSET_ANTISYM THEN CONJ_TAC THENL [ASM SET_TAC[]; ALL_TAC] THEN
  ASM_CASES_TAC
   `!c. c IN s ==> aff_dim(c:real^N->bool) = aff_dim(u:real^N->bool)`
  THENL [ASM SET_TAC[]; ALL_TAC] THEN
  MATCH_MP_TAC(MESON[CLOSURE_CLOSED]
     `closed s /\ u SUBSET closure s ==> u SUBSET s`) THEN
  ASM_SIMP_TAC[CLOSED_UNIONS; FINITE_RESTRICT; FORALL_IN_GSPEC] THEN
  TRANS_TAC SUBSET_TRANS
   `closure(INTERS
     {u DIFF c:real^N->bool |c| c IN s /\ aff_dim c < aff_dim u})` THEN
  CONJ_TAC THENL
   [MATCH_MP_TAC BAIRE THEN
    ASM_SIMP_TAC[FORALL_IN_GSPEC; CLOSED_IMP_LOCALLY_COMPACT] THEN
    ONCE_REWRITE_TAC[SIMPLE_IMAGE_GEN] THEN
    ASM_SIMP_TAC[COUNTABLE_IMAGE; FINITE_IMP_COUNTABLE; FINITE_RESTRICT] THEN
    X_GEN_TAC `c:real^N->bool` THEN REPEAT STRIP_TAC THENL
     [MATCH_MP_TAC OPEN_IN_DIFF THEN REWRITE_TAC[OPEN_IN_REFL] THEN
      MATCH_MP_TAC CLOSED_SUBSET THEN ASM SET_TAC[];
      MATCH_MP_TAC(SET_RULE `t = s ==> s SUBSET t`) THEN
      MATCH_MP_TAC DENSE_COMPLEMENT_CONVEX_CLOSED THEN ASM_REWRITE_TAC[]];
    MATCH_MP_TAC SUBSET_CLOSURE THEN
    REWRITE_TAC[SUBSET; INTERS_GSPEC; FORALL_IN_GSPEC] THEN
    X_GEN_TAC `x:real^N` THEN DISCH_TAC THEN
    REWRITE_TAC[UNIONS_GSPEC; IN_ELIM_THM]  THEN
    SUBGOAL_THEN
     `?c. c IN s /\ aff_dim(c:real^N->bool) < aff_dim(u:real^N->bool)`
    ASSUME_TAC THENL
     [FIRST_X_ASSUM(MP_TAC o GEN_REWRITE_RULE I [NOT_FORALL_THM]) THEN
      MATCH_MP_TAC MONO_EXISTS THEN SIMP_TAC[NOT_IMP; INT_LT_LE] THEN
      REPEAT STRIP_TAC THEN MATCH_MP_TAC AFF_DIM_SUBSET THEN ASM SET_TAC[];
      ALL_TAC] THEN
    SUBGOAL_THEN `(x:real^N) IN u /\ x IN UNIONS s`
     (CONJUNCTS_THEN2 ASSUME_TAC MP_TAC) THENL [ASM SET_TAC[]; ALL_TAC] THEN
    REWRITE_TAC[IN_UNIONS] THEN MATCH_MP_TAC MONO_EXISTS THEN
    SIMP_TAC[] THEN X_GEN_TAC `c:real^N->bool` THEN STRIP_TAC THEN
    FIRST_X_ASSUM(MP_TAC o SPEC `c:real^N->bool`) THEN
    ASM_SIMP_TAC[IN_DIFF; INT_NOT_LT; GSYM INT_LE_ANTISYM] THEN
    DISCH_TAC THEN MATCH_MP_TAC AFF_DIM_SUBSET THEN ASM SET_TAC[]]);;

let TRIANGULAR_SUBDIVISION_OF_CELL_COMPLEX = prove
 (`!m:(real^N->bool)->bool d.
        FINITE m /\
        (!c. c IN m ==> polytope c) /\
        (!c. c IN m ==> aff_dim c = d) /\
        (!c1 c2. c1 IN m /\ c2 IN m
                 ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
        ==> ?t. triangulation t /\
                (!k. k IN t ==> aff_dim k = d) /\
                UNIONS t = UNIONS m /\
                (!c. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f) /\
                (!k. k IN t ==> ?c. c IN m /\ k SUBSET c)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPEC `m:(real^N->bool)->bool`
    SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX) THEN
  ASM_REWRITE_TAC[simplicial_complex; triangulation] THEN
  DISCH_THEN(X_CHOOSE_THEN `t:(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `{k:real^N->bool | k IN t /\ aff_dim k = d}` THEN
  ASM_SIMP_TAC[FINITE_RESTRICT; IN_ELIM_THM] THEN
  MATCH_MP_TAC(TAUT `(q ==> p) /\ q ==> p /\ q`) THEN CONJ_TAC THENL
   [ASM SET_TAC[]; ALL_TAC] THEN
  X_GEN_TAC `c:real^N->bool` THEN DISCH_TAC THEN
  UNDISCH_THEN
   `!c:real^N->bool. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f`
   (MP_TAC o SPEC `c:real^N->bool`) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(X_CHOOSE_THEN `f:(real^N->bool)->bool`
    (STRIP_ASSUME_TAC o GSYM)) THEN
  EXISTS_TAC `{k:real^N->bool | k IN f /\ aff_dim k = d}` THEN
  ASM_SIMP_TAC[FINITE_RESTRICT] THEN
  CONJ_TAC THENL [ASM SET_TAC[]; CONV_TAC SYM_CONV] THEN
  SUBGOAL_THEN `d = aff_dim(c:real^N->bool)` SUBST1_TAC THENL
   [ASM_MESON_TAC[]; MATCH_MP_TAC CONVEX_UNIONS_FULLDIM_CELLS] THEN
  ASM_REWRITE_TAC[] THEN
  ASM_MESON_TAC[SUBSET; POLYTOPE_IMP_CONVEX; POLYTOPE_IMP_CLOSED;
                SIMPLEX_IMP_POLYTOPE]);;

let FINE_TRIANGULAR_SUBDIVISION_OF_CELL_COMPLEX = prove
 (`!m:(real^N->bool)->bool d e.
        &0 < e /\ FINITE m /\
        (!c. c IN m ==> polytope c) /\
        (!c. c IN m ==> aff_dim c = d) /\
        (!c1 c2. c1 IN m /\ c2 IN m
                 ==> c1 INTER c2 face_of c1 /\ c1 INTER c2 face_of c2)
        ==> ?t. triangulation t /\
                (!k. k IN t ==> diameter k < e) /\
                (!k. k IN t ==> aff_dim k = d) /\
                UNIONS t = UNIONS m /\
                (!c. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f) /\
                (!k. k IN t ==> ?c. c IN m /\ k SUBSET c)`,
  REPEAT STRIP_TAC THEN
  MP_TAC(ISPECL [`m:(real^N->bool)->bool`; `e:real`]
    FINE_SIMPLICIAL_SUBDIVISION_OF_CELL_COMPLEX) THEN
  ASM_REWRITE_TAC[simplicial_complex; triangulation] THEN
  DISCH_THEN(X_CHOOSE_THEN `t:(real^N->bool)->bool` STRIP_ASSUME_TAC) THEN
  EXISTS_TAC `{k:real^N->bool | k IN t /\ aff_dim k = d}` THEN
  ASM_SIMP_TAC[FINITE_RESTRICT; IN_ELIM_THM] THEN
  MATCH_MP_TAC(TAUT `(q ==> p) /\ q ==> p /\ q`) THEN CONJ_TAC THENL
   [ASM SET_TAC[]; ALL_TAC] THEN
  X_GEN_TAC `c:real^N->bool` THEN DISCH_TAC THEN
  UNDISCH_THEN
   `!c:real^N->bool. c IN m ==> ?f. FINITE f /\ f SUBSET t /\ c = UNIONS f`
   (MP_TAC o SPEC `c:real^N->bool`) THEN
  ASM_REWRITE_TAC[] THEN
  DISCH_THEN(X_CHOOSE_THEN `f:(real^N->bool)->bool`
    (STRIP_ASSUME_TAC o GSYM)) THEN
  EXISTS_TAC `{k:real^N->bool | k IN f /\ aff_dim k = d}` THEN
  ASM_SIMP_TAC[FINITE_RESTRICT] THEN
  CONJ_TAC THENL [ASM SET_TAC[]; CONV_TAC SYM_CONV] THEN
  SUBGOAL_THEN `d = aff_dim(c:real^N->bool)` SUBST1_TAC THENL
   [ASM_MESON_TAC[]; MATCH_MP_TAC CONVEX_UNIONS_FULLDIM_CELLS] THEN
  ASM_REWRITE_TAC[] THEN
  ASM_MESON_TAC[SUBSET; POLYTOPE_IMP_CONVEX; POLYTOPE_IMP_CLOSED;
                SIMPLEX_IMP_POLYTOPE]);;
