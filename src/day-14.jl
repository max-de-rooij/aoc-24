using CairoMakie

struct Robot
    row_init::Int
    col_init::Int
    vr::Int
    vc::Int
end

struct Area
    nrows::Int
    ncols::Int
    quadrants::Dict{Int, Int}
end

function Area(size::Tuple{Int, Int})
    Area(size[1], size[2], Dict{Int, Int}())
end

function add_robot(area::Area, robot::Robot, t::Int)
    quadrant = get_quadrant(robot, t, (area.nrows, area.ncols))
    if quadrant != 0
        area.quadrants[quadrant] = get(area.quadrants, quadrant, 0) + 1
    end
end

function get_position(robot::Robot, t::Int, size::Tuple{Int, Int})
    return (mod(robot.row_init + robot.vr*t, size[1]), mod(robot.col_init + robot.vc*t, size[2]))
end

function get_quadrant(robot::Robot, t::Int, size::Tuple{Int, Int})
    row, col = get_position(robot, t, size)

    if row == size[1] ÷ 2 || col == size[2] ÷ 2
        return 0
    end

    if row < size[1] ÷ 2
        if col < size[2] ÷ 2
            return 1
        else
            return 2
        end
    else
        if col < size[2] ÷ 2
            return 3
        else
            return 4
        end
    end
end

function Robot(input)
    vals = [parse(Int,m.captures[1]) for m in eachmatch(r"(-?\d+)", input)]
    Robot(
        vals[2], vals[1], vals[4], vals[3]
    )
end

function safety_factor(area::Area)
    reduce(*, values(area.quadrants), init=1)
end

function safety_factor(area::Area, input_str, t::Int)
    for line in split(input_str, '\n')
        add_robot(area, Robot(line), t)
    end
    reduce(*, values(area.quadrants), init=1)
end

function day14_part1(input_file)

    result = open(input_file) do f
        area = Area((103, 101))
        safety_factor(area, read(f, String), 100)
    end
    return result
end

function has_contiguous_points(rows, cols, row; l=10)
    cols_in_row = cols[rows .== row]
    
    differences = diff(sort(cols_in_row))

    # look for 10 or more consecutive 1s
    id = 1
    cons = 0
    while id <= length(differences)
        if differences[id] == 1
            cons += 1
        else
            if cons >= l
                return true
            end
            cons = 0
        end
        id += 1
    end

    return false
end


function has_base(area::Area, robots::Vector, t::Int)
    rows = Int[]; cols = Int[]
    for robot in robots
        row, col = get_position(robot, t, (area.nrows, area.ncols))
        push!(rows, row)
        push!(cols, col)
    end

    for row in unique(rows)
        if has_contiguous_points(rows, cols, row)
            return true
        end
    end

    return false
end

day14_part1("inputs/day-14.txt")

function visualize(area::Area, robots::Vector{Robot}, t::Int)
    fig = Figure()
    ax = Axis(fig[1, 1], aspect = 1)
    #println(is_symmetric(area, robots, t))
    for robot in robots
        row, col = get_position(robot, t, (area.nrows, area.ncols))
        scatter!(ax, [col], [row], markersize = 10, color=:red)
    end
    fig
end

function christmas_tree(area::Area, robots::Vector{Robot})

    t = 0
    while !has_base(area, robots, t)
        t += 1
    end

    #display(visualize(area, robots, t))
    return t
end

function day14_part2(input_file)
    result = open(input_file) do f
        area = Area((103, 101))
        robots = Robot.(split(read(f, String), '\n'))
        christmas_tree(area, robots)
    end
    return result
end

function get_cols(area::Area, robots::Vector{Robot}, t::Int)
    cols = Int[]
    for robot in robots
        row, col = get_position(robot, t, (area.nrows, area.ncols))
        push!(cols, col)
    end
    return cols
end

function get_rows(area::Area, robots::Vector{Robot}, t::Int)
    rows = Int[]
    for robot in robots
        row, col = get_position(robot, t, (area.nrows, area.ncols))
        push!(rows, row)
    end
    return rows
end

function day_14_animation(input_file)
    max_time = day14_part2(input_file)
    time = Observable(0)

    area = Area((103, 101))
    robots = Robot.(split(read(input_file, String), '\n'))

    xs = @lift get_cols(area, robots, $time)
    ys = @lift get_rows(area, robots, $time)

    fig = Figure()
    ax = Axis(fig[1, 1], aspect = 1)
    scatter!(ax, xs, ys, markersize = 5, color=:red)

    framerate = 1
    timestamps = range(max_time-10, max_time)
    record(fig, "time_animation.mp4", timestamps;
            framerate = framerate) do t
        time[] = t
    end
end

#day_14_animation("inputs/day-14.txt")

println("The solution to part 1 is: $(day14_part1("inputs/day-14.txt"))")
println("The solution to part 2 is: $(day14_part2("inputs/day-14.txt"))")