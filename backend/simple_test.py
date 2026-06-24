"""
Simple authentication test without requiring database
"""
import sys
import os

# Add the parent directory to the path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

def test_imports():
    """Test that all modules can be imported"""
    try:
        from app.core.security import create_access_token, verify_token, get_password_hash
        print("✓ Security module imports working")
        
        from app.schemas.auth import Token, AuthResponse
        print("✓ Auth schemas importing")
        
        from app.schemas.doctor import DoctorCreate, DoctorResponse
        print("✓ Doctor schemas importing")
        
        from app.models.doctor import Doctor
        print("✓ Doctor model importing")
        
        return True
    except Exception as e:
        print(f"✗ Import error: {e}")
        return False

def test_security_functions():
    """Test security functions"""
    try:
        from app.core.security import create_access_token, verify_token, get_password_hash
        
        # Test password hashing
        password = "test123"
        hashed = get_password_hash(password)
        print(f"✓ Password hashing works: {hashed[:20]}...")
        
        # Test token creation and verification
        token_data = {"sub": "test@example.com"}
        token = create_access_token(token_data)
        print(f"✓ Token creation works: {token[:20]}...")
        
        # Test token verification
        payload = verify_token(token)
        if payload and payload.get("sub") == "test@example.com":
            print("✓ Token verification works")
        else:
            print("✗ Token verification failed")
            return False
            
        return True
    except Exception as e:
        print(f"✗ Security function error: {e}")
        return False

def test_schemas():
    """Test Pydantic schemas"""
    try:
        from app.schemas.doctor import DoctorCreate
        from app.schemas.auth import Token, AuthResponse
        
        # Test Doctor schema
        doctor_data = {
            "name": "Dr. Test",
            "specialization": "Test",
            "rating": 4.5,
            "reviews": 10,
            "experience": "5+ years",
            "image_url": "http://test.com",
            "biography": "Test doctor",
            "consultation_fee": 500,
            "email": "test@test.com",
            "password": "test123"
        }
        doctor = DoctorCreate(**doctor_data)
        print("✓ Doctor schema validation works")
        
        # Test Token schema
        token_data = {"access_token": "test_token", "token_type": "bearer"}
        token = Token(**token_data)
        print("✓ Token schema validation works")
        
        # Test AuthResponse schema
        auth_data = {"message": "Test message"}
        auth_response = AuthResponse(**auth_data)
        print("✓ AuthResponse schema validation works")
        
        return True
    except Exception as e:
        print(f"✗ Schema validation error: {e}")
        return False

if __name__ == "__main__":
    print("Running backend authentication tests...")
    print("=" * 50)
    
    success = True
    
    if not test_imports():
        success = False
    
    if not test_security_functions():
        success = False
        
    if not test_schemas():
        success = False
    
    print("=" * 50)
    if success:
        print("🎉 All tests passed! Backend is ready for integration.")
    else:
        print("❌ Some tests failed. Please check the errors above.")
