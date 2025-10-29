# Assets de Imágenes para Onboarding

Este directorio contiene las imágenes necesarias para los slides de onboarding de la aplicación Terra.

## Imágenes Requeridas

### 1. onboarding_welcome.png
- **Slide**: Bienvenida a Terra
- **Dimensiones recomendadas**: 300x300px
- **Descripción**: Imagen que representa la bienvenida a la plataforma inmobiliaria
- **Sugerencias**: Logo de Terra, casa con iconos de tecnología, o una ilustración de bienvenida

### 2. onboarding_search.png
- **Slide**: Encuentra tu hogar ideal
- **Dimensiones recomendadas**: 300x300px
- **Descripción**: Imagen que representa la búsqueda de propiedades
- **Sugerencias**: Lupa con casas, mapa con marcadores, o pantalla de búsqueda

### 3. onboarding_connect.png
- **Slide**: Conecta directamente
- **Dimensiones recomendadas**: 300x300px
- **Descripción**: Imagen que representa la conexión con agentes
- **Sugerencias**: Personas conversando, chat bubbles, o handshake

### 4. onboarding_start.png
- **Slide**: ¡Comencemos!
- **Dimensiones recomendadas**: 300x300px
- **Descripción**: Imagen que invita a comenzar a usar la app
- **Sugerencias**: Cohete, llaves de casa, o familia feliz

## Formato de Imágenes
- **Formato**: PNG con fondo transparente
- **Resolución**: Alta resolución para pantallas retina
- **Estilo**: Ilustraciones planas o iconos vectoriales
- **Colores**: Que combinen con la paleta de Terra (#1a2c5b, #5f7bb0, etc.)

## Notas para Desarrolladores
- Si las imágenes no están disponibles, se mostrarán iconos de fallback
- Los iconos de fallback son:
  - Slide 1: Icons.home
  - Slide 2: Icons.search
  - Slide 3: Icons.people
  - Slide 4: Icons.rocket_launch

## Actualizar pubspec.yaml
Asegúrate de agregar las imágenes al pubspec.yaml:

```yaml
flutter:
  assets:
    - assets/images/
```