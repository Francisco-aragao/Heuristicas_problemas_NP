# lista de adjacencia
struct Grafo
    adjacencias::Array{Set{Int},1}

    # Construtor que inicializa o grafo com um número específico de vértices
    function Grafo(num_vertices::Int)
        new([Set{Int}() for _ in 1:num_vertices])
    end
end

function ler_grafo(nome_arquivo::String)
    open(nome_arquivo, "r") do file
        num_vertices = parse(Int, split(readline(file), '\t')[2])
        grafo = Grafo(num_vertices)  # Usa o construtor da struct Grafo
        for linha in eachline(file)
            dados = split(linha, '\t')
            v, u = parse(Int, dados[2]), parse(Int, dados[3])
            push!(grafo.adjacencias[v], u)
            push!(grafo.adjacencias[u], v)
        end
        return grafo
    end
end

function ordenar_vertices_por_grau(grafo::Grafo)
    # retorna os indices do vetor odernado
    sortperm(map(length, grafo.adjacencias), rev=true)
end

function encontrar_cor_minima(cores_usadas)
    cor = 1
    while cor in cores_usadas
        cor += 1
    end
    return cor
end

function colorir_grafo(grafo::Grafo)
    num_vertices = length(grafo.adjacencias)
    cores = fill(0, num_vertices)
    ordem = ordenar_vertices_por_grau(grafo)
    for v in ordem
        cores_usadas = Set{Int}()
        for vizinho in grafo.adjacencias[v]
            if cores[vizinho] != 0
                push!(cores_usadas, cores[vizinho])
            end
        end
        cores[v] = encontrar_cor_minima(cores_usadas)
    end
    return cores
end

function agrupar_vertices_por_cor(cores)
    grupos = Dict{Int, Set{Int}}()
    for (v, cor) in enumerate(cores)
        if !haskey(grupos, cor)
            grupos[cor] = Set{Int}()
        end
        push!(grupos[cor], v)
    end
    return grupos
end

function imprimir_certificado(cores)
    grupos = agrupar_vertices_por_cor(cores)
    for cor in sort(collect(keys(grupos)))
        vertices = grupos[cor]
        println(join(sort(collect(vertices)), "\t"))
    end
end

function main()
    nome_arquivo = ARGS[1]
    grafo = ler_grafo(nome_arquivo)
    cores = colorir_grafo(grafo)
    num_cores = maximum(cores)
    println("TP2 2021031726 = ", num_cores)
    imprimir_certificado(cores)
end

main()