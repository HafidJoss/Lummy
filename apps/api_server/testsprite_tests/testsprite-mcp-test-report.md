# Reporte de Pruebas de TestSprite AI (MCP)

---

## 1️⃣ Metadatos del Documento
- **Nombre del Proyecto:** api_server
- **Fecha:** 2026-07-08 (Actualizado)
- **Preparado por:** Equipo TestSprite AI

---

## 2️⃣ Resumen de Validación de Requisitos

### API de Autenticación (Auth API)

#### Prueba TC001 post api v1 auth login con credenciales válidas
- **Código de Prueba:** [TC001_post_api_v1_auth_login_with_valid_credentials.py](./TC001_post_api_v1_auth_login_with_valid_credentials.py)
- **Estado:** ✅ Aprobado (Ejecución Local)
- **Análisis / Hallazgos:** La prueba pasó correctamente. Se validó que al enviar el payload correcto en formato JSON (`email` y `password`), el servidor devuelve el código `200` y entrega un token JWT en el campo `access_token`.

#### Prueba TC002 post api v1 auth login con credenciales inválidas
- **Código de Prueba:** [TC002_post_api_v1_auth_login_with_invalid_credentials.py](./TC002_post_api_v1_auth_login_with_invalid_credentials.py)
- **Estado:** ✅ Aprobado (Ejecución Local)
- **Análisis / Hallazgos:** La prueba comprobó exitosamente el rechazo de credenciales inválidas, confirmando que la API responde con un estado `401 Unauthorized` y no emite el `access_token`.

### API de Usuarios (Users API)

#### Prueba TC003 get api v1 users me con token válido
- **Código de Prueba:** [TC003_get_api_v1_users_me_with_valid_token.py](./TC003_get_api_v1_users_me_with_valid_token.py)
- **Estado:** ✅ Aprobado (Ejecución Local)
- **Análisis / Hallazgos:** El script realiza el login de manera dinámica extrayendo el `access_token`. Usando este token, consulta correctamente la ruta `/api/v1/users/me`. El servidor devolvió el código `200` y entregó la información del perfil del usuario comprobando las claves requeridas (`id`, `email`, `full_name`).

#### Prueba TC004 get api v1 users me sin token o con token inválido
- **Código de Prueba:** [TC004_get_api_v1_users_me_without_token_or_invalid_token.py](./TC004_get_api_v1_users_me_without_token_or_invalid_token.py)
- **Estado:** ✅ Aprobado (Ejecución Local)
- **Análisis / Hallazgos:** Se validó de manera exitosa que realizar la petición a la ruta privada sin el encabezado de Autorización o con un token erróneo, produce una respuesta `401 Unauthorized` protegiendo adecuadamente el endpoint.

---

## 3️⃣ Métricas de Cobertura y Cumplimiento

- **100.00%** de las pruebas pasaron satisfactoriamente.

| Requisito                                        | Pruebas Totales | ✅ Aprobadas | ❌ Fallidas |
|--------------------------------------------------|-----------------|--------------|-------------|
| Autenticación de Usuarios (Login)                | 2               | 2            | 0           |
| Perfil de Usuario (Autenticado y No autenticado) | 2               | 2            | 0           |

---

## 4️⃣ Riesgos y Brechas (Key Gaps / Risks)
- **Mapeo de Schemas de Pydantic con TestSprite:** Existe una discrepancia entre los valores predeterminados de la IA de TestSprite (`username` y `token`) y el esquema implementado en FastAPI (`email` y `access_token`). Como resultado, la re-generación automática de código sobrescribe la configuración correcta. Las pruebas manuales locales han mitigado este problema para esta suite.
- **Sin riesgo de seguridad:** Las rutas privadas están correctamente protegidas y el JWT se valida correctamente como se demostró en TC004 y TC002.
