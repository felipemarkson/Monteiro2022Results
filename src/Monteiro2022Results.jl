module Monteiro2022Results
export julia_main

using JuMP, Ipopt, DataFrames, CSV, HCEstimator, JLD

include("./Scenario.jl")
import .Scenario


function load_sys_from_csv()::DataFrames.DataFrame
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


function build_sys(data::DataFrames.DataFrame, add_der, hc_modes)::HCEstimator.System
    sub = build_substation()
    sys = DistSystem.factory_system(data, 0.93, 1.05, sub)
    sys = add_der(sys)
    sys.m_load = [0.6, 0.8, 1.0]
    sys.m_new_dg = hc_modes
    sys.time_curr = 1.0
    return sys
end

function set_options!(model)
    if solver_name(model) == "Ipopt"
        set_optimizer_attribute(model, "expect_infeasible_problem", "yes")
        set_optimizer_attribute(model, "timing_statistics", "yes")

        set_optimizer_attribute(model, "tol", 1e-5)
        set_optimizer_attribute(model, "constr_viol_tol", 1e-5)
        set_optimizer_attribute(model, "dual_inf_tol", 1e-5)
        set_optimizer_attribute(model, "compl_inf_tol", 1e-5)
        set_optimizer_attribute(model, "mumps_mem_percent", 1000)
        set_silent(model)
    end
    return model

end

function get_ders_operation!(sys, model, df, i, alpha)
    (Ω, bΩ, L, K, D, S) = Tools.Get.sets(sys)
    HC = objective_value(model)

    for d = D, l = L, k = K, s = S
        P = Tools.Get.power_active_DER(model, d, l, k, s)
        Q = Tools.Get.power_reactive_DER(model, d, l, k, s)
        push!(df, ("S$(i)", alpha, HC, P, Q, d, l, k, s))
    end
end


function julia_main(mode)::Cint
    println("################################## MODE: $(mode["name"]) ######################## ")
    println("Stated!")
    println("Loading data...")
    data = load_sys_from_csv()

    ders_scenario = [
        [
            Scenario.dg_dispached,
            Scenario.renewable,
            Scenario.ev,
            Scenario.ess
        ],
        [Scenario.dg_dispached, Scenario.renewable, Scenario.ev],
        [Scenario.dg_dispached, Scenario.renewable, Scenario.ess],
        [Scenario.dg_dispached, Scenario.renewable],
        [Scenario.dg_dispached],
        [Scenario.renewable, Scenario.ev],
        [Scenario.renewable, Scenario.ess],
        [Scenario.renewable],
        [],
    ]
    ders_scenario = reverse(ders_scenario)

    A = [0.0, 0.025, 0.05, 0.075, 0.1]

    df = DataFrame(
        Scenario=String[], alpha=Float64[], HC=Float64[],
        P=Float64[],
        Q=Float64[],
        der=Int[],
        l=Float64[],
        k=Float64[],
        s=Float64[],
    )

    for (i, ders) in enumerate(ders_scenario)
        # println("Scenario: ", i)
        for α in A
            # println("   with α = ", α)
            add_der(sys) = Scenario.scenario(α, ders)(sys)
            sys = build_sys(data, add_der, mode["hc"])
            # println("       with HC modes = ", sys.m_new_dg)
            model = Model(Ipopt.Optimizer)
            model = set_options!(model)
            println("       Building Model...")
            model = build_model(model, sys)
            println("       Solving...")
            @time optimize!(model)
            println("       STATUS: ", termination_status(model))
            if termination_status(model) == MOI.LOCALLY_SOLVED || termination_status(model) == MOI.OPTIMAL
                # println("       Hosting Capacity: ", round(objective_value(model), digits=6), " MVA")
                get_ders_operation!(sys, model, df, i, α)
                println(df[end, [:Scenario, :alpha, :HC]])
            else
                error("Model infeasible!")
            end

            println("   Finished!!")
        end
    end

    println("Salving results...")
    CSV.write("results/results_$(mode["name"]).csv", df)
    println("Exting...")
    return 0
end
end # module