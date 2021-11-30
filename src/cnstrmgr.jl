function jl_CMGR_CreateCMgr()
    Dim = 100 
    cmp_ref = Ref{CnstrMgrPointer}()
    ccall(
        (:CMGR_CreateCMgr, LIB_CVRPSEP), 
        Cvoid, 
        (Ptr{CnstrMgrPointer}, Cint), 
        cmp_ref, Dim
    )
    return cmp_ref[]
end
init_CMP = jl_CMGR_CreateCMgr # alias

function jl_CMGR_MoveCnstr!(MyCutsCMP::CnstrMgrPointer, MyOldCutsCMP::CnstrMgrPointer)
    size = unsafe_load(MyCutsCMP).Size
    for i in 0:size-1
        ccall(
            (:CMGR_MoveCnstr, LIB_CVRPSEP), 
            Cvoid, 
            (CnstrMgrPointer, CnstrMgrPointer, Cint, Cint), 
            MyCutsCMP, MyOldCutsCMP, i, 0
        )
    end
    unsafe_load(MyCutsCMP).Size = 0 
end