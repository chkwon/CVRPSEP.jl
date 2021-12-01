function framed_capacity_inequalities!(
    cut_manager::CutManager, 
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_tree_nodes = 10::Cint,
    max_n_cuts = 1000::Cint,
)
    n_customers, _demand, n_edges, _edge_tail, _edge_head, _edge_x = input_conversion(demand, edge_tail, edge_head, edge_x)

    new_cmp = init_CMP()

    _integer_and_feasible = Ref{Cchar}()
    _max_violation = Ref{Cdouble}()

    ccall(
        (:FCISEP_SeparateFCIs, LIB_CVRPSEP),
        Cvoid,
        (
            Cint, Ptr{Cint}, Cint, 
            Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, 
            CnstrMgrPointer, Cint, Cint, 
            Ref{Cdouble}, CnstrMgrPointer
        ),
        Cint(n_customers), Cint.(_demand), Cint(capacity), 
        Cint(n_edges), Cint.(_edge_tail), Cint.(_edge_head), Cdouble.(_edge_x), 
        cut_manager.cmp, Cint(max_n_tree_nodes), Cint(max_n_cuts), 
        _max_violation, new_cmp
    )

    cut_manager.new_cuts = convert_CMP(new_cmp)
    # jl_CMGR_MoveCnstr!(new_cmp, cut_manager.cmp)
    cut_manager.violation = Float64(_max_violation[])

    SS = Vector{Vector{Vector{Int}}}(undef, length(cut_manager.new_cuts))
    RHS = Vector{Float64}(undef, length(cut_manager.new_cuts))

    for j in 1:length(cut_manager.new_cuts)
        cr = cut_manager.new_cuts[j]
        @assert cr.Ctype == CMGR_CT_GENCAP

        SS[j] = Vector{Vector{Int}}(undef, length(cr.ExtList))

        MaxIdx = 0 
        for i in 1:length(SS[j])
            MinIdx = MaxIdx + 1
            MaxIdx = MinIdx + cr.ExtList[i] - 1
            SS[j][i] = cr.IntList[MinIdx:MaxIdx] .+ 1
        end

        RHS[j] = cr.RHS
    end

    return SS, RHS
end
