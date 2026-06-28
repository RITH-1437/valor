# VALOR API - Backend Service

This is the official backend API service for the **VALOR** premium men's fashion ecosystem. Built with **Laravel 13**, this service provides a scalable, secure, and performant RESTful API for the Flutter mobile application.

---

## 🚀 Key Technical Features

### 🔐 Authentication & Security
- **Laravel Sanctum**: Implemented for lightweight, token-based authentication.
- **Role-Based Access Control (RBAC)**: Custom middleware to protect administrative routes.
- **Data Validation**: Strict request validation using Laravel's FormRequest objects to ensure data integrity.

### 📦 Commerce Engine
- **Eloquent ORM**: Utilized for efficient database management and complex relationship mapping (Products, Categories, Orders, Cart Items).
- **API Resources**: Transforming models into consistent JSON responses for optimized mobile consumption.
- **Seeding Engine**: Comprehensive database seeders that populate the catalog with high-fidelity fashion data.

### 🤖 AI Support Modules
- **Size Calculation Service**: Business logic to process body measurements and return fit recommendations.
- **Outfit Stylist Service**: Occasion-based filtering logic to suggest complete outfits.

---

## 🛠️ Tech Stack
- **Framework**: Laravel 13 (PHP 8.3+)
- **Authentication**: Laravel Sanctum
- **Frontend (Admin Dashboard)**: Blade / Tailwind CSS
- **Database**: SQLite (Local) / MySQL (Production)
- **Tooling**: Composer, NPM, Vite

---

## 📂 Backend Architecture

```text
app/
├── Http/
│   ├── Controllers/API/   # API logic separated from web logic
│   ├── Middleware/        # Auth & Role protection
│   └── Resources/         # JSON Transformation layers
├── Models/                # Eloquent Model definitions
└── Services/              # Business logic (AI calculation, Image processing)
routes/
└── api.php                # Main entry point for mobile application
```

---

## 🚦 Getting Started

### 1. Installation
```bash
composer install
npm install
cp .env.example .env
php artisan key:generate
```

### 2. Database Setup
```bash
# Initialize SQLite database
touch database/database.sqlite

# Run migrations and seed the fashion catalog
php artisan migrate:fresh --seed
```

### 3. Execution
```bash
# Start the local development server
php artisan serve
```

---

## 📝 API Documentation
Detailed endpoint information, request schemas, and response examples are available in:
👉 `API_DOCUMENTATION.md`

---

## 🎓 Academic Highlights
- **RESTful Best Practices**: Correct usage of HTTP verbs (GET, POST, PUT, DELETE) and status codes.
- **Clean Code**: Adherence to PSR-12 coding standards and DRY principles.
- **Decoupling**: Complete separation of business logic into Service classes to keep controllers thin.

---
<p align="center">
  VALOR Backend Service • © 2026
</p>
