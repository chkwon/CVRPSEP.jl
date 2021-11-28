
"""
    rounded_capacity_cut!(cmp, demand, capacity, edge_tail, edge_head, edge_x)

Generate the rounded capacity cuts and put them in `cmp::CnstrMgrPointer`. 

Returns lists of `S` and `RHS` in the form of 
`x(S:S) <= |S| - k(S)`
"""
function rounded_capacity_cut!(
    cmp::CnstrMgrPointer, 
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_cuts = 10,
    integrality_tolerance = 1e-4
)
    n_customers = length(demand) 
    n_edges = length(edge_tail)

    # In C, customers are 1, 2, ..., n.
    # depot is n + 1.
    _edge_tail = copy(edge_tail)
    _edge_head = copy(edge_head)
    _edge_tail .-= 1
    _edge_head .-= 1
    _edge_tail[_edge_tail .== 0] .= n_customers + 1
    _edge_head[_edge_head .== 0] .= n_customers + 1

    new_cmp = jl_CMGR_CreateCMgr()

    integer_and_feasible = Ref{Cchar}(-9)
    max_violation = Ref{Cdouble}(-9.9)

    ccall(
        (:CAPSEP_SeparateCapCuts, LIB_CVRPSEP),
        Cvoid,
        (Cint, Ptr{Cint}, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, CnstrMgrPointer, Cint, Cdouble, Ref{Cchar}, Ref{Cdouble}, CnstrMgrPointer),
        n_customers, demand, capacity, n_edges, _edge_tail, _edge_head, edge_x, cmp, max_n_cuts, integrality_tolerance, integer_and_feasible, max_violation, new_cmp
    )

    new_cmr = unsafe_load(new_cmp)

    cpl = unsafe_wrap(Array, new_cmr.CPL, new_cmr.Size)

    list_S = Vector{Int}[]
    list_RHS = Float64[]
    for i in 1:length(cpl)
        cr = unsafe_load(cpl[i])
        S = unsafe_wrap(Vector{Cint}, cr.IntList, cr.IntListSize)[2:end]
        push!(list_S, Int.(S) .+ 1) # For Julia, index += 1.
        push!(list_RHS, cr.RHS)
    end

    jl_CMGR_MoveCnstr!(new_cmp, cmp)

    return list_S, list_RHS, Bool(integer_and_feasible[]), max_violation[]
end