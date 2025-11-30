@enum RetCode OK=0 HALT=1

"""Register A: 33024962
Register B: 0
Register C: 0

Program: 2,4,1,3,7,5,1,5,0,3,4,2,5,5,3,0"""

mutable struct Computer
    registers::Vector{Int}
    position::Int
    output::Vector{Int}
end

function Computer(a::Int, b::Int, c::Int)
    return Computer(
        [a,b,c],0,Int[]
    )
end

function clear!(c)
    c.output = Int[]
end

function combo(computer::Computer, operand::Int)
    if 0 <= operand <= 3
        return operand
    elseif 4 <= operand <= 6
        return computer.registers[operand-3]
    else
        throw(ArgumentError("Operand $operand is reserved and cannot be used in valid programs."))
    end
end

function adv!(computer::Computer, operand)
    computer.registers[1] = computer.registers[1] ÷ Int(2^combo(computer, operand))
    computer.position += 2
end

function bxl!(computer::Computer, operand)
    computer.registers[2] = xor(computer.registers[2], operand)
    computer.position += 2
end

function bst!(computer::Computer, operand)
    computer.registers[2] = mod(combo(computer, operand), 8)
    computer.position += 2
end

function jnz!(computer::Computer, operand)
    if computer.registers[1] != 0
        computer.position = operand
    else
        computer.position += 2
    end
end

function bxc!(computer::Computer, _)
    computer.registers[2] = xor(computer.registers[2], computer.registers[3])
    computer.position += 2
end

function out!(computer::Computer, operand)
    push!(computer.output, mod(combo(computer, operand), 8))
    computer.position += 2
end

function bdv!(computer::Computer, operand)
    computer.registers[2] = computer.registers[1] ÷ Int(2^combo(computer, operand))
    computer.position += 2
end

function cdv!(computer::Computer, operand)
    computer.registers[3] = computer.registers[1] ÷ Int(2^combo(computer, operand))
    computer.position += 2
end

const EXEC_MAP = Dict(
    0 => adv!,
    1 => bxl!,
    2 => bst!,
    3 => jnz!,
    4 => bxc!,
    5 => out!,
    6 => bdv!,
    7 => cdv!
)

function exec!(computer, program)
    if computer.position+1 >= length(program)
        return HALT
    end
    opcode = program[computer.position+1]
    operand = program[computer.position+2]

    if opcode ∉ keys(EXEC_MAP)
        throw(ArgumentError("Opcode $opcode is reserved and cannot be used in valid programs."))
    end

    EXEC_MAP[opcode](computer, operand)

    return OK
end

function run!(computer::Computer, program::Vector{Int})

    clear!(computer)

    retcode = OK
    while retcode == OK
        retcode = exec!(computer, program)
    end

    return computer.output
end

function run_(a, b, c, program)
    computer = Computer(a, b, c)
    return run!(computer, program)
end

function find_copy(computer::Computer, A, program::Vector{Int}, compare_index, possible::Set{Int})
    for n in 0:7
        A2 = (A << 3) | n
        output = run_(A2, computer.registers[2], computer.registers[3], program)
        if output == program[end-compare_index+1:end]
            if output == program
                push!(possible, A2)
            else
                find_copy(computer, A2, program, compare_index+1, possible)
            end
        end
    end

    if length(possible) > 0
        return minimum(possible)
    else
        return 0
    end
end

read("inputs/day-17.txt", String)

function read_input(input)
    registers, program = open(input) do file
        s = read(file, String)
        registers = [parse(Int, x.captures[1]) for x in eachmatch(r"Register.+[ABC]: (\d+)", s)]
        program = parse.(Int,split(match(r"Program: (\d.+)", s).captures[1], ","))
        registers, program
    end
    return registers, program
end

function day17_part1(input)
    registers, program = read_input(input)
    computer = Computer(registers...)
    return run_(computer.registers..., program)
end

function day17_part2(input)
    registers, program = read_input(input)
    computer = Computer(registers...)
    return find_copy(computer, 0, program, 1, Set{Int}())
end

println("The solution to part 1 is: $(day17_part1("inputs/day-17.txt"))")
println("The solution to part 2 is: $(day17_part2("inputs/day-17.txt"))")