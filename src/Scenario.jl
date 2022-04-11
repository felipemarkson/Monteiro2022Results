module Scenario
include("./DERs.jl")
import .DERs

export *

function renewable(sys, alpha)
    renewable_location = [26, 29, 13, 6]
    renewable_config = DERs.Config(false, true, 0.1, 0.0, alpha, 0.0)
    for location in renewable_location
        push!(sys.dgs, DERs.dg(renewable_config, location))
    end
    return sys
end
function ess(sys, alpha)
    ess_location = [4, 32]
    ess_config = DERs.Config(true, true, 0.05, 0.05, alpha, alpha)
    for location in ess_location
        push!(sys.dgs, DERs.ess(ess_config, location))
    end
    return sys
end
function ev(sys, alpha)
    ev_location = [17, 20]
    ev_config = DERs.Config(false, true, 0.05, 0.0, alpha, 0.0)
    for location in ev_location
        push!(sys.dgs, DERs.ev_charger(ev_config, location))
    end
    return sys
end
function dg_dispached(sys, alpha)
    dg_dispached_location = [18, 33, 22, 25]
    dg_dispached_config = DERs.Config(true, true, 0.1, 100.0, 1.0, 1.0)
    for location in dg_dispached_location
        push!(sys.dgs, DERs.dg(dg_dispached_config, location))
    end
    return sys
end
function ess_dispached(sys, alpha)
    ess_dispached_location = [9]
    ess_dispached_config = DERs.Config(true, true, 0.1, 0.1, 1.0, 1.0)
    for location in ess_dispached_location
        push!(sys.dgs, DERs.ess(ess_dispached_config, location))
    end
    return sys
end
function scenario(alpha::Float64, ders)
    null = (sys, alpha) -> sys
    return mapreduce((func) -> (sys) -> func(sys, alpha), ∘, [ders; null])
end
end