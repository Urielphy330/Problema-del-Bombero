using Random
include("GraphTypes.jl")

export grado_strategy, aleatoria_strategy, cercania_strategy, bfs_strategy, dfs_strategy

const Estado = Main.Estado
const E = Estado

# --- Utilidades internas ---------------------------------------------------

# BFS multi-fuente: devuelve vector de distancias (Inf si no alcanzable)
function _multi_source_bfs(top::Topologia, fuentes::Vector{Int})
    n = top.n
    dist = fill(typemax(Int), n)   # usar un entero grande como "infinito"
    q = Vector{Int}()
    for s in fuentes
        if 1 <= s <= n
            dist[s] = 0
            push!(q, s)
        end
    end
    head = 1
    while head <= length(q)
        v = q[head]; head += 1
        for u in top.adj[v]
            if dist[u] == typemax(Int)
                dist[u] = dist[v] + 1
                push!(q, u)
            end
        end
    end
    # convertir "infinito" a -1 para indicar no alcanzable (más cómodo)
    for i in 1:n
        if dist[i] == typemax(Int)
            dist[i] = -1
        end
    end
    return dist
end

# BFS desde una fuente única (devuelve dist vector)
function _bfs_from(top::Topologia, s::Int)
    n = top.n
    dist = fill(-1, n)
    if s < 1 || s > n
        return dist
    end
    dist[s] = 0
    q = [s]
    head = 1
    while head <= length(q)
        v = q[head]; head += 1
        for u in top.adj[v]
            if dist[u] == -1
                dist[u] = dist[v] + 1
                push!(q, u)
            end
        end
    end
    return dist
end

# --- Estrategias exportadas -----------------------------------------------

"""
    grado_strategy(top, estado, quemados, b; rng)

Selecciona hasta `b` vértices salvados con mayor grado (número de vecinos).
"""
function grado_strategy(top::Topologia, estado::Vector{E}, quemados::Vector{Int}, b::Int; rng=Random.GLOBAL_RNG)
    candidates = [i for i in 1:top.n if estado[i] == Salvado]
    sort!(candidates, by = i -> length(top.adj[i]), rev = true)
    return candidates[1:min(b, length(candidates))]
end

"""
    aleatoria_strategy(top, estado, quemados, b; rng)

Selecciona hasta `b` vértices salvados al azar.
"""
function aleatoria_strategy(top::Topologia, estado::Vector{E}, quemados::Vector{Int}, b::Int; rng=Random.GLOBAL_RNG)
    candidates = [i for i in 1:top.n if estado[i] == Salvado]
    shuffle!(rng, candidates)
    return candidates[1:min(b, length(candidates))]
end

"""
    bfs_strategy(top, estado, quemados, b)

Selecciona hasta `b` vértices salvados más cercanos al frente (distancia mínima a cualquier quemado).
"""
function bfs_strategy(top::Topologia, estado::Vector{E}, quemados::Vector{Int}, b::Int; rng=Random.GLOBAL_RNG)
    if isempty(quemados)
        return Int[]
    end
    dist = _multi_source_bfs(top, quemados)
    candidates = [i for i in 1:top.n if estado[i] == Salvado && dist[i] != -1]
    sort!(candidates, by = i -> dist[i])
    return candidates[1:min(b, length(candidates))]
end

"""
    cercania_strategy(top, estado, quemados, b)

Heurística basada en 'cercanía' al conjunto de quemados: calcula la distancia media
desde cada vértice salvado a todos los quemados y selecciona los de menor media.
(Es más costosa que `bfs_strategy` si hay muchos quemados.)
"""
function cercania_strategy(top::Topologia, estado::Vector{E}, quemados::Vector{Int}, b::Int; rng=Random.GLOBAL_RNG)
    if isempty(quemados)
        return Int[]
    end
    nb = length(quemados)
    n = top.n
    sumdist = fill(0.0, n)
    reachable_count = fill(0, n)
    # para cada quemado, hacemos BFS y acumulamos distancias
    for s in quemados
        d = _bfs_from(top, s)
        for i in 1:n
            if d[i] != -1
                sumdist[i] += d[i]
                reachable_count[i] += 1
            end
        end
    end
    # calcular media (si no alcanzable, asignar Inf)
    avgdist = fill(Inf, n)
    for i in 1:n
        if reachable_count[i] > 0
            avgdist[i] = sumdist[i] / reachable_count[i]
        end
    end
    candidates = [i for i in 1:n if estado[i] == Salvado && isfinite(avgdist[i])]
    sort!(candidates, by = i -> avgdist[i])
    return candidates[1:min(b, length(candidates))]
end

"""
    dfs_strategy(top, estado, quemados, b)

Realiza un DFS desde el primer quemado (si existe) y protege los primeros `b`
vértices salvados en el orden DFS.
"""
function dfs_strategy(top::Topologia, estado::Vector{E}, quemados::Vector{Int}, b::Int; rng=Random.GLOBAL_RNG)
    if isempty(quemados)
        return Int[]
    end
    start = quemados[1]
    visited = falses(top.n)
    order = Int[]
    function _dfs(v)
        visited[v] = true
        push!(order, v)
        for u in top.adj[v]
            if !visited[u]
                _dfs(u)
            end
        end
    end
    _dfs(start)
    # filtrar solo salvados
    candidates = [v for v in order if estado[v] == Salvado]
    return candidates[1:min(b, length(candidates))]
end
