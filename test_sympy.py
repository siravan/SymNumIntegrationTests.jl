from sympy import *
from sympy import integrals
import os


def test_integrals(sym, verbose=False):
    name = f"{sym}.txt"
    path = os.path.join("suite/", name)
    fd = open(path, "r")

    u = Symbol('u')
    
    k = 0
    mh = 0  # count of heurisch
    mt = 0  # count of deep
    sol = 0
    
    for line in fd.readlines():
        k += 1
        s = line.split(';')
        eq = eval(s[1])
        
        if verbose:
            print(eq)        
    
        try:
            sol = integrals.heurisch.heurisch(eq, u)
            if sol is not None:
                mh += 1
                mt += 1
            else:
                sol = integrate(eq, u)
                if not sol.has(Integral):
                    mt += 1
        except:   
            pass
            
        if verbose:
            print(eq, " -> ", sol)
        else:
            print(f"{mh} / {k} and {mt} / {k}        \r", end='')
    
    print(f"{mh} / {k} and {mt} / {k}")
    fd.close()
