using JLD

"""
    save_results(foldername, estimates, loglikelihoods)

Save results at a given location.

# Arguments
- `foldername::String`: set of results
- `results`: location to store the set of results at
- `loglikelihoods`: initial indexing value
"""
function save_results(foldername::String, results::Dict)
    JLD.save(resultsdir(foldername, "results.jld"), "results", results)
end
