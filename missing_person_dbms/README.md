# AI Civic Safety & Missing Person Platform

An intelligent full-stack civic safety platform designed to help citizens report missing persons quickly, enable authorities to verify cases efficiently, and improve public awareness through a trusted digital ecosystem.

---

## 📌 Overview

Missing person cases often face delays due to manual reporting systems, lack of centralized records, misinformation, and poor coordination between citizens and authorities.

This project solves that problem by creating a **citizen-centric reporting and verification platform** where:

- Citizens can report missing persons with photo and details
- Admins can review, approve, or reject reports
- Verified cases become publicly visible
- Users can track submitted reports
- AI chatbot assists users
- Geolocation helps identify last-seen areas

The platform combines **technology + social impact + public safety** into one scalable solution.

---

## 🚀 Key Features

### 👤 User Side

- User Registration & Login
- Report Missing Person Cases
- Upload Photo Evidence
- Enter Name, Age, Gender, Description
- Add Last-Seen Location
- Pin Location on Map
- View Approved Missing Person Listings
- Track Submitted Reports
- AI Chatbot Guidance

### 🛡 Admin Side

- Secure Admin Login
- View Submitted Reports
- Approve / Reject Cases
- Manage Pending Reports
- View Approved Cases
- View Rejected Cases
- View Registered Users
- Maintain Data Transparency

### 🤖 AI Integration

- Gemini API powered chatbot
- Helps users with reporting steps
- Provides guidance and support
- Improves accessibility

### 🌍 Sustainability Impact

- Reduces paperwork
- Faster case handling
- Better authority coordination
- Reduced travel for complaints
- Social sustainability through safer communities

---

## 🏗 Tech Stack

### Frontend
- Flutter
- Dart

### Backend
- PHP
- REST API

### Database
- MySQL
- phpMyAdmin

### Development Tools
- XAMPP
- Android Studio
- VS Code

### APIs & Services
- Google Gemini API
- Google Maps API

### Version Control
- GitHub

---

## 📂 Project Modules

### 1️⃣ Authentication Module

Handles:

- User Registration
- User Login
- Admin Login

### 2️⃣ Missing Person Reporting Module

Allows citizens to submit:

- Name
- Age
- Gender
- Photo
- Description
- Last-Seen Location

### 3️⃣ Verification Module

Admin can:

- Approve Reports
- Reject Reports
- Validate Authenticity

### 4️⃣ Public Listing Module

Displays approved missing person cases for public awareness.

### 5️⃣ AI Assistant Module

Supports users through chatbot guidance.

### 6️⃣ Map Module

Shows pinned locations of reported cases.

---

## 🗃 Database Tables

### users

Stores:

- id
- username
- email
- password
- user_id

### pending_missing_persons

Stores newly submitted reports awaiting review.

### approved_missing_persons

Stores approved reports.

### rejected_persons

Stores rejected reports for tracking.

### missing_person

Stores publicly visible verified missing person cases.

---

## 🔄 Workflow

Citizen submits report  
⬇  
Stored in Pending Reports  
⬇  
Admin Reviews Case  
⬇  
Approve / Reject  

### If Approved:

- Added to Public Missing Person Listing

### If Rejected:

- Stored in Rejected Records

---

## 📱 End Users

### Citizens

- Report missing persons
- View verified cases
- Receive assistance

### Authorities / Admins

- Review reports
- Track cases
- Improve response time

### NGOs / Social Organizations

- Spread awareness
- Assist in recovery

### Smart Cities

- Build safer civic ecosystems

---

## ⚙ Installation Guide

### Requirements

- Flutter SDK
- Android Studio
- XAMPP
- VS Code

### Backend Setup

1. Copy project folder into:

```bash
htdocs/


