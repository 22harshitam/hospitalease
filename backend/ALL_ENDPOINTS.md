# 🌐 HospitalEasy Backend - Complete API Endpoints

## 🔐 Authentication Endpoints

### POST `/api/auth/test`
- **Description**: Test authentication endpoint
- **Authentication**: None required
- **Request Body**: None
- **Response**: 
```json
{
  "message": "Authentication endpoint is working"
}
```

### POST `/api/auth/login`
- **Description**: OAuth2 password flow login
- **Authentication**: None required
- **Request Body**: Form data with `username` and `password`
- **Response**:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

### POST `/api/auth/login-json`
- **Description**: JSON login with email and password
- **Authentication**: None required
- **Request Body**:
```json
{
  "email": "doctor@hospital.com",
  "password": "password123"
}
```
- **Response**:
```json
{
  "access_token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
  "token_type": "bearer"
}
```

### GET `/api/auth/me`
- **Description**: Get current doctor profile
- **Authentication**: JWT token required
- **Headers**: `Authorization: Bearer <token>`
- **Response**:
```json
{
  "id": "1",
  "name": "Dr. Arun Ravi",
  "specialization": "Cardiologist",
  "rating": 4.8,
  "reviews": 120,
  "experience": "12+ Years Experience",
  "image_url": "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
  "is_available": true,
  "biography": "Dr. Arun Ravi is a senior Cardiologist in Mumbai with over 12 years of experience at AIIMS Delhi.",
  "consultation_fee": 1200,
  "email": "doctor@hospital.com"
}
```

---

## 👨‍⚕️ Doctors Endpoints

### GET `/api/doctors/`
- **Description**: List all doctors
- **Authentication**: None required
- **Query Parameters**: None
- **Response**: Array of doctor objects
```json
[
  {
    "id": "1",
    "name": "Dr. Arun Ravi",
    "specialization": "Cardiologist",
    "rating": 4.8,
    "reviews": 120,
    "experience": "12+ Years Experience",
    "image_url": "https://img.freepik.com/free-photo/doctor-with-his-arms-crossed-white-background_1368-5790.jpg",
    "is_available": true,
    "biography": "Dr. Arun Ravi is a senior Cardiologist in Mumbai with over 12 years of experience at AIIMS Delhi.",
    "consultation_fee": 1200,
    "email": "doctor@hospital.com"
  }
]
```

### GET `/api/doctors/{doctor_id}`
- **Description**: Get doctor by ID
- **Authentication**: None required
- **Path Parameters**: `doctor_id` (string)
- **Response**: Single doctor object

### POST `/api/doctors/`
- **Description**: Create new doctor
- **Authentication**: None required
- **Request Body**:
```json
{
  "name": "Dr. New Doctor",
  "specialization": "General Medicine",
  "rating": 4.5,
  "reviews": 50,
  "experience": "5+ Years Experience",
  "image_url": "https://example.com/doctor.jpg",
  "biography": "Experienced general practitioner",
  "consultation_fee": 800,
  "email": "newdoctor@hospital.com",
  "password": "password123"
}
```
- **Response**: Created doctor object

### PUT `/api/doctors/{doctor_id}`
- **Description**: Update doctor profile
- **Authentication**: JWT token required (doctor can only update own profile)
- **Path Parameters**: `doctor_id` (string)
- **Request Body**: Same as POST endpoint
- **Response**: Updated doctor object

---

## 📅 Appointments Endpoints

### GET `/api/appointments/`
- **Description**: List appointments (filtered by current doctor)
- **Authentication**: JWT token required
- **Query Parameters**:
  - `doctor_id` (optional): Filter by specific doctor ID
  - `status` (optional): Filter by status ("Upcoming", "Completed", "Cancelled")
- **Response**: Array of appointment objects
```json
[
  {
    "id": "1",
    "doctor_id": "1",
    "date": "2024-01-15T10:00:00",
    "time_slot": "10:00 AM",
    "patient_name": "Arjun Mehta",
    "patient_age": "42",
    "patient_phone": "9876543210",
    "patient_email": null,
    "patient_symptoms": "Mild chest pain and high blood pressure",
    "status": "Upcoming",
    "token": "HEA12345",
    "created_at": "2024-01-14T12:00:00"
  }
]
```

### GET `/api/appointments/{appointment_id}`
- **Description**: Get appointment by ID
- **Authentication**: JWT token required (doctor can only view own appointments)
- **Path Parameters**: `appointment_id` (string)
- **Response**: Single appointment object

### POST `/api/appointments/`
- **Description**: Create new appointment
- **Authentication**: None required
- **Request Body**:
```json
{
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
}
```
- **Response**: Created appointment object

### PUT `/api/appointments/{appointment_id}`
- **Description**: Update appointment status
- **Authentication**: JWT token required (doctor can only update own appointments)
- **Path Parameters**: `appointment_id` (string)
- **Request Body**:
```json
{
  "status": "Completed"
}
```
- **Response**: Updated appointment object

