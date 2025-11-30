struct Antenna
    id::Char
    row::Int
    col::Int
end

struct Antinode
    row::Int
    col::Int
end

function get_antinodes!(positions, a::Antenna, b::Antenna, size::Tuple{Int, Int})

    antinodes = Antinode[]
    if a.id == b.id

        # find the difference in rows and columns
        r = a.row - b.row
        c = a.col - b.col

        if (1 <= b.row-r <= size[1]) && (1 <= b.col-c <= size[2])
            position = (b.row-r, b.col-c)
            if !(position in positions)
                push!(antinodes, Antinode(b.row-r, b.col-c))
                push!(positions, position)
            end
        end
        if (1 <= a.row+r <= size[1]) && (1 <= a.col+c <= size[2])
            position = (a.row+r, a.col+c)
            if !(position in positions)
                push!(antinodes, Antinode(a.row+r, a.col+c))
                push!(positions, position)
            end
        end
    end

    return antinodes
end

function get_repeat_antinodes!(antinodes::Vector{Antinode}, a::Antenna, b::Antenna, size::Tuple{Int, Int})

    if a.id == b.id

        # find the difference in rows and columns
        r = a.row - b.row
        c = a.col - b.col

        position = (a.row, a.col)
        while (1 <= position[1] <= size[1]) && (1 <= position[2] <= size[2])
            antinode = Antinode(position[1], position[2])
            if !(antinode in antinodes)
                push!(antinodes, antinode)
            end
            position = position .- (r, c)
        end

        position = (b.row, b.col)

        while (1 <= position[1] <= size[1]) && (1 <= position[2] <= size[2])
            antinode = Antinode(position[1], position[2])
            if !(antinode in antinodes)
                push!(antinodes, antinode)
            end
            position = position .+ (r, c)
        end
    end
end

function get_all_antinodes(input_lines)

    size = (length(input_lines), length(input_lines[1]))

    positions = Tuple{Int,Int}[]
    antennas = Antenna[]
    for (i,line) in enumerate(input_lines)
        for (j,char) in enumerate(line)
            if char != '.'
                push!(antennas, Antenna(char, i, j))
            end
        end
    end

    antinodes = Antinode[]
    for i in eachindex(antennas)[1:end-1]
        for j in eachindex(antennas)[i+1:end]
            append!(antinodes, get_antinodes!(positions, antennas[i], antennas[j], size))
        end
    end

    return length(antinodes)
end

function get_all_repeat_antinodes(input_lines)

    size = (length(input_lines), length(input_lines[1]))

    antennas = Antenna[]
    for (i,line) in enumerate(input_lines)
        for (j,char) in enumerate(line)
            if char != '.'
                push!(antennas, Antenna(char, i, j))
            end
        end
    end

    antinodes = Antinode[]
    for i in eachindex(antennas)[1:end-1]
        for j in eachindex(antennas)[i+1:end]
            get_repeat_antinodes!(antinodes, antennas[i], antennas[j], size)
        end
    end

    return length(antinodes)
end

function day8_part1(input_file)
    open(input_file) do f
        get_all_antinodes(readlines(f))
    end
end

function day8_part2(input_file)
    open(input_file) do f
        get_all_repeat_antinodes(readlines(f))
    end
end

println("The answer to part 1 is: ", day8_part1("inputs/day-8.txt"))
println("The answer to part 2 is: ", day8_part2("inputs/day-8.txt"))