function read_graph(file_name)
    edges = []
    open(file_name, "r") do f
        for line in eachline(f)
            if startswith(line, "e\t")
                push!(edges, parse.(Int, split(line, '\t')[2:3]))
            end
        end
    end
    return edges
end

function build_graph(edges, num_vertices)
    graph = [[] for _ in 1:num_vertices]
    for edge in edges
        push!(graph[edge[1]], edge[2])
        push!(graph[edge[2]], edge[1])
    end
    return graph
end

function find_independent_set(graph)
    independent_set = Set{Int}()
    active = trues(length(graph))
    degrees = [length(neighbors) for neighbors in graph]

    # Ordenando os vértices pelo grau
    vertices_by_degree = sortperm(degrees)

    for vertex in vertices_by_degree
        if active[vertex]
            push!(independent_set, vertex)
            active[vertex] = false
            for neighbor in graph[vertex]
                active[neighbor] = false
            end
        end
    end

    # Refinamento: Tentativa de adicionar vértices que foram pulados
    for vertex in vertices_by_degree
        if !active[vertex] && all(!active[n] for n in graph[vertex]) && !(vertex in independent_set)
            push!(independent_set, vertex)
            for neighbor in graph[vertex]
                active[neighbor] = true
            end
        end
    end

    return independent_set
end

function main()
    file_name = ARGS[1]
    edges = read_graph(file_name)
    num_vertices = maximum([edge for pair in edges for edge in pair])
    graph = build_graph(edges, num_vertices)
    independent_set = find_independent_set(graph)
    println("TP2 2021031726 = $(length(independent_set))")

    sorted_independent_set = sort(collect(independent_set))
    println(join(sorted_independent_set, '\t'))
end

main()
