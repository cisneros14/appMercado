# Estructura de Carpetas - Triara Flutter

## 📁 Arquitectura del Proyecto

Este proyecto sigue los principios de **Clean Architecture + MVVM** con una estricta separación de capas:

```
lib/
├── core/                    # Configuración global y utilidades
│   ├── config/             # Configuraciones de la aplicación
│   ├── constants/          # Constantes globales
│   ├── theme/              # Temas y estilos
│   ├── utils/              # Utilidades generales
│   ├── errors/             # Manejo de errores y excepciones
│   └── core.dart           # Exportaciones del módulo
│
├── domain/                  # Lógica de negocio pura
│   ├── entities/           # Entidades del dominio
│   ├── repositories/       # Contratos de repositorios
│   └── use_cases/          # Casos de uso (lógica de negocio)
│
├── data/                    # Acceso a datos
│   ├── models/             # Modelos de datos (extienden entidades)
│   ├── repositories/       # Implementaciones de repositorios
│   └── data_sources/       # Fuentes de datos
│       ├── remote/         # APIs remotas
│       └── local/          # Almacenamiento local
│
└── presentation/            # Interfaz de usuario
    ├── pages/              # Pantallas de la aplicación
    ├── widgets/            # Widgets reutilizables
    ├── controllers/        # Controladores de estado
    └── providers/          # Gestores de estado (Provider, etc.)
```

## 🏗️ Principios Arquitectónicos

### Dependencias
- **Domain**: No depende de ninguna otra capa
- **Data**: Depende solo de Domain
- **Presentation**: Depende de Domain y Core

### Separación de Responsabilidades
- **Core**: Configuración transversal, constantes, tema, utilidades
- **Domain**: Lógica de negocio pura, entidades, casos de uso
- **Data**: Acceso a datos, mapeo, implementación de repositorios
- **Presentation**: UI, gestión de estado, widgets

## 📝 Convenciones de Nomenclatura

### Archivos y Carpetas
- **snake_case**: `user_repository.dart`, `data_sources/`

### Clases
- **PascalCase**: `UserRepository`, `GetUserUseCase`
- **Sufijos específicos**:
  - Modelos: `PropiedadModel`
  - Repositorios: `PropiedadRepository`
  - Casos de uso: `ObtenerPropiedadesUseCase`
  - Servicios: `ApiService`
  - Providers: `AuthProvider`
  - Controladores: `LoginController`

### Variables
- **camelCase**: `userName`, `tipoOperacion`

### Constantes
- **SCREAMING_SNAKE_CASE**: `API_BASE_URL`, `CONNECTION_TIMEOUT`

## 🎨 Tema y Colores

### Paleta de Colores
Basada en el color primario `#1a2c5b`:

- **Base**: `#1a2c5b`
- **Variante oscura**: `#2e4170`
- **Intermedio**: `#405a8a`
- **Acento claro**: `#5f7bb0`
- **Secundarios**: `#8fa5d6`

### Tipografía
- **Fuente principal**: Roboto

## 🔧 Configuración Técnica

### Cliente HTTP
- **Biblioteca**: Dio
- **URL Base**: `https://mercadoinmobiliario.ec/admin/apis/`
- **Timeouts**: 30 segundos (conexión y recepción)

### Archivos Creados

#### Core
- `app_constants.dart`: Constantes globales
- `app_theme.dart`: Configuración de tema
- `app_config.dart`: Configuración de Dio y servicios
- `exceptions.dart`: Excepciones personalizadas
- `failures.dart`: Fallas para manejo de errores
- `app_utils.dart`: Utilidades generales

#### Domain
- `propiedad_entity.dart`: Entidad de propiedad
- `usuario_entity.dart`: Entidad de usuario
- `propiedad_repository.dart`: Contrato de repositorio
- `obtener_propiedades_use_case.dart`: Caso de uso ejemplo

#### Data
- `propiedad_model.dart`: Modelo de datos con serialización JSON

## 🚀 Próximos Pasos

1. Implementar repositorios en `data/repositories/`
2. Crear fuentes de datos en `data/data_sources/`
3. Desarrollar pantallas en `presentation/pages/`
4. Implementar controladores de estado
5. Agregar widgets reutilizables

## 📖 Documentación Adicional

Consultar `arquitectura.json` para detalles completos de los estándares arquitectónicos del proyecto.