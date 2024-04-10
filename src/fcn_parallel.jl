# paralell computing
using Distributed, SharedArrays
addprocs(parsed_args["procs"])

@everywhere using DrWatson
@everywhere @quickactivate "Kukacka_Sacht_2022"
@everywhere using Random
@everywhere include("fcn_sml.jl")
@everywhere include("fcn_watson.jl")

"""
    parallelize_sml(data, setup)

Estimate parameters using simulated maximum likelihood in parallel.

# Parameters
- `data`: dataset
- `setup::Dict`: full setup dictionary

# Returns
- `results::Dict`: estimated parameters and log likelihoods
"""
function parallelize_sml(data, setup::Dict)
    par_cnt = length(setup["theta"]) # number of estimated parameters
    rep_cnt = setup["est"]["rep"] # number of repetitions

    results_par = SharedArray{Float64}(par_cnt, rep_cnt) # shared array for estimated parameters
    results_ll = SharedArray{Float64}(rep_cnt) # shared array for log likelihoods

    @sync @distributed for i in 1:rep_cnt
    # for i in 1:rep_cnt
        flushln("Estimating parameters for Monte Carlo repetition $i...")

        Random.seed!(setup["est"]["seed"]+i) # set random seed
        out = sml(data[:, :, i], setup) # estimate parameters using simulated maximum likelihood

        # split output
        results_par[:, i] = out[1]
        results_ll[i] = out[2]

        flushln("... parameters for Monte Carlo repetition $i estimated to be $(out[1])!")
    end

    results = Dict(
        "par" => Array(results_par), # estimated parameters
        "ll" => Array(results_ll), # log likelihoods
    )

    return results
end