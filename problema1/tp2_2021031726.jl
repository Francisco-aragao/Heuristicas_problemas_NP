
mutable struct EmpacotamentoDados
    n::Int #numero de objetos
    peso::Array{Float64} #peso de cada produto
    id::Array{Int} #id dos produtos
end

function lerArq(file)
	n = 0
	peso = Float64[]
	id = Int[]
	for l in eachline(file)
		q = split(l, "\t")
		num = parse(Int64, q[2])
		if q[1] == "n"
			n = num
			peso = zeros(Float64, n)
			id = zeros(Int, n)
		elseif q[1] == "o"
			indice = num+1
			id[indice] = num
			peso[indice] = parse(Float64, q[3])
		end
	end
	return EmpacotamentoDados(n,peso, id)
end


file = open(ARGS[1], "r")

data = lerArq(file)

ordem_indices = sortperm(data.peso, rev=true)

# Reorganizar os dados com base nos itens ordenados por peso
data.peso = data.peso[ordem_indices]
data.id = data.id[ordem_indices]

bin_capacity = 20

bins = [] # Lista para armazenar as caixas utilizadas

for (pesoItem, idItem) in zip(data.peso, data.id)
	alocado = false

    for i in 1:size(bins)[1] #adiciono de maneira gulosa os itens nas caixas até encher a capacidade
        if (sum(bins[i][j].peso for j=1:size(bins[i])[1])) + pesoItem <= bin_capacity
            push!(bins[i], (peso=pesoItem, id=idItem))
            alocado = true
            break
        end
    end

    if !alocado #se nenhuma caixa usada anteriormente comporta o novo item, uso outra caixa
        push!(bins, [(peso=pesoItem, id=idItem)])
    end
    
end

#ordeno saida
compare_length(s1, s2) = length(s1) > length(s2)
bins = sort(bins, lt=compare_length)

#imprimo resultado
println("TP2 2021031726 = ", size(bins)[1])
for i in bins
	for j in i
		print(j[2], '\t')
	end
	println()
end
