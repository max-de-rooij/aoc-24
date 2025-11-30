

struct ClawMachine
    A::Matrix{Int}
    b::Vector{Int}
end

function det(A)
    return A[1,1]*A[2,2] - A[1,2]*A[2,1]
end

# Cramer's rule
function compute_cost(mach::ClawMachine, offset=0)
    x1 = det([mach.b .+ offset mach.A[:,2]])/det(mach.A)*3
    x2 = det([mach.A[:,1] mach.b .+ offset])/det(mach.A)

    if x1 == floor(x1) && x2 == floor(x2)
        return Int(x1 + x2)
    else
        return 0
    end
end

function ClawMachine(machine_input)
    rx = r"Button A: X\+(\d+), Y\+(\d+)\nButton B: X\+(\d+), Y\+(\d+)\nPrize: X=(\d+), Y=(\d+)"
    matches = match(rx, machine_input).captures

    button_A = [parse(Int, matches[1]), parse(Int, matches[2])]
    button_B = [parse(Int, matches[3]), parse(Int, matches[4])]
    prize = [parse(Int, matches[5]), parse(Int, matches[6])]

    return ClawMachine([button_A button_B], prize)
end

clawmachines = open("inputs/day-13.txt") do f
    data = read(f, String)
    sum(x -> compute_cost(x,10000000000000), ClawMachine.(split(data, "\n\n")))
end
