# Advent of Code 2024 - Day 3


function multiply(m::RegexMatch{String})
    return parse(Int, m[1]) * parse(Int, m[2])
end

pattern = r"mul\((\d+),(\d+)\)"
inputfile = "inputs/day-3.txt"

function day3_part1(inputfile::String)
    open(inputfile) do f
        input_text = read(f, String)
        sum(map(multiply, eachmatch(pattern, input_text)))
    end
end

# Part 2
function get_pattern_indices(input_text::String, pattern::Regex)
    [x[end] for x in findall(pattern, input_text)]
end

function get_start_end_status(all_indices::Vector{Int}, statuses::Vector{Int})
    status = 1
    starts = [1]; ends = []
    for i in eachindex(all_indices)
        if statuses[i] != status
            if statuses[i] == 1
                push!(starts, all_indices[i])
            else
                push!(ends,  all_indices[i])
            end
        end
        status = statuses[i]
    end
    if length(starts) > length(ends)
        push!(ends, length(input_text))
    end
    return starts, ends
end

function day3_part2(inputfile::String)

    do_pattern = r"do\(\)"
    dont_pattern = r"don't\(\)"

    input_text = open(inputfile) do f
        read(f, String)
    end

    do_indices = get_pattern_indices(input_text, do_pattern)
    dont_indices = get_pattern_indices(input_text, dont_pattern)

    all_indices = sort([do_indices; dont_indices])
    statuses = [ones(Int,length(do_indices)); 2*ones(Int, length(dont_indices))][sortperm([do_indices; dont_indices])]

    starts, ends = get_start_end_status(all_indices, statuses)

    result = 0
    pattern = r"mul\((\d+),(\d+)\)"
    for (start, stop) in zip(starts, ends)
        result += sum(map(multiply, eachmatch(pattern, input_text[start:stop])))
    end

    return result
end

println("The answer to part 1 is: $(day3_part1(inputfile))")
println("The answer to part 2 is: $(day3_part2(inputfile))")
