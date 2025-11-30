using CairoMakie

abstract type Object end
abstract type AbstractMap end

struct Wall <: Object end
struct Box <: Object end
abstract type WideBox <: Object end
struct WideBoxLeft <: WideBox end
struct WideBoxRight <: WideBox end
struct Empty <: Object end
struct Robot <: Object end

function parse_object(c::Char)
    if c == '#'
        return Wall()
    elseif c == 'O'
        return Box()
    elseif c == '@'
        return Robot()
    elseif c == '.'
        return Empty()
    elseif c == '['
        return WideBoxLeft()
    elseif c == ']'
        return WideBoxRight()
    else
        throw(ArgumentError("Invalid character: $c"))
    end
end

function get_gps(row::Int, col::Int)
    col - 1 + (row - 1) * 100
end

function get_coordinates(gps::Int)
    ((gps ÷ 100) + 1,gps % 100 + 1)
end

struct Map <: AbstractMap
    objects::Dict{Int, Object}
    size::Tuple{Int, Int}
end

struct WideMap <: AbstractMap
    objects::Dict{Int, Object}
    size::Tuple{Int, Int}
end

function find_robot(map::AbstractMap)
    for (k, v) in map.objects
        if v isa Robot
            return k
        end
    end
end

function find_new_position(robot_gps::Int, instruction::Char)
    if instruction == '^'
        return robot_gps - 100
    elseif instruction == 'v'
        return robot_gps + 100
    elseif instruction == '<'
        return robot_gps - 1
    elseif instruction == '>'
        return robot_gps + 1
    else
        return -1
    end
end

function move_robot!(map::AbstractMap, robot_gps::Int, new_gps::Int)
    map.objects[new_gps] = Robot()
    map.objects[robot_gps] = Empty()
end

function is_box_movable(map::AbstractMap, box_gps::Int, instruction::Char, amount_of_boxes::Int)

    new_box_gps = find_new_position(box_gps, instruction)
    if new_box_gps in keys(map.objects)
        if map.objects[new_box_gps] isa Empty
            return true, amount_of_boxes
        elseif map.objects[new_box_gps] isa Box
            return is_box_movable(map, new_box_gps, instruction, amount_of_boxes + 1)
        end
    end
    return false, amount_of_boxes
end

function is_box_movable(map::WideMap, box_gps::Int, instruction::Char)
    if instruction == '^' || instruction == 'v'
        if map.objects[box_gps] isa WideBoxLeft
            return wide_box_movable_top_down(map, (box_gps, box_gps+1), instruction, 1)
        else
            return wide_box_movable_top_down(map, (box_gps-1, box_gps), instruction, 1)
        end
    else
        return wide_box_movable_left_right(map, box_gps, instruction, 1)
    end
end

function wide_box_movable_left_right(map::WideMap, box_gps::Int, instruction::Char, amount_of_boxes::Int)
    new_box_gps = find_new_position(find_new_position(box_gps, instruction), instruction)
    if new_box_gps in keys(map.objects)
        if map.objects[new_box_gps] isa Empty
            return true, amount_of_boxes
        elseif map.objects[new_box_gps] isa WideBox
            return wide_box_movable_left_right(map, new_box_gps, instruction, amount_of_boxes + 1)
        end
    end
    return false, amount_of_boxes
end

function wide_box_movable_top_down(map::WideMap, box_gps::Tuple{Int, Int}, instruction::Char, amount_of_boxes::Int)
    # TODO; tree search (recursive with list)
    new_box_gps = (find_new_position(box_gps[1], instruction), find_new_position(box_gps[2], instruction))

    if new_box_gps[1] in keys(map.objects) && new_box_gps[2] in keys(map.objects)


        if map.objects[new_box_gps[1]] isa Empty && map.objects[new_box_gps[2]] isa Empty
            return true, amount_of_boxes
        elseif map.objects[new_box_gps[1]] isa Wall || map.objects[new_box_gps[2]] isa Wall
            return false, amount_of_boxes
        elseif map.objects[new_box_gps[1]] isa WideBoxLeft
            return wide_box_movable_top_down(map, (new_box_gps[1], new_box_gps[2]), instruction, amount_of_boxes + 1)
        elseif map.objects[new_box_gps[1]] isa Empty && map.objects[new_box_gps[2]] isa WideBoxLeft
            return wide_box_movable_top_down(map, (new_box_gps[2], new_box_gps[2]+1), instruction, amount_of_boxes + 1)
        elseif map.objects[new_box_gps[1]] isa WideBoxRight
            left_box, amount_left = wide_box_movable_top_down(map, (new_box_gps[1]-1, new_box_gps[1]), instruction, amount_of_boxes + 1)
            if map.objects[new_box_gps[2]] isa WideBoxLeft
                right_box, amount_right = wide_box_movable_top_down(map, (new_box_gps[2], new_box_gps[2]+1), instruction, 1)
                return left_box && right_box, amount_left + amount_right
            end
            # create new branch
            return left_box, amount_left
        end
    end
    return false, amount_of_boxes
