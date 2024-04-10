using ArgParse, YAML, Dates

include("fcn_watson.jl")

"""
    parse_commandline()

Parse command line arguments.

# Returns
- `parsed_args::Dict`: parsed command line arguments
"""
function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--procs", "-p"
            help = "number of processes"
            arg_type = Int
            required = true
        "--experiment", "-e"
            help = "name of experiment"
            arg_type = String
            required = true
    end

    parsed_args = parse_args(s)

    return parsed_args
end


"""
    merge_recursive(orig, new)

Merge two dictionaries recursively.

# Arguments
- `orig::Dict`: original dictionary
- `new::Dict`: new dictionary
"""
function merge_recursive(orig::Dict, new::Dict)
    for key in keys(new)
        if !isa(new[key], Dict)
            orig[key] = new[key]
        else
            merge_recursive(orig[key], new[key])
        end
    end
end


"""
    create_folder(experiment::String)

Create a new experiment folder and return its name.

# Arguments
- `experiment::String`: name of the experiment

# Returns
- `foldername::String`: name of the experiment folder
"""
function create_folder(experiment::String)
    ts = replace(string(Dates.now()), r"\..*" => "") # generate timestamp
    foldername = "$(experiment)_$(ts)" # generate folder name
    mkdir(resultsdir(foldername)) # create experiment folder

    return foldername
end


"""
    load_setup(parsed_args)

Load parameters for the selected experiment.
    
# Arguments
- `parsed_args::Dict`: parsed command line arguments

# Returns
- `setup::Dict`: full setup dictionary
- `foldername::String`: name of the folder to store results
"""
function load_setup(parsed_args::Dict)
    experiment = parsed_args["experiment"] # retrieve experiment name 

    setup = YAML.load_file(configsdir("default.yaml")) # load default parameters
    setup_experiment = YAML.load_file(configsdir("$(experiment).yaml")) # load experiment-specific parameters

    merge_recursive(setup, setup_experiment) # merge default and experiment-specific parameters

    foldername = create_folder(experiment) # generate experiment folder
    YAML.write_file(resultsdir("$(foldername)", "setup.yaml"), setup) # save parameter setup to experiment folder

    setup["foldername"] = foldername # store foldername in the setup dictionary

    return setup
end
