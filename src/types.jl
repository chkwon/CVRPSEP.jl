
# /* Definition of constants for identification of constraint types. */
@enum ConstraintType begin
    CMGR_CT_MIN_ROUTES        = 101
    CMGR_CT_NODE_DEGREE       = 102  # /* Degree = 2 for each customer. */
    CMGR_CT_CAP               = 103  # /* Capacity constraint. */
    CMGR_CT_GENCAP            = 104  # /* Generalized capacity constraint. */
    # CMGR_CT_FCI               = 104  # /* For public version. */ # duplicate
    CMGR_CT_TWOMATCHING       = 105
    CMGR_CT_COMB              = 106
    CMGR_CT_STR_COMB          = 107  # /* Strengthened comb. */
    CMGR_CT_HYPOTOUR          = 108
    CMGR_CT_EXT_HYPOTOUR      = 109
    CMGR_CT_MSTAR             = 110  # /* Homogeneous multistar. */
    CMGR_CT_WMSTAR            = 111  # /* Weak multistar. */
    CMGR_CT_DJCUT             = 112  # /* Disjunctive cut. */
    CMGR_CT_GOMORY            = 113  # /* By variable numbers */
    CMGR_CT_TWOEDGES_HYPOTOUR = 114  # /* 2EH inequality */
    CMGR_BT_CLIQUE_DOWN       = 201  # /* x(S:S) <= RHS */
    CMGR_BT_CLIQUE_UP         = 202  # /* x(S:S) >= RHS */
    CMGR_BT_STAR_DOWN         = 301  # /* x(i:F) <=RHS */
    CMGR_BT_STAR_UP           = 302  # /* x(i:F) >=RHS */
    CMGR_CT_SLB               = 401  # /* x(F) >= RHS. Simple lower bound */
end

mutable struct CnstrRecord
    Ctype       :: Cint 
    Key         :: Cint
    IntListSize :: Cint
    IntList     :: Ptr{Cint}
    ExtListSize :: Cint
    ExtList     :: Ptr{Cint}
    CListSize   :: Cint
    CList       :: Ptr{Cint}
    CoeffList   :: Ptr{Cdouble}
    A           :: Cint
    B           :: Cint
    L           :: Cint
    RHS         :: Cdouble
    BranchLevel :: Cint
    GlobalNr    :: Cint
end

CnstrPointer = Ptr{CnstrRecord}
CnstrPointerList = Ptr{CnstrPointer}

mutable struct CnstrMgrRecord 
    CPL         :: CnstrPointerList
    Dim         :: Cint
    Size        :: Cint
end

CnstrMgrPointer = Ptr{CnstrMgrRecord}



