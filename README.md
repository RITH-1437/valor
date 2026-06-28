<p align="center">
  <img src="valor_logo.svg" alt="VALOR logo" width="160" />
</p>

<h1 align="center">VALOR</h1>

<p align="center">
  <strong>Premium Men's Fashion E-commerce Ecosystem</strong><br>
  <em>A high-performance full-stack solution built with Flutter, Laravel, and AI Integration.</em>
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white&style=for-the-badge">
  <img alt="Laravel" src="https://img.shields.io/badge/Laravel-11--13-FF2D20?logo=laravel&logoColor=white&style=for-the-badge">
  <img alt="Riverpod" src="https://img.shields.io/badge/State-Riverpod-40C4FF?style=for-the-badge">
  <img alt="License" src="https://img.shields.io/badge/License-MIT-green?style=for-the-badge">
</p>

---

## 📌 Project Overview

**VALOR** is a sophisticated, full-stack e-commerce platform specifically designed for the premium men's fashion market. This project demonstrates a production-ready mobile application architecture seamlessly integrated with a robust Laravel backend. 

The system provides a comprehensive shopping experience, from personalized AI-driven sizing to a community-focused social feed, all wrapped in a "Dark Mode" luxury aesthetic.

---

## 🚀 Key Technical Features

### 💎 Mobile Application (Flutter)
- **State Management**: Implemented using **Riverpod**, ensuring a unidirectional data flow and highly testable state transitions.
- **Navigation**: Structured using **GoRouter** with support for Stateful Shell navigation (Bottom Navigation Bar persistence).
- **Architecture**: Follows **Clean Architecture** principles, separating the project into Data, Domain, and Presentation layers.
- **Dual-Mode Repository**: A sophisticated pattern that allows the app to toggle between **Mock Data (JSON)** and **Live API (Laravel)** via a single configuration switch.
- **Iconography**: Optimized UI using **Font Awesome Icons** for crisp, scalable graphics across all screen densities.
- **Performance**: Optimized Splash Screen logic and image caching using `cached_network_image`.

### 🧠 Intelligence & Integration
- **AI Size Recommender**: Intelligent logic that calculates the perfect fit based on height, weight, and body type.
- **AI Stylist**: Dynamic outfit suggestions tailored for specific occasions (Business, Wedding, Street Style).
- **Store Locator**: Integration with **OpenStreetMap** via `flutter_map` for real-time branch discovery and navigation.

### 🛠️ Backend System (Laravel)
- **API Security**: Token-based authentication using **Laravel Sanctum**.
- **Admin Dashboard**: Comprehensive management tools for products, orders, and customer analytics.
- **Social Engine**: Backend support for likes, follows, style tags, and community engagement.
- **Database**: Flexible migration-based schema currently optimized for SQLite/MySQL.

---

## 🛠️ Technology Stack

| Component | Technology |
| --- | --- |
| **Frontend Framework** | Flutter (Dart) |
| **Backend Framework** | Laravel 13 (PHP 8.3+) |
| **State Management** | Riverpod 3.x |
| **Local Storage** | Flutter Secure Storage (AES Encryption) |
| **Networking** | Dio (with Interceptors & Error Handling) |
| **Maps & GIS** | Flutter Map & OpenStreetMap |
| **Design System** | Custom Premium Dark/Light Themes |

---

## 📂 Project Architecture

```text
lib/
├── app/             # Application configuration (Theme, Router, Constants)
├── core/            # Shared logic (Models, Storage, Network, Global Providers)
│   ├── data/        # Mock Data Source & Dual Repository Implementations
│   └── network/     # Dio Client & API Interceptors
├── features/        # Feature-driven modules (Auth, Home, Shop, Map)
│   ├── auth/        # Splash, Login, Registration
│   ├── map/         # Geographic store discovery
│   └── shop/        # Catalog, Cart, Checkout, Admin Panel, Social Feed
└── shared/          # Reusable UI components (Buttons, Logos, TextFields)
```

---

## 📥 Getting Started

### 1. Prerequisites
- **Flutter SDK**: `^3.x`
- **PHP**: `^8.3`
- **Composer** & **Node.js**

### 2. Mobile App Setup
```bash
# Clone the repository
git clone https://github.com/your-repo/valor.git

# Navigate to project
cd valor

# Install dependencies
flutter pub get

# Run the app (Mock Mode enabled by default)
flutter run
```

### 3. Backend Setup
```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
touch database/database.sqlite
php artisan migrate --seed
php artisan serve
```

---

## 📊 Technical Implementation Highlights (For Evaluators)

- **Decoupled Development**: The `ApiMode.mock` toggle allows frontend development to proceed even when the server is offline.
- **Secure Authentication**: Implementation of Bearer token rotation and secure persistent storage.
- **Responsive Design**: Custom UI layouts that adapt to various mobile screen aspect ratios.
- **Type Safety**: Strong emphasis on Dart type-safety and model serialization/deserialization using factory constructors.

---

## 👨‍💻 Developer Credits
Developed with a focus on **Software Engineering best practices** and **High-fidelity UI/UX**.

---
<p align="center">
  © 2026 VALOR Fashion Group. All rights reserved.
</p>
