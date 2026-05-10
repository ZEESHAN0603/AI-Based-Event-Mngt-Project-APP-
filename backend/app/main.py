from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.settings import get_settings
from app.routes import health, auth, events, vendors, categories, availability, shortlists, bookings, recommendations

settings = get_settings()

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description=settings.APP_DESCRIPTION,
)

# Configure CORS
# In production, you would restrict these origins
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8000",
    "*" # Placeholder for dev
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(health.router, tags=["Health"])
app.include_router(auth.router)
app.include_router(events.router)
app.include_router(vendors.router)
app.include_router(categories.router)
app.include_router(availability.router)
app.include_router(shortlists.router)
app.include_router(bookings.router)
app.include_router(recommendations.router)

@app.get("/")
def root():
    return {"message": f"Welcome to the {settings.APP_NAME} API"}
