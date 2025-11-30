struct Keypad
    position_of_A::Tuple{Int, Int}
    keys::Dict{Char, Tuple{Int, Int}}
end

function NumericKeypad()
    keys = Dict(
        '1' => (1, 3),
        '2' => (2, 3),
        '3' => (3, 3),
        '4' => (1, 2),
        '5' => (2, 2),
        '6' => (3, 2),
        '7' => (1, 1),
        '8' => (2, 1),
        '9' => (3, 1),
        '0' => (2, 4),
        'A' => (3, 4)
    )
    return Keypad((3, 4), keys)
end

function DirectionalKeypad()
    keys = Dict(
        '^' => (2, 1),
        'v' => (2, 2),
        '<' => (1, 2),
        '>' => (3, 2),
        'A' => (3, 1),
    )
    return Keypad((3, 1), keys)
end

function get_neighbors(position, keypad::Keypad, directions::Vector{Int})
    neighbors = Tuple{Int, Int}[]
    sequence_parts = Char[]
    for (dc, dr, c) in [(0, -1, '^'), (0, 1, 'v'), (1, 0, '>'), (-1, 0, '<')][directions]
        new_col = position[1] + dc
        new_row = position[2] + dr
        if (new_col, new_row) ∈ values(keypad.keys)
            push!(neighbors, (new_col, new_row))
            push!(sequence_parts, c)
        end
    end

    return neighbors, sequence_parts
end

function find_available_directions(start_position::Tuple{Int, Int}, end_position::Tuple{Int, Int})

    difference = end_position .- start_position
    directions = Int[]
    if difference[1] > 0
        push!(directions, 3) # right
    end

    if difference[2] < 0
        push!(directions, 1) # up
    end

    if difference[2] > 0
        push!(directions, 2) # down
    end

    if difference[1] < 0
        push!(directions, 4) # left
    end
    directions
end

function sequence_dfs(sequence::Vector{Char}, keypad::Keypad, current_position::Tuple{Int, Int}, target_position::Tuple{Int, Int}, directions::Vector{Int}, found_sequences::Vector{Vector{Char}})
    if current_position == target_position
        push!(found_sequences, sequence)
    else
        neighbors, sequence_parts = get_neighbors(current_position, keypad, directions)
        for (nb, part) in zip(neighbors, sequence_parts)
            sequence_dfs([sequence; part], keypad, nb, target_position, directions, found_sequences)
        end
    end
end

function find_all_possible_moves(start_position::Tuple{Int, Int}, end_position::Tuple{Int, Int}, keypad::Keypad, directions::Vector{Int})
    possible_sequences = Vector{Char}[]
    sequence = Char[]
    sequence_dfs(sequence, keypad, start_position, end_position, directions, possible_sequences)
    return possible_sequences
end


function find_possible_moves(start_position::Tuple{Int, Int}, end_position::Tuple{Int, Int}, keypad::Keypad)
    
    # both coordinates are the same
    if start_position == end_position
        return []
    else
        directions = find_available_directions(start_position, end_position)
        return find_all_possible_moves(start_position, end_position, keypad, directions)
    end
end

function get_button_presses(keypad::Keypad, target::Char; current_position::Tuple{Int, Int}=keypad.position_of_A)
    target_position = keypad.keys[target]
    sequences = find_possible_moves(current_position, target_position, keypad)

    if isempty(sequences)
        return ['A'], target_position 
    else
        return [sequences[1]; 'A'], target_position
    end

end

# function translate(source_keypad::Keypad, sequence::Vector{Vector{Char}})
#     translations = Vector{Char}[]
#     start_position = source_keypad.position_of_A
#     for poss in sequence
#         for c in poss
#             translation_possibilities, start_position = get_button_presses(source_keypad, c; current_position=start_position)
#             if isempty(translations)
#                 translations = translation_possibilities
#             else
#                 for tp in translation_possibilities
#                     push!(translations, tp)
#                 end
#             end
#         end
#     end
       
#     return translations
# end

function translate(keypads::Vector{Keypad}, sequence::String)
    
    for keypad in keypads
        seq = Char[]
        start_position = keypad.position_of_A
        for character in sequence
            translation, start_position = get_button_presses(keypad, character; current_position=start_position)
            append!(seq, translation)
        end
        sequence = join(seq)
    end
    return sequence
    
end

function translate(number_of_keypads::Int, sequence::String)
    keypads = Keypad[NumericKeypad()]
    for _ in 2:number_of_keypads
        push!(keypads, DirectionalKeypad())
    end
    return translate(keypads, sequence)
end

function complexity(number_of_keypads::Int, sequence::String)

    numerical_value = parse(Int, sequence[1:end-1])

    return length(translate(number_of_keypads, sequence))*numerical_value
end

keypads = [
    NumericKeypad(),
    DirectionalKeypad()
]

sequence = "029A"

sequences = """029A
980A
179A
456A
379A"""

sum(seq -> complexity(3, seq), String.(split(sequences, "\n")))
