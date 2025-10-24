# Problema del Bombero en Julia 🔥

Este repositorio contiene la implementación computacional del problema del bombero utilizando el lenguaje de programación Julia y el enfoque de programación orientada a objetos.

## 📘 Descripción

El problema del bombero es un modelo de propagación de incendios en una gráfica, donde en cada paso del tiempo el fuego se extiende a los vértices adyacentes, y un bombero puede defender un vértice para evitar que se queme. Este proyecto define vértices como estructuras mutables y construye gráficas dinámicas para simular el comportamiento del fuego y las estrategias de defensa.

## 📦 Estructura del proyecto

- `src/` → Código fuente en Julia
- `notebooks/` → Cuadernos de Jupyter con ejemplos y visualizaciones
- `data/` → Datos de entrada o configuraciones de gráficas
- `LICENSE` → Licencia MIT
- `README.md` → Este archivo

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
