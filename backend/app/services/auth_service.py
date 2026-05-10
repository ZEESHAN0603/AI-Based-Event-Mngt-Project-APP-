from fastapi import HTTPException, status
from supabase import Client
from app.schemas.auth_schema import UserRegister, UserLogin, TokenResponse
from app.utils.security import hash_password, verify_password
from app.auth.jwt_handler import create_access_token
import uuid
from datetime import datetime, timezone

def register_user(user: UserRegister, supabase: Client):
    # Check if email exists
    try:
        response = supabase.table("users").select("id").eq("email", user.email).execute()
        if response.data and len(response.data) > 0:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Email already registered"
            )
    except HTTPException:
        raise
    except Exception as e:
        print(f"SUPABASE SELECT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Failed to verify email uniqueness."
        )
    
    # Hash password
    hashed_password = hash_password(user.password)
    
    # Generate UUID and timestamps
    user_id = str(uuid.uuid4())
    created_at = datetime.now(timezone.utc).isoformat()
    
    # Insert user
    user_data = {
        "id": user_id,
        "name": user.name,
        "email": user.email,
        "password_hash": hashed_password,
        "role": user.role,
        "phone": user.phone,
        "city": user.city,
        "created_at": created_at
    }
    
    try:
        result = supabase.table("users").insert(user_data).execute()
        print(f"SUPABASE INSERT SUCCESS: {result.data}")
        return {"message": "User registered successfully", "user_id": user_id}
    except Exception as e:
        print(f"SUPABASE INSERT ERROR: {repr(e)}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to register user: {str(e)}"
        )

def login_user(user_credentials: UserLogin, supabase: Client) -> TokenResponse:
    # Fetch user by email
    response = supabase.table("users").select("*").eq("email", user_credentials.email).execute()
    if not response.data:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    user = response.data[0]
    
    # Verify password
    if not verify_password(user_credentials.password, user["password_hash"]):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password"
        )
    
    # Create JWT
    access_token = create_access_token(
        data={"user_id": user["id"], "email": user["email"], "role": user["role"]}
    )
    
    return TokenResponse(access_token=access_token)
