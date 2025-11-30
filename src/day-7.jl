function grow(root::Int, child::Int)
    return [root + child, root * child]
end

function grow(root::Vector{Int}, child::Int)
    return [root .+ child; root .* child]
end

function conc(a, b)
    a * 10^ndigits(b) + b
end

function grow_p2(root::Int, child::Int)
    return [root + child, root * child, conc(root, child)]
end

function grow_p2(root::Vector{Int}, child::Int)
    return [root .+ child; root .* child; conc.(root, child)]
end

function traverse(order::Vector{Int}, func::Function)

    root = popfirst!(order)
    if isempty(order)
        return [root]
    end

    child = popfirst!(order)
    possibilities = func(root, child)
    while !isempty(order)
        child = popfirst!(order)
        possibilities = func(possibilities, child)
    end

    return possibilities
end

function check_line_part1(line::String)
    pattern = r"(\d+): (.*)"
    m = match(pattern, line)
    target = parse(Int, m.captures[1])
    order = parse.(Int, split(m.captures[2], " "))
    return any(x -> x == target, traverse(order, grow))*target
end

function check_line_part2(line::String)
    pattern = r"(\d+): (.*)"
    m = match(pattern, line)
    target = parse(Int, m.captures[1])
    order = parse.(Int, split(m.captures[2], " "))
    return any(x -> x == target, traverse(order, grow_p2))*target
end

function day7_part1(file::String)
    return open(file) do f
        lines = readlines(f)
        sum(check_line_part1, lines)
    end
end

function day7_part2(file::String)
    return open(file) do f
        lines = readlines(f)
        sum(check_line_part2, lines)
    end
end


println("The answer to part 1 is: ", day7_part1("inputs/day-7.txt"))
println("The answer to part 2 is: ", day7_part2("inputs/day-7.txt"))
