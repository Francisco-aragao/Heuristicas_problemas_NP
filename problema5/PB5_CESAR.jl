using JuMP
using HiGHS


mutable struct LargestSubgraphData
	n::Int # Número de vértices
	edge::Array{Bool, 2} # Se existe aresta entre vértices i e j
	weight::Array{Float64, 2} # Peso das arestas
end


function readData(file)
	n = 0
	edge = zeros(Bool, 0, 0)
	weight = zeros(Float64, 0, 0)

	for l in eachline(file)
		q = split(l, "	")

		if q[1] == "n"
			n = parse(Int64, q[2])
			edge = falses(n, n)
			weight = zeros(Float64, n, n)

		elseif q[1] == "e"
			v1 = parse(Int64, q[2])
			v2 = parse(Int64, q[3])
			w = parse(Float64, q[4])
			
			edge[v1, v2] = true
			weight[v1, v2] = w
		end
	end
	return LargestSubgraphData(n, edge, weight)
end


function printSolution(k, sol)
	selected_vertices = Int[]

	for i in 1:data.n
		if value(k[i]) == 1
			append!(selected_vertices, i)
		end
	end

	list_string = join(selected_vertices, ", ")
	println("TP1 2021031521 = $sol; selected vertices: $list_string")
end


model = Model(HiGHS.Optimizer)

file = open(ARGS[1], "r")
data = readData(file)

# Representa se aresta ij faz parte do subgrafo
@variable(model, x[i=1:data.n, j=1:data.n], Bin)

# Representa se vértice i faz parte ou não do subgrafo induzido
@variable(model, k[i=1:data.n], Bin)

# Var. auxiliar
@variable(model, aux[i=1:data.n, j=1:data.n], Bin)

# Restrições da var. aux
for i = 1:data.n
	for j = 1:data.n
    	@constraint(model, aux[i,j] <= k[i])
		@constraint(model, aux[i,j] <= k[j])

		@constraint(model, aux[i,j] >= k[i] + k[j] - 1)
	end
end

@objective(model, Max, sum(aux[i, j] * data.weight[i, j] for i in 1:data.n, j in 1:data.n))

print(model)

optimize!(model)

if termination_status(model) == MOI.OPTIMAL
    sol = objective_value(model)
    printSolution(k, sol)
else
    println("No optimal solution found.")
end