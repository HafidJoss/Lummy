# Documento Técnico: Sistema Gamificado Basado en IA para POO

## 1. Objetivos del Proyecto {#objetivos-del-proyecto}

### Objetivo General

Determinar el impacto de un sistema gamificado basado en Inteligencia Artificial (IA) en el desarrollo de competencias de programación en los estudiantes de Ingeniería de Sistemas de la Universidad Nacional San Cristóbal de Huamanga (UNSCH).

### Objetivos Específicos

- Evaluar de qué manera el sistema gamificado basado en IA impacta en el rendimiento de aprendizaje de los estudiantes.

- Establecer cómo influye el sistema gamificado basado en IA en el nivel de participación y retención de los estudiantes.

- Medir el efecto del sistema gamificado en la satisfacción y motivación intrínseca de los usuarios.

## 2. Explicación Detallada (Reglas de Negocio) {#explicación-detallada-reglas-de-negocio}

El núcleo del sistema opera bajo un motor de gamificación competitivo y adaptativo, diseñado para mitigar la frustración y fomentar la repetición constante mediante un ciclo de riesgo-recompensa.

### A. Economía de Puntos (XP) y Sistema Competitivo {#a.-economía-de-puntos-xp-y-sistema-competitivo}

- **Evaluación por Sesión:** Cada sesión consta de 5 preguntas exclusivas sobre la lógica de la Programación Orientada a Objetos.

- **Sistema de Puntuación:** El usuario obtiene **+5 XP** por cada respuesta correcta y se le penaliza con **-5 XP** por cada respuesta incorrecta. Una sesión perfecta otorga un máximo de +25 XP.

- **Leaderboard:** El sistema mantiene una tabla de clasificación global basada en la experiencia total (XP) acumulada por los estudiantes, fomentando la alta competitividad.

### B. Sistema de Progresión de Niveles {#b.-sistema-de-progresión-de-niveles}

El sistema cuenta con una escala cerrada de 7 niveles. Para avanzar al siguiente nivel, la exigencia aumenta de forma ascendente.

| **Nivel** | **Costo de Subida** | **Rango de XP** |
|-----------|---------------------|-----------------|
| Nivel 1   | 100 XP              | 0 - 99          |
| Nivel 2   | 150 XP              | 100 - 249       |
| Nivel 3   | 200 XP              | 250 - 449       |
| Nivel 4   | 250 XP              | 450 - 699       |

- **Protección Antifrustration (Piso de Nivel):** Para evitar el abandono de los usuarios, la lógica de negocio implementa un \"piso de nivel\". Si un estudiante en Nivel 2 (105 XP) falla múltiples preguntas, su XP no bajará de 100, evitando que pierda el nivel ya consolidado.

### C. Motor Adaptativo de IA {#c.-motor-adaptativo-de-ia}

- **Arranque en Frío:** Para usuarios nuevos sin historial, el sistema inyectará un prompt semilla solicitando a la IA evaluar fundamentos básicos de POO.

- **Filtro Anti-Alucinaciones y Rotación:** El backend enviará en el contexto de la petición los identificadores o conceptos clave de las últimas 15 preguntas respondidas, forzando a la IA a no repetir temas de manera cíclica.

## 3. Delimitación del Proyecto {#delimitación-del-proyecto}

- **Ámbito Académico:** Exclusivo para estudiantes universitarios matriculados en cursos troncales de programación de la Facultad de Ingeniería de Sistemas de la UNSCH durante el semestre académico 2026.

- **Ámbito Temático:** Restringido a la lógica computacional de la Programación Orientada a Objetos (POO). No incluye la evaluación de sintaxis de código en crudo, ni compilación algorítmica en tiempo real.

- **Ámbito Tecnológico:** La aplicación operará en dispositivos móviles (Android/iOS) con conexión a internet para consumir las APIs RESTful en la nube.

## 4. Alcance del Proyecto {#alcance-del-proyecto}

