
function multistar_inequalities!(
    cut_manager::CutManager, 
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_cuts = 100
)
    n_customers, _demand, n_edges, _edge_tail, _edge_head, _edge_x = input_conversion(demand, edge_tail, edge_head, edge_x)

    new_cmp = init_CMP()
    _max_violation = Ref{Cdouble}()

    ccall(
        (:MSTARSEP_SeparateMultiStarCuts, LIB_CVRPSEP),
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
    jl_CMGR_MoveCnstr!(new_cmp, cut_manager.cmp)
    cut_manager.violation = Float64(_max_violation[])




    N = map(x -> x.IntList, cut_manager.new_cuts) 
    T = map(x -> x.ExtList, cut_manager.new_cuts) 
    C = map(x -> x.CList, cut_manager.new_cuts) 
    
    for i in 1:length(N) 
        N[i] .+= 1
        T[i] .+= 1
        C[i] .+= 1
    end

    A = map(x -> x.A, cut_manager.new_cuts)
    B = map(x -> x.B, cut_manager.new_cuts)
    L = map(x -> x.L, cut_manager.new_cuts)

    return N, T, C, A, B, L
end