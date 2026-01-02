# Echo: El Mercado de Cómputo Inactivo

<p align="center">
  <img src="docs/logo.png" alt="Echo Logo" width="120"/>
</p>

<p align="center">
  <strong>Monetiza el poder de cómputo de tus dispositivos mientras están inactivos</strong>
</p>

<p align="center">
  <a href="#características">Características</a> •
  <a href="#arquitectura">Arquitectura</a> •
  <a href="#instalación">Instalación</a> •
  <a href="#uso">Uso</a> •
  <a href="#api">API</a> •
  <a href="#contribuir">Contribuir</a>
</p>

---

## 🌟 Descripción

**Echo** es una plataforma de computación distribuida que permite a los usuarios monetizar el poder de procesamiento inactivo de sus dispositivos móviles. Cuando tu dispositivo está cargando y conectado a WiFi, Echo utiliza su capacidad de cómputo para procesar tareas de clientes que necesitan potencia de procesamiento, generando ingresos pasivos para ti.

## ✨ Características

### 📱 App iOS
- **Dashboard intuitivo** con estadísticas en tiempo real
- **Sesiones de cómputo** con visualización animada
- **Historial de ganancias** con gráficos y proyecciones
- **Sistema de retiro** de ganancias
- **Configuración avanzada** de preferencias

### 🎨 Diseño Premium
- Interfaz **glassmorphism** con gradientes neón
- **Animaciones fluidas** y micro-interacciones
- **Feedback háptico** contextual
- **Modo oscuro** optimizado

### 🔐 Seguridad
- Autenticación **JWT** con refresh tokens
- Almacenamiento seguro en **Keychain**
- Cifrado de comunicaciones

### 🚀 Backend Robusto
- API **FastAPI** de alto rendimiento
- Base de datos **SQLite/PostgreSQL**
- Documentación **OpenAPI/Swagger** automática

---

## 🏗️ Arquitectura

```
echo/
├── Echo/                      # App iOS (SwiftUI)
│   ├── Models/               # Modelos de datos
│   ├── Views/                # Vistas UI
│   │   ├── Auth/            # Login/Registro
│   │   ├── Dashboard/       # Dashboard principal
│   │   ├── Compute/         # Sesión de cómputo
│   │   ├── Earnings/        # Historial y retiros
│   │   ├── Settings/        # Configuración
│   │   └── Components/      # Componentes reutilizables
│   ├── Services/            # Servicios y API
│   └── Utils/               # Utilidades
│
├── echo-backend/             # Backend Python
│   ├── app/
│   │   ├── models/          # SQLAlchemy models
│   │   ├── schemas/         # Pydantic schemas
│   │   ├── routers/         # API endpoints
│   │   └── services/        # Business logic
│   └── requirements.txt
│
└── docs/                     # Documentación
```

---

## 📋 Requisitos

### iOS App
- **Xcode 15.0+**
- **iOS 17.0+**
- **Swift 5.9+**

### Backend
- **Python 3.11+**
- **pip**

---

## 🚀 Instalación

### Backend

```bash
# Clonar repositorio
cd echo/echo-backend

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate

# Instalar dependencias
pip install -r requirements.txt

# Configurar variables de entorno
cp .env.example .env

# Ejecutar servidor
uvicorn app.main:app --reload --port 8000
```

### iOS App

```bash
# Abrir proyecto en Xcode
cd echo
open Echo.xcodeproj

# Seleccionar dispositivo/simulador
# Presionar Cmd+R para ejecutar
```

---

## 📖 Uso

### Primer inicio

1. **Registro**: Crea una cuenta con tu email
2. **Onboarding**: Conoce cómo funciona Echo
3. **Dashboard**: Ve tu resumen de ganancias
4. **Iniciar sesión**: Comienza a generar ingresos

### Sesión de cómputo

1. Conecta tu dispositivo al **cargador**
2. Asegúrate de estar en **WiFi**
3. Presiona **"Iniciar Sesión"** en el dashboard
4. El orbe pulsante indica que estás computando
5. Las tareas se procesan automáticamente
6. Ganas **€0.001-0.01 por tarea** completada

### Retiro de ganancias

1. Ve a **Ganancias** → **Retirar**
2. Selecciona el método (PayPal, Banco, Crypto)
3. Ingresa el monto (mínimo €5)
4. Confirma el retiro

---

## 🔌 API

### Documentación interactiva
- **Swagger UI**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

### Endpoints principales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Registrar usuario |
| POST | `/api/v1/auth/login/json` | Iniciar sesión |
| GET | `/api/v1/users/me` | Perfil del usuario |
| POST | `/api/v1/sessions/start` | Iniciar sesión de cómputo |
| POST | `/api/v1/sessions/stop` | Detener sesión |
| GET | `/api/v1/earnings/balance` | Ver balance |
| POST | `/api/v1/earnings/withdraw` | Solicitar retiro |

---

## 🛠️ Stack Tecnológico

### Frontend (iOS)
| Tecnología | Uso |
|------------|-----|
| SwiftUI | Framework de UI |
| SwiftData | Persistencia local |
| Swift Charts | Gráficos de ganancias |
| Combine | Programación reactiva |

### Backend
| Tecnología | Uso |
|------------|-----|
| FastAPI | Framework web |
| SQLAlchemy | ORM |
| Pydantic | Validación |
| python-jose | JWT |

---

## 🤝 Contribuir

1. Fork el repositorio
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Add: nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## 📄 Licencia

Este proyecto está bajo la licencia MIT. Ver [LICENSE](LICENSE) para más detalles.

---

## 📞 Contacto

- **Email**: soporte@echocompute.com
- **Twitter**: [@EchoCompute](https://twitter.com/echocompute)
- **Discord**: [Echo Community](https://discord.gg/echo)

---

<p align="center">
  Hecho con ❤️ para la comunidad de computación distribuida
</p>
