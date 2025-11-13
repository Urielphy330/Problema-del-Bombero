# Plan de trabajo de 12 semanas

Este documento describe un plan de trabajo de 12 semanas para el proyecto **Problema del Bombero**. Incluye objetivos semanales, tareas concretas, entregables y criterios de éxito. Está pensado para guiar el desarrollo del simulador en Julia, la ejecución de experimentos en gráficas aleatorias, la exploración de variantes estocásticas y la preparación de un borrador publicable.

---

## Resumen de hitos

- **Hito 1 (Semana 4):** Simulador robusto (determinista y estocástico) y pipeline de experimentos funcional.  
- **Hito 2 (Semana 8):** Resultados comparativos en ER/BA/WS y análisis de umbrales frente a \(b\) y grado medio.  
- **Hito 3 (Semana 10):** Heurística mejorada (greedy submodular o híbrida) o prototipo RL básico.  
- **Hito 4 (Semana 12):** Borrador de manuscrito y repositorio reproducible con código, datos y figuras.

---

## Cronograma detallado

### Semana 1 — Consolidación y diseño
**Objetivo:** cerrar especificación del simulador y protocolo experimental.  
**Tareas:**
- Formalizar orden de acciones por turno y estados (quemado, defendido, susceptible).
- Definir parámetros experimentales: tamaños \(n\), grado medio, \(b\), repeticiones, tipos de foco.
- Estructurar el proyecto en módulos Julia: `Generators`, `Strategies`, `Simulator`, `Experiments`.
**Entregables:** documento de especificación y estructura de carpetas.  
**Criterio de éxito:** decisiones documentadas y repositorio inicial.

### Semana 2 — Simulador determinista estable
**Objetivo:** implementar simulador determinista con las 5 heurísticas.  
**Tareas:**
- Implementar `simulate_fire!` y las estrategias: grado, aleatoria, cercanía, BFS, DFS.
- Escribir pruebas unitarias básicas (estados válidos, invariantes).
- Perfilado inicial de rendimiento.
**Entregables:** paquete mínimo con tests que pasan.  
**Criterio de éxito:** simulador reproduce casos de control (grillas, árboles).

### Semana 3 — Generadores y pipeline ER/BA/WS
**Objetivo:** generar instancias calibradas y montar pipeline de ejecución.  
**Tareas:**
- Implementar generadores ER, BA, WS con control de grado medio.
- Manejar componente gigante y selección de foco.
- Script maestro para ejecutar lotes y guardar resultados en CSV.
**Entregables:** scripts de generación y ejecución por lotes.  
**Criterio de éxito:** 30+ corridas por combinación con logs y CSV.

### Semana 4 — Métricas y visualización
**Objetivo:** definir métricas y producir figuras comparativas iniciales.  
**Tareas:**
- Implementar cálculo de métricas: % salvados, tiempo de contención, área quemada, varianza.
- Generar gráficas: barras, líneas vs. \(b\), boxplots.
**Entregables:** notebook con tablas y figuras preliminares.  
**Criterio de éxito:** patrones interpretables por familia de grafos.

### Semana 5 — Dinámica estocástica
**Objetivo:** introducir propagación probabilística y recursos variables.  
**Tareas:**
- Implementar propagación Bernoulli por aristas con parámetro \(p_{fire}\).
- Permitir \(b_t\) variable por turno y ventanas de disponibilidad.
- Comparar heurísticas deterministas vs. estocásticas.
**Entregables:** resultados comparativos y análisis de robustez.  
**Criterio de éxito:** diferencias cuantificadas y documentadas.

### Semana 6 — Análisis de umbrales y mapas de fase
**Objetivo:** mapear regiones de contención/fracaso en el espacio de parámetros.  
**Tareas:**
- Barridos en mallas de parámetros: \(b\), \(\langle k\rangle\), \(p_{fire}\), \(r_{WS}\).
- Generar heatmaps y curvas críticas.
**Entregables:** figuras de umbrales y texto explicativo.  
**Criterio de éxito:** identificación de \(b\) crítico por familia.

