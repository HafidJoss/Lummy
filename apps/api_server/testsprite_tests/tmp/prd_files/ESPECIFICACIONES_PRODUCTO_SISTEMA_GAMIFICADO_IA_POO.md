# Especificaciones del Producto  
## Sistema Gamificado Basado en IA para Aprendizaje de POO

---

## 1. Propósito del producto

El producto es una plataforma gamificada basada en inteligencia artificial diseñada para apoyar el aprendizaje de **Programación Orientada a Objetos (POO)** en estudiantes universitarios.

Su propósito principal es:

- evaluar conocimientos conceptuales de POO mediante retos interactivos,
- adaptar el nivel de dificultad según el progreso del estudiante,
- ofrecer retroalimentación inmediata,
- registrar métricas de aprendizaje para análisis académico,
- y fomentar la motivación mediante un sistema de XP, niveles y ranking competitivo.

El sistema debe funcionar como una aplicación móvil consumiendo un backend API RESTful seguro y escalable.

---

## 2. Objetivo de la evaluación con TestSprite

Este documento sirve como base para evaluar que el sistema:

- responde correctamente a las solicitudes del frontend móvil,
- autentica usuarios de forma segura,
- genera y entrega sesiones de preguntas de forma válida,
- aplica correctamente las reglas de gamificación,
- guarda y recupera datos de progreso,
- y mantiene consistencia funcional incluso ante fallas parciales, especialmente en la integración con IA.

La prueba debe verificar tanto el flujo principal del usuario como los comportamientos críticos del backend.

---

## 3. Descripción general del producto

El sistema permite que un estudiante:

1. se registre o inicie sesión,
2. acceda a su perfil y progreso,
3. inicie un reto de 5 preguntas sobre POO,
4. responda preguntas generadas o seleccionadas por el sistema,
5. reciba retroalimentación inmediata,
6. acumule o pierda XP según sus respuestas,
7. actualice su nivel y posición en el leaderboard,
8. y genere datos útiles para análisis académico.

El backend es responsable de:
- autenticación,
- orquestación del reto,
- validación de respuestas de IA,
- cálculo de XP y niveles,
- persistencia de sesiones,
- y entrega de métricas y ranking.

---

## 4. Características principales del producto

### 4.1 Autenticación y gestión de usuarios
- Registro de usuario con email y contraseña.
- Inicio de sesión mediante JWT.
- Renovación de sesión mediante refresh token.
- Cierre de sesión y revocación de acceso.
- Visualización de perfil del estudiante.

### 4.2 Sesiones de reto gamificado
- Inicio de una sesión de preguntas desde el dashboard.
- Generación de exactamente 5 preguntas por sesión.
- Preguntas de opción múltiple sobre POO.
- Validación de estructura de preguntas antes de ser usadas.
- Respuesta una por una por parte del usuario.
- Retroalimentación inmediata después de cada respuesta.
- Cierre automático al completar las 5 preguntas.

### 4.3 Sistema de gamificación
- El usuario gana **+5 XP** por respuesta correcta.
- El usuario pierde **-5 XP** por respuesta incorrecta.
- El sistema calcula XP total de sesión y XP acumulado.
- El sistema actualiza el nivel según reglas predefinidas.
- Se aplica un **piso antifrustración** para evitar que el XP baje por debajo del mínimo del nivel consolidado actual.

### 4.4 Leaderboard
- Mostrar clasificación global de usuarios.
- Ordenar por XP total descendente.
- Paginación para mejorar rendimiento.
- Mostrar la posición del usuario autenticado cuando esté disponible.

### 4.5 Analíticas y trazabilidad
- Registrar eventos de sesión.
- Registrar respuestas por pregunta.
- Registrar tiempo de respuesta.
- Registrar aciertos y errores.
- Guardar información útil para pre-test y post-test.
- Permitir exportación de datos anonimizables para investigación.

### 4.6 Resiliencia e integración con IA
- Validar la estructura de toda salida generada por IA.
- Reintentar si la IA entrega un resultado inválido.
- Usar preguntas fallback si la IA falla.
- Evitar que el usuario quede bloqueado si el proveedor IA no responde.

---

## 5. Cómo debería funcionar el producto

### 5.1 Flujo principal del usuario

#### Paso 1: autenticación
El usuario abre la aplicación móvil e inicia sesión con sus credenciales.

#### Paso 2: acceso al dashboard
El sistema muestra:
- nombre de usuario,
- XP total,
- nivel actual,
- precisión global,
- y posición en el leaderboard si está disponible.

