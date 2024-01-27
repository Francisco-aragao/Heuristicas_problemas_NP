mutable struct Lotsizing
    n::Int #numero de periodos
    custo::Array{Int}
    demanda::Array{Int}
    estoque::Array{Int}
    multa::Array{Int}
end

function lerArq(file)
	n = 0
  custo = Int64[]
  demanda =Int64[] 
  estoque = Int64[]
  multa = Int64[]
  indice = 0
	for l in eachline(file)
		q = split(l, "\t")
		if q[1] == "n" 
			n = parse(Int64, q[2])
			custo = zeros(Int64, n)
			demanda = zeros(Int64, n)
      estoque = zeros(Int64, n)
      multa = zeros(Int64, n)
		elseif q[1] == "c"
      indice = parse(Int64, q[2])
      custo[indice] = parse(Int64, q[3])
		elseif q[1] == "d"
      indice = parse(Int64, q[2])
      demanda[indice] = parse(Int64, q[3])
    elseif q[1] == "s"
      indice = parse(Int64, q[2])
      estoque[indice] = parse(Int64, q[3])
    elseif q[1] == "p"
      indice = parse(Int64, q[2])
      multa[indice] = parse(Int64, q[3])
    end
	end
	return Lotsizing(n,custo,demanda, estoque, multa)
end

function printSolution(data, x)
	println("Producoes:")
	for i = 1: data.n
		println("Producao periodo $(i): $(value(x[i]))");
	end
end


file = open(ARGS[1], "r")

data = lerArq(file)

#= #conjunto independente
@variable(model, qtdProdI[1:data.n] >= 0)
@variable(model, estoqueI_J[1:data.n] >= 0) #estoquei no fim do periodo i
@variable(model, atraseiI[1:data.n] >= 0)

@constraint(model, estoqueI_J[data.n] == 0) #estoque fim tem que ser 0
@constraint(model, atraseiI[data.n] == 0) #atraso fim tem que ser 0 -> satisfaço todas as demandas

@constraint(model, qtdProdI[1] == data.demanda[1] + estoqueI_J[1] - atraseiI[1]) #defino producao inicial 

for i=2:data.n
	#relaciono todas as variaveis: producao atual = demanda atual - atraso atual + estoque atual + atraso anterior - estoque anterior
	@constraint(model,  qtdProdI[i] == data.demanda[i] + estoqueI_J[i] - atraseiI[i] - estoqueI_J[i-1] + atraseiI[i-1] )
end

#Minimizo os gastos com atrasos, estoque e producao
@objective(model, Min, sum((qtdProdI[i]*data.custo[i]) + (estoqueI_J[i]*data.estoque[i]) + (atraseiI[i]*data.multa[i]) for i=1:data.n))
 =#
#print(model)


#printSolution(data, qtdProdI)
