#!/usr/bin/env python3
"""
Database Setup Script for HospitalEasy
This script helps set up the PostgreSQL database and initial data
"""
import psycopg2
import os
from getpass import getpass
import hashlib

def get_db_connection(create_db=False):
    """Get database connection"""
    db_name = 'postgres' if create_db else os.getenv('DB_NAME', 'hospitaleasy')
    
    try:
        conn = psycopg2.connect(
            host=os.getenv('DB_HOST', 'localhost'),
            database=db_name,
            user=os.getenv('DB_USER', 'postgres'),
            password=os.getenv('DB_PASSWORD', 'password'),
            port=os.getenv('DB_PORT', '5432')
        )
        return conn
    except Exception as e:
        print(f"❌ Connection failed: {e}")
        return None

def create_database():
    """Create the hospitaleasy database"""
    conn = get_db_connection(create_db=True)
    if not conn:
        return False
    
    try:
        conn.autocommit = True
        cursor = conn.cursor()
        
        # Check if database exists
        cursor.execute("SELECT 1 FROM pg_database WHERE datname = 'hospitaleasy'")
        if cursor.fetchone():
            print("✅ Database 'hospitaleasy' already exists")
        else:
            cursor.execute("CREATE DATABASE hospitaleasy")
            print("✅ Database 'hospitaleasy' created successfully")
        
        conn.close()
        return True
    except Exception as e:
        print(f"❌ Error creating database: {e}")
        return False

def execute_schema():
    """Execute the schema.sql file"""
    conn = get_db_connection()
    if not conn:
        return False
    
    try:
        with open('schema.sql', 'r') as f:
            schema_sql = f.read()
        
        cursor = conn.cursor()
        cursor.execute(schema_sql)
        conn.commit()
        
        print("✅ Database schema executed successfully")
        conn.close()
        return True
    except Exception as e:
        print(f"❌ Error executing schema: {e}")
        return False

def test_connection():
    """Test database connection and show data"""
    conn = get_db_connection()
    if not conn:
        return False
    
    try:
        cursor = conn.cursor()
        
        # Test doctors table
        cursor.execute("SELECT COUNT(*) FROM doctors")
        doctor_count = cursor.fetchone()[0]
        
        # Test appointments table
        cursor.execute("SELECT COUNT(*) FROM appointments")
        appointment_count = cursor.fetchone()[0]
        
        print(f"✅ Database connection successful!")
        print(f"📊 Doctors: {doctor_count}")
        print(f"📅 Appointments: {appointment_count}")
        
        # Show sample data
        cursor.execute("SELECT name, email, specialization FROM doctors LIMIT 2")
        doctors = cursor.fetchall()
        print("\n👨‍⚕️ Sample Doctors:")
        for doctor in doctors:
            print(f"   - {doctor[0]} ({doctor[2]})")
        
        conn.close()
        return True
    except Exception as e:
        print(f"❌ Error testing connection: {e}")
        return False

def setup_env_file():
    """Create .env file with database configuration"""
    env_content = """# HospitalEasy Database Configuration
DB_HOST=localhost
DB_NAME=hospitaleasy
DB_USER=postgres
DB_PASSWORD=password
DB_PORT=5432
SECRET_KEY=your-super-secret-key-change-in-production
"""
    
    with open('.env', 'w') as f:
        f.write(env_content)
    
    print("✅ .env file created with default configuration")
    print("📝 Please update the database credentials in .env file")

def main():
    print("🚀 HospitalEasy Database Setup")
    print("=" * 40)
    
    # Check if .env file exists
    if not os.path.exists('.env'):
        print("📝 Creating .env file...")
        setup_env_file()
        print("\n⚠️  Please update the database credentials in .env file and run this script again.")
        return
    
    # Load environment variables
    from dotenv import load_dotenv
    load_dotenv()
    
    print("🔗 Testing database connection...")
    
    # Step 1: Create database
    print("\n📦 Step 1: Creating database...")
    if not create_database():
        print("❌ Failed to create database")
        return
    
    # Step 2: Execute schema
    print("\n🏗️  Step 2: Creating database schema...")
    if not execute_schema():
        print("❌ Failed to execute schema")
        return
    
    # Step 3: Test connection
    print("\n🧪 Step 3: Testing database connection...")
    if not test_connection():
        print("❌ Failed to test connection")
        return
    
    print("\n🎉 Database setup completed successfully!")
    print("\n📋 Next steps:")
    print("   1. Run: pip install -r requirements.txt")
    print("   2. Run: python server_with_db.py")
    print("   3. Test the API endpoints")

if __name__ == "__main__":
    main()
