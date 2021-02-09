function loadinputs(folder::String)

    p_D_rowdata=CSV.File(folder *"/demand.csv") |> Tables.matrix
    p_D=p_D_rowdata'

    p_D_MW=p_D*max_demand
    D= maximum(sum(p_D_MW, dims=1))

    Τ=CSV.File(folder *"/carbontax_scenarios.csv") |> Tables.matrix

    wind_rowdata= CSV.File(folder *"/wind_existing.csv") |> Tables.matrix
    wind=wind_rowdata'

    wind_opt_rowdata= CSV.File(folder *"/wind_options.csv") |> Tables.matrix

    wind_opt=wind_opt_rowdata'

    Ns_H= CSV.File(folder *"/weights.csv") |> Tables.matrix


return (p_D,D,Τ,wind,wind_opt,Ns_H)
end

#do read headers
#Write a Csv file
#=
https://stackoverflow.com/questions/54410030/read-csv-into-array
df = DataFrame(rand(2,3))
CSV.write("test.csv", df)
CSV.File("test.csv") |> Tables.matrix
=#
