
"""
    rounded_capacity_cut!(cmp, demand, capacity, edge_tail, edge_head, edge_x)

Generate the rounded capacity cuts and put them in `cmp::CnstrMgrPointer`. 

Input:
- Customers are numbered 2, 3, ... n_customers + 1.
- Depot is numbered 1.

Returns lists of `S` and `RHS` in the form of 
`x(S:S) <= |S| - k(S)`

`return list_S, list_RHS, is_integer_and_feasible, max_violation`
"""
function rounded_capacity_cut!(
    cmp::CnstrMgrPointer, 
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_cuts = 1000::Cint,
    integrality_tolerance = 1e-3::Cdouble
)
    n_edges = length(edge_tail)

    # In CVRPSEP, customers are 1, 2, ..., n_customers.
    # Since C starts with index 0, we need to fill the first element.
    # The input vector `demand` should already contain 
    _demand = demand 
    n_customers = length(demand) - 1

    # make copies
    _edge_tail = copy(edge_tail)
    _edge_head = copy(edge_head)
    _edge_x = copy(edge_x)

    # In Julia,   customers are 2, 3, ..., n_customers+1
    # In CVRPSEP, customers are 1, 2, ..., n_customers.
    _edge_tail .-= 1
    _edge_head .-= 1

    # In Julia,   depot is 1
    # In CVRPSEP, depot is n_customers+1
    _edge_tail[_edge_tail .== 0] .= n_customers + 1
    _edge_head[_edge_head .== 0] .= n_customers + 1

    # In CVRPSEP, edges with positive x values are numbered 1, 2, ..., n_edges
    # a dummy zero is necessary to fill the first element
    _edge_tail = [-1; _edge_tail]
    _edge_head = [-1; _edge_head]
    _edge_x = [-1; _edge_x]

    @assert length(_edge_tail) == n_edges + 1

    new_cmp = jl_CMGR_CreateCMgr()

    _integer_and_feasible = Ref{Cchar}()
    _max_violation = Ref{Cdouble}()

    ccall(
        (:CAPSEP_SeparateCapCuts, LIB_CVRPSEP),
        Cvoid,
        (Cint, Ptr{Cint}, Cint, Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, CnstrMgrPointer, Cint, Cdouble, Ref{Cchar}, Ref{Cdouble}, CnstrMgrPointer),
        Cint(n_customers), Cint.(_demand), Cint(capacity), 
        Cint(n_edges), Cint.(_edge_tail), Cint.(_edge_head), Cdouble.(_edge_x), 
        cmp, Cint(max_n_cuts), Cdouble(integrality_tolerance), 
        _integer_and_feasible, _max_violation, new_cmp
    )

    new_cmr = unsafe_load(new_cmp)

    cpl = unsafe_wrap(Array, new_cmr.CPL, new_cmr.Size)

    list_S = Vector{Int}[]
    list_RHS = Float64[]
    for i in 1:length(cpl)
        cr = unsafe_load(cpl[i])
        S = unsafe_wrap(Vector{Cint}, cr.IntList, cr.IntListSize + 1)[2:end]
        S .+= 1 # For Julia, index += 1.
        push!(list_S, Int.(S))
        push!(list_RHS, Float64(cr.RHS))
    end

    jl_CMGR_MoveCnstr!(new_cmp, cmp)

    is_integer_and_feasible = Bool(_integer_and_feasible[])
    max_violation = Float64(_max_violation[])

    return list_S, list_RHS, is_integer_and_feasible, max_violation
end