### DELETE `/api/appointments/{appointment_id}`
- **Description**: Cancel appointment
- **Authentication**: JWT token required (doctor can only cancel own appointments)
- **Path Parameters**: `appointment_id` (string)
- **Response**:
```json
{
  "message": "Appointment cancelled successfully"
}
```

---

## 💊 Prescriptions Endpoints

### GET `/api/prescriptions/`
- **Description**: List prescriptions (filtered by current doctor)
- **Authentication**: JWT token required
- **Query Parameters**:
  - `appointment_id` (optional): Filter by specific appointment ID
- **Response**: Array of prescription objects
```json
[
  {
    "id": 1,
    "appointment_id": "1",
    "medicines": ["Paracetamol", "Ibuprofen"],
    "instructions": "Take after meals twice daily",
    "date": "2024-01-15T10:00:00",
    "created_at": "2024-01-15T10:30:00"
  }
]
```

### GET `/api/prescriptions/{prescription_id}`
- **Description**: Get prescription by ID
- **Authentication**: JWT token required (doctor can only view own prescriptions)
- **Path Parameters**: `prescription_id` (integer)
- **Response**: Single prescription object

### POST `/api/prescriptions/`
- **Description**: Create new prescription
- **Authentication**: JWT token required (doctor can only create for own appointments)
- **Request Body**:
```json
{
  "appointment_id": "1",
  "medicines": ["Paracetamol", "Ibuprofen"],
  "instructions": "Take after meals twice daily",
  "date": "2024-01-15T10:00:00"
}
```
- **Response**: Created prescription object

### PUT `/api/prescriptions/{prescription_id}`
- **Description**: Update prescription
- **Authentication**: JWT token required (doctor can only update own prescriptions)
- **Path Parameters**: `prescription_id` (integer)
- **Request Body**: Same as POST endpoint
- **Response**: Updated prescription object

---

## 🏠 System Endpoints

### GET `/`
- **Description**: Root endpoint
- **Authentication**: None required
- **Response**:
```json
{
  "message": "HospitalEasy API is running"
}
```

### GET `/health`
- **Description**: Health check endpoint
- **Authentication**: None required
- **Response**:
```json
{
  "status": "healthy"
}
```

---

## 🔒 Authentication Flow

### 1. Login
```bash
curl -X POST http://localhost:8000/api/auth/login-json \
  -H "Content-Type: application/json" \
  -d '{"email": "doctor@hospital.com", "password": "password123"}'
```

### 2. Use Token for Protected Endpoints
```bash
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9..."
```

---

## 📊 Endpoint Summary

| Category | Endpoints | Auth Required |
|----------|-----------|---------------|
| Authentication | 4 endpoints | 1 requires auth |
| Doctors | 4 endpoints | 1 requires auth |
| Appointments | 5 endpoints | 4 require auth |
| Prescriptions | 4 endpoints | 4 require auth |
| System | 2 endpoints | 0 require auth |
| **Total** | **19 endpoints** | **10 require auth** |

---

## 🧪 Testing Examples

### Test All Endpoints
```bash
# 1. Test health
curl http://localhost:8000/health

# 2. Get all doctors
curl http://localhost:8000/api/doctors/

# 3. Login as doctor
TOKEN=$(curl -s -X POST http://localhost:8000/api/auth/login-json \
  -H "Content-Type: application/json" \
  -d '{"email": "doctor@hospital.com", "password": "password123"}' | \
  python3 -c "import sys, json; print(json.load(sys.stdin)['access_token'])")

# 4. Get doctor profile
curl -X GET http://localhost:8000/api/auth/me \
  -H "Authorization: Bearer $TOKEN"

# 5. Get appointments
curl -X GET http://localhost:8000/api/appointments/ \
  -H "Authorization: Bearer $TOKEN"

# 6. Create appointment
curl -X POST http://localhost:8000/api/appointments/ \
  -H "Content-Type: application/json" \
  -d '{
    "doctor_id": "1",
    "date": "2024-01-15T10:00:00",
    "time_slot": "10:00 AM",
    "patient_details": {
      "name": "Test Patient",
      "age": "30",
      "phone": "9876543210",
      "symptoms": "Test symptoms"
    }
  }'
```

---

## 📱 Flutter Integration

### Base URL
```dart
const String BASE_URL = 'http://localhost:8000';
```

### Authentication Service
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

### API Service
```dart
class ApiService {
  Future<List<Doctor>> getDoctors() async {
    final response = await http.get(Uri.parse('$BASE_URL/api/doctors/'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Doctor.fromJson(json)).toList();
    }
    throw Exception('Failed to load doctors');
  }
}
```

---

## 🚀 Start Server

```bash
cd /Users/kiranlalk/Desktop/hospitaleasy/backend
python3 -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Visit**: `http://localhost:8000/docs` for interactive API documentation