end

function move_box!(map::AbstractMap, box_gps::Int, instruction::Char, amount_of_boxes::Int)
    new_box_gps = find_new_position(box_gps, instruction)
    map.objects[new_box_gps] = Box()
    amount_of_boxes -= 1
    if amount_of_boxes > 0
        move_box!(map, new_box_gps, instruction, amount_of_boxes)
    end
end

function move_box!(map::WideMap, box_gps::Int, instruction::Char, amount_of_boxes::Int, boxtype::Type{<:WideBox})
    if instruction == '^' || instruction == 'v'
        if boxtype == WideBoxLeft
            move_wide_box_top_down!(map, (box_gps, box_gps+1), instruction)
        else
            move_wide_box_top_down!(map, (box_gps-1, box_gps), instruction)
        end
    else
        move_wide_box_right_left!(map, box_gps, instruction, amount_of_boxes)
    end
end

function move_wide_box_right_left!(map::WideMap, box_gps::Int, instruction::Char, amount_of_boxes::Int)
    new_position = find_new_position(box_gps, instruction)
    other_new_position = find_new_position(new_position, instruction)
    if instruction == '<'
        map.objects[new_position] = WideBoxRight()
        map.objects[other_new_position] = WideBoxLeft()
    else
        map.objects[new_position] = WideBoxLeft()
        map.objects[other_new_position] = WideBoxRight()
    end

    amount_of_boxes -= 1
    if amount_of_boxes > 0
        move_wide_box_right_left!(map, other_new_position, instruction, amount_of_boxes)
    end
end

function move_wide_box_top_down!(map::WideMap, box_gps::Tuple{Int, Int}, instruction::Char)
    new_box_gps = (find_new_position(box_gps[1], instruction), find_new_position(box_gps[2], instruction))

    if map.objects[new_box_gps[1]] isa WideBoxLeft && map.objects[new_box_gps[2]] isa WideBoxRight
        move_wide_box_top_down!(map, (new_box_gps[1], new_box_gps[2]), instruction)
    elseif map.objects[new_box_gps[1]] isa WideBoxRight && map.objects[new_box_gps[2]] isa WideBoxLeft
        move_wide_box_top_down!(map, (new_box_gps[1]-1, new_box_gps[1]), instruction)
        move_wide_box_top_down!(map, (new_box_gps[2], new_box_gps[2]+1), instruction)

        map.objects[new_box_gps[1]-1] = Empty()
        map.objects[new_box_gps[2]+1] = Empty()

    elseif map.objects[new_box_gps[1]] isa WideBoxRight && map.objects[new_box_gps[2]] isa Empty
        move_wide_box_top_down!(map, (new_box_gps[1]-1, new_box_gps[1]), instruction)
        map.objects[new_box_gps[1]-1] = Empty()

    elseif map.objects[new_box_gps[1]] isa Empty && map.objects[new_box_gps[2]] isa WideBoxLeft
        move_wide_box_top_down!(map, (new_box_gps[2], new_box_gps[2]+1), instruction)
        map.objects[new_box_gps[2]+1] = Empty()

    end

    map.objects[new_box_gps[1]] = WideBoxLeft()
    map.objects[new_box_gps[2]] = WideBoxRight()
            
end

function move!(map::AbstractMap, instruction::Char)
    robot_gps = find_robot(map)
    new_position = find_new_position(robot_gps, instruction)

    if new_position in keys(map.objects)
        # empty space
        if map.objects[new_position] isa Empty
            move_robot!(map, robot_gps, new_position)
        # box
        elseif map.objects[new_position] isa Box
            # check if box can be moved
            box_movable, amount_of_boxes = is_box_movable(map, new_position, instruction, 1)
            if box_movable

                move_robot!(map, robot_gps, new_position)
                move_box!(map, new_position, instruction, amount_of_boxes)

            end
        end
    end
end

function move!(map::WideMap, instruction::Char)
    robot_gps = find_robot(map)
    new_position = find_new_position(robot_gps, instruction)

    if new_position in keys(map.objects)
        # empty space
        if map.objects[new_position] isa Empty
            move_robot!(map, robot_gps, new_position)

        # box
        elseif map.objects[new_position] isa WideBox
            # check if box can be moved
            box_movable, amount_of_boxes = is_box_movable(map, new_position, instruction)
            if box_movable
                original_box_type = typeof(map.objects[new_position])
                move_robot!(map, robot_gps, new_position)
                move_box!(map, new_position, instruction, amount_of_boxes, original_box_type)

                if (instruction == '^' || instruction == 'v')
                    if original_box_type == WideBoxLeft
                        map.objects[new_position+1] = Empty()
                    else
                        map.objects[new_position-1] = Empty()
                    end
                end

            end
        end
    end
end

function read_input(input::String)

    map_input, instructions = split(input, "\n\n")

    objects = Dict{Int, Object}()
    size = (0, 0)
    for (i, line) in enumerate(split(map_input, '\n'))
        size = (i, length(line))
        for (j, c) in enumerate(line)
            objects[get_gps(i, j)] = parse_object(c)
        end
    end

    if any([v isa WideBox for v in values(objects)])
        return WideMap(objects, size), instructions
    end

    return Map(objects, size), instructions
