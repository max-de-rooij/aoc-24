import Base.parse

struct Rule
    page::Int
    before::Int
end

function parse(::Type{Rule}, s::String)
    page, before = split(s, "|")
    Rule(parse(Int, page), parse(Int, before))
end

function contains_pages(rule, pages)
    rule.page in pages && rule.before in pages
end

function is_valid(rule, pages)
    Int(findfirst(pages .== rule.page)) < Int(findfirst(pages .== rule.before))
end

function assess(rule, pages)
    if contains_pages(rule, pages)
        return is_valid(rule, pages)
    else
        return true
    end
end

function page(s)
    parse.(Int, split(s,","))
end

rules, updates = open("inputs/day-5.txt") do f
    rules = Rule[]
    updates = Vector{Int}[]
    for line in readlines(f)
        if occursin("|", line)
            push!(rules, parse(Rule, line))
        elseif occursin(",", line)
            push!(updates, page(line))
        end
    end
    rules, updates
end

function assess_update(pages::Vector{Int}, rules::Vector{Rule})
    all(assess.(rules, Ref(pages)))
end

function first_invalid_rule(pages::Vector{Int}, rules::Vector{Rule})
    for rule in rules
        if !assess(rule, pages)
            return rule
        end
    end
    return nothing
end

function assess_and_fix!(pages::Vector{Int}, rules::Vector{Rule})
    while !isnothing(first_invalid_rule(pages, rules))
        rule = first_invalid_rule(pages, rules)
        
        # swap indices
        page_index = findfirst(pages .== rule.page)
        before_index = findfirst(pages .== rule.before)
        pages[page_index], pages[before_index] = pages[before_index], pages[page_index]
    end
end

function day5_part1(rules::Vector{Rule}, updates::Vector{Vector{Int}})
    result = 0
    for update in updates
        if assess_update(update, rules)
            # find the middle
            mid = Int((length(update)+1)/2)
            result += update[mid]
        end
    end
    return result
end

function day5_part2(rules::Vector{Rule}, updates::Vector{Vector{Int}})
    result = 0
    for pages in updates
        if !assess_update(pages, rules)
            assess_and_fix!(pages, rules)
    
            # get middle
            mid = Int((length(pages)+1)/2)
            result += pages[mid]
        end
    end
    return result
end

println("The answer to part 1 is: ", day5_part1(rules, updates))
println("The answer to part 2 is: ", day5_part2(rules, updates))