using JuMP
using HiGHS

mutable struct Coloracao
    n::Int #numero de objetos
    qtdArestas::Int
	vizinhanca::Array{Array{Int}}
end

function lerArq(file)
	n = 0
	qtdArestas = 0;
	vizinhanca = [[]]
	for l in eachline(file)
		q = split(l, "\t")
		if q[1] == "n" 
			n = parse(Int64, q[2])
			vizinhanca = [[] for i=1:n]
		elseif q[1] == "e"
			qtdArestas+=1
			v = parse(Int64, q[2])
			u = parse(Int64, q[3])
			push!(vizinhanca[v], u)
			push!(vizinhanca[u], v)
		end
	end
	return Coloracao(n,qtdArestas,vizinhanca)
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
    for j in data.vizinhanca[i]
    	for k=1:data.n
			@constraint(model, corIVerticeJ[k,i] + corIVerticeJ[k,j] <= coresUsadas[k]) #vertices adjacentes tem cores diferentes
		end 
   end
end

#Maximizar a quantidade de vertices no conjunto independente
@objective(model, Min, sum(coresUsadas[i] for i=1:data.n))

#print(model)

optimize!(model)

sol = objective_value(model)
println("TP1 2021031726 = ", round(sol))

#printSolution(data, corIVerticeJ) #posso imprimir as cores de cada vértice
