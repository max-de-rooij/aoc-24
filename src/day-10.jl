using LinearAlgebra, SparseArrays

function node_id(row, col, ncol)
    (row-1)*ncol + col
end

function construct_directed_graph(mat)

    adj = spzeros(Int, length(mat), length(mat))
    ncol = size(mat, 2)
    for j in axes(mat, 2)
        for i in axes(mat, 1)
            id = node_id(i, j, ncol)
            connections = neighbors((i,j), mat)
            for connection in connections
                connection_id = node_id(connection[1], connection[2], ncol)
                adj[id, connection_id] += 1
            end
        end
    end
    adj
end

function find_node_ids(mat, value)
    ids = Int[]
    for I in findall(mat .== value)
        push!(ids, node_id(I[1], I[2], size(mat, 2)))
    end
    ids
end
                
function neighbors((row, col), mat)
    n = Tuple{Int, Int}[]
    for position in [(row-1, col), (row+1,col), (row, col-1), (row, col+1)]
        if 0 < position[1] <= size(mat, 1) && 0 < position[2] <= size(mat, 2)
            if mat[position[1], position[2]] - mat[row, col] == 1
                push!(n, position)
            end
        end
    end
    return n
end

function neighbors!(ns, (row, col), mat)
    append!(ns, neighbors((row, col), mat))
end

function read_map(text_input)
    lines = split(text_input, '\n')
    mat = zeros(Int, length(lines), length(lines[1]))

    for (i,line) in enumerate(lines)
        for (j,item) in enumerate(line)
            mat[i,j] = parse(Int, item)
        end
    end
    return mat
end

function find_trailhead_scores(map_matrix::Matrix{Int})
    score = 0
    for trailhead in findall(map_matrix .== 0)
        ns = neighbors(Tuple(trailhead), map_matrix)
        tops = Tuple{Int, Int}[]
        while !isempty(ns)
            row, col = popfirst!(ns)
            if map_matrix[row, col] == 9
                push!(tops, (row,col))
            else
                neighbors!(ns, (row, col), map_matrix)
            end
        end
        score += length(unique(tops))
    end
    score
end

function day10_part1(file)

    result = open(file) do f
        map_matrix = read_map(read(f, String))
        find_trailhead_scores(map_matrix)
    end
    return result
end

function day10_part2(file)
    result = open(file) do f
        map_matrix = read_map(read(f, String))
        adj = construct_directed_graph(map_matrix)
        walks = adj^9
        starting_points = find_node_ids(map_matrix, 0)
        end_points = find_node_ids(map_matrix, 9)
        ratings = 0
        for spoint in starting_points
            for epoint in end_points
                ratings += walks[spoint, epoint]
            end
        end
        ratings
    end
return result
end

println("The solution to part 1 is: $(day10_part1("inputs/day-10.txt"))")
println("The solution to part 2 is: $(day10_part2("inputs/day-10.txt"))")
