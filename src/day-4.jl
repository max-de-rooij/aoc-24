input_text = open("inputs/day-4.txt") do f
    readlines(f)
end

# construct arrays of horizontal, vertical, and diagonal lines
function day4_part1(input_text)
    horizontal = input_text 
    vertical = [join([x[i] for x in input_text]) for i in 1:length(input_text[1])]

    diagonals = []
    for i in eachindex(input_text)
        push!(diagonals, join([input_text[i+j-1][j] for j in 1:length(input_text)-i+1]))
        push!(diagonals, join([input_text[i+j-1][end-j+1] for j in 1:length(input_text)-i+1]))

        if i > 1
            push!(diagonals, join([input_text[j][i+j-1] for j in 1:length(input_text)-i+1]))
            push!(diagonals, join([input_text[j][end-(i-1+j)+1] for j in 1:length(input_text)-i+1]))
        end
    end
    
    sum(count("XMAS", st, overlap=false) for st in [horizontal; vertical; diagonals]) + sum(count("SAMX", st, overlap=false) for st in [horizontal; vertical; diagonals])
end

# Part 2
function is_mas(a_location, input_matrix)
    tl = input_matrix[a_location[1]-1, a_location[2]-1]
    tr = input_matrix[a_location[1]-1, a_location[2]+1]
    bl = input_matrix[a_location[1]+1, a_location[2]-1]
    br = input_matrix[a_location[1]+1, a_location[2]+1]

    diagonal_1 = join([tl, 'A', br])
    diagonal_2 = join([tr, 'A', bl])

    return (diagonal_1 == "MAS" || diagonal_1 == "SAM") && (diagonal_2 == "MAS" || diagonal_2 == "SAM")
end

function day4_part2(input_text)

    input_matrix = hcat([collect(x) for x in input_text]...)

    count = 0
    for i in 2:size(input_matrix, 1)-1
        for j in 2:size(input_matrix, 2)-1
            if input_matrix[i, j] == 'A' && is_mas((i, j), input_matrix)
                count += 1
            end
        end
    end
    return count
end

println("The answer to part 1 is: $(day4_part1(input_text))")
println("The answer to part 2 is: $(day4_part2(input_text))")


