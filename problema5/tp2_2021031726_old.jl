using JuMP
using HiGHS

mutable struct SubgrafoInduzido
    n::Int #numero de objetos
    #v::Array{Int64} #vertices de ida
    #u::Array{Int64} #vertices de volta
    qtdArestas::Int
	vizinhanca::Array{Array{Float64}}
end

function lerArq(file)
	n = 0
	indice = 0;
	vizinhanca = [[]]
	for l in eachline(file)
		q = split(l, "\t")
		if q[1] == "n" 
			n = parse(Int64, q[2])
			vizinhanca = [[] for i=1:n]
			for j in 1:n
				vizinhanca[j] = zeros(Float64, n)
			end
		elseif q[1] == "e"
			indice+=1
			v = parse(Int64, q[2])
			u = parse(Int64, q[3])
			#vizinhanca[v][u] = 1
			#vizinhanca[u][v] = 1
      		peso = parse(Float64, q[4])
			#  push!(vizinhanca[v], u)
      		vizinhanca[v][u] = peso
			
      #  push!(vizinhanca[u], v)
      		#vizinhanca[u][v] = peso
		end
	end
	return SubgrafoInduzido(n,indice,vizinhanca)
end

function printSolution(conjVerticesS, sol)

	print("TP1 2021031521 = $sol; VERTICES ")
	for i in 1:data.n
		if value(conjVerticesS[i]) == 1
			print("$i ")
		end
	end
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = lerArq(file)

@variable(model, conjVerticesS[1:data.n], Bin) #1 se escolhi vertice i pro conjunto S

@variable(model, conjVerticesSIJ[i=1:data.n, j=1:data.n], Bin) #1 se escolhi vertice i e j pro conjunto S

for i=1:data.n
	for j=1:data.n
		if (data.vizinhanca[i][j] != 0)
			#preciso garantir que nova variavel conjVerticesSIJ possua o vertice I e o vertice J
			@constraint(model, conjVerticesSIJ[i,j] <= conjVerticesS[i])
			@constraint(model, conjVerticesSIJ[i,j] <= conjVerticesS[j])
			@constraint(model, conjVerticesSIJ[i,j] >= conjVerticesS[i] + conjVerticesS[j] - 1)
		end
	end
end

#Maximizar o peso dos vertices escolhidos para o conjunto S
@objective(model, Max, sum(data.vizinhanca[i][j] * conjVerticesSIJ[i,j] for i=1:data.n, j=1:data.n))

#print(model)

optimize!(model)

sol = objective_value(model)
println("TP1 2021031726 = ", round(sol))

#printSolution(conjVerticesS, sol) #posso printar vertices selecionados
