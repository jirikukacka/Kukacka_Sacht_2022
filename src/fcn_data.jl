using JLD

include("fcn_model.jl")
include("fcn_watson.jl")

"""
    gen_dataset(setup)

Generate a dataset based on the setup.

# Arguments
- `setup::Dict`: full setup dictionary
"""
function gen_dataset(setup::Dict)
    total_obs = setup["mod"]["obs"] + setup["mod"]["burn"] # total number of generated observations
    theta = setup["par"]["cali"][setup["mod"]["cali"]] # model calibration
    data = zeros(setup["mod"]["obs"], 3, setup["est"]["rep"]) # initialize array to store dataset

    # produce a pseudo-empirical dataset
    for i in 1:setup["est"]["rep"]
        # initialize data structure for current series
        ypr = zeros(total_obs, 3) # model output
        ADA = zeros(total_obs, 2) 
        U = zeros(total_obs, 6) # forecast performance measures, ordered as fractions
        fra = zeros(total_obs, 6) # fractions, order: ADA_y, TF_y, LAA_y, ADA_p, TF_p, LAA_p
        
        # set initial values
        fra[1:3, :] .= setup["par"]["ifra"]

        # generate random noise
        noise = randn(3, 1, total_obs) 

        for j = 4:total_obs
            # recalculate average mean values
            yp_avg_l = [mean(ypr[1:(j-1), 1]); mean(ypr[1:(j-1), 2])]
            yp_avg_ll = [mean(ypr[1:(j-2), 1]); mean(ypr[1:(j-2), 2])]

            # calculate next observation
            out = fcn_mod(theta, ypr[j-1, :], ypr[j-2, :], ypr[j-3, :], yp_avg_l, yp_avg_ll, ADA[j-2, :], U[j-2, :], fra[j-2, :], 1, noise[:, :, j], setup)
            
            # separate output 
            ypr[j, :] = out[1]
            ADA[j, :] = out[2]
            U[j, :] = out[3]
            fra[j, :] = out[4]
        end

        # discard burn-in period
        data[:, :, i] = ypr[setup["mod"]["burn"]+1:end, :]
    end

    flushln("Pseudo-empirical data generated!")

    return data
end


"""
    load_dataset(setup)

Load data from the file specified in the setup.

# Arguments
- `setup::Dict`: full setup dictionary
"""
function load_dataset(setup::Dict)
    # load matrix of empirical observations from JLD file and duplicate it
    emp_series = JLD.load(datadir(setup["est"]["data"]), "data")
    data = repeat(emp_series, 1, 1, setup["est"]["rep"])

    flushln("Empirical data loaded!")

    return data
end