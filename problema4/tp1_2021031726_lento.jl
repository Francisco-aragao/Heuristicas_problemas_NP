using JuMP
using HiGHS

mutable struct Coloracao
    n::Int #numero de objetos
    #v::Array{Int64} #vertices de ida
    #u::Array{Int64} #vertices de volta
    qtdArestas::Int
	vizinhanca::Array{Array{Int}}
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
				vizinhanca[j] = zeros(Int64, n)
			end
		elseif q[1] == "e"
			indice+=1
			v = parse(Int64, q[2])
			u = parse(Int64, q[3])
			vizinhanca[v][u] = 1
			vizinhanca[u][v] = 1
		end
	end
	return Coloracao(n,indice,vizinhanca)
end

function printSolution(data, corIVerticeJ)
	println("Cores:")

	for i = 1: data.n
		for j in 1:data.n
			if value(corIVerticeJ[i,j]) != 0
				println("Vertice $(j) tem cor $(i)");
				#println(" ", value(corIVerticeJ[i,j]))
			end
		end
	end
end

model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")

data = lerArq(file)

@variable(model, coresUsadas[1:data.n], Bin) #uso no máximo n cores
@variable(model, corIVerticeJ[1:data.n, 1:data.n], Bin) # = 1 se uso cor I no vertice J


for i=1:data.n
	@constraint(model, sum(corIVerticeJ[j,i] for j=1:data.n) == 1 ) #cada vertice tem 1 cor
    for j=i:data.n
    	for k=1:data.n
			if (data.vizinhanca[i][j] == 1)
				@constraint(model, corIVerticeJ[k,i] + corIVerticeJ[k,j] <= 1 * coresUsadas[k]) #vertices adjacentes tem cores diferentes
			end       
		end 
   end
end

#Maximizar a quantidade de vertices no conjunto independente
@objective(model, Min, sum(coresUsadas[i] for i=1:data.n))
#@objective(model, Min, sum(corIVerticeJ[i][j] for i=1:data.n , j=1:data.n))

#print(model)

optimize!(model)

sol = objective_value(model)
println("TP1 2021031726 = ", round(sol))

printSolution(data, corIVerticeJ)
