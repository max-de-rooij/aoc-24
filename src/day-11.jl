

function blink(value::Int, blink_cache::Dict{Int, Tuple{Int, Int}})
    if haskey(blink_cache, value)
        return blink_cache[value]
    end

    if value == 0
        blink_cache[value] = (1, -1)
        return 1, -1
    elseif iseven(ndigits(value))
        blink_cache[value] = (value ÷ 10^(ndigits(value) ÷ 2), value % 10^(ndigits(value) ÷ 2))
        return value ÷ 10^(ndigits(value) ÷ 2), value % 10^(ndigits(value) ÷ 2)
    else
        blink_cache[value] = (value * 2024, -1)
        return value * 2024, -1
    end
end

function count_stone_blinks(value::Int, depth::Int, 
    blink_cache::Dict{Int, Tuple{Int, Int}}, 
    count_stone_blinks_cache::Dict{Tuple{Int, Int}, Int})

    if haskey(count_stone_blinks_cache, (value, depth))
        return count_stone_blinks_cache[(value, depth)]
    end

    left, right = blink(value, blink_cache)
    if depth == 1
        if right == -1
            count_stone_blinks_cache[(value, depth)] = 1
            return 1
        else
            count_stone_blinks_cache[(value, depth)] = 2
            return 2
        end
    else
        output = count_stone_blinks(left, depth - 1, blink_cache, count_stone_blinks_cache)

        if right != -1
            output += count_stone_blinks(right, depth - 1, blink_cache, count_stone_blinks_cache)
        end

        count_stone_blinks_cache[(value, depth)] = output
        return output
    end
end

function count_stones(stones::Vector{Int}, depth::Int, 
    blink_cache::Dict{Int, Tuple{Int, Int}},
    count_stone_blinks_cache::Dict{Tuple{Int, Int}, Int})

    count = 0
    for stone in stones
        count += count_stone_blinks(stone, depth, blink_cache, count_stone_blinks_cache)
    end
    count
end

function day11_part1(input_file::String)
    result = open(input_file) do f
        stones = parse.(Int, split(read(f, String)))
        blink_cache = Dict{Int, Tuple{Int, Int}}()
        count_stone_blinks_cache = Dict{Tuple{Int, Int}, Int}()
        count_stones(stones, 25, blink_cache, count_stone_blinks_cache)
    end
    return result
end

function day11_part2(input_file::String)
    result = open(input_file) do f
        stones = parse.(Int, split(read(f, String)))
        blink_cache = Dict{Int, Tuple{Int, Int}}()
        count_stone_blinks_cache = Dict{Tuple{Int, Int}, Int}()
        count_stones(stones, 75, blink_cache, count_stone_blinks_cache)
    end
    return result
end

println("The solution to part 1 is: $(day11_part1("inputs/day-11.txt"))")
println("The solution to part 2 is: $(day11_part2("inputs/day-11.txt"))")
# day11_part2("inputs/day-11.txt")



