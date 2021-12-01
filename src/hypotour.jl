function hypotour_inequalities!(
    cut_manager::CutManager, 
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_cuts = 1000::Cint
)
    n_customers, _demand, n_edges, _edge_tail, _edge_head, _edge_x = input_conversion(demand, edge_tail, edge_head, edge_x)

    new_cmp = init_CMP()

    _max_violation = Ref{Cdouble}()

    ccall(
        (:HTOURSEP_SeparateHTours, LIB_CVRPSEP),
        Cvoid,
        (
            Cint, Ptr{Cint}, Cint, 
            Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, 
            CnstrMgrPointer, Cint, 
            Ref{Cdouble}, CnstrMgrPointer
        ),
        Cint(n_customers), Cint.(_demand), Cint(capacity), 
        Cint(n_edges), Cint.(_edge_tail), Cint.(_edge_head), Cdouble.(_edge_x), 
        cut_manager.cmp, Cint(max_n_cuts), 
        _max_violation, new_cmp
    )

    cut_manager.new_cuts = convert_CMP(new_cmp)
    # jl_CMGR_MoveCnstr!(new_cmp, cut_manager.cmp)
    cut_manager.violation = Float64(_max_violation[])

    n_new_cuts =  length(cut_manager.new_cuts)
    Tail = Vector{Vector{Int}}(undef, n_new_cuts)
    Head = Vector{Vector{Int}}(undef, n_new_cuts)
    Coeff = Vector{Vector{Float64}}(undef, n_new_cuts)
    RHS = Vector{Float64}(undef, n_new_cuts)

    for j in 1:n_new_cuts
        cr = cut_manager.new_cuts[j]
        @assert cr.Ctype == CMGR_CT_TWOEDGES_HYPOTOUR
        Tail[j] = cr.IntList .+ 1
        Head[j] = cr.ExtList .+ 1
        Coeff[j] = cr.CoeffList
        RHS[j] = cr.RHS

        @show Tail[j], Head[j], Coeff[j], RHS[j]
    end

    return Tail, Head, Coeff, RHS
end
