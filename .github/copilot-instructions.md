# Instrucciones de Desarrollo - Proyecto BIE Flutter

## Descripción General
Este es un proyecto **Flutter** para compra, venta y renta de propiedades, siguiendo los principios de **Clean Architecture + MVVM** con reglas arquitectónicas personalizadas definidas en `arquitectura.json`.  

El proyecto utiliza convenciones de **nombres y documentación en español**.  

---

## Arquitectura (Crítica)
🔑 **Siempre consulta `arquitectura.json`** – allí se definen los estándares completos:  

- **Estructura de carpetas (`lib/`)**:  
  - `core/` → configuración global, constantes, theme  
  - `data/` → modelos, repositorios implementados, fuentes de datos/API  
  - `domain/` → entidades, casos de uso, repositorios abstractos  
  - `presentation/` → pantallas, widgets, gestión de estado  

- **Patrón**: Clean Architecture + MVVM con estricta separación de capas  
- **Cliente HTTP**: `Dio`  
- **URL Base API**: `https://mercadoinmobiliario.ec/admin/apis/`  
- **Tema**: color primario `#1a2c5b`, tipografía Roboto, paleta derivada  

---

## Paleta de Colores
Basada en el color primario `#1a2c5b`:  

- `#1a2c5b` → base  
- `#2e4170` → variante oscura  
- `#405a8a` → intermedio  
- `#5f7bb0` → acento claro  
- `#8fa5d6` → secundarios  

---

## Convenciones de Nombres
```dart
// Clases: PascalCase
class UserRepository {}

// Archivos / Carpetas: snake_case
user_repository.dart
data_sources/

// Variables: camelCase
final String userName = 'example';

// Constantes: SCREAMING_SNAKE_CASE
static const String API_BASE_URL = 'https://mercadoinmobiliario.ec/admin/apis/';

// Sufijos:
class UserModel {}        // Modelos terminan en "Model"
class UserRepository {}   // Repositorios terminan en "Repository"
class GetUserUseCase {}   // Casos de uso terminan en "UseCase"
class ApiService {}       // Servicios terminan en "Service"
class AuthProvider {}     // Providers terminan en "Provider"
class LoginController {}  // Controladores terminan en "Controller"
