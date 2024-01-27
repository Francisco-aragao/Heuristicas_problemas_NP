function ler_arquivo(nome_arquivo)
    arquivo = open(nome_arquivo, "r")
    n = parse(Int, split(readline(arquivo))[2])
    grafo = zeros(Int, n, n)

    for linha in eachline(arquivo)
        dados = split(linha)
        v, u, w = parse(Int, dados[2]), parse(Int, dados[3]), parse(Float64, dados[4])
        grafo[v, u] = w
        grafo[u, v] = w
    end
    close(arquivo)
    return grafo
end

function calcular_peso_subgrafo(grafo, subgrafo)
    peso = 0
    for i in 1:length(subgrafo)
        if subgrafo[i]
            for j in (i+1):length(subgrafo)
                if subgrafo[j]
                    peso += grafo[i, j]
                end
            end
        end
    end
    return peso
end

function busca_local(grafo)
    melhor_solucao = [true for _ in 1:size(grafo, 1)]
    melhor_peso = calcular_peso_subgrafo(grafo, melhor_solucao)
    melhorou = true

    while melhorou
        melhorou = false
        for i in 1:length(melhor_solucao)
            nova_solucao = copy(melhor_solucao)
            nova_solucao[i] = !nova_solucao[i]
            novo_peso = calcular_peso_subgrafo(grafo, nova_solucao)

            if novo_peso > melhor_peso
                melhor_peso = novo_peso
                melhor_solucao = nova_solucao
                melhorou = true
            end
        end
    end

    return melhor_solucao
end

function imprimir_certificado(solucao)
    vertices = []
    for (i, incluido) in enumerate(solucao)
        if incluido
            push!(vertices, i)
        end
    end
    sort!(vertices)
    println(join(vertices, "\t"))
end

function main()
    nome_arquivo = ARGS[1]
    grafo = ler_arquivo(nome_arquivo)

    solucao_final = busca_local(grafo)
    peso_final = calcular_peso_subgrafo(grafo, solucao_final)

    println("TP2 2021031726 = ", peso_final)
    imprimir_certificado(solucao_final)
end

main()
