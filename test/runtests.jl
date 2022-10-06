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

    @testset "Rounded Capacity Inequalities" begin
        @info "Rounded Capacity Inequalities"
        S, RHS = rounded_capacity_inequalities!(
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

    @testset "Strenghthed Comb Inequalities" begin
        @info "Strenghthed Comb Inequalities"
        S, RHS = strengthened_comb_inequalities!(
            demand, 
            capacity, 
            edge_tail, 
            edge_head, 
            edge_x;
            max_n_cuts = 10,
            Q_min = -1, 
            K = -1
        )

        @show S
        @show RHS
    end    

    @testset "Framed Capacity Inequalities" begin
        @info "Framed Capacity Inequalities"
        S, RHS = framed_capacity_inequalities!(
            cut_manager,
            demand, 
            capacity, 
            edge_tail, 
            edge_head, 
            edge_x;
            max_n_cuts = 10,
            max_n_tree_nodes = 1000
        )

        @show S
        @show RHS
    end        

    @testset "Multistar Inequalities" begin
        @info "Multistar Inequalities"
        S, RHS = multistar_inequalities!(
            cut_manager,
            demand, 
            capacity, 
            edge_tail, 
            edge_head, 
            edge_x;
            max_n_cuts = 100
        )

        @show S
        @show RHS
    end      

    @testset "Hypotour Inequalities" begin
        @info "Hypotour Inequalities"
        Tail, Head, Coeff, RHS = hypotour_inequalities!(
            cut_manager,
            demand, 
            capacity, 
            edge_tail, 
            edge_head, 
            edge_x;
            max_n_cuts = 2
        )

        @show Tail
        @show Head
        @show Coeff
        @show RHS
    end          
end

