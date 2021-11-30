module CVRPSEP

include("main.jl")

export LIB_CVRPSEP, ConstraintType, 
        CnstrRecord, CnstrPointer, CnstrPointerList, 
        CnstrMgrRecord, CnstrMgrPointer,
        CutRecord, CutManager, 
        convert_CMP, init_CMP,
        rounded_capacity_cut!, strengthened_comb_inequality!

end
