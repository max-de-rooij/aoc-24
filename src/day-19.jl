test_input="""r, wr, b, g, bwu, rb, gb, br

brwrr
bggr
gbbr
rrbgbr
ubwu
bwurrg
brgr
bbrgwb"""

function check_pattern(pattern, towels)
    
    if length(pattern) == 0 || any(pattern .== towels)
        return true
    end

    for towel in towels
        if length(towel) <= length(pattern) && towel == pattern[1:length(towel)]
            if check_pattern(pattern[length(towel)+1:end], towels)
                return true
            end
        end 
    end
    return false
end

function count_possibilities(pattern, towels, memory)
    if length(pattern) == 0
        return 1
    end

    if pattern in keys(memory)
        return memory[pattern]
    end

    count = 0
    for i in 1:maximum(length.(towels))
        if i <= length(pattern) && pattern[1:i] in towels
            count += count_possibilities(pattern[i+1:end], towels, memory)
        end
    end
    memory[pattern] = count
    return count
end

function parse_input(file)
    towels = String.(strip.(split(readline(file), ',')))
    readline(file)
    patterns = String.(split(read(file, String), "\n"))
    towels, patterns
end 

function read_input(input)
    towels, patterns = open(input) do file
        parse_input(file)
    end
    return towels, patterns
end

function day19_part1(input)
    towels, patterns = read_input(input)
    count = 0
    for pattern in patterns
        if check_pattern(pattern, towels)
            count += 1
        end
    end

    return count
end

function day19_part2(input)
    towels, patterns = read_input(input)
    count = 0
    memory = Dict{String, Int}()
    for pattern in patterns
        count += count_possibilities(pattern, towels, memory)
    end

    return count
end

day19_part1("inputs/day-19.txt")
day19_part2("inputs/day-19.txt")


