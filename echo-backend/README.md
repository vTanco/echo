# Echo Backend

Backend API para Echo - El Mercado de Cómputo Inactivo.

## Requisitos

- Python 3.11+
- pip

## Instalación

```bash
cd echo-backend

# Crear entorno virtual
python3 -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# Instalar dependencias
pip install -r requirements.txt
```

## Configuración

Copia `.env.example` a `.env` y configura las variables:

```bash
cp .env.example .env
```

Variables importantes:
- `SECRET_KEY`: Clave secreta para JWT (cambiar en producción)
- `DATABASE_URL`: URL de la base de datos

## Ejecutar

```bash
# Desarrollo
uvicorn app.main:app --reload --port 8000

# Producción
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

## API Docs

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Endpoints

### Auth
- `POST /api/v1/auth/register` - Registrar usuario
- `POST /api/v1/auth/login` - Iniciar sesión
- `POST /api/v1/auth/refresh` - Refrescar token

### Users
- `GET /api/v1/users/me` - Perfil actual
- `PATCH /api/v1/users/me` - Actualizar perfil
- `GET /api/v1/users/me/stats` - Estadísticas

### Devices
- `POST /api/v1/devices/register` - Registrar dispositivo
- `GET /api/v1/devices/` - Listar dispositivos
- `PATCH /api/v1/devices/{id}/status` - Actualizar estado

### Sessions
- `POST /api/v1/sessions/start` - Iniciar sesión de cómputo
- `POST /api/v1/sessions/stop` - Detener sesión
- `GET /api/v1/sessions/history` - Historial

### Tasks
- `GET /api/v1/tasks/pending?device_id=...` - Tareas pendientes
- `PATCH /api/v1/tasks/{id}/progress` - Actualizar progreso
- `POST /api/v1/tasks/{id}/complete` - Completar tarea

### Earnings
- `GET /api/v1/earnings/balance` - Balance actual
- `GET /api/v1/earnings/history` - Historial
- `POST /api/v1/earnings/withdraw` - Solicitar retiro
