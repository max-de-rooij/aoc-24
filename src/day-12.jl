mutable struct Region
    perimeter::Int
    area::Int
    sides::Int
end

function cost(region::Region)
    return region.area * region.perimeter
end

function bulk_cost(region::Region)
    return region.area * region.sides
end

function read_map(text_input)
    lines = split(text_input, '\n')
    mat = Matrix{Char}(undef, length(lines), length(lines[1]))
    positions = Tuple{Int, Int}[]
    for (i,line) in enumerate(lines)
        for (j,item) in enumerate(line)
            mat[i,j] = item
            push!(positions, (i,j))
        end
    end
    return mat, positions
end

function is_corner(diagonal::Tuple{Int, Int}, current_position::Tuple{Int, Int}, plant_map::Matrix{Char})

    outside_mat = !(0 < diagonal[1] <= size(plant_map,1) && 0 < diagonal[2] <= size(plant_map,2))

    if outside_mat || (plant_map[diagonal[1], diagonal[2]] != plant_map[current_position[1], current_position[2]])
        check_col = !(0 < diagonal[1] <= size(plant_map,1)) || plant_map[diagonal[1], current_position[2]] != plant_map[current_position[1], current_position[2]]
        check_row = !(0 < diagonal[2] <= size(plant_map, 2)) || plant_map[current_position[1], diagonal[2]] != plant_map[current_position[1], current_position[2]]
        return (check_col && check_row) || (!check_col && !check_row)
    elseif plant_map[diagonal[1], diagonal[2]] == plant_map[current_position[1], current_position[2]]
        check_row = plant_map[diagonal[1], current_position[2]] != plant_map[current_position[1], current_position[2]]
        check_col = plant_map[current_position[1], diagonal[2]] != plant_map[current_position[1], current_position[2]]
        return check_row && check_col
    end
    return false
end

function count_corners(current_position::Tuple{Int, Int}, plant_map::Matrix{Char})
    row, col = current_position
    corners = 0

    for diagonal in [(row+1, col+1), (row-1, col-1), (row+1, col-1), (row-1, col+1)]
        if is_corner(diagonal, current_position, plant_map)
            corners += 1
        end
    end
    return corners
end

function search!(region::Region, current_position::Tuple{Int, Int}, 
    neighbors::Vector{Tuple{Int, Int}}, positions::Vector{Tuple{Int,Int}}, plant_map::Matrix{Char})

    region.area += 1
    perimeter = 0
    row, col = current_position

    for position in [(row-1, col), (row+1,col), (row, col-1), (row, col+1)]
        if 0 < position[1] <= size(plant_map, 1) && 0 < position[2] <= size(plant_map, 2)
            if plant_map[position[1], position[2]] == plant_map[current_position[1], current_position[2]]
                if position in positions
                    positions = filter!(x -> x != position, positions)
                    push!(neighbors, position)
                end
            else
                perimeter += 1
            end
        else
            perimeter += 1
        end
    end
    region.perimeter += perimeter
end

function find_regions(plant_map, positions)
    regions = Region[]
    while !isempty(positions)
        region = Region(0, 0, 0)
        current_position = popfirst!(positions)
        neighbors = Tuple{Int, Int}[]
        search!(region, current_position, neighbors, positions, plant_map)
        region.sides += count_corners(current_position, plant_map)
        while !isempty(neighbors)
            neighbor = popfirst!(neighbors)
            region.sides += count_corners(neighbor, plant_map)
            search!(region, neighbor, neighbors, positions, plant_map)
        end
        push!(regions, region)
    end
    return regions
end

function day12_part1(input_file)
    open(input_file) do f
        plant_map, positions = read_map(read(f, String))
        regions = find_regions(plant_map, positions)
        sum(cost, regions)
    end
end

function day12_part2(input_file)
    open(input_file) do f
        plant_map, positions = read_map(read(f, String))
        regions = find_regions(plant_map, positions)
        sum(bulk_cost, regions)
    end
end

println("The solution to part 1 is: $(day12_part1("inputs/day-12.txt"))")
println("The solution to part 2 is: $(day12_part2("inputs/day-12.txt"))")