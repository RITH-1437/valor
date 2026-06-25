<p align="center">
  <img src="valor_logo.svg" alt="VALOR logo" width="120" />
</p>

<h1 align="center">VALOR</h1>

<p align="center">
  A polished full-stack men's fashion commerce app built with Flutter and Laravel.
</p>

<p align="center">
  <img alt="Flutter" src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white">
  <img alt="Laravel" src="https://img.shields.io/badge/Laravel-13-FF2D20?logo=laravel&logoColor=white">
  <img alt="PHP" src="https://img.shields.io/badge/PHP-8.3+-777BB4?logo=php&logoColor=white">
  <img alt="Riverpod" src="https://img.shields.io/badge/Riverpod-3.x-40C4FF">
</p>

---

## Overview

VALOR is a premium men's fashion platform with a Flutter client and a Laravel API. It covers the full shopping journey: onboarding, product discovery, product detail pages, cart, checkout, payments, order history, wishlist, reviews, profile management, notifications, social style posts, AI recommendations, store locations, and an admin panel.

The Flutter app can run immediately with bundled mock data, then switch to the Laravel backend when you want the full API/database flow.

## Highlights

- Premium catalog experience with categories, featured products, trending products, search, filtering, sorting, images, sizes, colors, stock, and reviews.
- Shopping flow with wishlist, cart totals, address management, checkout, orders, order details, payment history, and notifications.
- AI modules for size recommendations and outfit styling by occasion.
- Social API and feed screen implementation for posts, likes, comments, follows, and style tags.
- Admin API coverage for dashboards, products, categories, orders, customers, reviews, and payment statistics.
- Store locator powered by `flutter_map` and OpenStreetMap tiles.
- Dark and light fashion themes with persisted theme preference.
- Token authentication with Laravel Sanctum and secure token storage in Flutter.
- Mock JSON data under `assets/mock/` for fast UI development without a running backend.

## Tech Stack

| Layer | Tools |
| --- | --- |
| Mobile/Web App | Flutter, Dart, Material 3 |
| State & Routing | Riverpod 3, GoRouter |
| Networking | Dio, Laravel Sanctum bearer tokens |
| Storage | Flutter Secure Storage, Shared Preferences |
| Media & Maps | Cached Network Image, Flutter SVG, Image Picker, Flutter Map, LatLong2 |
| Backend | Laravel 13, PHP 8.3+, Eloquent, API Resources, Middleware |
| Backend Tooling | Composer, Vite 8, Tailwind CSS 4 |
| Database | SQLite by default, MySQL-compatible migrations if configured |

## App Features

### Customer App

- Onboarding and splash/auth handoff
- Login, registration, profile, avatar upload, and settings
- Home dashboard with categories, featured products, and trending products
- Shop page with search, category filters, price filters, and sorting
- Product detail pages with gallery data, sizes, colors, reviews, and related commerce actions
- Wishlist and cart management
- Checkout with shipping address and payment selection
- Order history, order detail, and payment history
- Notification center with unread count and read/delete actions
- Branch map for store discovery

### AI and Social

- Size recommendation based on height, weight, and body type
- Outfit stylist suggestions for business, office, formal, street, weekend, date, and wedding occasions
- Fashion feed, post creation, likes, comments, follows, followers, and following lists

### Admin

- Flutter admin panel with dashboard and product management tabs
- Admin API endpoints for products, categories, orders, customers, reviews, and dashboard data
- Product data includes images, sizes, colors, featured flags, and trending flags
- Role-protected admin middleware

## Project Structure

