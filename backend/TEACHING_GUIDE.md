# 🏥 HospitalEasy Backend - Complete Teaching Guide

## 🎯 Course Overview

This guide will teach students how to understand, set up, and work with a **complete FastAPI backend** for a hospital appointment management system. The backend demonstrates modern Python web development practices including REST APIs, database integration, authentication, and more.

---

## 📚 Learning Objectives

By the end of this guide, students will understand:
- ✅ **FastAPI framework** and modern Python web development
- ✅ **PostgreSQL database** integration with SQLAlchemy ORM
- ✅ **JWT authentication** and security best practices
- ✅ **RESTful API design** principles
- ✅ **Database migrations** with Alembic
- ✅ **Pydantic schemas** for data validation
- ✅ **Project structure** and code organization
- ✅ **Environment configuration** and deployment concepts

---

## 🛠️ Prerequisites Check

### Required Software
```bash
# Check Python version (3.8+ required)
python --version

# Check PostgreSQL installation
psql --version

# Check Git
git --version
```

### System Requirements
- **Python 3.8+** installed
- **PostgreSQL 12+** installed and running
- **Basic command line** familiarity
- **Text editor** (VS Code recommended)
- **Basic Python knowledge** (variables, functions, classes)

---

## 🏗️ Project Structure Deep Dive

### Directory Overview
```
backend/
├── app/                      # Main application package
│   ├── api/                 # API route handlers (controllers)
│   │   ├── auth.py         # Authentication endpoints
│   │   ├── doctors.py      # Doctor management endpoints
│   │   ├── appointments.py # Appointment system endpoints
│   │   └── prescriptions.py# Prescription endpoints
│   ├── core/               # Core configuration and utilities
│   │   ├── config.py       # Settings and environment variables
│   │   └── security.py     # JWT and password security
│   ├── db/                 # Database connection setup
│   │   └── database.py     # SQLAlchemy database configuration
│   ├── models/             # Database models (SQLAlchemy)
│   │   ├── doctor.py       # Doctor table model
│   │   ├── appointment.py  # Appointment table model
│   │   └── prescription.py # Prescription table model
│   ├── schemas/            # Data validation schemas (Pydantic)
│   │   ├── auth.py         # Authentication data schemas
│   │   ├── doctor.py       # Doctor data schemas
│   │   ├── appointment.py  # Appointment data schemas
│   │   └── prescription.py # Prescription data schemas
│   └── main.py            # FastAPI application entry point
├── alembic/               # Database migration files
├── tests/                 # Test files
├── requirements.txt       # Python dependencies
├── .env                  # Environment variables
├── alembic.ini           # Alembic configuration
└── README.md            # Project documentation
```

### Architecture Pattern: **Layered Architecture**

1. **Presentation Layer** (`app/api/`) - HTTP request/response handling
2. **Business Logic Layer** (embedded in API routes) - Core application logic
3. **Data Access Layer** (`app/models/`) - Database operations
4. **Configuration Layer** (`app/core/`) - Settings and security

---

## 📦 Dependencies Explained

### Core Framework
```txt
fastapi==0.104.1          # Modern Python web framework
uvicorn[standard]==0.24.0 # ASGI server for running FastAPI
```

### Database & ORM
```txt
sqlalchemy==2.0.23        # Object-Relational Mapping (ORM)
alembic==1.12.1          # Database migration tool
psycopg2-binary==2.9.9   # PostgreSQL database driver
```

### Security & Authentication
```txt
python-jose[cryptography]==3.3.0  # JWT token handling
passlib[bcrypt]==1.7.4             # Password hashing
```

### Data Validation & Configuration
```txt
pydantic==2.5.0         # Data validation and serialization
python-dotenv==1.0.0   # Environment variable management
python-multipart==0.0.6 # Form data handling
```

### Testing & Development
```txt
pytest==7.4.3          # Testing framework
httpx==0.25.2          # Async HTTP client for testing
```

---

## 🚀 Step-by-Step Installation Guide

### Step 1: Environment Setup
```bash
# Clone the repository
git clone <repository-url>
cd hospitaleasy/backend

# Create virtual environment (recommended)
python -m venv venv

# Activate virtual environment
# On Windows:
venv\Scripts\activate
# On macOS/Linux:
source venv/bin/activate
```

### Step 2: Install Dependencies
```bash
# Install all required packages
pip install -r requirements.txt

# Verify installation
pip list
```

### Step 3: Database Setup
```bash
# Start PostgreSQL service
# On macOS with Homebrew:
brew services start postgresql

# Create database user
createuser hospital_user

# Create database
createdb hospital_db -O hospital_user

# Set password for database user
psql -d hospital_db -c "ALTER USER hospital_user PASSWORD 'hospital_pass';"
```

### Step 4: Environment Configuration
```bash
# Create environment file
cp .env.example .env
# Or create .env file manually:
```

