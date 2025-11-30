function check_signs(difference::Vector{T}) where T<:Int
    abs(sum(sign, difference)) == length(difference)
end

function check_magnitude(difference::T) where T<:Int
    T(1) <= abs(difference) <= T(3)
end

function check_magnitude(difference::Vector{T}) where T<:Int
    map(check_magnitude, difference) |> all
end

function run_checks(difference::Vector{T}) where T<:Int
    check_signs(difference) && check_magnitude(difference)
end

function check_safety(levels::Vector{T}) where T<:Int
    d = diff(levels)

    run_checks(d) || return 0

    return 1
end

function check_safety(levels::Vector{T}, dampener::Function) where T<:Int
    d = diff(levels)

    run_checks(d) || return dampener(levels)

    # dampen the levels
    return 1
end

function dampen(levels::Vector{T}) where T<:Int
    # remove one level and check if the remaining levels are safe
    safety = 0
    i = 1
    while safety == 0 && i <= length(levels)
        safety = check_safety([levels[1:i-1]; levels[i+1:end]])
        i += 1
    end
    return safety
end

inputfile = "inputs/day-2.txt"

# Part 1
function day2_part1(inputfile::String)
    result = open(inputfile) do f
        lines = readlines(f)
        safe = 0 
        for line in lines
            levels = parse.(Int, split(line))
            safe += check_safety(levels)
        end
        safe
    end
    return result
end

println("The answer to part 1 is: ", day2_part1(inputfile))

# Part 2
function day2_part2(inputfile::String)
    result = open(inputfile) do f
        lines = readlines(f)
        safe = 0 
        for line in lines
            levels = parse.(Int, split(line))
            safe += check_safety(levels, dampen)
        end
        safe
    end
    return result
end

println("The answer to part 2 is: ", day2_part2(inputfile))