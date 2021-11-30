###############################################################
# structs used by the C side
###############################################################

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


###############################################################
# structs used by the Julia side
###############################################################


mutable struct CutRecord
    Ctype       :: ConstraintType 
    Key         :: Int
    IntList     :: Vector{Int}
    ExtList     :: Vector{Int}
    CList       :: Vector{Int}
    CoeffList   :: Vector{Float64}
    A           :: Int
    B           :: Int
    L           :: Int
    RHS         :: Float64
    BranchLevel :: Int
    GlobalNr    :: Int

    function CutRecord(cr::CnstrRecord)
        # CVRPSEP.c uses 1-based indexing, 
        # with 0 position filled with an unused value 
        # hence, all Size + 1
        # then, [2:end]
        int_list = Int[]
        ext_list = Int[] 
        c_list = Int[] 
        coeff_list = Float64[] 

        if cr.IntList != C_NULL && cr.IntListSize > 0 
            c_int_list = unsafe_wrap(Array, cr.IntList, cr.IntListSize + 1)
            int_list = c_int_list[2:end]
        end

        if cr.ExtList != C_NULL && cr.ExtListSize > 0 
            c_ext_list = unsafe_wrap(Array, cr.ExtList, cr.ExtListSize + 1)
            ext_list = c_ext_list[2:end]
        end

        if cr.CList != C_NULL && cr.CListSize > 0 
            c_list = unsafe_wrap(Array, cr.CList, cr.CListSize + 1)[2:end]
        end
 
        ctype = ConstraintType(Int(cr.Ctype))
        if cr.CoeffList != C_NULL && cr.IntListSize > 0 #&& ctype == CMGR_CT_HYPOTOUR 
            coeff_list = unsafe_wrap(Array, cr.CoeffList, cr.IntListSize + 1)[2:end]
            @show typeof(coeff_list)
        end

        new(
            ctype,
            cr.Key,
            int_list,
            ext_list,
            c_list,
            coeff_list,
            cr.A,
            cr.B,
            cr.L,
            cr.RHS,
            cr.BranchLevel,
            cr.GlobalNr
        )
    end
end

function convert_CMP(cmp::CnstrMgrPointer)
    cmr = unsafe_load(cmp)
    cpl = unsafe_wrap(Array, cmr.CPL, cmr.Size)

    ret = Vector{CutRecord}(undef, length(cpl))
    for i in 1:length(cpl)
        cr = unsafe_load(cpl[i])
        ret[i] = CutRecord(cr)
    end
    return ret
end

mutable struct CutManager
    new_cuts::Vector{CutRecord}
    is_integer_and_feasible::Bool
    violation::Float64
    cmp::CnstrMgrPointer
    function CutManager()
        new(CutRecord[], false, Inf, init_CMP())
    end
end