**.env file content:**
```env
DATABASE_URL=postgresql://hospital_user:hospital_pass@localhost:5432/hospital_db
SECRET_KEY=your-super-secret-key-change-in-production-use-random-string
ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Step 5: Database Migration
```bash
# Initialize Alembic (first time only)
alembic init alembic

# Run database migrations
alembic upgrade head

# Verify tables were created
psql -d hospital_db -c "\dt"
```

### Step 6: Seed Initial Data
```bash
# Populate database with sample data
python seed_simple.py

# Verify data was inserted
psql -d hospital_db -c "SELECT COUNT(*) FROM doctors;"
```

### Step 7: Start the Server
```bash
# Development server with auto-reload
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Alternative: python module syntax
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

---

## 🔍 Code Structure Deep Dive

### 1. Main Application (`app/main.py`)

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.api import auth, doctors, appointments, prescriptions
from app.core.config import settings

# Create FastAPI instance
app = FastAPI(
    title="HospitalEasy API",
    description="Backend API for HospitalEasy appointment system",
    version="1.0.0"
)

# CORS middleware - allows cross-origin requests
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify your Flutter app's origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routers
app.include_router(auth.router, prefix="/api/auth", tags=["authentication"])
app.include_router(doctors.router, prefix="/api/doctors", tags=["doctors"])
app.include_router(appointments.router, prefix="/api/appointments", tags=["appointments"])
app.include_router(prescriptions.router, prefix="/api/prescriptions", tags=["prescriptions"])
```

**Key Concepts:**
- **FastAPI Instance**: Main application object
- **Middleware**: Cross-Origin Resource Sharing (CORS) configuration
- **Routers**: Modular API endpoint organization
- **Prefixes**: URL path organization (`/api/auth`, `/api/doctors`, etc.)

### 2. Database Models (`app/models/`)

#### Doctor Model (`app/models/doctor.py`)
```python
from sqlalchemy import Column, String, Float, Integer, Boolean, Text
from app.db.database import Base

class Doctor(Base):
    __tablename__ = "doctors"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    specialization = Column(String, nullable=False)
    rating = Column(Float, nullable=False)
    reviews = Column(Integer, nullable=False)
    experience = Column(String, nullable=False)
    image_url = Column(String, nullable=False)
    is_available = Column(Boolean, default=True)
    biography = Column(Text, nullable=False)
    consultation_fee = Column(Float, nullable=False)
    email = Column(String, unique=True, nullable=False, index=True)
    hashed_password = Column(String)
```

**Key SQLAlchemy Concepts:**
- **Base**: Base class for all models
- **Column**: Database column definitions
- **String, Float, Integer, Boolean, Text**: Data types
- **primary_key**: Unique identifier
- **index**: Performance optimization for queries
- **nullable**: Whether column can be empty
- **unique**: Enforce uniqueness constraint

### 3. Pydantic Schemas (`app/schemas/`)

#### Doctor Schema (`app/schemas/doctor.py`)
```python
from pydantic import BaseModel, EmailStr
from typing import Optional

class DoctorBase(BaseModel):
    name: str
    specialization: str
    rating: float
    reviews: int
    experience: str
    image_url: str
    biography: str
    consultation_fee: float
    email: EmailStr

class DoctorCreate(DoctorBase):
    password: str

class DoctorResponse(DoctorBase):
    id: str
    is_available: bool
    
    class Config:
        from_attributes = True

class DoctorUpdate(BaseModel):
    name: Optional[str] = None
    specialization: Optional[str] = None
    # ... other optional fields
```

**Key Pydantic Concepts:**
- **BaseModel**: Base class for all schemas
- **Type Hints**: Automatic validation (str, int, float, bool)
- **Optional**: Fields that can be None
- **EmailStr**: Email validation
- **Config.from_attributes**: Allow creating from ORM objects

### 4. API Routes (`app/api/`)

#### Authentication Routes (`app/api/auth.py`)
```python
from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer, OAuth2PasswordRequestForm
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.schemas.auth import Token
from app.core.security import verify_password, create_access_token

router = APIRouter()
oauth2_scheme = OAuth2PasswordBearer(tokenUrl="api/auth/login")

