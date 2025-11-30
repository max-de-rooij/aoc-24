# step 1; read the input
function read_input(input_str)
    walls = Tuple{Int, Int}[]
    start = (0, 0); goal = (0, 0)
    width = length(split(input_str, '\n')[1]); height = length(split(input_str, '\n'))
    for (j, line) in enumerate(split(input_str, '\n'))
        for (i, c) in enumerate(line)
            if c == '#'
                push!(walls, (i, j))
            elseif c == 'S'
                start = (i, j)
            elseif c == 'E'
                goal = (i, j)
            end
        end
    end
    return walls, start, goal, width, height
end

# step 2; find the route
function is_within_bounds(current, width, height)
    return current[1] > 0 && current[1] <= width && current[2] > 0 && current[2] <= height
end

function get_neighbors(current, walls, width, height)
    neighbors = Tuple{Int, Int}[]
    for (dc, dr) in [(0, 1), (0, -1), (1, 0), (-1, 0)]
        new_col = current[1] + dc
        new_row = current[2] + dr
        if (new_col, new_row) ∉ walls && is_within_bounds((new_col, new_row), width, height)
            push!(neighbors, (new_col, new_row))
        end
    end

    return neighbors
end

function get_route(start, goal, walls, width, height)
    route = Dict(start => 0)
    current = start
    while current != goal
        neighbors = get_neighbors(current, walls, width, height)
        for nb in neighbors
            if nb ∉ keys(route)
                route[nb] = route[current] + 1
                current = nb
            end
        end
    end
    return route
end

function evaluate_cheats(walls, route, width, height, minimum_win)
    
    cheats = Dict{Tuple{Tuple{Int, Int}, Tuple{Int, Int}}, Int}()

    for wall in walls

        # get neighbors
        neighbors = get_neighbors(wall, walls, width, height)

        if length(neighbors) >= 2
            route_locations = [get(route, nb, typemax(Int)) for nb in neighbors]
            picoseconds_won = maximum(route_locations) - minimum(route_locations) - 2
            if picoseconds_won >= minimum_win
                cheats[(wall, neighbors[argmax(route_locations)])] = picoseconds_won
            end
        end
    end

    return cheats
end

function manhattan_distance(p1, p2)
    return abs(p1[1] - p2[1]) + abs(p1[2] - p2[2])
end

function evaluate_multilength_cheat(walls, route, width, height, maximum_cheat_length, minimum_win)


    cheats = Dict{Tuple{Tuple{Int, Int}, Tuple{Int, Int}}, Int}()

    for (sp, route_location) in route
        for target in keys(route)
            distance = manhattan_distance(target, sp)
            if distance <= maximum_cheat_length
                picoseconds_won = get(route, target, 0) - route_location - distance
                if picoseconds_won >= minimum_win
                    current_win = get(cheats, (sp, target), 0)
                    cheats[(sp, target)] = max(current_win, picoseconds_won)
                end
            end
        end
    end

    return cheats
end

function day20_part1(input)
    result = open(input) do f
        walls, start, goal, width, height = read_input(read(f, String))
        route = get_route(start, goal, walls, width, height)
        minimum_win = 100
        evaluate_cheats(walls, route, width, height, minimum_win)
    end
    return result
end

function day20_part2(input)
    result = open(input) do f
        walls, start, goal, width, height = read_input(read(f, String))
        route = get_route(start, goal, walls, width, height)
        minimum_win = 100
        maximum_cheat_length = 20
        evaluate_multilength_cheat(walls, route, width, height, maximum_cheat_length, minimum_win)
    end
    return result
end

chts = day20_part2("inputs/day-20.txt")
