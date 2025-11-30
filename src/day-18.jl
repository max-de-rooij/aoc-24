



function get_neighbors(current, width, height)
    neighbors = Tuple{Int, Int}[]
    for (dc, dr) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
        new_col = current[1] + dc
        new_row = current[2] + dr
        if new_col > 0 && new_col <= width && new_row > 0 && new_row <= height
            push!(neighbors, (new_col, new_row))
        end
    end

    return neighbors
end

function dijkstra(width::Int, height::Int, bytes::Vector{Tuple{Int, Int}}, up_to::Int)
    distance = Dict{Tuple{Int, Int}, Int}()
    visited = Dict{Tuple{Int, Int}, Bool}()
    # previous = Dict{Position, Vector{Position}}()

    distance[(1, 1)] = 0
    # previous[Position(2, height - 1, E)] = Position[]

    queue = [(1, 1)]

    while !isempty(queue)

        current = popfirst!(queue)
        neighbors = get_neighbors(current, width, height)
        for nb in neighbors
            if get(visited, nb, false) || nb in bytes[1:up_to]
                continue
            end
            if nb ∉ queue && nb != (width, height)
                push!(queue, nb)
            end
            d = get(distance, current, typemax(Int))
            d += 1
            if d < get(distance, nb, typemax(Int))
                distance[nb] = d
            end
        end
        visited[current] = true
        sort!(queue, by = x -> get(distance, x, typemax(Int)))
    end

    return distance
end

function read_input(input)
    bytes = Tuple{Int, Int}[]
    open(input) do file
        for line in eachline(file)
            push!(bytes, Tuple(parse.(Int, match(r"(\d+),(\d+)", line).captures)) .+ 1)
        end
    end
    return bytes
end

function day18_part1(input)
    bytes = read_input(input)
    return dijkstra(71, 71, bytes, 1024)[(71, 71)]
end

function day18_part2(input)
    bytes = read_input(input)
    up_to = 1025
    while (71, 71) in keys(dijkstra(71, 71, bytes, up_to))
        up_to += 1
    end
    return bytes[up_to] .- 1
end

day18_part1("inputs/day-18.txt")
day18_part2("inputs/day-18.txt")