@router.post("/login", response_model=Token)
async def login(form_data: OAuth2PasswordRequestForm = Depends(), db: Session = Depends(get_db)):
    # Authenticate user
    user = authenticate_user(db, form_data.username, form_data.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email or password",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    # Create access token
    access_token = create_access_token(data={"sub": user.email})
    return {"access_token": access_token, "token_type": "bearer"}
```

**Key FastAPI Concepts:**
- **APIRouter**: Modular route organization
- **Depends**: Dependency injection system
- **HTTPException**: Error handling
- **OAuth2PasswordBearer**: Security scheme
- **Response Models**: Automatic response validation

### 5. Security (`app/core/security.py`)
```python
from datetime import datetime, timedelta
from typing import Optional
from jose import JWTError, jwt
from passlib.context import CryptContext
from app.core.config import settings

# Password hashing context
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

def verify_password(plain_password: str, hashed_password: str) -> bool:
    """Verify a password against its hash."""
    return pwd_context.verify(plain_password, hashed_password)

def get_password_hash(password: str) -> str:
    """Generate password hash."""
    return pwd_context.hash(password)

def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    """Create JWT access token."""
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, settings.SECRET_KEY, algorithm=settings.ALGORITHM)
    return encoded_jwt
```

**Key Security Concepts:**
- **bcrypt**: Secure password hashing
- **JWT**: JSON Web Tokens for authentication
- **Secret Key**: Cryptographic signing key
- **Expiration**: Token lifetime management

---

## 🗄️ Database Schema Explained

### Entity Relationship Diagram
```
┌─────────────┐     ┌─────────────────┐     ┌──────────────┐
│   doctors   │     │   appointments  │     │ prescriptions│
├─────────────┤     ├─────────────────┤     ├──────────────┤
│ id (PK)     │◄────┤ doctor_id (FK)  │◄────┤ appointment_ │
│ name        │     │ id (PK)         │     │ id (FK)      │
│ email       │     │ date            │     │ id (PK)      │
│ password    │     │ time_slot       │     │ medicines    │
│ specialty   │     │ patient_name    │     │ instructions │
│ rating      │     │ patient_phone   │     │ date         │
│ ...         │     │ status          │     │ ...          │
└─────────────┘     │ token           │     └──────────────┘
                    │ ...             │
                    └─────────────────┘
```

### Table Relationships
- **doctors** ↔ **appointments**: One-to-Many (one doctor can have many appointments)
- **appointments** ↔ **prescriptions**: One-to-One (each appointment can have one prescription)

---

## 🌐 API Endpoints Reference

### Authentication Endpoints
```
POST /api/auth/test              # Test endpoint (no auth required)
POST /api/auth/login             # OAuth2 password flow login
POST /api/auth/login-json        # JSON login with email/password
GET  /api/auth/me               # Get current doctor profile (requires auth)
```

### Doctor Management
```
GET    /api/doctors/             # List all doctors
GET    /api/doctors/{id}         # Get doctor by ID
POST   /api/doctors/             # Create new doctor
PUT    /api/doctors/{id}         # Update doctor (requires auth)
```

### Appointment System
```
GET    /api/appointments/        # List appointments (filtered by doctor)
GET    /api/appointments/{id}    # Get appointment by ID
POST   /api/appointments/        # Create new appointment
PUT    /api/appointments/{id}    # Update appointment status
DELETE /api/appointments/{id}    # Cancel appointment
```

### Prescription Management
```
GET    /api/prescriptions/       # List prescriptions
GET    /api/prescriptions/{id}   # Get prescription by ID
POST   /api/prescriptions/       # Create new prescription
PUT    /api/prescriptions/{id}   # Update prescription
```

---

## 🧪 Testing the API

### 1. Health Check
```bash
curl http://localhost:8000/health
# Expected: {"status": "healthy"}
```

### 2. Get All Doctors
```bash
curl http://localhost:8000/api/doctors/
# Expected: JSON array of doctor objects
```

### 3. Authentication Test
```bash
# Login with default doctor
curl -X POST http://localhost:8000/api/auth/login-json \
  -H "Content-Type: application/json" \
  -d '{"email": "doctor@hospital.com", "password": "password123"}'

# Expected: {"access_token": "...", "token_type": "bearer"}
```

### 4. Create Appointment (with auth)
```bash
# First get token from login
TOKEN="your_jwt_token_here"

# Create appointment
curl -X POST http://localhost:8000/api/appointments/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "doctor_id": "1",
    "date": "2024-01-15T10:00:00",
    "time_slot": "10:00 AM",
    "patient_details": {
      "name": "John Doe",
      "age": "35",
      "phone": "9876543210",
      "email": "john@example.com",
      "symptoms": "Headache and fever"
    }
  }'
```

---

## 🔧 Development Workflow

### Adding New Features

#### 1. Add New Database Model
```python
# app/models/new_model.py
from sqlalchemy import Column, String, Integer
from app.db.database import Base

class NewModel(Base):
    __tablename__ = "new_table"
    
    id = Column(String, primary_key=True, index=True)
    name = Column(String, nullable=False)
    # ... other fields
```

#### 2. Create Pydantic Schema
```python
# app/schemas/new_model.py
from pydantic import BaseModel

class NewModelBase(BaseModel):
    name: str

class NewModelCreate(NewModelBase):
    pass

class NewModelResponse(NewModelBase):
    id: str
    
    class Config:
        from_attributes = True
