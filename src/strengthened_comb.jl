function strengthened_comb_inequalities!(
    demand::Vector{Int}, 
    capacity::Int, 
    edge_tail::Vector{Int}, 
    edge_head::Vector{Int}, 
    edge_x::Vector{Float64};
    max_n_cuts = 1000::Cint,
    Q_min = -1, 
    K = -1
)
    n_customers, _demand, n_edges, _edge_tail, _edge_head, _edge_x = 
        input_conversion(demand, edge_tail, edge_head, edge_x)

    new_cmp = init_CMP()

    _max_violation = Ref{Cdouble}()

    if Q_min == -1 
        if K == -1 
            K = n_customers
        end
        Q_min = sum(_demand) - (K - 1) * capacity
    end


    # @show n_customers, _demand, capacity, Q_min 
    # @show n_edges 
    # @show _edge_tail 
    # @show _edge_head 
    # @show _edge_x

    ccall(
        (:COMBSEP_SeparateCombs, LIB_CVRPSEP),
        Cvoid,
        (
            Cint, Ptr{Cint}, Cint, Cint, 
            Cint, Ptr{Cint}, Ptr{Cint}, Ptr{Cdouble}, 
            Cint, Ref{Cdouble}, CnstrMgrPointer
        ),
            Cint(n_customers), Cint.(_demand), Cint(capacity), Cint(Q_min), 
            Cint(n_edges), Cint.(_edge_tail), Cint.(_edge_head), Cdouble.(_edge_x), 
            Cint(max_n_cuts), _max_violation, new_cmp
    )


    new_cuts = convert_CMP(new_cmp)

    n_new_cuts = length(new_cuts)

    handles = Vector{Vector{Int}}(undef, n_new_cuts)
    teeth = Vector{Vector{Vector{Int}}}(undef, n_new_cuts)
    rhs = Vector{Float64}(undef, n_new_cuts)

    for i in 1:n_new_cuts
        cr = new_cuts[i]
        n_teeth = cr.Key

        # Handle
        handles[i] = cr.IntList .+ 1
        depot = n_customers + 2
        replace!(x -> x == depot ? 1 : x, handles[i])

        # Teeth
        teeth[i] = Vector{Int}[]
        for t in 1:n_teeth
            min_idx = cr.ExtList[t]
            if t == n_teeth
                max_idx = length(cr.ExtList)
            else
                max_idx = cr.ExtList[t + 1] - 1
            end
            tooth = cr.ExtList[min_idx:max_idx] .+ 1
            replace!(x -> x == depot ? 1 : x, tooth)
            push!(teeth[i], tooth)
        end

        # RHS 
        rhs[i] = cr.RHS
    end

    return handles, teeth, rhs
end