```text
valor/
|-- lib/
|   |-- app/
|   |   |-- constants/        # Brand colors
|   |   |-- router/           # GoRouter routes and shell navigation
|   |   `-- theme/            # Light and dark themes
|   |-- core/
|   |   |-- data/             # Mock data source and mock repositories
|   |   |-- models/           # API models
|   |   |-- network/          # Dio client and API constants
|   |   |-- providers/        # Riverpod providers
|   |   |-- repositories/     # API repository contracts/implementations
|   |   `-- storage/          # Secure token/user storage
|   |-- features/
|   |   |-- auth/             # Splash, login, register
|   |   |-- home/             # Home screen
|   |   |-- map/              # Branch map
|   |   |-- onboarding/       # First-run onboarding
|   |   `-- shop/             # Catalog, cart, checkout, orders, admin, social
|   `-- shared/widgets/       # Reusable UI components
|-- assets/
|   |-- icons/
|   |-- images/
|   `-- mock/                 # Local JSON fixtures for mock mode
|-- backend/
|   |-- app/
|   |   |-- Http/Controllers/API/
|   |   |-- Http/Middleware/
|   |   |-- Http/Resources/
|   |   |-- Mail/
|   |   |-- Models/
|   |   `-- Services/
|   |-- database/
|   |   |-- migrations/
|   |   `-- seeders/
|   |-- routes/api.php
|   `-- API_DOCUMENTATION.md
`-- pubspec.yaml
```

## Getting Started

### Prerequisites

- Flutter 3.x with Dart SDK compatible with `^3.11.0`
- PHP 8.3+
- Composer
- Node.js and npm
- SQLite for the fastest local backend setup, or MySQL if you prefer to configure it

### Run The Flutter App With Mock Data

The app is currently set to mock mode in `lib/core/network/api_client.dart`:

```dart
static ApiMode apiMode = ApiMode.mock;
```

That means you can run the UI without starting Laravel:

```bash
flutter pub get
flutter run
```

### Run The Laravel API

```bash
cd backend
composer install
npm install
cp .env.example .env
php artisan key:generate
```

For the default SQLite setup:

```bash
touch database/database.sqlite
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
```

If you want MySQL instead, update the `DB_*` values in `backend/.env`, create the database, then run the same migration/seed command.

### Connect Flutter To The API

Set the API mode to live:

```dart
static ApiMode apiMode = ApiMode.live;
```

Then run Flutter with the API URL for your target device:

```bash
# Desktop/web/iOS simulator
flutter run --dart-define=API_BASE_URL=http://localhost:8000/api

# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000/api

# Physical device on the same network
flutter run --dart-define=API_BASE_URL=http://YOUR_LOCAL_IP:8000/api
```

## Main Routes

| Route | Screen |
| --- | --- |
| `/` | Splash |
| `/onboarding` | Onboarding |
| `/login`, `/register` | Auth |
| `/home` | Home |
| `/shop` | Product listing |
| `/product/:slug` | Product detail |
| `/wishlist` | Wishlist |
| `/cart` | Cart |
| `/checkout` | Checkout |
| `/orders` | Orders |
| `/addresses` | Addresses |
| `/payment-history` | Payment history |
| `/notifications` | Notifications |
| `/profile` | Profile |
| `/settings` | Settings |
| `/map` | Store locator |
| `/admin` | Admin panel |

## API Areas

The API lives under `http://localhost:8000/api` by default.

| Area | Examples |
| --- | --- |
| Auth | `POST /auth/register`, `POST /auth/login`, `GET /auth/profile` |
| Catalog | `GET /categories`, `GET /products`, `GET /products/featured`, `GET /products/{slug}` |
| Commerce | `/wishlist`, `/cart`, `/orders`, `/addresses`, `/payments/*` |
| Reviews | `GET /products/{id}/reviews`, `POST /products/{id}/reviews` |
| AI | `POST /ai/size-recommendation`, `POST /products/{product}/stylist` |
| Social | `/feed`, `/posts`, `/posts/{post}/like`, `/users/{user}/follow` |
| Admin | `/admin/dashboard`, `/admin/products`, `/admin/categories`, `/admin/orders`, `/admin/customers`, `/admin/reviews` |

See `backend/API_DOCUMENTATION.md` for request and response examples.

## Seed Data

The backend seeders create:

- 8 categories: T-Shirts, Shirts, Pants, Jeans, Shoes, Accessories, Watches, and Outerwear
- A premium product catalog with images, sizes, colors, stock, featured flags, and trending flags

The Flutter mock mode reads matching fixture data from `assets/mock/`.

## Useful Commands

```bash
# Flutter
flutter pub get
flutter analyze
flutter test
flutter run

# Laravel
cd backend
composer run test
php artisan migrate:fresh --seed
php artisan serve --host=0.0.0.0 --port=8000
npm run dev
```

## Security Notes

- Laravel Sanctum protects authenticated API routes.
- Admin endpoints are guarded by role-based middleware.
- User-owned resources are checked against the authenticated user.
- API requests use Laravel validation and Eloquent query binding.
- Flutter stores tokens with `flutter_secure_storage`.

## Documentation

- API reference: `backend/API_DOCUMENTATION.md`
- Flutter dependencies: `pubspec.yaml`
- Backend dependencies: `backend/composer.json` and `backend/package.json`

## License

This project is intended for education, portfolio, and demonstration use.
