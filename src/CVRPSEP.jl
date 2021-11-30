module CVRPSEP

include("../deps/deps.jl") # const LIB_CVRPSEP

include("types.jl")
include("cnstrmgr.jl")
include("separation.jl")

export LIB_CVRPSEP, ConstraintType, 
        CnstrRecord, CnstrPointer, CnstrPointerList, 
        CnstrMgrRecord, CnstrMgrPointer,
        CutRecord, CutManager, 
        convert_CMP, init_cmp,
        rounded_capacity_cut!

end
