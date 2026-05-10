# AI-Based Intelligent Event Vendor Management System - Backend Phase 1

This is the backend foundation built with FastAPI and connected to Supabase using the native `supabase-py` client.

## Prerequisites
- Python 3.12+
- Supabase Account

## Setup Instructions

1. **Create Virtual Environment**
   ```bash
   python -m venv venv
   # On Windows
   venv\Scripts\activate
   # On macOS/Linux
   source venv/bin/activate
   ```

2. **Install Dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Environment Configuration**
   - Copy `.env.example` to `.env`
   - Fill in your Supabase connection string and credentials in `.env`
   ```bash
   cp .env.example .env
   ```



## Running the Application

Start the FastAPI server:
```bash
uvicorn app.main:app --reload
```

## API Documentation
Once running, visit:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`
- Health Endpoint: `http://localhost:8000/health`
