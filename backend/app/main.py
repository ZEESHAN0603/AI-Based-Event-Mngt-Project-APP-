from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config.settings import get_settings
from app.routes import (
    health,
    auth,
    events,
    vendors,
    categories,
    availability,
    shortlists,
    bookings,
    recommendations,
    admin_routes,
    vendor_status,
    blogs,
    ai_chat,
)

settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=settings.APP_DESCRIPTION,
)

# Configure CORS (development placeholder)
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8000",
    "*",
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(health.router)
app.include_router(auth.router)
app.include_router(events.router)
app.include_router(vendors.router)
app.include_router(categories.router)
app.include_router(availability.router)
app.include_router(shortlists.router)
app.include_router(bookings.router)
app.include_router(recommendations.router)
app.include_router(admin_routes.router)
app.include_router(vendor_status.router)
app.include_router(blogs.router)
app.include_router(ai_chat.router)

@app.get("/")
def root():
    return {"message": f"Welcome to the {settings.APP_NAME} API"}
