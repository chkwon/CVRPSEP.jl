# Define the Julia wrapper function
function BP_ExactBinPacking(bin_capacity::T, item_sizes::Vector{T}) where T <: Integer

    @assert issorted(item_sizes, rev=true) "The item sizes are not sorted in non-increasing order."

    n = length(item_sizes)
    
    # Handle edge cases directly
    if n == 0
        return 0, 0, Int[]
    elseif n == 1
        return 1, 1, [1]
    end

    LB = Ref{Cint}()
    UB = Ref{Cint}()

    # Pad with zero because the C library expects 1-based indexing for item sizes.
    _item_sizes = [0; item_sizes]

    # return vector for bin assignments (1-based)
    # the first element is not used. 
    _bin_idx = Vector{Cint}(undef, n + 1)



    # void BP_ExactBinPacking(int CAP,
    #                     int *ItemSize,
    #                     int n,
    #                     int *LB,
    #                     int *UB,
    #                     int *Bin)

    ccall(
        (:BP_ExactBinPacking, LIB_CVRPSEP),
        Cvoid,
        (
            Cint, Ptr{Cint}, Cint, 
            Ref{Cint}, Ref{Cint}, Ptr{Cint}
        ),
        Cint(bin_capacity), Cint.(_item_sizes), Cint(n),
        LB, UB, _bin_idx
    )

    return Int(LB[]), Int(UB[]), Int.(_bin_idx[2:end])
end
