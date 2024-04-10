using LaTeXStrings

function fcn_par(setup::Dict)
    type = setup["mod"]["model"]

    # order of parameters: (chi), tau; (alpha), kappa; (phi_r), phi_y, phi_pi; sigma_y, sigma_pi, sigma_r; [eta_y, iota_y, mu_y, eta_pi, iota_pi, mu_pi; rho, varphi, gamma]
    # () ... not included in the BR forward-looking model, [] ... not included in the RE hybrid model

    brf_hom_all = Dict{}(
        "vers" => "brf",
        # order of parameters: tau, kappa, phi_y, phi_pi, sigma_y, sigma_pi, sigma_r, eta_y, iota_y, mu_y, eta_pi, iota_pi, mu_pi, rho, varphi, gamma
        "cali" => Dict{}(
            "jb2efb" => [0.371; 0.213; 0.709; 1.914; 0.543; 0.240; 0.151; 0.65; 0.85; 0.5; 0.65; 0.85; 0.5; 0.7; 0.9; 1.0],
            "van01sd" => [0.2; 0.3; 0.5; 1.5; 0.1; 0.1; 0.1; 0.65; 0.85; 0.5; 0.65; 0.85; 0.5; 0.7; 0.9; 1.0],
        ),
        "cons" => Dict{}(
            "bas" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (1.0, 3.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 5.0)],
            "ph0" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 3.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 10.0)],
        ),
        "ifra" => 1/3,
        "kappa_idx" => 2,
    )

    brf_hom_trN = Dict{}(
        "vers" => "brf",
        # order of parameters: tau, kappa, phi_y, phi_pi, eta, iota, mu, gamma
        "cali" => Dict{}(
            "jb2efb" => [0.371; 0.213; 0.709; 1.914; 0.65; 0.85; 0.5; 1.0], # Table 1, BR NKM + Table 2, BR NKM, All
            "van01sd" => [0.2; 0.3; 0.5; 1.5; 0.65; 0.85; 0.5; 1.0],
        ),
        "cons" => Dict{}(
            "bas" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (1.0, 3.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 5.0)],
            "ph0" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 3.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 10.0)],
        ),
        "ifra" => 1/3,
        "kappa_idx" => 2,
    )

    brf_hom_trK = Dict{}(
        "vers" => "brf",
        # order of parameters: phi_y, phi_pi, eta, iota, mu, gamma
        "cali" => Dict{}(
            "jb2efb" => [0.709; 1.914; 0.65; 0.85; 0.5; 1.0], # Table 2, BR NKM, B
            "jb2efbtau02kap005" => [0.709; 1.914; 0.65; 0.85; 0.5; 1.0], # Table 2, BR NKM, C
            "van01sd" => [0.5; 1.5; 0.65; 0.85; 0.5; 1.0],
        ),
        "cons" => Dict{}(
            "bas" => [(0.0, 1.0), (1.0, 3.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 5.0)],
            "ph0" => [(0.0, 1.0), (0.0, 3.0), (0.0, 1.0), (0.0, 2.0), (0.0, 1.0), (0.0, 10.0)],
        ),
        "ifra" => 1/3,
        "kappa_idx" => 0,
    )

    reh_hom_all = Dict{}(
        "vers" => "reh",
        # order of parameters: chi, tau, alpha, kappa, phi_r, phi_y, phi_pi, sigma_y, sigma_pi, sigma_r
        "cali" => Dict{}(
            "jb2efb" => [0.5; 0.371; 0.5; 0.213; 0.808; 0.709; 1.914; 0.543; 0.240; 0.151],
            "van01sd" => [0.5; 0.2; 0.5; 0.3; 0.5; 0.5; 1.5; 0.1; 0.1; 0.1],
        ),
        "cons" => Dict{}(
            "bas" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (1.0, 3.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0)],
            "ph0" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 3.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0)],
        ),
        "ifra" => 1/3,
        "kappa_idx" => 4,
    )

    reh_hom_alN = Dict{}(
        "vers" => "reh",
        # order of parameters: chi, tau, alpha, kappa, phi_r, phi_y, phi_pi
        "cali" => Dict{}(
            "jb2efb" => [0.5; 0.371; 0.5; 0.213; 0.808; 0.709; 1.914],
            "van01sd" => [0.5; 0.2; 0.5; 0.3; 0.5; 0.5; 1.5], # Table 1, Hybrid RE NKM + Table 2, Hybrid RE NKM, All
        ),
        "cons" => Dict{}(
            "bas" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (1.0, 3.0)],
            "ph0" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 3.0)],
        ),
        "ifra" => 1/3,
        "kappa_idx" => 4,
    )

    reh_hom_alC = Dict{}(
        "vers" => "reh",
        # order of parameters: chi, tau, alpha, phi_r, phi_y, phi_pi
        "cali" => Dict{}(
            "jb2efb1" => [0.5; 0.371; 0.5; 0.808; 0.709; 1.914], # Table 2, Hybrid RE NKM, D
        ),
        "cons" => Dict{}(
            "bas" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (1.0, 3.0)],
            "ph0" => [(0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 1.0), (0.0, 3.0)],
        ),
        "ifra" => 1/3,
        "kappa_idx" => 0,
    )

    models = Dict{}(
        "brf_hom_all" => brf_hom_all,
        "brf_hom_trN" => brf_hom_trN,
        "brf_hom_trK" => brf_hom_trK,
        "reh_hom_all" => reh_hom_all,
        "reh_hom_alN" => reh_hom_alN,
        "reh_hom_alC" => reh_hom_alC,
    )

   if type in keys(models)
       return(models[type])
   else
       error("There is no model \"$type\" defined in the model dictionary!")
   end
end

function fcn_nos(setup::Dict)
    cali = setup["mod"]["cali"]

    jb2efb = Dict{}(
        "tau" => 0.371,
        "kappa" => 0.213,
        "phi_y" => 0.709,
        "sig_y" => 0.543,
        "sig_p" => 0.240,
        "sig_r" => 0.151,
        "gamma" => 1.0,
    )

    # only for reh_hom_alC
    jb2efb1 = Dict{}(
        "chi" => 1.0,
        "kappa" => 0.030,
        "sig_y" => 0.543,
        "sig_p" => 0.240,
        "sig_r" => 0.151,
    )

    jb2efbtau02kap005 = Dict{}(
        "tau" => 0.2,
        "kappa" => 0.05,
        "sig_y" => 0.543,
        "sig_p" => 0.240,
        "sig_r" => 0.151,
    )
    
    van01sd = Dict{}(
        "tau" => 0.2,
        "kappa" => 0.3,
        "sig_y" => 0.1,
        "sig_p" => 0.1,
        "sig_r" => 0.1,
        "gamma" => 1.0,
    )

    calibrations = Dict{}(
        "jb2efb" => jb2efb,
        "jb2efb1" => jb2efb1,
        "jb2efbtau02kap005" => jb2efbtau02kap005,
        "van01sd" => van01sd,
    )

    if cali in keys(calibrations)
        return(calibrations[cali])
    else
        error("There is no calibration \"$cali\" defined in the calibration dictionary.")
    end
end
