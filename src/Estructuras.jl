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
using GraphMakie
using CairoMakie

# -----------------------------------------------------
# Estructuras básicas

@enum Estado begin
    Salvado
    Quemado
    Protegido
end
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
    for i in nodos
        vertices[i] = Vertice(i, Salvado)
    end
    matriz = spzeros(Int, n, n)
    aristas = Set{Tuple{Int, Int}}()
    for (a, b) in lista_aristas
        matriz[a, b] = 1
        matriz[b, a] = 1
        push!(aristas, (a, b))
        push!(aristas, (b, a))  # Si es no dirigido
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
    push!(G.aristas, (a, b))
    push!(G.aristas, (b, a))
    G.matriz[a, b] = 1
    G.matriz[b, a] = 1
end

# -----------------------------------------------------
# 🔥 Funciones para el problema del bombero

# Vecinos de un vértice
function vecinos(G::Grafo, id::Int)
    fila = G.matriz[id, :]
    return [i for i in 1:size(G.matriz, 1) if fila[i] != 0]
end
# Infectar desde nodos quemados
function infectar!(G::Grafo, quemados::Vector{Int})
    nuevos_quemados = Set{Int}()
    for q in quemados
        for v in vecinos(G, q)
            if G.vertices[v].estado == Salvado
                G.vertices[v].estado = Quemado
                push!(nuevos_quemados, v)
            end
        end
    end
    return collect(nuevos_quemados)
end
# Obtener nodos quemados
function nodos_quemados(G::Grafo)
    return [v.id for v in values(G.vertices) if v.estado == Quemado]
end

# -----------------------------------------------------
# 🎨 Visualización del estado del grafo
function estatus_grafo(G::Grafo; karg...)
    colores = Vector{RGB}(undef, length(G.vertices))
    for (i, v) in pairs(G.vertices)
        if v.estado == Salvado
            colores[i] = RGB(120/255, 180/255, 120/255)
        elseif v.estado == Quemado
            colores[i] = RGB(200/255, 0, 0)
        else
            colores[i] = RGB(70/255, 130/255, 180/255)
        end
    end
    H = Graph(G.matriz)
    return gplot(H, nodefillc = colores; karg...)
end
function plotGrafo(G::Grafo; karg...)
    H = Graph(G.matriz)
    return gplot(H; karg...)
end

function simular_bombero!(G::Grafo, inicio::Int, estrategia::Function, turnos::Int, bomberos_por_turno::Int)
    # Inicializar el fuego
    G.vertices[inicio].estado = Quemado
    println("🔥 Inicio del fuego en el nodo $inicio")
    println("\n🔄 Turno 0")
    etiquetas = [string(i) for i in 1:length(G.vertices)]
    display(estatus_grafo(G; nodelabel = etiquetas))
    for t in 1:turnos
        println("\n🔄 Turno $t")

        # Obtener nodos quemados
        quemados = nodos_quemados(G)

        # Aplicar estrategia de protección
        protegidos = estrategia(G, quemados, bomberos_por_turno)
        for p in protegidos
            G.vertices[p].estado = Protegido
        end
        println("🛡️ Nodos protegidos: $(protegidos)")

        # Propagar fuego
        nuevos_quemados = infectar!(G, quemados)
        println("🔥 Nuevos nodos quemados: $(nuevos_quemados)")

        # Mostrar estado del grafo
        display(estatus_grafo(G; nodelabel = etiquetas))
    end
end

# -----------------------------------------------------
