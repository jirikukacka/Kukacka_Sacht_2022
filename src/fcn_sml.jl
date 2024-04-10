using Optim, BlackBoxOptim, LineSearches, Distributions

include("fcn_model.jl")

"""
    fcn_lol(theta, data, noise, setup)

Calculate negative log-likelihood given the data and the model.

# Arguments
- `theta`: model parameters
- `ypr`: dataset
- `noise`: kernel approximation noise
- `setup::Dict`: full setup dictionary

# Returns
- `logLsim::Float64`: negative log-likelihood
"""
function fcn_lol(theta, ypr, noise, setup::Dict)
    obs = setup["mod"]["obs"] # number of observations
    sim = setup["opt"]["sim"] # number of simulations
    delta_und = setup["opt"]["delta_und"] # undersmoothing parameter

    # initialize data structure
    fsim = zeros(obs)
    ADA = zeros(obs, 2)
    U = zeros(obs, 6) # forecast performance measures, ordered as fractions
    fra = zeros(obs, 6) # fractions, order: ADA_y, TF_y, LAA_y, ADA_p, TF_p, LAA_p

    # set initial values
    fra[1:3, :] .= setup["par"]["ifra"]

    for i = 4:obs
        # recalculate average mean values
        yp_avg_l = [mean(ypr[1:(i-1), 1]); mean(ypr[1:(i-1), 2])]
        yp_avg_ll = [mean(ypr[1:(i-2), 1]); mean(ypr[1:(i-2), 2])]

        # calculate next observation
        out = fcn_mod(theta, ypr[i-1, :], ypr[i-2, :], ypr[i-3, :], yp_avg_l, yp_avg_ll, ADA[i-2, :], U[i-2, :], fra[i-2, :], setup["opt"]["sim"], noise[:, :, i], setup)

        # separate output
        ypr_sim = out[1]
        ADA[i, :] = out[2]
        U[i, :] = out[3]
        fra[i, :] = out[4]

        # UNIVARIATE case
        # Bandwidth computed following Wand & Jones (1995, p. 98) + possible undersmoothing by delta_und, see https://en.wikipedia.org/wiki/Multivariate_kernel_density_estimation#Rule_of_thumb
        # h = (4/(3 * sim^(1+delta_und)))^(1/5) * std(psim)

        # MULTIVARIATE case
        hy = (4 / (5 * sim^(1 + delta_und)))^(1 / 7) * std(ypr_sim[:, 1])
        hp = (4 / (5 * sim^(1 + delta_und)))^(1 / 7) * std(ypr_sim[:, 2])
        hr = (4 / (5 * sim^(1 + delta_und)))^(1 / 7) * std(ypr_sim[:, 3])

        K = zeros(3, sim)
        K[1, :] = pdf.(Normal(ypr[i, 1], hy), ypr_sim[:, 1])
        K[2, :] = pdf.(Normal(ypr[i, 2], hp), ypr_sim[:, 2])
        K[3, :] = pdf.(Normal(ypr[i, 3], hr), ypr_sim[:, 3])
        
        fsim[i] = max(1e-32, mean(prod(K, dims=1)))
    end
    
    logLsim = mean(log.(fsim[4:obs])) # calculate mean log likelihood

    return -logLsim
end


"""
    sml(data, setup)

Simulated maximum likelihood estimation.

# Arguments
- `data`: dataset
- `setup::Dict`: full setup dictionary

# Returns
- `(par::Vector{Float64}, ll::Float64)`:  tuple of estimated parameters and optimized log likelihood
"""
function sml(data, setup::Dict)    
    par_cnt = length(setup["theta"]) # number of estimated parameters

    cons = setup["par"]["cons"][setup["mod"]["cons"]] # retrieve constraints
    low = [cons[i][1] for i in 1:par_cnt] # lower constraints
    up = [cons[i][2] for i in 1:par_cnt] # upper constraints

    trial_par = zeros(par_cnt, setup["opt"]["inits"]) # estimated parameters across initial points
    trial_ll = zeros(setup["opt"]["inits"]) # log likelihoods across initial points

    noise = randn(3, setup["opt"]["sim"], setup["mod"]["obs"]) # kernel approximation noise, same batch of draws may be used across t, see Kristensen and Shin (2012)

    for i in 1:setup["opt"]["inits"]
        # optimize using Optim.jl package
        if setup["opt"]["optimizer"] == "opt"
            init = [rand(Uniform(low[i], up[i])) for i in 1:par_cnt] # sample random initial point

            optout = optimize(
                theta -> fcn_lol(theta, data, noise, setup),
                low, up, # search constraints
                init, # initial point
                Fminbox(BFGS(linesearch=LineSearches.BackTracking())), # optimizer
                Optim.Options(
                    outer_iterations=setup["opt"]["iter_out"], # outer iteration cycles
                    iterations=setup["opt"]["iter"], # inner iteration cycles
                    show_trace=false # verbose
                )
            )
            
            trial_par[:, i] = Optim.minimizer(optout) # retrieve estimated parameters
            trial_ll[i] = Optim.minimum(optout) # retrieve minimum log likelihood

        # optimize using BlackBoxOptim.jl package
        elseif setup["opt"]["optimizer"] == "bbo"
            optout = bboptimize(
                theta -> fcn_lol(theta, data, noise, setup),
                SearchRange=cons, # search constraints
                Method=:adaptive_de_rand_1_bin_radiuslimited, # optimizer
                NumDimensions=length(cons), # search dimensionality
                MaxFuncEvals=setup["opt"]["iter"], # iteration cycles
                TraceMode=:silent # verbose
            )
            
            trial_par[:, i] = best_candidate(optout) # retrieve estimated parameters
            trial_ll[i] = best_fitness(optout) # retrieve minimum log likelihood
        end
    end

    return (trial_par[:, argmin(trial_ll)], minimum(trial_ll))
end
