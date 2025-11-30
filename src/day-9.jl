function compacting(disk_map)

    # files
    files = vcat([repeat([i-1], parse(Int,j)) for (i,j) in enumerate(disk_map[1:2:end])]...)

    # initialize disk
    file_disk = Int[]

    # fill disk with files
    loc = 1
    while !isempty(files)
        room = parse(Int, disk_map[loc])
        j = 1
        while j <= room && !isempty(files) 
            if iseven(loc)
                push!(file_disk, pop!(files))
            else
                push!(file_disk, popfirst!(files))
            end
            j += 1
        end
        loc += 1
    end

    return file_disk
end

function empties(disk, until)
    disk[[-1 in d for d in disk[1:until]]]
end

function compacting_v2(disk_map)
    # files
    files = [repeat([i-1], parse(Int,j)) for (i,j) in enumerate(disk_map[1:2:end])]

    # initialize disk
    file_disk = Vector{Int}[]
    loc = 1
    while !isempty(files)
        if iseven(loc)
            push!(file_disk, repeat([-1], parse(Int, disk_map[loc])))
        else
            push!(file_disk, popfirst!(files))
        end
        loc += 1
    end

    # start with the rightmost file
    current_location = length(file_disk)

    # move
    while current_location > 0
        current_file = file_disk[current_location]

        if !(-1 in current_file)
            fit_space = findfirst([(-1 in space) && (length(space) >= length(current_file)) for space in file_disk[1:current_location]])

            if !isnothing(fit_space)

                target = file_disk[fit_space]

                if length(target) == length(current_file)
                    file_disk[current_location], file_disk[fit_space] = target, current_file
                else
                    # remove the file from the disk
                    file_to_move = popat!(file_disk, current_location)

                    # place the file at the index of the empty space
                    insert!(file_disk, fit_space, file_to_move)

                    # change the length of the empty space to the right
                    file_disk[fit_space+1] = repeat([-1], length(target)-length(file_to_move))
                    
                    # add empty space at the current location
                    insert!(file_disk, current_location+1, repeat([-1], length(file_to_move)))

                    # because we have made the file disk longer, don't change the current location :)
                    current_location += 1
                end
            end
        end
        current_location -= 1
    end
    return vcat(file_disk...)
end

function check_sum(disk)
    sum((i-1)*j for (i,j) in enumerate(disk))
end

function check_sum_v2(disk)
    sum(j >= 0 ? (i-1)*j : 0 for (i,j) in enumerate(disk))
end

check_sum_v2(compacting_v2("2333133121414131402"))

function day9_part1(inputfile::String)
    result = open(inputfile) do f
        disk_map = read(f, String)
        file_disk = compacting(disk_map)
        check_sum(file_disk)
    end
    return result
end

function day9_part2(inputfile::String)
    result = open(inputfile) do f
        disk_map = read(f, String)
        file_disk = compacting_v2(disk_map)
        check_sum_v2(file_disk)
    end
    return result
end

println("The answer to part 1 is: ", day9_part1("inputs/day-9.txt"))
println("The answer to part 2 is: ", day9_part2("inputs/day-9.txt"))

