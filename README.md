# Monteiro2022Results

The Mathematical model can be found in [HCEstimator.jl](https://github.com/felipemarkson/HCEstimator.jl)

## Scenarios:

- S1: No Distributed Generation (DG), Electrical Vehicles Charger (EV) or Energy Storage System (ESS).
- S2: 3º Party 0.1 MW Renewable DGs on buses 26, 29, 13, and 6
- S3: Same of S2 and 3º Party 50kW/50kWh ESSs on buses 4and 32
- S4: Same of S2 and 3º Party 50kW EV chargers on buses 17 and 20
- S5: Full dispaced 0.1 MVA DG on buses 18, 33, 22, and 25
- S6: Same as S5 and same as S2
- S7: Same as S5 and same as S3
- S8: Same as S5 and same as S4
- S9: Same of S5, same of S4 and 3º Party 50kW/50kWh ESSs on buses 4 and 32

## Results:

It was genereted tree types of results:

1. Estimation of Hosting Capacity (HC) for DG and EV together (ESS case).
2. Estimation of HC only for DG.
3. Estimation of HC only for EV. 

Results can be seen [here](results/results.pdf).

## How to run

### 0. Download and install Julia 

> The scripts were tested on Julia LTS v1.6.6, but any version >= 1.6 < 2.0 should work.

[Download Julia](https://julialang.org/downloads/) and 
install in your current platform, instructions [here](https://julialang.org/downloads/platform/).

### 1. Set up the environment

#### Clone this repository 
```shell
git clone https://github.com/felipemarkson/Monteiro2022Results.git
```
#### Change to the project repository
```shell
cd Monteiro2022Results/
```

### 2. Start Julia in the current repository
```shell
julia --project=.
```
This command will install all dependencies in the current environment keeping your Julia installation clean.

### 3. Run the ```main.jl``` file
The main file generete the results for DG and EV Hosting capacity estimation together.
```julia
julia> include("src/main.jl")
```
>This command should take several minutes to finish.

### 4. Changing the ```main.jl``` file to generate others results (optional)

#### For evaluation of only EV Chargers
The function ```build_sys``` in [```src/Monteiro2022Results.jl```](src/Monteiro2022Results.jl) must be repleced by:

```julia
function build_sys(data::DataFrames.DataFrame, add_der)::HCEstimator.System
    sub = build_substation()
    sys = DistSystem.factory_system(data, 0.93, 1.05, sub)
    sys = add_der(sys)
    sys.m_load = [0.6, 0.8, 1.0]
    sys.m_new_dg = [-1.0, 0.0] # The only change occurs here
    sys.time_curr = 1.0
    return sys
end
```

#### For evaluation of only DGs
The function ```build_sys``` in [```src/Monteiro2022Results.jl```](src/Monteiro2022Results.jl) must be repleced by:

```julia
function build_sys(data::DataFrames.DataFrame, add_der)::HCEstimator.System
    sub = build_substation()
    sys = DistSystem.factory_system(data, 0.93, 1.05, sub)
    sys = add_der(sys)
    sys.m_load = [0.6, 0.8, 1.0]
    sys.m_new_dg = [0.0, 1.0] # The only change occurs here
    sys.time_curr = 1.0
    return sys
end
```

#### Run again
After choose the evaluation tu can be able to run:
```julia
julia> include("src/main.jl")
```
>This command should take several minutes to finish.

## How to generate the Plots

This project uses [```Pluto.jl```](https://github.com/fonsp/Pluto.jl) as a notebook. 

After [start Julia in the current repository](#2-start-julia-in-the-current-repository) you should be able to run:

```julia
julia> import Pluto; Pluto.run()
```

Then, open the [```results/results.jl```](results/results.jl) in Pluto.



