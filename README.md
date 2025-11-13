# Problema del Bombero en gráficas simples 🔥

Repositorio para el proyecto de investigación sobre el Problema del Bombero en teoría de gráficas.
Contiene simulador en Julia, heurísticas, experimentos en gráficas aleatorias y resultados reproducibles.

## ✍️ Autor
Desarrollado por Uriel Villanueva Alcala. Contacto: urielalcala330@ciencias.unam.mx

## 📘 Descripción

El problema del bombero es un modelo de propagación de incendios en una gráfica, donde en cada paso del tiempo el fuego se extiende a los vértices adyacentes, y un bombero puede defender un vértice para evitar que se queme. Este proyecto define vértices como estructuras mutables y construye gráficas dinámicas para simular el comportamiento del fuego y las estrategias de defensa.

## 📦 Estructura del proyecto

- `src/` Código Julia
- `scripts/` Scripts de ejecución
- `data/` Resultados
- `notebooks/` Análisis y visualización
- `tests/` Pruebas unitarias

## 🚀 Requisitos

- Julia 1.9 o superior
- Paquetes recomendados:
  - `Graphs.jl`
  - `Plots.jl`
  - `DataFrames.jl` (si se usan datos tabulares)

Instalación de paquetes:
```julia
using Pkg
Pkg.add("Graphs")
Pkg.add("Plots")


