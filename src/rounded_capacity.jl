
"""
rounded_capacity_inequality!(cmp, demand, capacity, edge_tail, edge_head, edge_x)

Generate the rounded capacity cuts and put them in `cmp::CnstrMgrPointer`. 

Input:
- Customers are numbered 2, 3, ... n_customers + 1.
- Depot is numbered 1.

Returns lists of `S` and `RHS` in the form of 
`x(S:S) <= |S| - k(S)`

`return list_S, list_RHS, is_integer_and_feasible, max_violation`
"""
function rounded_capacity_inequalities!(
    cut_manager::CutManager, 
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_cuts = 1000::Cint,
    integrality_tolerance = 1e-4::Cdouble
)
    n_customers, _demand, n_edges, _edge_tail, _edge_head, _edge_x = input_conversion(demand, edge_tail, edge_head, edge_x)

    new_cmp = init_CMP()

    _integer_and_feasible = Ref{Cchar}()
    _max_violation = Ref{Cdouble}()

    ccall(
        (:CAPSEP_SeparateCapCuts, LIB_CVRPSEP),
        Cvoid,
        (
            Cint, Ptr{Cint}, Cint, 
            Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, 
            CnstrMgrPointer, Cint, Cdouble, 
            Ref{Cchar}, Ref{Cdouble}, CnstrMgrPointer
        ),
        Cint(n_customers), Cint.(_demand), Cint(capacity), 
        Cint(n_edges), Cint.(_edge_tail), Cint.(_edge_head), Cdouble.(_edge_x), 
        cut_manager.cmp, Cint(max_n_cuts), Cdouble(integrality_tolerance), 
        _integer_and_feasible, _max_violation, new_cmp
    )

    cut_manager.new_cuts = convert_CMP(new_cmp)
    jl_CMGR_MoveCnstr!(new_cmp, cut_manager.cmp)

    cut_manager.is_integer_and_feasible = Bool(_integer_and_feasible[])
    cut_manager.violation = Float64(_max_violation[])

    S = map(x -> x.IntList, cut_manager.new_cuts) 
    # then .+ 1 for Julia customer numbering: 
    #       2, 3, ... n_customers + 1
    for s in S 
        s .+= 1
    end
    RHS = map(x -> x.RHS, cut_manager.new_cuts)

    return S, RHS
end