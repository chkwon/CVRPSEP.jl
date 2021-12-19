using CVRPSEP
using Test

include("testdata.jl")

@testset "CVRPSEP.jl" begin
    # Write your tests here.
    demand, capacity, edge_head, edge_tail, edge_x = testdata_provider()
    cut_manager = CutManager()

    idx = findall(v -> v > 0.0, edge_x)
    edge_tail = edge_tail[idx]
    edge_head = edge_head[idx]
    edge_x = edge_x[idx]

    S, RHS = rounded_capacity_cuts!(
        cut_manager, 
        demand, 
        capacity, 
        edge_tail, 
        edge_head, 
        edge_x,
        integrality_tolerance = 1e-6,
        max_n_cuts = 10
    )

    @show S
    @show RHS

    @test RHS == [13.0, 5.0, 7.0]
end

