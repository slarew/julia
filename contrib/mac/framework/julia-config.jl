#!/usr/bin/env julia
# This file is a part of Julia. License is MIT: http://julialang.org/license

const options =
[
    "--cflags",
    "--ldflags",
    "--ldlibs"
];

threadingOn() = ccall(:jl_threading_enabled, Cint, ()) != 0

function frameworkDir()
    abspath(normpath(joinpath(dirname(Libdl.dlpath("Julia")),"..","..","..")))
end

function ldflags()
    replace("""-F$(frameworkDir())""","\\","\\\\")
end

function ldlibs()
    return "-framework Julia"
end

function cflags()
    threading_def = threadingOn() ? "-DJULIA_ENABLE_THREADING=1 " : ""
    return """$(threading_def)-F$(replace(frameworkDir(),"\\","\\\\"))"""
end

function check_args(args)
    checked = intersect(args,options)
    if length(checked) == 0 || length(checked) != length(args)
        println(STDERR,"Usage: julia-config [",reduce((x,y)->"$x|$y",options),"]")
        exit(1)
    end
end

function main()
    check_args(ARGS)
    for args in ARGS
        if args == "--ldflags"
            println(ldflags())
        elseif args == "--cflags"
            println(cflags())
        elseif args == "--ldlibs"
            println(ldlibs())
        end
    end
end

main()
