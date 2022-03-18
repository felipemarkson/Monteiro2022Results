module DERs
using HCEstimator
export add_ders!

struct DERConfig
    active_dispatchable::Bool
    reactive_dispatchable::Bool
    power::Float64
    α::Float64
end

function configure_limits!(MW::Vector{Float64}, MVAr::Vector{Float64}, configs::DERConfig)::Tuple{Vector{Float64},Vector{Float64}}
    if !configs.active_dispatchable
        MW = [0.0, 0.0]
    end

    if !configs.reactive_dispatchable
        MVAr = [0.0, 0.0]
    end

    return MW, MVAr
end

function dg(configs::DERConfig, bus)
    MW = [0.0, configs.power]
    MVAr = [-configs.power, configs.power]

    MW, MVAr = configure_limits!(MW, MVAr, configs)

    return DistSystem.DER(
        bus,                  # Bus
        configs.power,                # Sᴰᴱᴿ (MVA)
        configs.α,                # αᴰᴱᴿ
        MW,         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
        MVAr,       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
        [0.0, 1.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
        [0.0] # Costs (Not used) 
    )
end

function ess(configs::DERConfig, bus)
    MW = [-configs.power, configs.power]
    MVAr = [-configs.power, configs.power]

    MW, MVAr = configure_limits!(MW, MVAr, configs)

    return DistSystem.DER(
        bus,                  # Bus
        configs.power,                # Sᴰᴱᴿ (MVA)
        configs.α,                # αᴰᴱᴿ
        MW,         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
        MVAr,       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
        [-1.0, 0.0, 1.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
        [0.0] # Costs (Not used) 
    )
end

function ev_charger(configs::DERConfig, bus)
    MW = [-configs.power, 0.0]
    MVAr = [-configs.power, configs.power]

    MW, MVAr = configure_limits!(MW, MVAr, configs)
    return DistSystem.DER(
        bus,                  # Bus
        configs.power,                # Sᴰᴱᴿ (MVA)
        configs.α,                # αᴰᴱᴿ
        MW,         # [Pᴰᴱᴿ_low, Pᴰᴱᴿ_upper]  (MW)
        MVAr,       # [Qᴰᴱᴿ_low, Qᴰᴱᴿ_upper]  (MVAr)
        [-1.0, 0.0],          # Possible DER's Operation Scenarios ≠ μᴰᴱᴿ
        [0.0] # Costs (Not used) 
    )
end

function add_ders!(sys::HCEstimator.System, α::Float64)
    renewable_config = DERConfig(false, true, 0.10/(1-α), α)
    dispatch_config = DERConfig(true, true, 0.5/(1-α), α)
    ess_config = DERConfig(true, true, 0.03/(1-α), α)
    ev_config = DERConfig(false, true, 0.03/(1-α), α)
    full_dispatch_config = DERConfig(true, true, 0.5, 0.99)

    # sys.dgs = [ess(foo_config, 33), ess(foo_config, 22)]
    sys.dgs = [
        dg(full_dispatch_config, 18),
        dg(dispatch_config, 25),
        dg(full_dispatch_config, 33),
        dg(dispatch_config, 22),
        dg(dispatch_config, 13),
        ess(ess_config, 12),
        ev_charger(ev_config, 6),
        ev_charger(ev_config, 16),
        # ev_charger(ev_config, 24),
        # ev_charger(ev_config, 20),
        # ev_charger(ev_config, 29),
        # ev_charger(ev_config, 11),
    ]
    sys
end

end