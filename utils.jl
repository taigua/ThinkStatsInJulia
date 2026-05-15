using DataFrames
using DuckDB
using FreqTables
using PrettyTables

function read_parquet(filepath::AbstractString)::DataFrame    
    con = DBInterface.connect(DuckDB.DB, ":memory:")
    DataFrame(DBInterface.execute(con, "SELECT * FROM read_parquet('$filepath')"))
end

function value_count(df::DataFrame, field::Symbol; skipmissing::Bool=true)
    ft = freqtable(df[!, field], skipmissing=skipmissing)
    pretty_table(HTML, (field => names(ft, 1), count = vec(ft)))
end