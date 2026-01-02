# Guía del Desarrollador - Echo

Esta guía proporciona información técnica detallada para desarrolladores que quieran contribuir o extender Echo.

## 📁 Estructura del Proyecto

### iOS App (`Echo/`)

```
Echo/
├── EchoApp.swift              # Entry point, SwiftData config
├── Models/
│   ├── User.swift             # Usuario (SwiftData)
│   ├── ComputeSession.swift   # Sesión de cómputo
│   ├── EarningsRecord.swift   # Registro de ganancias
│   └── ComputeTask.swift      # Tarea de cómputo
│
├── Views/
│   ├── Auth/
│   │   └── LoginView.swift    # Login/Registro
│   ├── Dashboard/
│   │   └── DashboardView.swift
│   ├── Onboarding/
│   │   └── OnboardingView.swift
│   ├── Compute/
│   │   └── ComputeSessionView.swift
│   ├── Earnings/
│   │   ├── EarningsHistoryView.swift
│   │   └── WithdrawView.swift
│   ├── Settings/
│   │   └── SettingsView.swift
│   └── Components/
│       ├── GlassCard.swift
│       ├── AnimatedGradient.swift
│       ├── PulsingOrb.swift
│       ├── StatCard.swift
│       ├── EarningsChart.swift
│       ├── LoadingView.swift
│       ├── ToastView.swift
│       └── EmptyStateView.swift
│
├── Services/
│   ├── APIClient.swift        # Cliente HTTP genérico
│   ├── AuthManager.swift      # Gestión de sesión
│   ├── ComputeService.swift   # Lógica de cómputo
│   ├── DeviceMonitorService.swift
│   └── EarningsService.swift
│
├── Utils/
│   ├── Extensions.swift       # Extensiones Swift
│   ├── Constants.swift        # Constantes
│   └── HapticManager.swift    # Feedback háptico
│
└── Resources/
    └── Assets.xcassets/       # Assets y colores
```

### Backend (`echo-backend/`)

```
app/
├── main.py                    # FastAPI entry point
├── config.py                  # Settings (pydantic-settings)
├── database.py                # SQLAlchemy async setup
│
├── models/
│   ├── user.py
│   ├── device.py
│   ├── compute_session.py
│   ├── task.py
│   └── transaction.py
│
├── schemas/                   # Pydantic validation
│   ├── auth.py
│   ├── user.py
│   ├── device.py
│   ├── session.py
│   ├── task.py
│   └── transaction.py
│
├── routers/                   # API endpoints
│   ├── auth.py
│   ├── users.py
│   ├── devices.py
│   ├── sessions.py
│   ├── tasks.py
│   └── earnings.py
│
├── services/                  # Business logic
│   ├── auth_service.py
│   ├── device_service.py
│   ├── task_service.py
│   └── earnings_service.py
│
└── utils/
    ├── security.py            # JWT, hashing
    └── mock_tasks.py          # Task generation
```

---

## 🔧 Configuración del Entorno

### iOS

1. **Xcode 15.0+** requerido
2. Abrir `Echo.xcodeproj`
3. Seleccionar Team en Signing & Capabilities
4. Cambiar Bundle ID si es necesario

### Backend

```bash
# Variables de entorno (.env)
DATABASE_URL=sqlite+aiosqlite:///./echo.db
SECRET_KEY=tu-clave-secreta-muy-larga
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

---

## 🎨 Sistema de Diseño

### Colores

| Nombre | Hex | Uso |
|--------|-----|-----|
| AccentCyan | `#00E5F7` | Color primario, enlaces |
| AccentMagenta | `#FF00E0` | Gradientes, destacados |
| AccentViolet | `#8B4AFF` | Secundario |
| AccentGreen | `#32D857` | Éxito, ganancias |
| AccentOrange | `#FF853E` | Advertencias |
| DarkBackground | `#0A0A0F` | Fondo principal |
| CardBackground | `#1A1A2E` | Tarjetas |

### Gradientes

```swift
// Gradiente principal
LinearGradient(
    colors: [.accentCyan, .accentMagenta],
    startPoint: .leading,
    endPoint: .trailing
)

// Fondo animado
RadialGradient con orbes flotantes
```

### Componentes

- **GlassCard**: `.glassCard()` modifier
- **Shimmer**: `.shimmer()` modifier  
- **Haptics**: `HapticManager.shared.buttonTap()`
- **Toast**: `ToastManager.shared.success("Mensaje")`

---

## 🔌 API Reference

### Autenticación

Todas las rutas (excepto auth) requieren header:
```
Authorization: Bearer <access_token>
```

### Flujo de Auth

```
1. POST /auth/register → UserResponse
2. POST /auth/login/json → TokenResponse
3. Guardar tokens en Keychain
4. Usar access_token en requests
5. Si 401 → POST /auth/refresh → Nuevos tokens
```

### Códigos de Estado

| Código | Significado |
|--------|-------------|
| 200 | OK |
| 201 | Creado |
| 400 | Error de validación |
| 401 | No autenticado |
| 403 | No autorizado |
| 404 | No encontrado |
| 500 | Error del servidor |

---

## 🧪 Testing

### iOS

```swift
// Previews en cada vista
#Preview {
    ViewName()
}
```

### Backend

```bash
# Probar endpoints
curl -X POST http://localhost:8000/api/v1/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "test@example.com", "password": "test123"}'
```

---

## 📝 Convenciones de Código

### Swift
- CamelCase para tipos y propiedades
- Prefijo `is` para booleanos
- Documentación con `///`
- Máximo 120 caracteres por línea

### Python
- snake_case para variables y funciones
- PascalCase para clases
- Type hints obligatorios
- Docstrings en funciones públicas

---

## 🚀 Deployment

### Backend (Producción)

```bash
# Usar gunicorn
gunicorn app.main:app -w 4 -k uvicorn.workers.UvicornWorker

# O Docker
docker build -t echo-backend .
docker run -p 8000:8000 echo-backend
```

### iOS

1. Archive en Xcode
2. Subir a App Store Connect
3. Enviar para revisión

---

## 🐛 Debugging

### iOS
- Breakpoints en Xcode
- `print()` o `debugPrint()`
- SwiftUI Previews

### Backend
- Logs en consola (DEBUG=True)
- Swagger UI para probar endpoints
- `print()` en servicios

---

## 📞 Soporte

¿Preguntas? Abre un issue en el repositorio.
