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

function somar_graus_vizinhos(A, vizinhanca, grausCopia, n)
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


for k in 1:data.n
	for l in k:data.n
		if ((data.grau[k].valor == data.grau[l].valor))
			somaGrauK = somar_graus_vizinhos(data.grau[k].vertice, data.vizinhanca, grausCopia, data.n)
			somaGrauL = somar_graus_vizinhos(data.grau[l].vertice, data.vizinhanca, grausCopia, data.n)

			if (somaGrauL == somaGrauK)
					#println("IGUAL")
				for m in l:length(data.grau)
					for n in m:length(data.grau)
						if ((data.grau[m].valor == data.grau[n].valor))
							
							somaGrauM = somar_graus_vizinhos(data.grau[m].vertice, data.vizinhanca, grausCopia, data.n)
							somaGrauN = somar_graus_vizinhos(data.grau[n].vertice, data.vizinhanca, grausCopia, data.n)


								if (somaGrauN > somaGrauM)
									aux = data.grau[k]
									data.grau[k] = data.grau[l]
									data.grau[l] = aux
						
									aux = data.id[k]
									data.id[k] = data.id[l]
									data.id[l] = aux
								end
						end
					end
				end
				continue
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
end



# COLOCAR PRA PRESQUISAR TODOS VIZINHOS E COLOCAR 0
#for (i, j) in zip(data.grau, data.id)
global j = 1
#for j in range(1,length(data.id))
while j <= length(data.id)
    if (j > length(data.id))	
		#println("FIm")
        break
    end
	

    #= println("inicio")
    println(data.grau)
    println(data.id)
    println() =#

	adiciono = true
	if (data.id[j] in sol)
		#println("pulei")
		continue
	end

	for l in sol
		if (( data.vizinhanca[data.id[j]][l] == 1) | (data.vizinhanca[l][data.id[j]] == 1))
			#println("adiciono vira false")
			adiciono = false
			break
		end
	end

	if adiciono == true
		#println("adiciono")
        #println("j ", data.id[j])
		push!(sol, data.id[j])
		atual = data.id[j]
		toDelete = []

		for l in 1:length(data.id)
			if (l > length(data.id))
				#println("SAIU NESSE BRAK")
				break
			end
			#println("l começo ", data.id[l])
			#println("j ", data.id[j])
			if ( (data.vizinhanca[data.id[j]][data.id[l]] == 1) | (data.vizinhanca[data.id[l]][data.id[j]] == 1) )

				#= idx = -1 
				for (m, c) in zip(data.grau, range(1,data.n))
					if m.vertice == data.id[l]
						idx = c 
                        break
					end 
				end =#
				data.vizinhanca[data.id[j]][data.id[l]] = 0
				data.vizinhanca[data.id[l]][data.id[j]] = 0

				#println("l ", data.id[l])

                for m in data.id
                    if ((data.vizinhanca[m][data.id[l]] == 1) | (data.vizinhanca[data.id[l]][m] == 1))
                        #println("   m ", m)
                        idx2 = -1 
                        for (n, c) in zip(data.grau, range(1,data.n))
                            if n.vertice == m
                                idx2 = c
                                break
                            end 
                        end
                        data.grau[idx2].valor -= 1
                        #println("   ma ", data.grau[idx2].vertice )
                        (data.vizinhanca[m][data.id[l]] == 0)
                        (data.vizinhanca[data.id[l]][m] == 0)
                    end
                end
				
                data.grau[l].valor -= 1
                #= deleteat!(data.grau, l)
                deleteat!(data.id, l) =#
				pushfirst!(toDelete, l)
				
				#data.grau[index_j].valor -= 1
				
			end
		end

		for l in toDelete
			deleteat!(data.grau, l)
            deleteat!(data.id, l)
		end
		#= println(data.id)
		println("atual ", atual) =#
		index_j = findfirst(x -> x == atual, data.id) 
		#= println("index j ", index_j) =#
        deleteat!(data.grau, index_j)
        deleteat!(data.id, index_j)
		global j -= 1
		ordem_idx = sortperm(data.grau, lt=funcao_comparacao)

		data.grau = data.grau[ordem_idx]
		data.id = data.id[ordem_idx]

		#= println("ordem pos grau")
		println(data.grau)
		println(data.id) =#

	end

	for k in 1:length(data.grau)
		for l in k:length(data.grau)
			if ((data.grau[k].valor == data.grau[l].valor))
				
				somaGrauK = somar_graus_vizinhos(data.grau[k].vertice, data.vizinhanca, grausCopia, data.n)
				somaGrauL = somar_graus_vizinhos(data.grau[l].vertice, data.vizinhanca, grausCopia, data.n)

				if (somaGrauL == somaGrauK)
						#println("IGUAL")
					for m in l:length(data.grau)
						for n in m:length(data.grau)
							if ((data.grau[m].valor == data.grau[n].valor))
								
								somaGrauM = somar_graus_vizinhos(data.grau[m].vertice, data.vizinhanca, grausCopia, data.n)
								somaGrauN = somar_graus_vizinhos(data.grau[n].vertice, data.vizinhanca, grausCopia, data.n)


									if (somaGrauN > somaGrauM)
										aux = data.grau[k]
										data.grau[k] = data.grau[l]
										data.grau[l] = aux
							
										aux = data.id[k]
										data.id[k] = data.id[l]
										data.id[l] = aux
									end
							end
						end
					end
					continue
				end
				if (somaGrauL > somaGrauK)
				#println("ORDE")
					aux = data.grau[k]
					data.grau[k] = data.grau[l]
					data.grau[l] = aux
		
					aux = data.id[k]
					data.id[k] = data.id[l]
					data.id[l] = aux

				end
			end
		end
	end

	global j+=1
end 

println(length(sol))
println(sol)

#printSolution(data, verticeConjIndep) #posso printar os vertices selecionados para o conjunto independente
