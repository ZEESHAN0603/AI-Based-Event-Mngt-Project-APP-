import os
from supabase import create_client

url = "https://wkkxgoyqnrzsoqqlxbbr.supabase.co"
key = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Indra3hnb3lxbnJ6c29xcWx4YmJyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgyOTkyMDcsImV4cCI6MjA5Mzg3NTIwN30.hfzq7NbCQ0qL4IVakhdikRG3qLkYsT6xUM3_O_CLXxE"
supabase = create_client(url, key)

try:
    res = supabase.table("admin_settings").select("*").execute()
    print("admin_settings exists:", res.data)
except Exception as e:
    print("Error admin_settings:", e)

try:
    res = supabase.table("vendor_categories").select("*").execute()
    print("vendor_categories exists:", res.data)
except Exception as e:
    print("Error vendor_categories:", e)
