import os
from supabase import create_client

url = "https://wkkxgoyqnrzsoqqlxbbr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indra3hnb3lxbnJ6c29xcWx4YmJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyOTkyMDcsImV4cCI6MjA5Mzg3NTIwN30.hfzq7NbCQ0qL4IVakhdikRG3qLkYsT6xUM3_O_CLXxE"
supabase = create_client(url, key)

res = supabase.table("bookings").select(
    "*, events(event_name), vendors(business_name, vendor_categories(name))"
).execute()

mapped_bookings = []
for b in res.data:
    event_data = b.get("events") or {}
    vendor_data = b.get("vendors") or {}
    category_data = vendor_data.get("vendor_categories") or {}
    
    mapped_bookings.append({
        "id": b.get("id"),
        "event_name": event_data.get("event_name", "Unknown Event"),
        "vendor_name": vendor_data.get("business_name", "Unknown Vendor"),
        "vendor_category": category_data.get("name", "Unknown Category"),
        "total_amount": b.get("total_amount"),
        "booking_status": b.get("booking_status"), # using booking_status to match frontend
        "created_at": b.get("created_at")
    })

class MockResponse:
    def __init__(self, data):
        self.data = data
        
m = MockResponse(mapped_bookings)
print(m.data)
