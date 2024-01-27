function read_graph(file_name)
    edges = []
    open(file_name, "r") do f
        for line in eachline(f)
            if startswith(line, "e\t")
                # Ajuste aqui para separar a string corretamente
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
    independent_set = []
    active = trues(length(graph))
    degrees = [length(neighbors) for neighbors in graph]

    while any(active)
        # Escolha o vértice com o menor grau
        vertex = findmin(degrees .* active)[2]
        if !(vertex in independent_set)
            push!(independent_set, vertex)
        end
        active[vertex] = false
        # Atualize o grau e desative os vizinhos
        for neighbor in graph[vertex]
            active[neighbor] = false
            for second_neighbor in graph[neighbor]
                if active[second_neighbor]
                    degrees[second_neighbor] -= 1
                end
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

    sort!(independent_set)
    println(join(independent_set, '\t'))
end

main()
