mutable struct Guard
    position::Tuple{Int, Int}
    direction::Tuple{Int, Int}
end

struct Map
    obstacles::Set{Tuple{Int, Int}}
    guard::Guard
    size::Tuple{Int, Int}
end

test = """....#.....
.........#
..........
..#.......
.......#..
..........
.#..^.....
........#.
#.........
......#..."""

test_lines = split(test, "\n")
function Map(lines)
    obstacles = Set{Tuple{Int, Int}}()
    guard = Guard((0,0), (0,0))
    size = (length(lines), length(lines[1]))
    for (i, line) in enumerate(lines)
        for (j, char) in enumerate(line)
            if char == '#'
                push!(obstacles, (i, j))
            elseif char == '^'
                guard.position = (i, j)
                guard.direction = (-1, 0)
            elseif char == 'v'
                guard.position = (i, j)
                guard.direction = (1, 0)
            elseif char == '<'
                guard.position = (i, j)
                guard.direction = (0, -1)
            elseif char == '>'
                guard.position = (i, j)
                guard.direction = (0, 1)
            end
        end
    end
    return Map(obstacles, guard, size)
end

function guard_walks_off_edge(map::Map)
    new_position = map.guard.position .+ map.guard.direction
    return new_position[1] < 1 || new_position[1] > map.size[1] || new_position[2] < 1 || new_position[2] > map.size[2]
end

function walk!(map::Map)

    occupied = Set{Tuple{Int,Int}}()
    push!(occupied, map.guard.position)
    new_position = map.guard.position .+ map.guard.direction
    # look ahead to see if there is an obstacle
    while !guard_walks_off_edge(map)
        if new_position in map.obstacles
            # turn right
            map.guard.direction = (map.guard.direction[2], -map.guard.direction[1])
        else
            map.guard.position = new_position
            push!(occupied, new_position)
        end
        new_position = map.guard.position .+ map.guard.direction
    end

    return occupied
end

function day6_part1(file)

    occupied = open(file) do f
        lines = readlines(f)
        map = Map(lines)
        length(walk!(map))
    end

    return occupied
end

day6_part1("inputs/day-6.txt")

function check_infinite_loop!(map::Map)

    occupied = Set{Tuple{Tuple{Int,Int}, Tuple{Int,Int}}}()
    push!(occupied, (map.guard.position, map.guard.direction))
    new_position = map.guard.position .+ map.guard.direction
    # look ahead to see if there is an obstacle
    while !guard_walks_off_edge(map) && !((new_position, map.guard.direction) in occupied)
        if new_position in map.obstacles
            # turn right
            map.guard.direction = (map.guard.direction[2], -map.guard.direction[1])
        else
            map.guard.position = new_position
            push!(occupied, (new_position, map.guard.direction))
        end
        new_position = map.guard.position .+ map.guard.direction
    end

    return (new_position, map.guard.direction) in occupied
end

function empty_spaces(map::Map)
    return Set{Tuple{Int,Int}}(x for x in Iterators.product(1:map.size[1], 1:map.size[2]) if !(x ∈ map.obstacles) && !(x == map.guard.position))
end

function day6_part2(file)

    possibilities = open(file) do f
        lines = readlines(f)
        initial_map = Map(lines)
        possibilities = 0
        for space in empty_spaces(initial_map)
            obstacles = copy(initial_map.obstacles)
            push!(obstacles, space)
            map = Map(
                obstacles,
                Guard(initial_map.guard.position, initial_map.guard.direction),
                initial_map.size
            )
            if check_infinite_loop!(map)
                possibilities += 1
            end
        end
        possibilities
    end

    return possibilities
end

println("The answer to part 1 is: ", day6_part1("inputs/day-6.txt"))
println("The answer to part 2 is: ", day6_part2("inputs/day-6.txt"))

