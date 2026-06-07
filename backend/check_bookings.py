import os
from supabase import create_client

url = "https://wkkxgoyqnrzsoqqlxbbr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indra3hnb3lxbnJ6c29xcWx4YmJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyOTkyMDcsImV4cCI6MjA5Mzg3NTIwN30.hfzq7NbCQ0qL4IVakhdikRG3qLkYsT6xUM3_O_CLXxE"
supabase = create_client(url, key)

try:
    res = supabase.table("bookings").select(
        "*, events(event_name), vendors(business_name, vendor_categories(name))"
    ).execute()
    print("Success:", len(res.data))
    if len(res.data) > 0:
        print("First booking:", res.data[0])
except Exception as e:
    print("Error:", str(e))
