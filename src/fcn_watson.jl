using DrWatson

resultsdir(args...) = projectdir("results", args...)
configsdir(args...) = projectdir("configs", args...)


"""
    flushln(line)

Print line and flush standard output.

# Arguments
- `line::String`: string to push to the standard output
"""
function flushln(line::String)
    println(line)
    flush(stdout)
end

