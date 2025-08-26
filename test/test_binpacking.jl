

@testset "BP_ExactBinPacking Tests" begin
    
    @info "Testing BP_ExactBinPacking function"

    @testset "Basic functionality" begin
        # Test case 1: Basic example from user
        CAP = 10
        ItemSize = [9, 7, 5, 3, 1]
        
        LB, UB, Bin = BP_ExactBinPacking(CAP, ItemSize)
        
        @test LB >= 0
        @test UB >= LB
        @test length(Bin) == length(ItemSize)
        @test all(b -> b >= 1, Bin)  # All bin assignments should be positive
        
        # Verify solution is feasible: check that items in each bin don't exceed capacity
        max_bin = maximum(Bin)
        for bin_id in 1:max_bin
            items_in_bin = ItemSize[Bin .== bin_id]
            @test sum(items_in_bin) <= CAP
        end
        
        # For this specific case, optimal solution should use 3 bins: [9,1], [7,3], [5]
        @test UB == 3
    end
    
    @testset "All items fit in one bin" begin
        CAP = 20
        ItemSize = [5, 4, 3, 2, 1]
        
        LB, UB, Bin = BP_ExactBinPacking(CAP, ItemSize)
        
        @test LB == 1
        @test UB == 1
        @test all(b -> b == 1, Bin)  # All items should be in bin 1
        @test sum(ItemSize) <= CAP
    end
    
    @testset "Each item needs its own bin" begin
        CAP = 5
        ItemSize = [5, 5, 5, 5]
        
        LB, UB, Bin = BP_ExactBinPacking(CAP, ItemSize)
        
        @test LB == 4
        @test UB == 4
        @test length(unique(Bin)) == 4  # Should use exactly 4 different bins
        @test sort(Bin) == [1, 2, 3, 4]  # Each item in different bin
    end
    
    @testset "Single item" begin
        CAP = 10
        ItemSize = [7]
        
        LB, UB, Bin = BP_ExactBinPacking(CAP, ItemSize)
        
        @test LB == 1
        @test UB == 1
        @test Bin == [1]
    end
    
    @testset "Empty items vector" begin
        CAP = 10
        ItemSize = Int[]
        
        LB, UB, Bin = BP_ExactBinPacking(CAP, ItemSize)
        
        @test LB == 0
        @test UB == 0
        @test length(Bin) == 0
    end
    
    @testset "Assert failure for unsorted items" begin
        CAP = 10
        ItemSize = [3, 7, 5, 1, 9]  # Not sorted in non-increasing order
        
        @test_throws AssertionError BP_ExactBinPacking(CAP, ItemSize)
    end
    
    @testset "Optimal solution verification" begin
        # Test case where we know the optimal solution
        CAP = 6
        ItemSize = [4, 3, 3, 2, 2, 1]  # Optimal: 3 bins: [4,2], [3,3], [2,1]
        
        LB, UB, Bin = BP_ExactBinPacking(CAP, ItemSize)
        
        @test UB == 3  # Known optimal solution
        @test LB <= UB
        
        # Verify the solution is valid
        max_bin = maximum(Bin)
        @test max_bin == UB
        
        for bin_id in 1:max_bin
            items_in_bin = ItemSize[Bin .== bin_id]
            @test sum(items_in_bin) <= CAP
        end
    end
end
