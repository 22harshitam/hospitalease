# HospitalEasy Backend API

A FastAPI backend for the HospitalEasy appointment management system.

## Features

- **Authentication**: JWT-based authentication for doctors
- **Doctors Management**: CRUD operations for doctors
- **Appointments**: Complete appointment booking and management system
- **Prescriptions**: Digital prescription management
- **Database**: PostgreSQL with SQLAlchemy ORM
- **API Documentation**: Auto-generated OpenAPI/Swagger docs

## Setup

### Prerequisites

- Python 3.8+
- PostgreSQL database
- pip or poetry

### Installation

1. Clone the repository and navigate to the backend folder:
```bash
cd backend
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Set up environment variables:
```bash
cp .env.example .env
# Edit .env with your database credentials
```

4. Create and set up the database:
```bash
# Create PostgreSQL database
createdb hospital_db

# Run database migrations
alembic upgrade head

# Seed initial data
python seed_data.py
```

### Running the Server

```bash
# Development server
uvicorn app.main:app --reload

# Production server
uvicorn app.main:app --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## API Endpoints

### Authentication
- `POST /api/auth/test` - Test authentication endpoint
- `POST /api/auth/login` - OAuth2 password flow login
- `POST /api/auth/login-json` - JSON login
- `GET /api/auth/me` - Get current doctor profile

### Doctors
- `GET /api/doctors/` - List all doctors
- `GET /api/doctors/{doctor_id}` - Get doctor by ID
- `POST /api/doctors/` - Create new doctor
- `PUT /api/doctors/{doctor_id}` - Update doctor (auth required)

### Appointments
- `GET /api/appointments/` - List appointments (filtered by doctor)
- `GET /api/appointments/{appointment_id}` - Get appointment by ID
- `POST /api/appointments/` - Create new appointment
- `PUT /api/appointments/{appointment_id}` - Update appointment status
- `DELETE /api/appointments/{appointment_id}` - Cancel appointment

### Prescriptions
- `GET /api/prescriptions/` - List prescriptions
- `GET /api/prescriptions/{prescription_id}` - Get prescription by ID
- `POST /api/prescriptions/` - Create new prescription
- `PUT /api/prescriptions/{prescription_id}` - Update prescription

## Testing

Run the authentication tests:
```bash
python test_auth.py
```

Or run all tests with pytest:
```bash
pytest
```

## Database Schema

### Doctors Table
- `id` (string, primary key)
- `name`, `specialization`, `rating`, `reviews`
- `experience`, `image_url`, `biography`
- `consultation_fee`, `email`, `hashed_password`
- `is_available` (boolean)

### Appointments Table
- `id` (string, primary key)
- `doctor_id` (foreign key)
- `date`, `time_slot`, `status`
- Patient details: `name`, `age`, `phone`, `email`, `symptoms`
- `token` (unique appointment token)

### Prescriptions Table
- `id` (integer, primary key)
- `appointment_id` (foreign key, unique)
- `medicines` (JSON array)
- `instructions`, `date`

## Environment Variables

```env
DATABASE_URL=postgresql://hospital_user:hospital_pass@localhost:5432/hospital_db
SECRET_KEY=your-super-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

## Security Features

- JWT token-based authentication
- Password hashing with bcrypt
- CORS middleware for cross-origin requests
- Doctor authorization (doctors can only access their own data)

## Development

### Adding New Models

1. Create model in `app/models/`
2. Add to `app/models/__init__.py`
3. Create migration: `alembic revision --autogenerate -m "description"`
4. Apply migration: `alembic upgrade head`

### Adding New Endpoints

1. Create schema in `app/schemas/`
2. Add routes in `app/api/`
3. Include router in `app/main.py`

## Deployment

For production deployment:

1. Set strong SECRET_KEY
2. Use HTTPS
3. Configure proper database credentials
4. Set up proper CORS origins
5. Use a production WSGI server like Gunicorn

## Default Doctors

The system comes pre-seeded with 4 doctors:

1. **Dr. Arun Ravi** (Cardiologist) - `doctor@hospital.com` / `password123`
2. **Dr. Priya Sharma** (Pediatrician) - `priya@hospital.com` / `password123`
3. **Dr. Rahul Verma** (Orthopedic) - `rahul@hospital.com` / `password123`
4. **Dr. K. S. Lakshmi** (Dermatologist) - `lakshmi@hospital.com` / `password123`

Use these credentials to test the authentication system.
