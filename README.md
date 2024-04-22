# Estimation of heuristic switching in behavioral macroeconomic models

This repository contains the official implementation of [Estimation of heuristic switching in behavioral macroeconomic models](https://doi.org/10.1016/j.jedc.2022.104585) by [Jiri Kukacka](mailto:jiri.kukacka@fsv.cuni.cz) and [Stephen Sacht](mailto:sacht@economics.uni-kiel.de).

If you find our work useful, we encourage you to use the following citation:
```
@article{kukackasacht2023,
    title = {Estimation of heuristic switching in behavioral macroeconomic models},
    author = {Jiri Kukacka and Stephen Sacht},
    journal = {Journal of Economic Dynamics and Control},
    volume = {146},
    pages = {104585},
    year = {2023},
    issn = {0165-1889},
    doi = {https://doi.org/10.1016/j.jedc.2022.104585},
    url = {https://www.sciencedirect.com/science/article/pii/S0165188922002883}
}
```

## Requirements

To download the content of the repository and move to the root directory, run:
```
git clone git@github.com:jirikukacka/Kukacka_Sacht_2022.git
cd Kukacka_Sacht_2022/
```

To install [DrWatson](https://juliadynamics.github.io/DrWatson.jl/dev/), run [Julia](https://julialang.org/) and execute:
```
julia> using Pkg
julia> Pkg.add("DrWatson")
```

To install the required packages, run [Julia](https://julialang.org/) (>= 1.6.1) in the root directory and execute:
```
julia> using Pkg
julia> Pkg.activate(pwd())
julia> Pkg.instantiate()
```

## Data

Empirical data used for empirical estimation are located in the `data/` folder.

## Reproduction

The repository contains all the code needed to reproduce simulated maximum likelihood experiments from the paper. Small discrepancies between the reported and reproduced results may be expected due to different seeding.

In order to set parameters for an experiment, create a new `.yaml` configuration file in the `configs/` directory and set parameters following the default configuration file at `configs/default.yaml`. Any and all parameters that remain unset in the new configuration file are retrieved from the default configuration file. An example of a configuration set-up trivializing the computation such that it can be run on a personal computer can be found at `configs/trivial.yaml`.

The program requires two command line parameters `--procs` (or `-p`) defining the number of workers to initialize, which should correspond to the number of CPU cores that you wish to parallelize the estimation procedure over, and `--experiment` (or `-e`) defining the experiment to be computed, which must correspond to the name of the configuration file.

For example, to run the `trivial.yaml` experiment using two workers, one must execute:
```
julia scripts/main.jl --experiment trivial --procs 2
```

### Table 1

Results found in Table 1 of our paper have the following configuration parameters in common:

| Parameter | Value |
|:--------- |:----- |
| `est.data` | `null` |
| `mod.cons` | `"bas"` |
| `opt.optimizer` | `"opt"` |
| `opt.sim` | `1000` |
| `opt.iter` | `40` |

Here, the most important configuration parameters that differ across columns can be identified for results found in Table 1:

| Column | `mod.obs` | `mod.model` | `mod.cali` |
|:------ |:----------:|:---------:|:-----------:|
| BR NKM, T=250 | `250` | `"brf_hom_trN"` | `"jb2efb"` |
| BR NKM, T=500 | `500` | `"brf_hom_trN"` | `"jb2efb"` |
| BR NKM, T=5000 | `5000` | `"brf_hom_trN"` | `"jb2efb"` |
| Hybrid RE NKM, T=250 | `250` | `"reh_hom_alN"` | `"van01sd"` |
| Hybrid RE NKM, T=500 | `500` | `"reh_hom_alN"` | `"van01sd"` |
| Hybrid RE NKM, T=5000 | `5000` | `"reh_hom_alN"` | `"van01sd"` |

Here, the corresponding configurations from the `configs/` directory can be located for results found in Table 1:

| Column | Experiment |
|:------ |:----------- |
| BR NKM, T=250 | `sim_brf_hom_trN_250` |
| BR NKM, T=500 | `sim_brf_hom_trN_500` |
| BR NKM, T=5000 | `sim_brf_hom_trN_5000` |
| Hybrid RE NKM, T=250 | `sim_reh_hom_alN_250` |
| Hybrid RE NKM, T=500 | `sim_reh_hom_alN_500` |
| Hybrid RE NKM, T=5000 | `sim_reh_hom_alN_5000` |

### Table 2

Results found in Table 2 of our paper have the following configuration parameters in common:

| Parameter | Value |
|:--------- |:----- |
| `est.data` | `"Data_US_all.jld"` |
| `mod.cons` | `"ph0"` |
| `opt.sim` | `2000` |

Here, the most important configuration parameters can be identified for results found in Table 2 of our paper:

| Column |`mod.model` | `mod.cali` | `opt.optimizer` | `opt.iter` |
|:------ |:----------:|:----------:|:---------------:|:----------:|
| BR NKM, All | `"brf_hom_trN"` | `"jb2efb"` | `"opt"` | `40` |
| BR NKM, B | `"brf_hom_trK"` | `"jb2efb"` | `"opt"` | `40` |
| BR NKM, C | `"brf_hom_trK"` | `"jb2efbtau02kap005"` | `"opt"` | `40` |
| Hybrid RE NKM, All | `"reh_hom_alN"` | `"van01sd"` | `"bbo"` | `4000` |
| Hybrid RE NKM, D | `"reh_hom_alC"` | `"jb2efb1"` | `"bbo"` | `4000` |

## Results

In the `results/` directory, a new folder is created whenever the estimation procedure is executed. The new folder's name is composed of the experiment's name and the timestamp at the initialization of the estimation procedure. In this folder, the full configuration file and results file are stored.

## License

All content in the repository is licensed under the MIT license. More information can be found in the [license file](LICENSE).