#### Paso 3: inicio del reto
El usuario selecciona “Iniciar Reto”.
El backend crea una nueva sesión y prepara el contexto necesario para generar o seleccionar preguntas.

#### Paso 4: generación de preguntas
El backend solicita 5 preguntas relacionadas con POO.
Las preguntas deben llegar en formato JSON estructurado y válido.

#### Paso 5: resolución
El usuario responde cada pregunta.
Después de cada respuesta, el sistema muestra:
- si fue correcta o incorrecta,
- la explicación conceptual,
- y el cambio de XP correspondiente.

#### Paso 6: cierre de sesión
Al finalizar las 5 preguntas:
- se calculan resultados finales,
- se actualiza el nivel,
- se aplica el piso antifrustración,
- se almacena la sesión,
- y se actualiza el leaderboard.

#### Paso 7: analítica
Se guardan eventos y métricas para análisis posterior de aprendizaje y desempeño.

---

## 6. Reglas funcionales esperadas

### 6.1 Registro e inicio de sesión
- Si el usuario proporciona credenciales válidas, debe obtener acceso.
- Si las credenciales son inválidas, el sistema debe rechazar la solicitud.
- Si el email ya existe en registro, no debe duplicarse la cuenta.

### 6.2 Reto de preguntas
- Cada sesión debe tener exactamente 5 preguntas.
- No debe repetirse la misma pregunta dentro de una sesión.
- La experiencia debe ser secuencial y clara.
- El sistema debe devolver feedback después de cada respuesta.

### 6.3 XP y niveles
- Cada correcta suma 5 XP.
- Cada incorrecta resta 5 XP.
- El nivel se recalcula según el total de XP.
- El XP no puede caer por debajo del mínimo del nivel consolidado actual.

### 6.4 Leaderboard
- El ranking debe ordenar por XP total.
- Debe soportar paginación.
- Debe mostrar datos consistentes y actualizados.

### 6.5 IA
- La IA no debe bloquear el flujo del usuario.
- La salida generada debe validarse antes de mostrarse.
- Si la IA falla, el sistema debe usar un fallback.

---

## 7. Requisitos de calidad que deben observarse

### 7.1 Seguridad
- Contraseñas protegidas con hash seguro.
- Autenticación mediante JWT.
- Tokens de refresco revocables.
- Comunicación por HTTPS.

### 7.2 Rendimiento
- El sistema debe responder con buena fluidez en navegación normal.
- El leaderboard debe consultarse rápidamente gracias a paginación y caché.
- La interacción con IA debe manejar latencia visible sin romper la experiencia.

### 7.3 Confiabilidad
- Las sesiones deben guardarse correctamente.
- Los eventos no deben perderse.
- El sistema debe continuar funcionando aun si la IA presenta fallos temporales.

### 7.4 Usabilidad
- La interfaz debe ser clara.
- La retroalimentación debe ser breve y comprensible.
- La experiencia debe ser motivadora y no frustrante.

---

## 8. Datos y entidades esperadas

El producto trabaja con entidades como:

- usuarios,
- perfiles de usuario,
- sesiones de reto,
- preguntas,
- respuestas,
- reglas de nivel,
- ledger de XP,
- leaderboard,
- eventos de aprendizaje,
- resultados pre-test y post-test.

---

## 9. Resultados esperados del sistema

Se espera que el producto:

- permita al estudiante aprender POO de forma interactiva,
- incremente la motivación mediante gamificación,
- registre evidencia útil para investigación,
- funcione de manera estable en entorno móvil,
- y mantenga integridad de datos en autenticación, progreso y ranking.

---

## 10. Criterios de aceptación generales

El producto será considerado funcional si:

- un usuario puede registrarse e iniciar sesión,
- puede iniciar una sesión de 5 preguntas,
- puede responderlas y recibir retroalimentación,
- el sistema calcula correctamente XP y nivel,
- el leaderboard refleja los cambios,
- y el sistema no falla si la IA no responde correctamente.

---

## 11. Alcance del producto

### Incluye
- App móvil.
- API backend.
- Autenticación.
- Sesiones de preguntas.
- XP, niveles y leaderboard.
- Registro de métricas.
- Integración con IA.
- Fallback ante fallas de IA.

### No incluye
- evaluación de código compilable,
- chat en tiempo real,
- modo offline completo,
- sistema docente completo.

---

## 12. Resumen final

Este producto es un sistema educativo gamificado cuyo objetivo es mejorar el aprendizaje de POO mediante retos interactivos asistidos por IA.  
Debe ser seguro, estable, validable y capaz de medir resultados de aprendizaje de forma estructurada.