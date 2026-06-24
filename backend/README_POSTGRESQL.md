# HospitalEasy Backend with PostgreSQL

This is the production-ready version of the HospitalEasy backend using PostgreSQL for data persistence.

## 🏗️ Database Schema

### Tables

#### **doctors**
- `id` (UUID) - Primary key
- `name` (VARCHAR) - Doctor name
- `email` (VARCHAR) - Unique email
- `specialization` (VARCHAR) - Medical specialization
- `rating` (DECIMAL) - Doctor rating
- `reviews` (INTEGER) - Number of reviews
- `experience` (VARCHAR) - Years of experience
- `image_url` (TEXT) - Profile image URL
- `is_available` (BOOLEAN) - Availability status
- `biography` (TEXT) - Doctor biography
- `consultation_fee` (DECIMAL) - Consultation fee
- `password_hash` (VARCHAR) - Hashed password
- `created_at`, `updated_at` (TIMESTAMP)

#### **patients**
- `id` (UUID) - Primary key
- `name` (VARCHAR) - Patient name
- `email` (VARCHAR) - Unique email
- `phone` (VARCHAR) - Phone number
- `age` (VARCHAR) - Patient age
- `password_hash` (VARCHAR) - Hashed password
- `address` (TEXT) - Address
- `emergency_contact` (VARCHAR) - Emergency contact
- `blood_group` (VARCHAR) - Blood group
- `created_at`, `updated_at` (TIMESTAMP)

#### **appointments**
- `id` (UUID) - Primary key
- `doctor_id` (UUID) - Foreign key to doctors
- `patient_id` (UUID) - Foreign key to patients
- `appointment_date` (DATE) - Appointment date
- `time_slot` (VARCHAR) - Time slot
- `status` (VARCHAR) - Status (Upcoming/Completed/Cancelled)
- `symptoms` (TEXT) - Patient symptoms
- `token` (VARCHAR) - Unique appointment token
- `id_file_path` (TEXT) - ID proof file path
- `photo_path` (TEXT) - Photo file path
- `consultation_fee` (DECIMAL) - Consultation fee
- `notes` (TEXT) - Doctor notes
- `created_at`, `updated_at` (TIMESTAMP)

## 🚀 Setup Instructions

### Prerequisites

1. **PostgreSQL** installed and running
2. **Python 3.8+** installed
3. **pip** package manager

### Step 1: Install Dependencies

```bash
pip install -r requirements.txt
```

Required packages:
- `psycopg2-binary` - PostgreSQL adapter
- `flask` - Web framework
- `flask-cors` - CORS support
- `python-jose` - JWT tokens
- `werkzeug` - Password hashing
- `python-dotenv` - Environment variables

### Step 2: Configure Database

Create a `.env` file with your database credentials:

```env
# HospitalEasy Database Configuration
DB_HOST=localhost
DB_NAME=hospitaleasy
DB_USER=postgres
DB_PASSWORD=your_password
DB_PORT=5432
SECRET_KEY=your-super-secret-key-change-in-production
```

### Step 3: Setup Database

Run the setup script:

```bash
python setup_database.py
```

This script will:
1. Create the `hospitaleasy` database
2. Execute the schema to create tables
3. Insert sample doctor data
4. Test the connection

### Step 4: Run the Server

```bash
python server_with_db.py
```

The server will start on `http://0.0.0.0:8000`

## 📡 API Endpoints

### Authentication
- `POST /api/auth/login-json` - Login (doctor/patient)
- `POST /api/auth/patient/register` - Patient registration
- `GET /api/auth/me` - Get current user info

### Doctors
- `GET /api/doctors/` - Get all doctors
- `GET /api/doctors/<id>` - Get specific doctor

### Appointments
- `GET /api/appointments/` - Get appointments (with filters)
- `POST /api/appointments/` - Create appointment
- `PUT /api/appointments/<id>` - Update appointment
- `DELETE /api/appointments/<id>` - Cancel appointment

### System
- `GET /health` - Health check with database status
- `GET /` - Root endpoint

## 🔐 Default Credentials

**Doctor Login:**
- Email: `doctor@hospital.com`
- Password: `password123`

**Sample Doctors:**
1. Dr. Arun Ravi (Cardiologist) - ₹1200
2. Dr. Priya Sharma (Pediatrician) - ₹800

## 📊 Database Features

### ✅ What's Included

- **UUID Primary Keys** - Unique identifiers
- **Foreign Key Constraints** - Data integrity
- **Indexes** - Performance optimization
- **Timestamps** - Created/updated tracking
- **Password Hashing** - Secure authentication
- **Connection Pooling** - Efficient connections
- **JSON Responses** - API compatibility

### 🔧 Advanced Features

- **Triggers** - Auto-update timestamps
- **Views** - Simplified queries
- **Transactions** - Data consistency
- **Error Handling** - Robust error management

## 🧪 Testing

### Test Database Connection

```bash
curl http://localhost:8000/health
```

### Test Doctor API

```bash
curl http://localhost:8000/api/doctors/
```

### Test Appointment Creation

```bash
curl -X POST http://localhost:8000/api/appointments/ \
  -H "Content-Type: application/json" \
  -d '{
    "doctor_id": "doctor-uuid-here",
    "date": "2026-05-06",
    "time_slot": "09:30 AM",
    "patient_details": {
      "name": "John Doe",
      "email": "john@example.com",
      "phone": "9876543210",
      "age": "30"
    }
  }'
```

## 🔄 Migration from In-Memory

The new PostgreSQL backend is **fully compatible** with the Flutter app. No changes needed in the mobile app!

### Differences:
- ✅ **Data Persistence** - Data survives server restarts
- ✅ **Real Database** - Production-ready storage
- ✅ **Better Performance** - Optimized queries
- ✅ **Data Integrity** - Constraints and validation
- ✅ **Scalability** - Handles multiple users

## 🚨 Troubleshooting

### Connection Issues

```bash
# Check PostgreSQL status
pg_isready -h localhost -p 5432

# Check if database exists
psql -h localhost -U postgres -l
```

### Permission Issues

```sql
-- Grant permissions in PostgreSQL
GRANT ALL PRIVILEGES ON DATABASE hospitaleasy TO your_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO your_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO your_user;
```

### Python Issues

```bash
# Install missing packages
pip install psycopg2-binary flask flask-cors python-jose werkzeug python-dotenv
```

## 📈 Production Deployment

For production deployment:

1. **Use environment variables** for all credentials
2. **Enable SSL** for database connections
3. **Use connection pooling** with appropriate limits
4. **Set up database backups**
5. **Monitor database performance**
6. **Use a WSGI server** like Gunicorn

## 🎯 Next Steps

- [ ] Add more doctor specializations
- [ ] Implement appointment reminders
- [ ] Add prescription management
- [ ] Create admin dashboard
- [ ] Add payment integration
- [ ] Implement email notifications

---

**🎉 Your HospitalEasy backend is now production-ready with PostgreSQL!**