```

#### 3. Create API Routes
```python
# app/api/new_model.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db

router = APIRouter()

@router.get("/")
async def get_new_models(db: Session = Depends(get_db)):
    # Implementation here
    pass
```

#### 4. Update Main App
```python
# app/main.py
from app.api import new_model

app.include_router(new_model.router, prefix="/api/new-model", tags=["new-model"])
```

#### 5. Create Database Migration
```bash
# Generate migration file
alembic revision --autogenerate -m "Add new model"

# Apply migration
alembic upgrade head
```

---

## 🚨 Common Issues & Solutions

### Database Connection Issues
```bash
# Check PostgreSQL status
brew services list | grep postgresql

# Restart PostgreSQL
brew services restart postgresql

# Test connection
psql -h localhost -U hospital_user -d hospital_db
```

### Permission Issues
```bash
# Grant database permissions
psql -d hospital_db -c "GRANT ALL PRIVILEGES ON SCHEMA public TO hospital_user;"
```

### Import Errors
```bash
# Reinstall dependencies
pip install -r requirements.txt --force-reinstall

# Check Python path
python -c "import sys; print(sys.path)"
```

### Port Already in Use
```bash
# Check what's using port 8000
lsof -i :8000

# Kill the process
kill -9 <PID>
```

---

## 📱 Flutter Integration Example

### HTTP Client Setup
```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:8000';
  
  // Authentication
  Future<String?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login-json'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );
    
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['access_token'];
    }
    return null;
  }
  
  // Get doctors
  Future<List<dynamic>> getDoctors() async {
    final response = await http.get(Uri.parse('$baseUrl/api/doctors/'));
    
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return [];
  }
}
```

---

## 🎯 Teaching Activities

### 1. Code Reading Exercise
Have students read and explain:
- `app/main.py` - Application structure
- `app/models/doctor.py` - Database model
- `app/api/auth.py` - Authentication logic
- `app/core/security.py` - Security implementation

### 2. Hands-on Exercises
1. **Add a new field** to the Doctor model
2. **Create a new endpoint** for doctor availability
3. **Implement password reset** functionality
4. **Add input validation** for appointments
5. **Create unit tests** for authentication

### 3. Debugging Challenges
1. Fix a broken authentication flow
2. Resolve database connection issues
3. Debug CORS problems
4. Fix data validation errors

### 4. Extension Projects
1. **Email notifications** for appointments
2. **File upload** for medical documents
3. **Role-based access control** (admin, doctor, patient)
4. **Appointment reminders** system
5. **Analytics dashboard** for hospital management

---

## 📚 Additional Learning Resources

### Documentation
- [FastAPI Official Docs](https://fastapi.tiangolo.com/)
- [SQLAlchemy Documentation](https://docs.sqlalchemy.org/)
- [Pydantic Documentation](https://pydantic-docs.helpmanual.io/)
- [Alembic Documentation](https://alembic.sqlalchemy.org/)

### Best Practices
- [Python Code Style Guide (PEP 8)](https://pep8.org/)
- [REST API Design Guidelines](https://restfulapi.net/)
- [Database Normalization Rules](https://www.guru99.com/database-normalization.html)

### Advanced Topics
- **Async/Await** in Python
- **Database Connection Pooling**
- **API Rate Limiting**
- **Caching Strategies**
- **Microservices Architecture**

---

## ✅ Assessment Checklist

### Understanding Check
- [ ] Can explain FastAPI application structure
- [ ] Understands SQLAlchemy ORM concepts
- [ ] Can implement JWT authentication
- [ ] Knows how to create API endpoints
- [ ] Can write database migrations
- [ ] Understands data validation with Pydantic

### Practical Skills
- [ ] Can set up development environment
- [ ] Can create new database models
- [ ] Can implement new API endpoints
- [ ] Can debug common issues
- [ ] Can write basic tests
- [ ] Can integrate with frontend applications

---

## 🎉 Conclusion

This HospitalEasy backend demonstrates **modern Python web development** best practices including:

- **Clean Architecture**: Separation of concerns with modular structure
- **Security First**: JWT authentication and password hashing
- **Data Validation**: Comprehensive input validation with Pydantic
- **Database Design**: Proper relational database design with SQLAlchemy
- **API Standards**: RESTful API design principles
- **Development Tools**: Modern development workflow with migrations and testing

Students who complete this guide will have a solid foundation in **backend web development** and be prepared to build their own APIs and web applications.

---

## 📞 Support & Next Steps

### For Students
- Review the codebase thoroughly
- Experiment with the API endpoints
- Try the extension projects
- Ask questions about concepts you don't understand

### For Instructors
- Use the provided exercises and activities
- Customize the difficulty based on student level
- Add domain-specific examples relevant to your course
- Encourage collaborative projects

**Happy Learning! 🚀**
