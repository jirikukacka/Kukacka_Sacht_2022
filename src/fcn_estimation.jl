using Random

include("fcn_parallel.jl")
include("fcn_data.jl")
include("fcn_parameters.jl")
include("fcn_watson.jl")
include("fcn_utils.jl")

"""
    estimate(setup)

Prepare dataset and initialize selected estimation procedure.
    
If `setup["est"]["data"]` is not set, generate pseudo-empirical data. Otherwise,
load empirical data from the specified file located in the `data` folder.

# Parameters
- `setup::Dict`: full setup dictionary
"""
function estimate(setup::Dict)
    Random.seed!(setup["est"]["seed"]) # set random seed

    setup["par"] = fcn_par(setup) # retrieve model parameters
    setup["nos"] = fcn_nos(setup) # retrieve noise parameters
    setup["theta"] = setup["par"]["cali"][setup["mod"]["cali"]]

    if setup["par"]["kappa_idx"] == 0
        setup["mod"]["ybar"] = 0.0 # trivialized solution
    else
        setup["mod"]["ybar"] = (1-setup["mod"]["nu"])*setup["mod"]["pbar"]/setup["theta"][setup["par"]["kappa_idx"]]
    end

    if setup["est"]["data"] isa Nothing
        # generate pseudo-empirical data
        data = gen_dataset(setup)
    else
        # load empirical data
        data = load_dataset(setup)
        setup["mod"]["obs"] = size(data, 1) # change setup dictionary to correct number of observations
    end

    results = parallelize_sml(data, setup) # estimate parameters using simulated maximum likelihood

    save_results(setup["foldername"], results) # save results to file
    
    flushln("Results saved to $(resultsdir(setup["foldername"], "results.jld"))!")
end
