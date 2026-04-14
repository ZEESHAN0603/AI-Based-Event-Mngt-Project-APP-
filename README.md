# 📱 AI-Based Intelligent Event Vendor Management System

An AI-assisted, role-based mobile application that helps users plan events efficiently by recommending suitable vendors, managing bookings, and tracking budgets.

---

## 🚀 Overview

The **AI-Based Intelligent Event Vendor Management System** is a smart marketplace platform designed to simplify event planning. It connects **Organizers**, **Vendors**, and **Admins** in a unified system, enhanced with AI-based vendor recommendations.

This system supports multiple event types such as weddings, birthdays, corporate events, and cultural functions.

---

## 🎯 Key Features

### 👤 Organizer
- Create and manage events
- Get AI-based vendor recommendations
- Browse and shortlist vendors
- Track event budget
- Book vendors بسهولة

### 🏢 Vendor
- Register and manage business profile
- Set availability dates
- Receive and manage booking requests

### 🛠 Admin
- Approve/reject vendors
- Manage categories
- Monitor platform activity

---

## 🤖 AI Feature – Event Nanban

The system includes an AI assistant that:
- Understands user requirements (budget, location, event type)
- Filters vendors based on:
  - Availability
  - Pricing
  - Ratings
- Suggests best-fit vendors for the event

---

## 🏗 System Architecture

Frontend → Backend API → Database  
             ↓  
         AI Logic Layer  

---

## 🛠 Tech Stack

| Layer        | Technology              |
|-------------|------------------------|
| Frontend     | Flutter / FlutterFlow |
| Backend      | Python FastAPI        |
| Database     | Supabase (PostgreSQL) |
| Authentication | JWT / Supabase Auth |
| Automation   | n8n                   |
| AI Logic     | Rule-based / LLM      |

---

## 📂 Project Structure


lib/ # Flutter app source code
assets/ # Images, icons
android/ ios/ web/ # Platform-specific files


---

## 📊 Database Tables

- users
- vendors
- vendor_categories
- events
- event_shortlists
- vendor_availability
- bookings
- blogs

---

## 🔐 Security

- JWT-based authentication
- Role-based access control
- Vendor approval system

---

## 📌 How It Works

1. User registers as Organizer or Vendor
2. Organizer creates an event
3. AI suggests relevant vendors
4. Organizer shortlists & books vendors
5. Vendor manages availability and bookings
6. Admin monitors and controls the platform

---

## ⚙️ Installation & Setup

```bash
git clone https://github.com/YOUR_USERNAME/YOUR_REPO_NAME.git
cd YOUR_REPO_NAME
flutter pub get
flutter run

📈 Future Enhancements
Real-time chat between organizer & vendor
Payment gateway integration
Advanced AI recommendations
Push notifications
