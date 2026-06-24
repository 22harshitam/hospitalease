# 🏥 HospitalEasy Backend - Complete Setup & Running Guide

## 🎯 Overview

I've successfully created a **complete Python FastAPI backend** for your HospitalEasy Flutter app with:
- ✅ **PostgreSQL database** with SQLAlchemy ORM
- ✅ **JWT authentication system** for doctors  
- ✅ **RESTful API endpoints** for all data models
- ✅ **Database migrations** with Alembic
- ✅ **Seeded data** with 4 default doctors
- ✅ **API documentation** with Swagger UI

---

## 📁 Backend Structure

```
backend/
├── app/
│   ├── api/                    # API route handlers
│   │   ├── auth.py            # Authentication endpoints
│   │   ├── doctors.py         # Doctor management
│   │   ├── appointments.py    # Appointment system
│   │   └── prescriptions.py   # Prescription management
│   ├── core/
│   │   ├── config.py          # Configuration settings
│   │   └── security.py        # JWT & password security
│   ├── db/
│   │   └── database.py        # Database connection
│   ├── models/                # SQLAlchemy database models
│   │   ├── doctor.py
│   │   ├── appointment.py
│   │   └── prescription.py
│   ├── schemas/               # Pydantic data validation
│   │   ├── auth.py
│   │   ├── doctor.py
│   │   ├── appointment.py
│   │   └── prescription.py
│   └── main.py               # FastAPI application entry
├── alembic/                  # Database migrations
├── requirements.txt          # Python dependencies
├── .env                     # Environment variables
├── seed_simple.py          # Initial data population
└── README.md               # Documentation
```

---

## 🛠️ Installation & Setup

### ✅ Step 1: Prerequisites (Already Done)
- ✅ **Python 3.9+** installed
- ✅ **PostgreSQL 14** installed via Homebrew
- ✅ **Database created**: `hospital_db`
- ✅ **Database user created**: `hospital_user`

### ✅ Step 2: Dependencies (Already Installed)
```bash
pip3 install -r requirements.txt
```

**Key Dependencies:**
- `fastapi==0.104.1` - Web framework
- `uvicorn[standard]==0.24.0` - ASGI server
- `sqlalchemy==2.0.23` - ORM
- `alembic==1.12.1` - Database migrations
- `psycopg2-binary==2.9.9` - PostgreSQL driver
- `python-jose[cryptography]==3.3.0` - JWT tokens
- `passlib[bcrypt]==1.7.4` - Password hashing
- `pydantic==2.0a3` - Data validation

### ✅ Step 3: Database Setup (Already Done)
```bash
# Database and user created
createdb hospital_db
createuser hospital_user
psql -d hospital_db -c "ALTER USER hospital_user PASSWORD 'hospital_pass';"
psql -d hospital_db -c "GRANT ALL PRIVILEGES ON SCHEMA public TO hospital_user;"

# Database migrations applied
python3 -m alembic upgrade head

# Initial data seeded
python3 seed_simple.py
```

---

## 🚀 Running the Backend

### Start the Server
```bash
cd /Users/kiranlalk/Desktop/hospitaleasy/backend
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### Access Points
- **API Base URL**: `http://localhost:8000`
- **Swagger Documentation**: `http://localhost:8000/docs`
- **ReDoc Documentation**: `http://localhost:8000/redoc`
- **Health Check**: `http://localhost:8000/health`

---

## 🔐 Authentication System

### Default Doctor Credentials
All doctors use the same password: `password123`

| Doctor ID | Name | Email | Specialization |
|-----------|------|-------|----------------|
| 1 | Dr. Arun Ravi | `doctor@hospital.com` | Cardiologist |
| 2 | Dr. Priya Sharma | `priya@hospital.com` | Pediatrician |
| 3 | Dr. Rahul Verma | `rahul@hospital.com` | Orthopedic |
| 4 | Dr. K. S. Lakshmi | `lakshmi@hospital.com` | Dermatologist |

### Authentication Flow
1. **Login**: POST `/api/auth/login-json` with email/password
2. **Receive JWT Token**: Valid for 30 minutes
3. **Access Protected Endpoints**: Include `Authorization: Bearer <token>` header

---

## 🌐 API Endpoints

### 🔐 Authentication
```
POST /api/auth/test              # Test authentication endpoint
POST /api/auth/login             # OAuth2 password flow login
POST /api/auth/login-json        # JSON login with email/password
GET  /api/auth/me               # Get current doctor profile (requires auth)
```

### 👨‍⚕️ Doctors
```
GET    /api/doctors/             # List all doctors
GET    /api/doctors/{id}         # Get doctor by ID
POST   /api/doctors/             # Create new doctor
PUT    /api/doctors/{id}         # Update doctor (requires auth)
```

### 📅 Appointments
```
GET    /api/appointments/        # List appointments (filtered by doctor)
GET    /api/appointments/{id}    # Get appointment by ID
POST   /api/appointments/        # Create new appointment
PUT    /api/appointments/{id}    # Update appointment status
DELETE /api/appointments/{id}    # Cancel appointment
```

### 💊 Prescriptions
```
GET    /api/prescriptions/       # List prescriptions
GET    /api/prescriptions/{id}   # Get prescription by ID
POST   /api/prescriptions/       # Create new prescription
PUT    /api/prescriptions/{id}   # Update prescription
```

---

## 🗄️ Database Schema

