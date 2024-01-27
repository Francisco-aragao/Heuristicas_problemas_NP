using JuMP
using HiGHS


mutable struct LotsizingData
	n::Int # Número de meses
	prod_cost::Array{Int64} 
	demand::Array{Int64} 
	stock_cost::Array{Int64} 
	fine_cost::Array{Int64} 
end


function readData(file)
	n = 0
	prod_cost = Int64[]
	demand = Int64[]
	stock_cost = Int64[]
	fine_cost = Int64[]

	for l in eachline(file)
		q = split(l, "	")

		if q[1] == "n"
			n = parse(Int64, q[2])
			append!(prod_cost, zeros(n))
			append!(demand, zeros(n))
			append!(stock_cost, zeros(n))
			append!(fine_cost, zeros(n))
			
		else
			value = parse(Int64, q[3])
			index = parse(Int64, q[2])
			
			if q[1] == "c"
				prod_cost[index] = value
			elseif q[1] == "d"
				demand[index] = value
			elseif q[1] == "s"
				stock_cost[index] = value
			elseif q[1] == "p"
				fine_cost[index] = value
			end
		end
	end
	return LotsizingData(n, prod_cost, demand, stock_cost, fine_cost)
end

function main()
	model = Model(HiGHS.Optimizer)

	file = open(ARGS[1], "r")
	data = readData(file)

	# Create array where element is produced at week i
	prod = zeros(Int, data.n)

	# decide whether I should produce or save @ week i
	current_production = 1
	prod[1] = 1
	for i = 2:data.n
		stocking_cost = data.prod_cost[current_production]

		for j = current_production:i-1
			stocking_cost += data.stock_cost[j]
		end
		
		if stocking_cost > data.prod_cost[i]
			prod[i] = i
			current_production = i
		else
			# println("Week $i is being produced @ week $current_production -> $stocking_cost vs $(data.prod_cost[i])")
			prod[i] = current_production
		end
	end

	# decide whether I should run late @ week i
	# HERE
	current_production = data.n
	for i = (data.n-1):-1:1
		fees_cost = data.prod_cost[current_production]

		for j = i:current_production-1
			fees_cost += data.fine_cost[j]
		end
		#println("prod[i] = $(prod[i]), i = $i, $current_production")
		if prod[i] == i
			# If it's better to run late
			#println("Fees $fees_cost, production cost $(data.prod_cost[i])")
			if fees_cost < data.prod_cost[i]
				prod[i] = current_production
			end
		else
			# If it's better to run late
			stock_costs = data.prod_cost[prod[i]]

			for j = prod[i]:i-1
				stock_costs += data.stock_cost[j]
			end

			if fees_cost < stock_costs
				prod[i] = current_production
			end
		end

		if prod[i] != 0
			current_production = i
		end
	end

	# Prints answer
	sum = 0
	certificate = zeros(Int, data.n)
	
	for i = 1:data.n
		if prod[i] < i 
			for j = prod[i]:i-1
				sum += data.demand[i] * data.stock_cost[j]
			end
		elseif prod[i] > i
			for j = i:prod[i]-1
				sum += data.demand[i] * data.fine_cost[j]
			end
		end

		sum += data.demand[i] * data.prod_cost[prod[i]]

		certificate[prod[i]] += data.demand[i] 
	end

	println("TP2 2021031726 = $sum")
	println(join(certificate, "\t"))
end

main()