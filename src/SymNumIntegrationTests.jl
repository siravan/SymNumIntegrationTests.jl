using SymbolicNumericIntegration
using Symbolics
using SpecialFunctions
using Printf

import SymPy

##############################################################################

@variables x a b c β
SymPy.@syms u

include("basic.jl")
include("rubi.jl")

function test_integrals(sym; verbose=false, kw...)
    if Threads.nthreads() == 1
         @warn "start julia as `julia --threads=auto`"
    end

    args = isempty(kw) ? Dict() : Dict(kw)
    args[:detailed] = false
    misses = []
    k = 1

    name = joinpath("suite/", "$sym.txt")
    fd = open(name, "r")     
    lines = readlines(fd)
    close(fd)

    for (i, line) in enumerate(lines)
        s = split(line, ';')
        eq = eval(Meta.parse(s[1]))
        args[:bypass] = (s[3] == "1")
    
        if verbose
            printstyled(k, ": "; color = :blue)
            printstyled(eq, " =>\n"; color = :green)
        end
            
        k += 1
            
        task = Threads.@spawn SymbolicNumericIntegration.integrate(eq, x; args...)
        sol = nothing
            
        for j = 1:100
            if istaskdone(task)
                sol = fetch(task)
                break
            else                    
                sleep(0.1)
            end
        end
            
        if !istaskdone(task)
            printstyled("integration timeout\n"; color = :red)
        end
            
        if sol == nothing
            if verbose
                printstyled("\t<no solution>\n"; color = :red)
            end
            push!(misses, eq)
        else
            if verbose
                printstyled('\t', sol, '\n'; color = :cyan)
            end
        end
            
        if !verbose
            n = length(misses)
            print("$(k - n) / $k\r")
        end        
    end

    n = length(misses)
    
    if verbose
        if n > 0
            println("**** missess (n=$n) *****")
        end
        for eq in misses
            printstyled(eq, '\n'; color = :red)
        end
    end
    
    println("successfully solved $(k-n) out of $k integrals")
end


###############################################################

function load_integrals(sym)
    if sym == "basic"
        integrals = basic
    elseif sym == "symbolic"
        integrals = symbolic
    else
        integrals = load_axiom(axiom_name(sym))
    end
    
    return integrals
end


function pytonize(eq)
    return substitute(eq, Dict(x => u))
end


function save_suite(sym)
    integrals = load_integrals(sym)
    name = joinpath("suite/", "$sym.txt")
    fd = open(name, "w")     
    bypass = 0
    
    for eq in integrals
        if isequal(eq, β)
            bypass = 1
            continue
        end

        jl = string(eq)
        
        py = string(pytonize(eq))
        py = replace(py, "^" => "**")
        
        @printf fd "%s;%s;%d\n" jl py bypass
    end
        
    close(fd)
end


function save_all()
    for sym in ["basic", "symbolic", "Apostle", "Bondarenko", "Bronstein",
                "Charlwood", "Hearn", "Hebisch", "Jeffrey", "Moses",
                "Stewart", "Timofeev", "Welz", "Wester"]
        println("processing ", sym)
        save_suite(sym)
    end    
end


