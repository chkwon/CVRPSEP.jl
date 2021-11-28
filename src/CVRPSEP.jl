module CVRPSEP

include("../deps/deps.jl") # const LIB_CVRPSEP

include("types.jl")
include("cnstrmgr.jl")
include("separation.jl")

export LIB_CVRPSEP, ConstraintType, 
        CnstrRecord, CnstrPointer, CnstrPointerList, 
        CnstrMgrRecord, CnstrMgrPointer,
        jl_CMGR_CreateCMgr,
        rounded_capacity_cut!

end
