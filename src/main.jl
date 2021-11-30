
include(joinpath(@__DIR__, "../deps/deps.jl")) # const LIB_CVRPSEP

include("types.jl")
include("cnstrmgr.jl")
include("rounded_capacity.jl")
include("strengthened_comb.jl")


function input_conversion(demand::Vector{Int}, edge_tail::Vector{Int}, edge_head::Vector{Int}, edge_x::Vector{Float64})
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

        return n_customers, _demand, n_edges, _edge_tail, _edge_head, _edge_x
end