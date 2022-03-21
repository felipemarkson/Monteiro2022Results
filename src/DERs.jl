module DERs
using HCEstimator
export add_ders!

struct Config
    active_dispatchable::Bool
    reactive_dispatchable::Bool
    power::Float64
    energy::Float64
    α::Float64
    β::Float64
end

function configure_limits!(MW::Vector{Float64}, MVAr::Vector{Float64}, configs::Config)::Tuple{Vector{Float64},Vector{Float64}}
    if !configs.active_dispatchable
        MW = [0.0, 0.0]
    end

    if !configs.reactive_dispatchable
        MVAr = [0.0, 0.0]
    end

    return MW, MVAr
end

function dg(configs::Config, bus)
    MW = [0.0, configs.power]
    MVAr = [-configs.power, configs.power]

    MW, MVAr = configure_limits!(MW, MVAr, configs)

    return DistSystem.DER(
        bus,                  # Bus
        configs.power,                # Sᴰᴱᴿ (MVA)
        configs.energy,                # Eᴰᴱᴿ (MWh)
        configs.α,                # αᴰᴱᴿ
        configs.β,                # βᴰᴱᴿ
        MW,         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
        MVAr,       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
        [0.0, 1.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
        [0.0] # Costs (Not used) 
    )
end

function ess(configs::Config, bus)
    MW = [-configs.power, configs.power]
    MVAr = [-configs.power, configs.power]

    MW, MVAr = configure_limits!(MW, MVAr, configs)

    return DistSystem.DER(
        bus,                  # Bus
        configs.power,                # Sᴰᴱᴿ (MVA)
        configs.energy,                # Eᴰᴱᴿ (MWh)
        configs.α,                # αᴰᴱᴿ
        configs.β,                # βᴰᴱᴿ
        MW,         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
        MVAr,       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
        [-1.0, 0.0, 1.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
        [0.0] # Costs (Not used) 
    )
end

function ev_charger(configs::Config, bus)
    MW = [-configs.power, 0.0]
    MVAr = [-configs.power, configs.power]

    MW, MVAr = configure_limits!(MW, MVAr, configs)
    return DistSystem.DER(
        bus,                  # Bus
        configs.power,                # Sᴰᴱᴿ (MVA)
        configs.energy,                # Eᴰᴱᴿ (MWh)
        configs.α,                # αᴰᴱᴿ
        configs.β,                # βᴰᴱᴿ
        MW,         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
        MVAr,       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
        [-1.0, 0.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
        [0.0] # Costs (Not used) 
    )
end



end