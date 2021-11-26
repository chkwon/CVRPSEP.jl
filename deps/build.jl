const SRC_FILE = "https://github.com/chkwon/CVRPSEP/archive/refs/heads/main.zip"

# function download_win_exe()
#     lkh_exe = joinpath(@__DIR__, "LKH.exe")
#     download(LKH_WIN_EXE_URL, lkh_exe)
#     return lkh_exe
# end

function _build()
    src_tarball = joinpath(@__DIR__, "cvrpsep.zip")
    download(SRC_FILE, src_tarball)
    src_dir = joinpath(@__DIR__, "src")
    run(`tar zxvf $(src_tarball)`)
    cd("CVRPSEP-main")
    run(`make`)
    shared_lib = joinpath(@__DIR__, "CVRPSEP-main/build", "libcvrpsep")
    return shared_lib
end

function _download()
    if Sys.islinux() && Sys.ARCH == :x86_64
        return _build()
    elseif Sys.isapple()
        return _build()
    # elseif Sys.iswindows()
    #     @error "Windows not supported yet."
    #     # return download_win_exe()
    end
    error("Unsupported operating system. Only 64-bit linux and macOS are supported.")
end

function _install()
    executable = get(ENV, "LIB_CVRPSEP", nothing)
    if !haskey(ENV, "LIB_CVRPSEP")
        shared_lib = _download()
        ENV["LIB_CVRPSEP"] = shared_lib
    end

    # if executable === nothing
    #     error("Environment variable `HGS_CVRP_EXECUTABLE` not found.")
    # else
    #     # pr2392 = joinpath(@__DIR__, LKH_VERSION, "pr2392.par")
    #     # run(`$(executable) $(pr2392)`)
    # end

    open(joinpath(@__DIR__, "deps.jl"), "w") do io
        write(io, "const LIB_CVRPSEP = \"$(escape_string(shared_lib))\"\n")
    end
end

_install()