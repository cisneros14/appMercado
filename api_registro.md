# Documentación de API Registro APP

**Endpoint Base:** `https://mercadoinmobiliario.ec/admin/apis/api_registro_app.php`

## 1. Obtener Provincias y Ciudades

Obtiene el listado completo de provincias y sus respectivas ciudades para poblar los selectores del formulario.

- **Método:** `GET`
- **Parámetro:** `action=provincias`
- **URL Ejemplo:**
  `https://mercadoinmobiliario.ec/admin/apis/api_registro_app.php?action=provincias`

### Respuesta Exitosa (200 OK)

```json
{
    "success": true,
    "message": "Catálogo de provincias y ciudades",
    "data": {
        "Azuay": ["Cuenca", "Girón", ...],
        "Bolívar": ["Guaranda", "Chillanes", ...],
        ...
    },
    "errors": []
}
```

---

## 2. Registrar Usuario

Envía los datos del formulario de registro, incluyendo el archivo adjunto.

- **Método:** `POST`
- **Tipo de Contenido:** `multipart/form-data` (Requerido para subir el archivo)
- **Parámetro URL:** `action=registrar`
- **URL Ejemplo:**
  `https://mercadoinmobiliario.ec/admin/apis/api_registro_app.php?action=registrar`

### Parámetros del Body (Form-Data)

| Campo                    | Tipo    | Obligatorio | Descripción             | Validaciones                                              |
| ------------------------ | ------- | ----------- | ----------------------- | --------------------------------------------------------- |
| `nombres`                | Texto   | Sí          | Nombres del usuario     | Solo letras y espacios, 2-50 caracteres.                  |
| `apellidos`              | Texto   | Sí          | Apellidos del usuario   | Solo letras y espacios, 2-50 caracteres.                  |
| `email`                  | Email   | Sí          | Correo electrónico      | Formato de email válido. Único en el sistema.             |
| `celular`                | Texto   | Sí          | Número celular          | Formato ecuatoriano `09XXXXXXXX` (10 dígitos).            |
| `matricula_inmobiliaria` | Texto   | Sí          | Código de licencia      | Alfanumérico, 6-20 caracteres. Se convierte a mayúsculas. |
| `user_password`          | Texto   | Sí          | Contraseña              | Mínimo 2 caracteres.                                      |
| `provincia`              | Texto   | Sí          | Provincia seleccionada  | Debe coincidir con una clave del catálogo de provincias.  |
| `ciudad`                 | Texto   | Sí          | Ciudad seleccionada     | Texto libre, máx 100 caracteres.                          |
| `acepto_privacidad`      | Check   | Sí          | Aceptación de políticas | Valores válidos: `on`, `true`, `1`.                       |
| `documento`              | Archivo | Sí          | Documento PDF o Imagen  | PDF, JPG, PNG, GIF. Máx 5MB (config server).              |

### Respuesta Exitosa (200 OK)

```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "id": 123,
    "email_sent": true,
    "status": "pending_approval"
  },
  "errors": []
}
```

### Respuesta de Error de Validación (422 Unprocessable Entity)

```json
{
  "success": false,
  "message": "Errores de validación",
  "data": null,
  "errors": ["El correo electrónico no es válido.", "La contraseña debe tener al menos 2 caracteres."]
}
```

### Respuesta de Error de Conflicto (409 Conflict)

```json
{
  "success": false,
  "message": "El correo electrónico ya está registrado.",
  "data": null,
  "errors": ["Duplicate entry '...' for key 'user_email'"]
}
```

## Notas de Implementación

1. **Seguridad:** La API permite peticiones desde cualquier origen (`Access-Control-Allow-Origin: *`) para facilitar el desarrollo en apps móviles/híbridas.
2. **Archivos:** Los documentos se guardan en `admin/images/docs/`.
3. **Email:** Al registrarse exitosamente, el sistema envía automáticamente un correo de bienvenida/confirmación al usuario usando la clase `EmailSender` del sistema.
