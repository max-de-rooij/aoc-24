@enum Direction N E S W
@enum Turn L R

struct Position
    row::Int
    col::Int
    direction::Direction
end

function turn(direction::Direction, towards::Turn)
    return Direction(mod(Int(direction) + (towards == L ? -1 : 1), 4))
end

function coordinates(direction::Direction)
    return [
        (0, 1),  # N
        (1, 0),  # E
        (0, -1), # S
        (-1, 0)  # W
    ][Int(direction)+1]
end

function has_same_location(a::Position, b::Position)
    return a.row == b.row && a.col == b.col
end

function get_neighbors(position::Position)
    return [
        Position(position.row + coordinates(position.direction)[1], position.col + coordinates(position.direction)[2], position.direction),
        Position(position.row, position.col, turn(position.direction, L)),
        Position(position.row, position.col, turn(position.direction, R))
    ]
end

function dijkstra(maze::Vector{String}, height::Int)
    distance = Dict{Position, Int}()
    visited = Dict{Position, Bool}()
    previous = Dict{Position, Vector{Position}}()

    distance[Position(2, height - 1, E)] = 0
    previous[Position(2, height - 1, E)] = Position[]

    queue = [Position(2, height - 1, E)]

    while !isempty(queue)

        current = popfirst!(queue)
        neighbors = get_neighbors(current)
        sort!(neighbors, by = x -> get(distance, x, typemax(Int)))
        for nb in neighbors
            if get(visited, nb, false) || maze[nb.col][nb.row] == '#'
                continue
            end
            if nb ∉ queue && maze[nb.col][nb.row] != 'E'
                push!(queue, nb)
            end
            d = get(distance, current, typemax(Int))
            if has_same_location(current, nb)
                d += 1000
            else
                d += 1
            end
            if d < get(distance, nb, typemax(Int))
                distance[nb] = d
                previous[nb] = [current]
            elseif d == get(distance, nb, typemax(Int))
                push!(previous[nb], current)
            end
        end
        visited[current] = true
        sort!(queue, by = x -> get(distance, x, typemax(Int)))
    end

    return distance, previous
end

function find_tiles(distance::Dict{Position, Int}, previous::Dict{Position, Vector{Position}}, width::Int)
    end_1 = Position(width - 1, 2, E)
    end_2 = Position(width - 1, 2, N)

    end_dist_1 = get(distance, end_1, typemax(Int))
    end_dist_2 = get(distance, end_2, typemax(Int))

    queue = Position[]
    if end_dist_1 <= end_dist_2
        push!(queue, end_1)
    end
    if end_dist_1 >= end_dist_2
        push!(queue, end_2)
    end

    tiles = Set{Tuple{Int, Int}}()
    while !isempty(queue)
        current = popfirst!(queue)
        push!(tiles, (current.row, current.col))
        for v in get(previous, current, Position[])
            push!(queue, v)
        end
    end

    return tiles
end

function day16_part1(input::String)
    result = open(input) do file
        maze = readlines(file)
        height = length(maze)
        width = length(maze[1])

        dist, _ = dijkstra(maze, height)
        score1 = get(dist, Position(width - 1, 2, E), typemax(Int))
        score2 = get(dist, Position(width - 1, 2, N), typemax(Int))

        min(score1, score2)
    end
    return result
end

function day16_part2(input::String)

    result = open(input) do file
        maze = readlines(file)
        height = length(maze)
        width = length(maze[1])

        dist, prev = dijkstra(maze, height)
        tiles = find_tiles(dist, prev, width)

        length(tiles)
    end
    return result
end

println("The solution to part 1 is: $(day16_part1("inputs/day-16.txt"))")
println("The solution to part 2 is: $(day16_part2("inputs/day-16.txt"))")