from fastapi import APIRouter, Depends
from fastapi.security import OAuth2PasswordRequestForm
from supabase import Client
from app.config.supabase import get_supabase
from app.schemas.auth_schema import UserRegister, UserLogin, TokenResponse, UserResponse
from app.services.auth_service import register_user, login_user
from app.auth.jwt_handler import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", status_code=201)
def register(user: UserRegister, supabase: Client = Depends(get_supabase)):
    """Register a new user."""
    return register_user(user, supabase)

@router.post("/login", response_model=TokenResponse)
def login(form_data: OAuth2PasswordRequestForm = Depends(), supabase: Client = Depends(get_supabase)):
    """
    Login user and return JWT token.
    Note: For Swagger UI integration, this endpoint expects form data (username & password).
    The 'username' field should contain the user's email.
    """
    # We map form_data.username to our UserLogin.email schema
    user_credentials = UserLogin(email=form_data.username, password=form_data.password)
    return login_user(user_credentials, supabase)

@router.get("/me", response_model=UserResponse)
def get_me(current_user: dict = Depends(get_current_user)):
    """Get the currently authenticated user's details."""
    return current_user
