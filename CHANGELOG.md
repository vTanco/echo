# Changelog

Todos los cambios notables en este proyecto serán documentados en este archivo.

El formato está basado en [Keep a Changelog](https://keepachangelog.com/es-ES/1.0.0/),
y este proyecto adhiere a [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-12-29

### 🎉 Lanzamiento Inicial

Primera versión completa de Echo: El Mercado de Cómputo Inactivo.

### ✨ Añadido

#### iOS App
- **Onboarding**: Flujo de introducción con 4 páginas animadas
- **Dashboard**: Vista principal con estadísticas, acciones rápidas y gráfico de ganancias
- **Sesión de Cómputo**: Vista con orbe animado, estadísticas en tiempo real y lista de tareas
- **Historial de Ganancias**: Gráficos, proyecciones y lista de transacciones
- **Retiro de Ganancias**: Flujo completo con selección de método y confirmación
- **Configuración**: Preferencias de cómputo, programación y notificaciones

#### Componentes UI
- `GlassCard`: Tarjetas con efecto glassmorphism
- `AnimatedGradient`: Fondos dinámicos animados
- `PulsingOrb`: Orbe animado para visualización de cómputo
- `StatCard` / `MiniStatCard`: Tarjetas de estadísticas
- `EarningsChart`: Gráfico de ganancias con Swift Charts
- `LoadingView`: Vista de carga con orbe pulsante
- `ToastView`: Sistema de notificaciones toast
- `EmptyStateView`: Estados vacíos ilustrados

#### Servicios
- `ComputeService`: Gestión de sesiones y tareas de cómputo
- `DeviceMonitorService`: Monitoreo de estado del dispositivo
- `EarningsService`: Gestión de ganancias y retiros
- `APIClient`: Cliente HTTP para comunicación con backend
- `AuthManager`: Gestión de autenticación JWT con Keychain

#### Utilidades
- `HapticManager`: Feedback háptico centralizado
- `Extensions`: Extensiones de Color, View, Double, Date
- `Constants`: Constantes de configuración

#### Backend (FastAPI)
- **Auth**: Registro, login, refresh token
- **Users**: Perfil, preferencias, estadísticas
- **Devices**: Registro, status, gestión
- **Sessions**: Inicio, parada, historial
- **Tasks**: Asignación, progreso, completado
- **Earnings**: Balance, historial, retiros, proyecciones

#### Base de Datos
- Modelo `User` con preferencias JSON
- Modelo `Device` con estado y métricas
- Modelo `ComputeSession` con estadísticas
- Modelo `Task` con progreso y recompensa
- Modelo `Transaction` para earnings y retiros

### 🎨 Diseño
- Paleta de colores neón (Cyan, Magenta, Violet, Green, Orange)
- Glassmorphism con fondos translúcidos
- Animaciones suaves con springs
- Micro-interacciones en botones
- Icono de app personalizado (orbe neón)

### 🔐 Seguridad
- Autenticación JWT con access y refresh tokens
- Almacenamiento seguro en iOS Keychain
- Hashing de contraseñas con bcrypt
- CORS configurado

### 📚 Documentación
- README completo del proyecto
- README del backend con endpoints
- Documentación OpenAPI automática (Swagger/ReDoc)
- CHANGELOG

---

## [Unreleased]

### 🚧 Planeado
- [ ] Notificaciones push
- [ ] Widget de iOS
- [ ] Background processing
- [ ] WebSocket para actualizaciones en tiempo real
- [ ] Migración a PostgreSQL
- [ ] Tests unitarios y de integración
- [ ] CI/CD pipeline
- [ ] Localización multi-idioma

---

## Tipos de cambios

- `Añadido` para nuevas funcionalidades
- `Cambiado` para cambios en funcionalidades existentes
- `Obsoleto` para funcionalidades próximas a eliminarse
- `Eliminado` para funcionalidades eliminadas
- `Corregido` para correcciones de bugs
- `Seguridad` para vulnerabilidades corregidas
