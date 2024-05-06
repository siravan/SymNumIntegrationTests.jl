extract_symbols(eq::Symbol) = [eq]
extract_symbols(eq::Expr) = union([extract_symbols(x) for x in eq.args[2:end]]...)
extract_symbols(eq) = []

subs(eq::Symbol, S) = get(S, eq, eq)
subs(eq::Expr, S) = Expr(eq.head, [subs(x, S) for x in eq.args]...)
subs(eq, S) = eq

function load_axiom(name)
    fd = open(name, "r")
    re = r"\[(.*)\]"
    L = []
    
    D = Dict{Any, Int}()

    for (lineno, line) in enumerate(readlines(fd))
        line = strip(line)
        if length(line) < 3 || line[1:2] == "--"
            continue
        end
        ma = match(re, line)

        if ma != nothing
            s = split(ma[1], ',')
            line = s[1]
            iv = Symbol(s[2])
            
            if occursin("%i", line)
                continue
            end
            
            line = replace(line, "%e" => MathConstants.e)
            line = replace(line, "%pi" => π)

            S = Dict{Any, Any}(iv => :x)
            eq = Meta.parse(line)
            
            for v in extract_symbols(eq)
                if v != iv && v != :ℯ && v != :im && v != :π
                    S[v] = rand(1:5)
                end
            end
            
            eq = subs(eq, S)
            try 
                push!(L, eval(eq))
            catch
                # 
            end
        end
    end

    close(fd)
    return unique(L)
end

function axiom_name(sym)
    name = if sym == "Apostle" || sym == 1
        "Apostol Problems.input"
    elseif sym == "Bondarenko" || sym == 2
        "Bondarenko Problems.input"
    elseif sym == "Bronstein" || sym == 3
        "Bronstein Problems.input"
    elseif sym == "Charlwood" || sym == 4
        "Charlwood Problems.input"
    elseif sym == "Hearn" || sym == 5
        "Hearn Problems.input"
    elseif sym == "Hebisch" || sym == 6
        "Hebisch Problems.input"
    elseif sym == "Jeffrey" || sym == 7
        "Jeffrey Problems.input"
    elseif sym == "Moses" || sym == 8
        "Moses Problems.input"
    elseif sym == "Stewart" || sym == 9
        "Stewart Problems.input"
    elseif sym == "Timofeev" || sym == 10
        "Timofeev Problems.input"
    elseif sym == "Welz" || sym == 11
        "Welz Problems.input"
    elseif sym == "Wester" || sym == 12
        "Wester Problems.input"
    end

    name = joinpath("RUBITestFiles/0 Independent test suites", name)
    println(name)
    return name
end


