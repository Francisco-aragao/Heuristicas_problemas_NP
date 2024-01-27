mutable struct Grau
    valor::Int
	vertice::Int
end

mutable struct ConjuntoIndependente
    n::Int #numero de objetos
	vizinhanca::Array{Array{Int}}
	grau::Array{Grau}
	id::Array{Int}
end

function lerArq(file)
	n = 0
	vizinhanca = [[]]
	grau = []
	id = []
	for l in eachline(file)
		q = split(l, "\t")
		if q[1] == "n" 
			n = parse(Int64, q[2])
			vizinhanca = [[] for i=1:n]
			grau = [Grau(0, i) for i=1:n]
			id = [-1 for i=1:n]
			for j in 1:n
				vizinhanca[j] = zeros(Int64, n)
			end
		elseif q[1] == "e"
			v = parse(Int64, q[2])
			u = parse(Int64, q[3])
			vizinhanca[v][u] = 1
			vizinhanca[u][v] = 1
			grau[v].valor += 1
			grau[u].valor += 1

			id[v] = v
			id[u] = u
		end
	end

	return ConjuntoIndependente(n,vizinhanca, grau, id)
end

function printSolution(data, x)
	println("Vertices:")
	quantidade = 0
	for i = 1: data.n
		z = value(x[i])
		println("$(i) $(z)");
	end
end

function somar_graus_vizinhos(A, vizinhanca, grausCopia, n, devoOlhar)
	vizinhos = [vizinhanca[A][x] == 1 for x=1:n]
	a = (findall(x -> x == 1, vizinhos))
	#println("a ", length(a))
	#println("A " , A)
	#println("vizi " )
	soma = sum(grausCopia[v].valor for v in a )
	return soma
end


file = open(ARGS[1], "r")

data = lerArq(file)

sol = []

funcao_comparacao(g1, g2) = g1.valor < g2.valor

ordem_indices = sortperm(data.grau, lt=funcao_comparacao)

grausCopia = copy(data.grau)

# Reorganizar os dados com base na ordem dos índices
data.grau = data.grau[ordem_indices]
#data.vizinhanca = data.vizinhanca[ordem_indices]
data.id = data.id[ordem_indices]

devoOlhar = []
devoOlhar = [true for i=1:data.n]


println()

println("inicio")
println(data.grau)
println()

for k in 1:data.n
	for l in k:data.n
		if ((devoOlhar[data.grau[k].vertice]) && (devoOlhar[data.grau[l].vertice]) && (data.grau[k].valor == data.grau[l].valor))
			somaGrauI = somar_graus_vizinhos(data.grau[k].vertice, data.vizinhanca, grausCopia, data.n, devoOlhar)
			somaGrauJ = somar_graus_vizinhos(data.grau[l].vertice, data.vizinhanca, grausCopia, data.n, devoOlhar)
			aux = data.grau[k]
			data.grau[k] = data.grau[l]
			data.grau[l] = aux

			aux = data.id[k]
			data.id[k] = data.id[l]
			data.id[l] = aux
		end
	end
end

		

# COLOCAR PRA PRESQUISAR TODOS VIZINHOS E COLOCAR 0
for (i, j) in zip(data.grau, data.id)
	
	# Encontrar o índice de j
	index_j = findfirst(x -> x == j, data.id) 

	#= for k in 1:data.n
		for l in k:data.n
			if ((devoOlhar[data.grau[k].vertice]) && (devoOlhar[data.grau[l].vertice]) && (data.grau[k].valor == data.grau[l].valor))
				
				somaGrauK = somar_graus_vizinhos(data.grau[k].vertice, data.vizinhanca, grausCopia, data.n, devoOlhar)
				somaGrauL = somar_graus_vizinhos(data.grau[l].vertice, data.vizinhanca, grausCopia, data.n, devoOlhar)
				if (somaGrauL == somaGrauK)
					println("IGUAL")
				end

				if (somaGrauL > somaGrauK)
					aux = data.grau[k]
					data.grau[k] = data.grau[l]
					data.grau[l] = aux
		
					aux = data.id[k]
					data.id[k] = data.id[l]
					data.id[l] = aux

				end
			end
		end
	end =#

	adiciono = true
	if (j in sol) | (devoOlhar[j] == false)
		#println("pulei")
		continue
	end

	for l in sol
		if (( data.vizinhanca[j][l] == 1) | (data.vizinhanca[l][j] == 1))
			println("adiciono vira false")
			adiciono = false
			break
		end
	end

	if adiciono == true
		println("adiciono")
		println("j ", j)
		push!(sol, j)
		devoOlhar[j] = false
		for l in data.id
			
			if ( (data.vizinhanca[j][l] == 1) | (data.vizinhanca[l][j] == 1) )
				devoOlhar[l] = false
				idx = -1 
				for m=1:data.n
					if data.grau[m].vertice == l
						idx = m 
					end 
				end
				data.vizinhanca[j][l] = 0
				data.vizinhanca[l][j] = 0
				
				data.grau[idx].valor -= 1

				data.grau[index_j].valor -= 1
			end
		end


		ordem_idx = sortperm(data.grau, lt=funcao_comparacao)

		data.grau = data.grau[ordem_idx]
		data.id = data.id[ordem_idx]

		println("ordem pos grau")
		println(data.grau)

		
	end

	
end 

println(length(sol))
println(sol)

#printSolution(data, verticeConjIndep) #posso printar os vertices selecionados para o conjunto independente