### Doctors Table
```sql
CREATE TABLE doctors (
    id VARCHAR PRIMARY KEY,
    name VARCHAR NOT NULL,
    specialization VARCHAR NOT NULL,
    rating FLOAT NOT NULL,
    reviews INTEGER NOT NULL,
    experience VARCHAR NOT NULL,
    image_url VARCHAR NOT NULL,
    is_available BOOLEAN DEFAULT TRUE,
    biography TEXT NOT NULL,
    consultation_fee FLOAT NOT NULL,
    email VARCHAR UNIQUE NOT NULL,
    hashed_password VARCHAR
);
```

### Appointments Table
```sql
CREATE TABLE appointments (
    id VARCHAR PRIMARY KEY,
    doctor_id VARCHAR REFERENCES doctors(id),
    date TIMESTAMP NOT NULL,
    time_slot VARCHAR NOT NULL,
    patient_name VARCHAR NOT NULL,
    patient_age VARCHAR NOT NULL,
    patient_phone VARCHAR NOT NULL,
    patient_email VARCHAR,
    patient_symptoms TEXT,
    status VARCHAR DEFAULT 'Upcoming',
    token VARCHAR UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

### Prescriptions Table
```sql
CREATE TABLE prescriptions (
    id SERIAL PRIMARY KEY,
    appointment_id VARCHAR UNIQUE REFERENCES appointments(id),
    medicines JSONB NOT NULL,
    instructions TEXT NOT NULL,
    date TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);
```

---

## 🧪 Testing the API

### 1. Test Authentication
```bash
# Test endpoint (no auth required)
curl -X POST http://localhost:8000/api/auth/test

# Login with doctor credentials
curl -X POST http://localhost:8000/api/auth/login-json \
  -H "Content-Type: application/json" \
  -d '{"email": "doctor@hospital.com", "password": "password123"}'
```

### 2. Get Doctors List
```bash
curl -X GET http://localhost:8000/api/doctors/
```

### 3. Create Appointment
```bash
curl -X POST http://localhost:8000/api/appointments/ \
  -H "Content-Type: application/json" \
  -d '{
    "doctor_id": "1",
    "date": "2024-01-15T10:00:00",
    "time_slot": "10:00 AM",
    "patient_details": {
      "name": "John Doe",
      "age": "35",
      "phone": "9876543210",
      "symptoms": "Headache and fever"
    }
  }'
```

---

## 🔧 Configuration

### Environment Variables (.env)
```env
DATABASE_URL=postgresql://hospital_user:hospital_pass@localhost:5432/hospital_db
SECRET_KEY=your-super-secret-key-change-in-production
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Security Features
- ✅ JWT token-based authentication
- ✅ Password hashing with bcrypt
- ✅ CORS middleware for cross-origin requests
- ✅ Doctor authorization (doctors can only access their own data)

---

## 📱 Flutter Integration

### HTTP Client Setup
```dart
// Add to pubspec.yaml
dependencies:
  http: ^1.1.0
  flutter_secure_storage: ^8.0.0

// API Base URL
const String BASE_URL = 'http://localhost:8000';
```

### Authentication Service Example
```dart
class AuthService {
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$BASE_URL/api/auth/login-json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
    return null;
  }
}
```

---

## 🚨 Troubleshooting

### Common Issues & Solutions

1. **Database Connection Error**
   ```bash
   # Check PostgreSQL status
   brew services list | grep postgresql
   
   # Restart PostgreSQL
   brew services restart postgresql@14
   ```

2. **Permission Denied**
   ```bash
   # Grant permissions again
   psql -d hospital_db -c "GRANT ALL PRIVILEGES ON SCHEMA public TO hospital_user;"
   ```

3. **Module Import Errors**
   ```bash
   # Reinstall dependencies
   pip3 install -r requirements.txt --force-reinstall
   ```

4. **Server Won't Start**
   ```bash
   # Check port 8000 availability
   lsof -i :8000
   
   # Kill process if needed
   kill -9 <PID>
   ```

---

## 🔄 Development Workflow

### Adding New Models
1. Create model in `app/models/`
2. Add to `app/models/__init__.py`
3. Create migration: `python3 -m alembic revision --autogenerate -m "description"`
4. Apply migration: `python3 -m alembic upgrade head`

### Adding New Endpoints
1. Create schema in `app/schemas/`
2. Add routes in `app/api/`
3. Include router in `app/main.py`

### Database Changes
```bash
# Create new migration
python3 -m alembic revision --autogenerate -m "Add new table"

# Apply migrations
python3 -m alembic upgrade head

# Rollback if needed
python3 -m alembic downgrade -1
```

---

## 🎉 Next Steps

### For Production Deployment
1. **Change SECRET_KEY** to a secure random string
2. **Use HTTPS** with SSL certificates
3. **Set proper CORS origins** for your Flutter app
4. **Use a production WSGI server** like Gunicorn
5. **Set up database backups**
6. **Configure environment variables** properly

### For Flutter Integration
1. Update your Flutter app's API calls to use the new endpoints
2. Implement JWT token storage (secure storage)
3. Add error handling for network requests
4. Update data models to match backend schemas

---

## 📞 Support

The backend is now **fully functional** and ready for integration! 

**Server Status**: ✅ Ready to start  
**Database**: ✅ Populated with test data  
**Authentication**: ✅ Working with default doctors  
**API Endpoints**: ✅ All endpoints implemented  

Start the server and visit `http://localhost:8000/docs` to explore the interactive API documentation!
