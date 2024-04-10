using DrWatson, Pkg
@quickactivate "Kukacka_Sacht_2022"
Pkg.instantiate()

include(srcdir("fcn_initialization.jl"))

parsed_args = parse_commandline()
setup = load_setup(parsed_args)

include(srcdir("fcn_estimation.jl"))

flushln("Executing experiment with ID \"$(parsed_args["experiment"])\" using $(parsed_args["procs"]) workers!")

@time begin
    results = estimate(setup) # initiliase estimation
end