El sistema desarrollado incluirá las siguientes capacidades funcionales durante la fase del Producto Mínimo Viable (MVP):

- Generación dinámica y controlada de preguntas de opción múltiple estructuradas en formato JSON a través de Gemini 1.5 Flash.

- Sistema de autenticación y perfiles de usuario mediante tokens (JWT).

- Tabla de clasificación competitiva (Leaderboard) con paginación.

- Almacenamiento del historial de interacciones para el cálculo del rendimiento estadístico (tasas de precisión y analíticas).

- Distribución nativa del aplicativo (APK) para pruebas de pre-test y post-test en campo.

## 5. Flujo del Sistema (User Journey) {#flujo-del-sistema-user-journey}

1.  **Autenticación y Lobby:** El estudiante ingresa a la aplicación móvil, se autentica de forma segura, y accede al *Dashboard*. Aquí visualiza su Nivel actual, su barra de XP, la posición en el ranking global y su porcentaje de precisión.

2.  **Petición de Sesión (Orquestación):** El usuario presiona \"Iniciar Reto\". El frontend móvil (Flutter) muestra una animación de carga interactiva utilizando Rive (enmascarando la latencia). Internamente, el backend extrae el historial del usuario y ensambla el JSON de contexto.

3.  **Procesamiento Inteligente:** El backend (FastAPI) envía la petición a Gemini 1.5 Flash. La IA devuelve un JSON estricto con 5 preguntas, opciones, respuesta correcta, nivel de dificultad y retroalimentación. El backend valida el esquema usando Pydantic y lo entrega al dispositivo móvil.

4.  **Ejecución e Interactividad:** El usuario responde cada pregunta. Por cada selección, Rive dispara una máquina de estado: animación de éxito (+5 XP) o de error (-5 XP). El feedback teórico se muestra en pantalla de inmediato.

5.  **Cierre y Recálculo:** Al finalizar las 5 preguntas, el frontend envía el log de respuestas al backend. Se actualizan las tablas de la base de datos (PostgreSQL), se recalcula el nivel considerando el piso protector, y el estudiante regresa al Lobby con el Leaderboard actualizado.

## 6. Stack Tecnológico {#stack-tecnológico}

La arquitectura seleccionada garantiza asincronía, alto rendimiento gráfico y robustez en la validación de datos.

| **Capa Arquitectónica** | **Tecnología Principal** | **Justificación y Componentes** |
|----|----|----|
| **Frontend UI (App Móvil)** | Flutter | Compilación nativa a código máquina (ARM) para Android/iOS, asegurando un rendimiento fluido a 60fps. Uso de Dio para interceptores HTTP y almacenamiento seguro de estado. |
| **Animación e Interactividad** | Rive | Gestión de máquinas de estado (State Machines) para transiciones instantáneas entre estados (Idle, Loading, Success, Fail) con consumo mínimo de recursos en el celular. |
| **Backend API RESTful** | Python (FastAPI) | Alta velocidad y soporte nativo asíncrono. Utiliza Pydantic para asegurar que la salida de la IA cumpla estrictamente con el esquema JSON esperado. |
| **Base de Datos** | PostgreSQL | Motor relacional ágil y potente. Soporte nativo para campos JSONB, permitiendo flexibilidad al guardar logs de IA o métricas complejas del Leaderboard. |
| **Motor de Inteligencia Artificial** | Gemini 1.5 Flash API | Baja latencia (esencial para la interactividad) y alta capacidad para acatar esquemas de *Structured Outputs*, previniendo fallos de parseo en la API. |

### Ejemplo de Estructura JSON (Comunicación Backend -\> IA)

> {\
> \"nivel_estudiante\": 3,\
> \"curso\": \"Programación Orientada a Objetos\",\
> \"historial_rendimiento\": \"usuario_conocido, tasa_acierto_60\",\
> \"excluir_temas\": \[\"polimorfismo_metodos\", \"herencia_simple\"\]\
> }