### Semana 7 — Heurística mejorada
**Objetivo:** diseñar e implementar una heurística superior (greedy submodular o híbrida).  
**Tareas:**
- Definir función objetivo marginal (vértices salvados por defensa).
- Implementar greedy con recomputación local y desempates razonados.
- Evaluar frente a las 5 heurísticas básicas.
**Entregables:** implementación y comparativa estadística.  
**Criterio de éxito:** mejora significativa en al menos una familia de grafos.

### Semana 8 — Validación en redes reales
**Objetivo:** probar generalización en redes reales pequeñas.  
**Tareas:**
- Seleccionar redes reales (colaboración, rutas, pequeñas redes sociales).
- Ejecutar pipeline y comparar resultados con sintéticos.
**Entregables:** sección de caso real con figuras y análisis.  
**Criterio de éxito:** coherencia con intuiciones topológicas.

### Semana 9 — Robustez y sensibilidad al foco
**Objetivo:** analizar impacto del foco inicial y múltiples focos.  
**Tareas:**
- Experimentos con focos en hubs, periféricos y focos múltiples.
- Análisis estadístico de sensibilidad y varianza.
**Entregables:** tablas y figuras de sensibilidad.  
**Criterio de éxito:** conclusiones claras sobre vulnerabilidad.

### Semana 10 — RL básico o refinamiento teórico
**Objetivo:** prototipo de política RL o consolidación de observaciones teóricas.  
**Tareas (RL):**
- Definir espacio de estado local y acciones; recompensa por vértices salvados.
- Entrenar política simple y comparar con heurísticas.
**Tareas (teoría):**
- Formalizar conjeturas sobre cotas y umbrales basadas en resultados empíricos.
**Entregables:** prototipo RL o sección teórica con lemas/conjeturas.  
**Criterio de éxito:** evidencia de mejora o claridad teórica.

### Semana 11 — Benchmark y documentación
**Objetivo:** preparar repositorio reproducible y benchmark público.  
**Tareas:**
- Organizar código en módulos, añadir README y ejemplos.
- Publicar scripts de experimentos y CSV con metadatos.
**Entregables:** repo ordenado con instrucciones reproducibles.  
**Criterio de éxito:** replicación de figuras por terceros en tiempo razonable.

### Semana 12 — Manuscrito y cierre
**Objetivo:** compilar resultados en un borrador listo para revisión.  
**Tareas:**
- Redacción de introducción, métodos, resultados y discusión.
- Selección final de figuras y tablas.
- Checklist de reproducibilidad y limitaciones.
**Entregables:** borrador del paper o capítulo y plan de envío.  
**Criterio de éxito:** versión completa y coherente lista para revisión.

---

## Recursos y buenas prácticas

- Mantener código limpio y modular; funciones puras y tests unitarios.  
- Registrar semillas y versiones de paquetes para reproducibilidad.  
- Perfilar y optimizar cuellos de botella antes de escalar experimentos.  
- Documentar cada experimento con parámetros, semilla y tiempo de ejecución.  
- Priorizar Hitos 1–3 si el tiempo es limitado.

---

## Checklist rápida por semana

- Semana 1: especificación y estructura creada.  
- Semana 2: simulador determinista con tests.  
- Semana 3: generadores y pipeline funcionando.  
- Semana 4: métricas y figuras preliminares.  
- Semana 5: dinámica estocástica implementada.  
- Semana 6: mapas de fase y umbrales.  
- Semana 7: heurística mejorada implementada.  
- Semana 8: validación en redes reales.  
- Semana 9: sensibilidad al foco analizada.  
- Semana 10: RL o teoría avanzada.  
- Semana 11: repo y benchmark listos.  
- Semana 12: manuscrito y entrega final.

---

## Notas finales

- Ajusta el ritmo según recursos computacionales y disponibilidad.  
- Si trabajas en equipo, asigna responsables por módulo y establece revisiones semanales.  
- Mantén un registro de decisiones experimentales para facilitar la redacción del método.