end

function get_box_gps(map::AbstractMap)
    box_gps = 0
    for (k, v) in map.objects
        if v isa Box
            box_gps += k
        end
    end
    return box_gps
end

function get_box_gps(map::WideMap)
    box_gps = 0
    for (k, v) in map.objects
        if v isa WideBoxLeft
            box_gps += k
        end
    end
    return box_gps
end

function get_object_coordinates(map::AbstractMap, object::Type{<:Object})
    coords = Point2f[]
    for (k, v) in map.objects
        row, col = get_coordinates(k)
        if v isa object
            push!(coords, Point2f(col, map.size[1]-row))
        end
    end
    return coords
end

function display_map(map::WideMap)
    walls = get_object_coordinates(map, Wall)
    lboxes = get_object_coordinates(map, WideBoxLeft)
    rboxes = get_object_coordinates(map, WideBoxRight)    
    robot = get_object_coordinates(map, Robot)

    fig, ax = scatter(walls, color=:black, markersize=10, marker = :rect)
    scatter!(ax, lboxes, color=:blue, markersize=10, marker = '[')
    scatter!(ax, rboxes, color=:blue, markersize=10, marker = ']')
    scatter!(ax, robot, color=:red, markersize=10, marker = :circle)
    return fig
end


function part1_anim(input_file)

    open(input_file) do f

        map, instructions = read_input(read(f, String))

        walls = Observable(get_object_coordinates(map, Wall()))
        boxes = Observable(get_object_coordinates(map, Box()))
        robot = Observable(get_object_coordinates(map, Robot()))

        fig, ax = scatter(walls, color=:black, markersize=10, marker = :rect)
        scatter!(ax, boxes, color=:blue, markersize=10, marker = '□')
        scatter!(ax, robot, color=:red, markersize=10, marker = collect("🤖"))

     
        record(fig, "day_15_part1_anim.mp4", instructions;
                framerate = 240) do instruction
            move!(map, instruction)
            walls[] = get_object_coordinates(map, Wall())
            boxes[] = get_object_coordinates(map, Box())
            robot[] = get_object_coordinates(map, Robot())
        end
    end
end

function day15_part1(input_file)
    result = open(input_file) do f
        map, instructions = read_input(read(f, String))
        for instruction in instructions
            move!(map, instruction)
        end
        get_box_gps(map)
    end
    return result
end

function widen_input(input::String)

    map_input, instructions = split(input, "\n\n")

    objects = Dict{Int, Object}()
    size = (0, 0)
    for (i, line) in enumerate(split(map_input, '\n'))
        size = (i, 2*length(line))

        # duplicate each character
        for (j, c) in enumerate(line)
            if c == '@'
                objects[get_gps(i, 2*j-1)] = parse_object(c)
                objects[get_gps(i, 2*j)] = Empty()
            elseif c == 'O'
                objects[get_gps(i, 2*j-1)] = WideBoxLeft()
                objects[get_gps(i, 2*j)] = WideBoxRight()
            else
                objects[get_gps(i, 2*j-1)] = parse_object(c)
                objects[get_gps(i, 2*j)] = parse_object(c)
            end
        end
    end

    if any([v isa WideBox for v in values(objects)])
        return WideMap(objects, size), instructions
    end

    return Map(objects, size), instructions
end

function day15_part2(input_file)
    result = open(input_file) do f
        map, instructions = widen_input(read(f, String))
        for instruction in instructions
            #display(display_map(map))
            move!(map, instruction)
        end
        get_box_gps(map)
    end
    return result
end


function part2_anim(input_file)

    open(input_file) do f

        map, instructions = widen_input(read(f, String))

        walls = Observable(get_object_coordinates(map, Wall))
        lboxes = Observable(get_object_coordinates(map, WideBoxLeft))
        rboxes = Observable(get_object_coordinates(map, WideBoxRight))
        robot = Observable(get_object_coordinates(map, Robot))

        fig, ax = scatter(walls, color=:black, markersize=8, marker = :rect)
        scatter!(ax, lboxes, color=:blue, markersize=8, marker = '[')
        scatter!(ax, rboxes, color=:blue, markersize=8, marker = ']')
        scatter!(ax, robot, color=:red, markersize=10, marker = '⎔')

     
        record(fig, "day_15_part2_anim.mp4", instructions;
                framerate = 240) do instruction
            move!(map, instruction)
            walls[] = get_object_coordinates(map, Wall)
            lboxes[] = get_object_coordinates(map, WideBoxLeft)
            rboxes[] = get_object_coordinates(map, WideBoxRight)
            robot[] = get_object_coordinates(map, Robot)
        end
    end
end

println("The solution to part 1 is: $(day15_part1("inputs/day-15.txt"))")
println("The solution to part 2 is: $(day15_part2("inputs/day-15.txt"))")