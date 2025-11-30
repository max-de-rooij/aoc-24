# Advent of Code - Day 1

function read_day1_input(file::String)
    left, right = open(file) do f
        lines = readlines(f) 
        data = zeros(Int, length(lines), 2)
        for (i, line) in enumerate(lines)
            data[i, :] = parse.(Int, split(line))
        end
        data[:,1], data[:,2]
    end
    return left, right
end

# Part 1
function day1_part1(inputfile::String)
    left, right = read_day1_input(inputfile)
    s = 0
    while !isempty(left)
        s += abs(popat!(left, argmin(left)) - popat!(right, argmin(right)))
    end
    return s
end

# Part 2
function day1_part2(inputfile::String)
    left, right = read_day1_input(inputfile)

    s = 0
    for number in unique(left)
        s += count(x -> x == number, right) * number
    end
    return s
end

inputfile = "inputs/day-1.txt"

println("The answer to part 1 is: ", day1_part1(inputfile))
println("The answer to part 2 is: ", day1_part2(inputfile))