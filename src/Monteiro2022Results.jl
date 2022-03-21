module Monteiro2022Results
export julia_main

using JuMP, Ipopt, DataFrames, CSV, HCEstimator
include("./DERs.jl")
using .DERs

function load_sys()::DataFrames.DataFrame
    return DataFrame(CSV.File("src/case33.csv"))
end

function build_substation()::HCEstimator.Substation
    return DistSystem.Substation(
        12660,              # Nominal voltage (V)
        1,                  # Bus
        1.02,                # Vˢᴮ: Voltage (p.u.)
        4.0,                # Pˢᴮ: Active power capacity (MW)
        2.5,                # Qˢᴮ: Reactive power capacity (MVAr)
        [0.003, 12, 240]    # Costs (Not used)
    )
end


function build_sys(data::DataFrames.DataFrame)::HCEstimator.System
    sub = build_substation()
    sys = DistSystem.factory_system(data, 0.93, 1.05, sub)
    DERs.add_ders!(sys, 0.0)
    sys.m_load = [0.5, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0, 1]
    return sys
end

function julia_main()::Cint
    println("Stated!")
    println("Loading data...")
    data = load_sys()
    sys = build_sys(data)
    println("Loaded!")
    println("Building model...")
    @time model = build_model(Model(Ipopt.Optimizer), sys)
    set_optimizer_attribute(model, "expect_infeasible_problem", "yes")
    set_optimizer_attribute(model, "timing_statistics", "yes")
    set_optimizer_attribute(model, "constr_viol_tol", 0.0005)
    set_optimizer_attribute(model, "mumps_mem_percent", 500)
    set_silent(model)

    println("Builded!")
    println("Optimizing...")
    @time optimize!(model)
    println("Finished!")

    println("STATUS: ", termination_status(model))
    println("Hosting Capacity: ", round(objective_value(model), digits=3), " MVA")
    println("Exting..") 
    return 0
end
end # module