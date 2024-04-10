"""
    fcn_mod(...)

Generate output of the New Keynesian model.
"""
function fcn_mod(
    theta::Vector{Float64},
    ypr_l::Vector{Float64},
    ypr_ll::Vector{Float64},
    ypr_lll::Vector{Float64},
    yp_avg_l::Vector{Float64},
    yp_avg_ll::Vector{Float64},
    ADA_ll::Vector{Float64},
    U_ll::Vector{Float64},
    fra_ll::Vector{Float64},
    sim::Int64,
    noise::Array{Float64,2},
    setup::Dict
)
    # retrive information from setup
    nu = setup["mod"]["nu"] # discount rate
    type = setup["mod"]["model"] # model identifier
    mod_dict = setup["par"] # model parameters
    nos_dict = setup["nos"] # noise parameters
    omega = setup["mod"]["omega"] # penalty term
    bars = [setup["mod"]["ybar"]; setup["mod"]["pbar"]; 0.0]
    
    y_bar = bars[1]
    p_bar = bars[2]

    # paramaters
    if type == "brf_hom_all"
        tau = theta[1]
        kappa = theta[2]
        phi_y = theta[3]
        phi_p = theta[4]
        sig_y = theta[5]
        sig_p = theta[6]
        sig_r = theta[7]
        eta_y = theta[8]
        iota_y = theta[9]
        mu_y = theta[10]
        eta_p = theta[11]
        iota_p = theta[12]
        mu_p = theta[13]
        chi = 0.0
        alpha = 0.0
        phi_r = 0.0
        rho = theta[14]
        varphi = theta[15]
        gamma = theta[16]
    elseif type == "brf_hom_trN"
        tau = theta[1]
        kappa = theta[2]
        phi_y = theta[3]
        phi_p = theta[4]
        sig_y = nos_dict["sig_y"]
        sig_p = nos_dict["sig_p"]
        sig_r = nos_dict["sig_r"]
        eta_y = theta[5]
        iota_y = theta[6]
        mu_y = theta[7]
        eta_p = eta_y
        iota_p = iota_y
        mu_p = mu_y
        chi = 0.0
        alpha = 0.0
        phi_r = 0.0
        rho = 0.0
        varphi = 0.0
        gamma = theta[8]
    elseif type == "brf_hom_trK"
        phi_y = theta[1]
        phi_p = theta[2]
        tau = nos_dict["tau"]
        kappa = nos_dict["kappa"]
        sig_y = nos_dict["sig_y"]
        sig_p = nos_dict["sig_p"]
        sig_r = nos_dict["sig_r"]
        eta_y = theta[3]
        iota_y = theta[4]
        mu_y = theta[5]
        eta_p = eta_y
        iota_p = iota_y
        mu_p = mu_y
        chi = 0.0
        alpha = 0.0
        phi_r = 0.0
        rho = 0.0
        varphi = 0.0
        gamma = theta[6]
    elseif type == "reh_hom_all"
        chi = theta[1]
        tau = theta[2]
        alpha = theta[3]
        kappa = theta[4]
        phi_r = theta[5]
        phi_y = theta[6]
        phi_p = theta[7]
        sig_y = theta[8]
        sig_p = theta[9]
        sig_r = theta[10]
    elseif type == "reh_hom_alN"
        chi = theta[1]
        tau = theta[2]
        alpha = theta[3]
        kappa = theta[4]
        phi_r = theta[5]
        phi_y = theta[6]
        phi_p = theta[7]
        sig_y = nos_dict["sig_y"]
        sig_p = nos_dict["sig_p"]
        sig_r = nos_dict["sig_r"]
    elseif type == "reh_hom_alC"
        chi = theta[1]
        tau = theta[2]
        alpha = theta[3]
        phi_r = theta[4]
        phi_y = theta[5]
        phi_p = theta[6]
        kappa = nos_dict["kappa"]
        sig_y = nos_dict["sig_y"]
        sig_p = nos_dict["sig_p"]
        sig_r = nos_dict["sig_r"]
    end

    # state-space matrices
    A = [1.0 0.0 tau; -kappa 1.0 0.0; -(1.0 - phi_r) * phi_y -(1.0 - phi_r) * phi_p 1.0]
    B = [-1.0/(1.0 + chi) -tau  0.0; 0.0 -nu/(1.0 + alpha * nu) 0.0; 0.0 0.0 0.0]
    C = [-chi/(1.0 + chi) 0.0 0.0; 0.0 -alpha/(1.0 + alpha * nu) 0.0; 0.0 0.0 -phi_r]
    D = [0.0 0.0 0.0; 0.0 0.0 0.0; (1.0 - phi_r) * phi_y -(1.0 - (1.0 - phi_r) * phi_p) 0.0]
    E = [-1.0 0.0 0.0; 0.0 -1.0 0.0; 0.0 0.0 -1.0]

    # PREVIOUS period
    # initialisation
    U_l = zeros(size(U_ll))
    fra_l = zeros(size(fra_ll))

    # for MLE code
    Omega = []
    Phi = []
    Sigma_eps = [sig_y^2 0 0; 0 sig_p^2 0; 0 0 sig_r^2]

    # expectations for the BRF version
    if mod_dict["vers"] == "brf"
        ADA_y_l = eta_y * ypr_ll[1] + (1.0 - eta_y) * ADA_ll[1]
        TF_y_l = ypr_ll[1] + iota_y * (ypr_ll[1] - ypr_lll[1])
        LAA_y_l = mu_y * (yp_avg_ll[1] + ypr_ll[1]) + (ypr_ll[1] - ypr_lll[1])
        ADA_p_l = eta_p * ypr_ll[2] + (1.0 - eta_p) * ADA_ll[2]
        TF_p_l = ypr_ll[2] + iota_p * (ypr_ll[2] - ypr_lll[2])
        LAA_p_l = mu_p * (yp_avg_ll[2] + ypr_ll[2]) + (ypr_ll[2] - ypr_lll[2])

        ADA_l = [ADA_y_l; ADA_p_l]

        # forecast performance measures
        U_l[1] = rho * U_ll[1] - (ADA_y_l - ypr_l[1])^2
        U_l[2] = rho * U_ll[2] - (TF_y_l - ypr_l[1])^2
        U_l[3] = rho * U_ll[3] - (LAA_y_l - ypr_l[1])^2
        U_l[4] = rho * U_ll[4] - (ADA_p_l - ypr_l[2])^2
        U_l[5] = rho * U_ll[5] - (TF_p_l - ypr_l[2])^2
        U_l[6] = rho * U_ll[6] - (LAA_p_l - ypr_l[2])^2

        # updating of fractions
        norm123pre = (exp(gamma * U_l[1]) + exp(gamma * U_l[2]) + exp(gamma * U_l[3]))
        norm456pre = (exp(gamma * U_l[4]) + exp(gamma * U_l[5]) + exp(gamma * U_l[6]))
        fra_l[1] = varphi * fra_ll[1] + (1.0 - varphi) * (exp(gamma * U_l[1]) / norm123pre)
        fra_l[2] = varphi * fra_ll[2] + (1.0 - varphi) * (exp(gamma * U_l[2]) / norm123pre)
        fra_l[3] = varphi * fra_ll[3] + (1.0 - varphi) * (exp(gamma * U_l[3]) / norm123pre)
        fra_l[4] = varphi * fra_ll[4] + (1.0 - varphi) * (exp(gamma * U_l[4]) / norm456pre)
        fra_l[5] = varphi * fra_ll[5] + (1.0 - varphi) * (exp(gamma * U_l[5]) / norm456pre)
        fra_l[6] = varphi * fra_ll[6] + (1.0 - varphi) * (exp(gamma * U_l[6]) / norm456pre)
    end

    # NEW period
    # initialisation
    ypr_t = zeros(sim, 3)
    U_t = zeros(size(U_ll))
    fra_t = zeros(size(fra_ll))

    # shocks
    noise[1, :] = noise[1, :] * sig_y
    noise[2, :] = noise[2, :] * sig_p
    noise[3, :] = noise[3, :] * sig_r

    # expectations for the BRF version
    if mod_dict["vers"] == "brf"
        ADA_y = eta_y * ypr_l[1] + (1.0 - eta_y) * ADA_l[1]
        TF_y = ypr_l[1] + iota_y * (ypr_l[1] - ypr_ll[1])
        LAA_y = mu_y * (yp_avg_l[1] + ypr_l[1]) + (ypr_l[1] - ypr_ll[1])
        ADA_p = eta_p * ypr_l[2] + (1.0 - eta_p) * ADA_l[2]
        TF_p = ypr_l[2] + iota_p * (ypr_l[2] - ypr_ll[2])
        LAA_p = mu_p * (yp_avg_l[2] + ypr_l[2]) + (ypr_l[2] - ypr_ll[2])

        E_y = fra_l[1] * ADA_y + fra_l[2] * TF_y + fra_l[3] * LAA_y
        E_p = fra_l[4] * ADA_p + fra_l[5] * TF_p + fra_l[6] * LAA_p
        forecasts = [E_y; E_p; 0.0]
        ADA_t = [ADA_y; ADA_p]
    end

    # solution for the REH version
    if mod_dict["vers"] == "reh"
        xi = 0.8   # stop criterion parameter
        iterations = 100
        Omega = xi * [1.0 0.0 0.0; 0.0 1.0 0; 0.0 0.0 1.0]
        for i = 2:iterations
            Omega_new = -inv(B * Omega + A) * C
            Omega = Omega_new
        end
        Phi = -inv(A + B * Omega) * E
        Pi = -inv(A + B * Omega) * D

        ADA_t = [0.0; 0.0]   # not needed but kept for the universality of the code
    end

    # final computation
    for i = 1:sim
        if mod_dict["vers"] == "reh"
            X = Omega * ypr_l + Phi * noise[:, i] + Pi * bars
        else
            X = -inv(A) * (B * forecasts + C * ypr_l + D * bars + E * noise[:, i])
        end

        ypr_t[i, 1] = X[1]
        ypr_t[i, 2] = X[2]
        ypr_t[i, 3] = X[3]
    end

    if sim == 1 && mod_dict["vers"] == "brf" # for SIMULATION and BRF
        # forecast performance measures
        U_t[1] = rho * U_l[1] - (ADA_y - ypr_t[1])^2
        U_t[2] = rho * U_l[2] - (TF_y - ypr_t[1])^2
        U_t[3] = rho * U_l[3] - (LAA_y - ypr_t[1])^2
        U_t[4] = rho * U_l[4] - (ADA_p - ypr_t[2])^2
        U_t[5] = rho * U_l[5] - (TF_p - ypr_t[2])^2
        U_t[6] = rho * U_l[6] - (LAA_p - ypr_t[2])^2

        # updating of fractions
        norm123fin = (exp(gamma * U_t[1]) + exp(gamma * U_t[2]) + exp(gamma * U_t[3]))
        norm456fin = (exp(gamma * U_t[4]) + exp(gamma * U_t[5]) + exp(gamma * U_t[6]))
        fra_t[1] = varphi * fra_l[1] + (1.0 - varphi) * (exp(gamma * U_t[1]) / norm123fin)
        fra_t[2] = varphi * fra_l[2] + (1.0 - varphi) * (exp(gamma * U_t[2]) / norm123fin)
        fra_t[3] = varphi * fra_l[3] + (1.0 - varphi) * (exp(gamma * U_t[3]) / norm123fin)
        fra_t[4] = varphi * fra_l[4] + (1.0 - varphi) * (exp(gamma * U_t[4]) / norm456fin)
        fra_t[5] = varphi * fra_l[5] + (1.0 - varphi) * (exp(gamma * U_t[5]) / norm456fin)
        fra_t[6] = varphi * fra_l[6] + (1.0 - varphi) * (exp(gamma * U_t[6]) / norm456fin)
    end

    return (ypr_t, ADA_t, U_t, fra_t, Omega, Phi, Sigma_eps)
end
