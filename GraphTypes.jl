module GraphTypes

using SparseArrays, Random

# Si ya existe `Estado` en Main (tu código original), lo reutilizamos.
if isdefined(Main, :Estado)
    const Estado = Main.Estado
else
    @enum Estado Salvado Quemado Protegido
end

export Estado, Topologia, topologia_from_edges, topologia_from_sparsematrix,
       topologia_from_grafo, nuevo_estado

"""
    struct Topologia

Estructura ligera que representa la topología del grafo mediante listas de adyacencia.
- `n`: número de nodos (asumimos nodos 1..n)
- `adj`: Vector{Vector{Int}} con vecinos para cada vértice
"""
struct Topologia
    n::Int
    adj::Vector{Vector{Int}}
end

"""
    topologia_from_edges(lista_aristas::Vector{Tuple{Int,Int}}) -> Topologia

Construye una Topologia a partir de una lista de aristas (tuplas `(a,b)`).
Normaliza aristas y evita bucles.
"""
function topologia_from_edges(lista_aristas::Vector{Tuple{Int,Int}})
    if isempty(lista_aristas)
        return Topologia(0, Vector{Vector{Int}}())
    end
    nodos = unique(vcat([a for (a,_) in lista_aristas], [b for (_,b) in lista_aristas]))
    n = maximum(nodos)
    adj = [Int[] for _ in 1:n]
    seen = Set{Tuple{Int,Int}}()
    for (a,b) in lista_aristas
        if a == b
            continue
        end
        u, v = min(a,b), max(a,b)
        if (u,v) in seen
            continue
        end
        push!(seen, (u,v))
        push!(adj[a], b)
        push!(adj[b], a)
    end
    return Topologia(n, adj)
end

"""
    topologia_from_sparsematrix(mat::SparseMatrixCSC) -> Topologia

Construye Topologia a partir de una matriz de adyacencia dispersa (fila i -> vecinos).
Asume índices 1..n.
"""
function topologia_from_sparsematrix(mat::SparseMatrixCSC{<:Integer,<:Integer})
    n = size(mat, 1)
    adj = [Int[] for _ in 1:n]
    for i in 1:n
        # findnz devuelve (I,J,V) para la submatriz; las columnas no nulas están en J
        _, cols, _ = findnz(mat[i, :])
        for j in cols
            if i != j
                push!(adj[i], j)
            end
        end
    end
    return Topologia(n, adj)
end

"""
    topologia_from_grafo(G::Any) -> Topologia

Convierte una instancia de `Grafo` (si existe en Main) a `Topologia`.
Busca `G.matriz` primero; si no existe, intenta usar `G.aristas`.
Lanza error si no puede convertir.
"""
function topologia_from_grafo(G::Any)
    if isdefined(Main, :Grafo) && isa(G, Main.Grafo)
        if hasproperty(G, :matriz) && !isempty(G.matriz)
            return topologia_from_sparsematrix(G.matriz)
        elseif hasproperty(G, :aristas)
            # G.aristas puede contener ambas direcciones; normalizamos
            edges = Set{Tuple{Int,Int}}()
            for (a,b) in G.aristas
                if a == b
                    continue
                end
                push!(edges, (min(a,b), max(a,b)))
            end
            return topologia_from_edges(collect(edges))
        else
            error("Grafo no tiene 'matriz' ni 'aristas' reconocibles.")
        end
    else
        error("No se reconoce el tipo `Grafo` en Main. Usa `topologia_from_edges` o `topologia_from_sparsematrix`.")
    end
end

"""
    nuevo_estado(n::Int) -> Vector{Estado}

Crea un vector de estados inicial (todos `Salvado`) de longitud `n`.
"""
function nuevo_estado(n::Int)
    fill(Estado.Salvado, n)
end

end # module
