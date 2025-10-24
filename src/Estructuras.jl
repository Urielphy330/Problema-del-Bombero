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

# -----------------------------------------------------
# Estructuras básicas
mutable struct vertice
    estado::Symbol
    etiqueta::String
end
mutable struct Grafo
    vertices::Array{vertice, 1}
    aristas::Array
    matriz::SparseMatrixCSC
end

#-------------------------------------------------------------------
# Funciones para la creación de gráficas

# Grafo Trivial de orden n
function Grafo(n::Int)
    vertices = [vertice(:Salvado, "$i") for i in 1 : n]
    M = zeros(n,n)
    M = sparse(M)
    return Grafo(vertices, [ ()  ], M)
end

# Grafo a partir de matriz de adyacencias
function Grafo(M::SparseMatrixCSC)
    vertices = [vertice(:Salvado,"$i") for i in 1 : size(M)[1]]
    aristas = [(vertices[1],vertices[1])]
    for j in size(M)[2]:-1:1
        for i in 1:j
            if M[i,j] == 1
                aristas = append!(aristas,[(vertices[i], vertices[j])])
            end
        end
    end
    aristas = aristas[2:end]
    return Grafo(vertices,aristas, M)
end

#Grafo a partir de lista de aristas
function Grafo(X::Array)
    vert = []
    for i in X
        vert = append!(vert,[i[1]])
        vert = append!(vert,[i[2]])
    end
    M = zeros(Int,length(unique!(vert)),length(unique!(vert)))
    M = sparse(M)
    vertices = [vertice(:Salvado,"$i") for i in unique!(vert) ]
    for i in X
        M[i[1], i[2]] = 1
        M[i[2], i[1]] = 1
    end
    return Grafo(vertices, X, M)
end

# ------------------------------------------------------------------
# Funciones básicas sobre gráficas

# Búsqueda de un vértice por su etiqueta
function vertice(G::Grafo, i)
    v = [parse(Int,j.etiqueta) for j in G.vertices]
    a = findall(x -> x == i, v)[1]
    return G.vertices[a]
end

# Agregar un vértice al grafo
function add_vertice(G, a::vertice)
    n = length(G.vertices)
    v = append!(G.vertices, [a])
    m = G.matriz 
    M = zeros(Int8, n + 1, n+1)
    M = sparse(M)
    for i in 1:n
        for j in 1:n
            M[i,j] = m[i,j]
        end
    end
    return Grafo(v, G.aristas, M)
end

# Agregar una arista al grafo
function add_arista(G, a::Tuple)
    E = G.aristas
    c,d = a[1],a[2]
    E = append!(E,[vertice(:Salvado, "$c") , vertice(:Salvado, "$d")])
    M = G.matriz
    M[c,d] = 1
    M[d,c] = 1
    return Grafo(G.vertices, E, M)
end

# Gráficar de forma básica
function plotGrafo(G; karg...)
    M = G.matriz
    H = Graph(M)
    return gplot(H; karg...)
end

# ------------------------------------------------------------------------
# Funciones para el problema del Bombero

# Vecinos de un vértice
function vecinos(G, A::vertice)
    i = parse.(Int, A.etiqueta)
    v = G.matriz[i,1:end]
    B = [i for i in 1:length(v) if v[i] != 0]
    G.vertices[B]
end  
function vecinos(G, A::Int)
    v = G.matriz[A,1:end]
    B = [i for i in 1:length(v) if v[i] != 0]
    return B
end

# Infección a partir de un vértice
function infectar(G::Grafo, v::Array)
    for i in v
        for j in vecinos(G, i)
            if j.estado != :Protegido
                j.estado = :Quemado
            end
        end
    end
    return G
end

# Vértices en llamas.
function infectados(G)
    A = [i for i in 1:length(G.vertices) if G.vertices[i].estado == :Quemado]
    return G.vertices[A]
end

# Representación gráfica del estatus
function estatus_grafo(G::Grafo; karg...)
    A = [i.estado for i in G.vertices]
    colores = [RGB(0,0,0) for _ in 1:length(A) ]
    for i in 1:length(A)
        if A[i] == :Salvado
            colores[i] = RGB(0,236/256,110/256)
        elseif A[i] == :Quemado
            colores[i] = RGB(232/256, 0 , 31/256)
        else 
            colores[i] = RGB(0, 204/256 , 204/256)
        end
    end
    return plotGrafo(G,nodefillc = colores; karg...)
end
