module Simulator

using Random, Dates
import GraphTypes: Topologia, Estado, topologia_from_grafo, nuevo_estado

export simulate, simulate_from_grafo

const E = Estado

"""
    simulate(top::Topologia, estado::Vector{Estado}, inicio::Int, estrategia::Function;
             max_turnos::Int=100, b::Int=1, p_fire::Float64=1.0, rng=Random.GLOBAL_RNG)

Ejecuta la simulación sobre la topología `top` y el vector de `estado` (mutado in-place).
- `inicio`: nodo donde comienza el fuego (1..n)
- `estrategia`: función con firma `(top, estado, quemados, b; rng) -> Vector{Int}`
- `p_fire`: probabilidad de transmisión por arista (1.0 determinista)
Devuelve un `Dict` con métricas y `historial` por turno.
"""
function simulate(top::Topologia, estado::Vector{E}, inicio::Int, estrategia::Function;
                  max_turnos::Int = 100, b::Int = 1, p_fire::Float64 = 1.0, rng = Random.GLOBAL_RNG)

    n = top.n
    if length(estado) != n
        error("El vector `estado` debe tener longitud top.n = $n")
    end

    # resetear estados a Salvado (por seguridad)
    for i in 1:n
        estado[i] = E.Salvado
    end

    if inicio < 1 || inicio > n
        error("Nodo inicio fuera de rango: $inicio")
    end

    estado[inicio] = E.Quemado

    historial = Vector{Dict{String,Any}}()
    t = 0
    start_time = now()

    while t < max_turnos
        quemados = [i for i in 1:n if estado[i] == E.Quemado]
        if isempty(quemados)
            break
        end

        # aplicar estrategia (se espera que devuelva IDs candidatos)
        candidatos = estrategia(top, estado, quemados, b; rng = rng)
        # filtrar candidatos válidos (salvados)
        protegidos = [p for p in candidatos if 1 <= p <= n && estado[p] == E.Salvado]
        for p in protegidos
            estado[p] = E.Protegido
        end

        # propagar fuego: acumulamos nuevos quemados y aplicamos al final del turno
        nuevos_set = Set{Int}()
        for q in quemados
            for v in top.adj[q]
                if estado[v] == E.Salvado && rand(rng) <= p_fire
                    push!(nuevos_set, v)
                end
            end
        end
        for v in nuevos_set
            estado[v] = E.Quemado
        end

        push!(historial, Dict(
            "turn" => t,
            "quemados" => copy(quemados),
            "protegidos" => copy(protegidos),
            "nuevos" => collect(nuevos_set)
        ))

        t += 1
    end

    elapsed = now() - start_time
    salvados = [i for i in 1:n if estado[i] == E.Salvado]
    quemados_final = [i for i in 1:n if estado[i] == E.Quemado]
    protegidos_final = [i for i in 1:n if estado[i] == E.Protegido]

    result = Dict(
        "turns" => t,
        "elapsed" => elapsed,
        "salvados_pct" => 100 * length(salvados) / max(1, n),
        "salvados" => salvados,
        "quemados" => quemados_final,
        "protegidos" => protegidos_final,
        "historial" => historial
    )

    return result
end

"""
    simulate_from_grafo(G::Any, inicio::Int, estrategia::Function; kwargs...)

Conveniencia: convierte `G` (tu `Grafo` en Main) a `Topologia` y crea un vector de estados,
luego llama a `simulate`. Requiere que `topologia_from_grafo` y `nuevo_estado` estén disponibles.
"""
function simulate_from_grafo(G::Any, inicio::Int, estrategia::Function; kwargs...)
    top = topologia_from_grafo(G)
    estado = nuevo_estado(top.n)
    return simulate(top, estado, inicio, estrategia; kwargs...)
end

end # module
