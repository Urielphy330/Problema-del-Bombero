#--------------------------------------------
# Estructuras básicas para grafos
# Autor: Uriel Villanueva Alcala
#--------------------------------------------

# Librerias básicas para grafos.
using LinearAlgebra
using SparseArrays
using Random
using Pkg
using Colors
using Graphs, GraphPlot
using Graphs, MetaGraphsNext
using Plots
#using GraphMakie
#using CairoMakie

# -----------------------------------------------------
# Estructuras básicas

# Reemplaza tu @enum Estado por:
@enum Estado::UInt8 Salvado=0 Quemado=1 Protegido=2

mutable struct Vertice
    id::Int              # Identificador único
    estado::Estado       # Estado actual del nodo
end
mutable struct Grafo
    vertices::Dict{Int, Vertice}                # Acceso rápido por ID
    aristas::Set{Tuple{Int, Int}}         # Conjunto de aristas únicas
    matriz::SparseMatrixCSC{Int, Int}           # Matriz de adyacencia
end

## Construcción de un grafo vacio
function Grafo(n::Int)
    vertices = Dict{Int, Vertice}()
    for i in 1:n
        vertices[i] = Vertice(i, Salvado)
    end
    matriz = spzeros(Int, n, n)
    aristas = Set{Tuple{Int, Int}}()
    return Grafo(vertices, aristas, matriz)
end

## Construcción desde listas de aristas
function Grafo(lista_aristas::Vector{Tuple{Int, Int}})
    nodos = unique(vcat([a for (a, _) in lista_aristas], [b for (_, b) in lista_aristas]))
    n = maximum(nodos)
    vertices = Dict{Int, Vertice}()
    for i in 1:n
        vertices[i] = Vertice(i, Salvado)
    end
    matriz = spzeros(Int, n, n)
    aristas = Set{Tuple{Int, Int}}()
    for (a, b) in lista_aristas
        if a == b
            continue
        end
        u, v = min(a,b), max(a,b)
        if !( (u,v) in aristas )
            push!(aristas, (u,v))
            matriz[a, b] = 1
            matriz[b, a] = 1
        end
    end
    return Grafo(vertices, aristas, matriz)
end

# Obtener un vértice por ID
function obtener_vertice(G::Grafo, id::Int)
    return G.vertices[id]
end

# Agregar vértice
function agregar_vertice!(G::Grafo, id::Int)
    G.vertices[id] = Vertice(id, Salvado)
    n = size(G.matriz, 1)
    if id > n
        nueva_matriz = spzeros(Int, id, id)
        for i in 1:n, j in 1:n
            nueva_matriz[i, j] = G.matriz[i, j]
        end
        G.matriz = nueva_matriz
    end
end

# Agregar arista
function agregar_arista!(G::Grafo, a::Int, b::Int)
    # asegurar existencia de vértices
    if !haskey(G.vertices, a)
        agregar_vertice!(G, a)
    end
    if !haskey(G.vertices, b)
        agregar_vertice!(G, b)
    end
    u, v = min(a,b), max(a,b)
    # almacenar una sola representación para no dirigido
    if !( (u,v) in G.aristas )
        push!(G.aristas, (u,v))
        G.matriz[a,b] = 1
        G.matriz[b,a] = 1
    end
end

# -----------------------------------------------------
# 🔥 Funciones para el problema del bombero

# Vecinos de un vértice
function vecinos(G::Grafo, id::Int)
    _, cols, _ = findnz(G.matriz[id, :])
    return collect(cols)
end
# Infectar desde nodos quemados
function infectar!(G::Grafo, quemados::Vector{Int}; p_fire::Float64 = 1.0, rng = Random.GLOBAL_RNG)
    nuevos = Set{Int}()
    for q in quemados
        for v in vecinos(G, q)
            if G.vertices[v].estado == Salvado && rand(rng) <= p_fire
                push!(nuevos, v)
            end
        end
    end
    for v in nuevos
        G.vertices[v].estado = Quemado
    end
    return collect(nuevos)
end

# Obtener nodos quemados
function nodos_quemados(G::Grafo)
    return [v.id for v in values(G.vertices) if v.estado == Quemado]
end

# -----------------------------------------------------
# 🎨 Visualización del estado del grafo
function estatus_grafo(G::Grafo; karg...)
    n = size(G.matriz, 1)
    colores = [RGB(0.9,0.9,0.9) for _ in 1:n]  # color por defecto
    for i in 1:n
        if haskey(G.vertices, i)
            v = G.vertices[i]
            if v.estado == Salvado
                colores[i] = RGB(120/255, 180/255, 120/255)
            elseif v.estado == Quemado
                colores[i] = RGB(200/255, 0, 0)
            else
                colores[i] = RGB(70/255, 130/255, 180/255)
            end
        end
    end
    H = Graph(G.matriz)
    return gplot(H, nodefillc = colores; karg...)
end

function plotGrafo(G::Grafo; karg...)
    H = Graph(G.matriz)
    return gplot(H; karg...)
end

function simular_bombero!(G::Grafo, inicio::Int, estrategia::Function;
                         max_turnos::Int = 100, bomberos_por_turno::Int = 1,
                         p_fire::Float64 = 1.0, rng = Random.GLOBAL_RNG)
    # resetear estados si es necesario
    for v in values(G.vertices)
        v.estado = Salvado
    end
    G.vertices[inicio].estado = Quemado
    historial = []
    t = 0
    while t < max_turnos
        quemados = nodos_quemados(G)
        if isempty(quemados)
            break
        end
        # estrategia debe devolver vértices válidos; filtramos por seguridad
        candidatos = estrategia(G, quemados, bomberos_por_turno)
        protegidos = [p for p in candidatos if haskey(G.vertices, p) && G.vertices[p].estado == Salvado]
        for p in protegidos
            G.vertices[p].estado = Protegido
        end
        nuevos = infectar!(G, quemados; p_fire = p_fire)
        push!(historial, (turn = t, quemados = copy(quemados), protegidos = copy(protegidos), nuevos = copy(nuevos)))
        t += 1
    end
    return (turns = t, historial = historial, salvados = [v.id for v in values(G.vertices) if v.estado == Salvado])
end
# ----------------------------------------------------------------------------------------------------
# Con esta separación puedes implementar estrategias que usen top.adj 
# y estado sin tocar matrices dispersas, y convertir a Graph solo para visualización si lo necesitas.
# ----------------------------------------------------------------------------------------------------

# Topología simple y vector de estados
struct Topologia
    n::Int
    adj::Vector{Vector{Int}}   # listas de adyacencia 1..n
end

function Topologia_from_edges(lista_aristas::Vector{Tuple{Int,Int}})
    nodos = unique(vcat([a for (a,_) in lista_aristas], [b for (_,b) in lista_aristas]))
    n = maximum(nodos)
    adj = [Int[] for _ in 1:n]
    for (a,b) in lista_aristas
        push!(adj[a], b)
        push!(adj[b], a)
    end
    return Topologia(n, adj)
end

# Estado separado
const EstadoVec = Vector{Estado}

function nuevo_estado(n::Int)
    fill(Salvado, n)
end

# infectar con adjlist
function infectar_adj!(top::Topologia, estado::EstadoVec, quemados::Vector{Int}; p_fire::Float64 = 1.0)
    nuevos = Set{Int}()
    for q in quemados
        for v in top.adj[q]
            if estado[v] == Salvado && rand() <= p_fire
                push!(nuevos, v)
            end
        end
    end
    for v in nuevos
        estado[v] = Quemado
    end
    return collect(nuevos)
end
