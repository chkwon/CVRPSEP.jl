module CVRPSEP

include("main.jl")

rounded_capacity_cuts! = rounded_capacity_inequalities!


export LIB_CVRPSEP, ConstraintType, 
        CnstrRecord, CnstrPointer, CnstrPointerList, 
        CnstrMgrRecord, CnstrMgrPointer,
        CutRecord, CutManager, 
        convert_CMP, init_CMP,
        rounded_capacity_cuts!, rounded_capacity_inequalities!,
        strengthened_comb_inequalities!,
        framed_capacity_inequalities!, 
        hypotour_inequalities!,
        multistar_inequalities!

end
