from pydantic_settings import BaseSettings, SettingsConfigDict
from functools import lru_cache

class Settings(BaseSettings):
    # App Settings
    APP_NAME: str = "AI-Based Intelligent Event Vendor Management System"
    APP_VERSION: str = "1.0.0"
    APP_DESCRIPTION: str = "Phase 1 backend foundation"


    # Supabase Settings
    SUPABASE_URL: str
    SUPABASE_KEY: str

    # JWT Settings
    JWT_SECRET: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

    #NEWS/BLOGS 
    news_api_key: str

    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8")

@lru_cache()
def get_settings():
    return Settings()
