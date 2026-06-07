import os
import sqlite3
from datetime import datetime, timezone

DB_PATH = os.path.join(os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__)))), "local_dashboard.db")

def get_db_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.row_factory = sqlite3.Row
    return conn

def init_db():
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Create reviews table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS reviews (
        id TEXT PRIMARY KEY,
        vendor_id TEXT NOT NULL,
        reviewer_name TEXT NOT NULL,
        rating INTEGER NOT NULL,
        comment TEXT,
        created_at TEXT NOT NULL
    )
    """)
    
    # Create activities table
    cursor.execute("""
    CREATE TABLE IF NOT EXISTS activities (
        id TEXT PRIMARY KEY,
        vendor_id TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        type TEXT NOT NULL
    )
    """)
    
    conn.commit()
    conn.close()

# Initialize on import
init_db()

def get_reviews(vendor_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM reviews WHERE vendor_id = ? ORDER BY created_at DESC", (vendor_id,))
    rows = cursor.fetchall()
    reviews = [dict(row) for row in rows]
    conn.close()
    return reviews

def insert_review(id_: str, vendor_id: str, reviewer_name: str, rating: int, comment: str, created_at: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO reviews (id, vendor_id, reviewer_name, rating, comment, created_at) VALUES (?, ?, ?, ?, ?, ?)",
        (id_, vendor_id, reviewer_name, rating, comment, created_at)
    )
    conn.commit()
    conn.close()

def get_activities(vendor_id: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute("SELECT * FROM activities WHERE vendor_id = ? ORDER BY created_at DESC LIMIT 10", (vendor_id,))
    rows = cursor.fetchall()
    activities = [dict(row) for row in rows]
    conn.close()
    return activities

def insert_activity(id_: str, vendor_id: str, title: str, description: str, created_at: str, type_: str):
    conn = get_db_connection()
    cursor = conn.cursor()
    cursor.execute(
        "INSERT INTO activities (id, vendor_id, title, description, created_at, type) VALUES (?, ?, ?, ?, ?, ?)",
        (id_, vendor_id, title, description, created_at, type_)
    )
    conn.commit()
    conn.close()

def seed_vendor_data_if_empty(vendor_id: str):
    import uuid
    conn = get_db_connection()
    cursor = conn.cursor()
    
    # Check reviews count
    cursor.execute("SELECT COUNT(*) FROM reviews WHERE vendor_id = ?", (vendor_id,))
    reviews_count = cursor.fetchone()[0]
    
    if reviews_count == 0:
        # Seed reviews
        mock_reviews = [
            ("Amit Pathak", 5, "The food was absolutely delicious! Every guest praised the catering. Highly recommended for weddings.", "2026-06-05T12:00:00Z"),
            ("Sangeeta Roy", 4, "Very professional team. They managed the crowd well, though the dessert refill was a bit slow.", "2026-06-04T15:30:00Z"),
            ("Vikram Malhotra", 5, "Top-notch service. The presentation was elegant and the staff was extremely polite.", "2026-06-03T09:15:00Z"),
            ("Neha Gupta", 5, "EventLink recommended them for my engagement. Best decision ever! The snacks were the highlight.", "2026-06-02T18:45:00Z"),
            ("Rajesh Khanna", 3, "Food was good but the communication before the event could have been better.", "2026-06-01T10:00:00Z")
        ]
        for name, rating, comment, date in mock_reviews:
            cursor.execute(
                "INSERT INTO reviews (id, vendor_id, reviewer_name, rating, comment, created_at) VALUES (?, ?, ?, ?, ?, ?)",
                (str(uuid.uuid4()), vendor_id, name, rating, comment, date)
            )
            
    # Check activities count
    cursor.execute("SELECT COUNT(*) FROM activities WHERE vendor_id = ?", (vendor_id,))
    activities_count = cursor.fetchone()[0]
    
    if activities_count == 0:
        # Seed activities
        mock_activities = [
            ("Booking Approved", "You accepted the wedding booking request for Rahul S.", "2026-06-07T14:30:00Z", "booking_approved"),
            ("New Review Received", "Amit Pathak gave you a 5-star rating.", "2026-06-07T12:00:00Z", "review_received"),
            ("Availability Updated", "Blocked June 15th, 2026 in your calendar.", "2026-06-06T18:00:00Z", "availability_updated"),
            ("Booking Received", "New booking request from Priya M. for Dec 28th.", "2026-06-06T10:00:00Z", "booking_received")
        ]
        for title, desc, date, type_ in mock_activities:
            cursor.execute(
                "INSERT INTO activities (id, vendor_id, title, description, created_at, type) VALUES (?, ?, ?, ?, ?, ?)",
                (str(uuid.uuid4()), vendor_id, title, desc, date, type_)
            )
            
    conn.commit()
    conn.close()
