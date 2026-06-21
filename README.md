# VALOR — Luxury Men's Fashion Platform

A full-stack e-commerce platform for premium men's fashion, built with **Flutter** (frontend) and **Laravel 12** (backend API).

---

## Features

### Customer Experience
- **Product Catalog** — Browse 50+ curated products with search, filter, sort, and pagination
- **Product Detail** — Image carousel with zoom, size/color selection, stock indicators, reviews
- **Shopping Cart** — Add products with size/color, quantity management, real-time totals
- **Checkout** — Address selection, payment method, order review, stock validation
- **Orders** — Order history, tracking timeline, status updates
- **Wishlist** — Save and manage favorite products
- **Addresses** — Multiple shipping addresses with default selection

### AI-Powered Features
- **AI Size Recommendation** — Enter height, weight, body type → get recommended size (S/M/L/XL/XXL)
- **AI Outfit Stylist** — Select a product and occasion → get outfit suggestions, matching colors, accessories, and styling tips

### Social Features
- **Fashion Feed** — Create posts with style tags
- **Follow System** — Follow other users
- **Likes & Comments** — Engage with posts

### Payments
- **Cash on Delivery** — Pay when you receive
- **Stripe** — Credit/debit card payments
- **PayPal** — Digital wallet payments
- **Payment History** — Track all transactions

### Notifications
- **In-App Notifications** — Order updates, payment confirmations, low stock alerts
- **Email System** — Branded HTML emails for orders, payments, welcome
- **Read/Unread State** — Mark individual or all notifications as read

### Admin Panel
- **Dashboard** — Revenue, orders, users, products, reviews, low stock alerts
- **Product Management** — Full CRUD with images, sizes, colors, featured/trending flags
- **Category Management** — Create, edit, delete categories
- **Order Management** — View all orders, filter, search, update status
- **Customer Management** — View customers and order history
- **Review Management** — View and delete reviews

### Theme System
- **Dark Mode** — Premium black/gold aesthetic (default)
- **Light Mode** — Clean white/gold alternative
- **System Default** — Follows device setting
- **Persistent** — Theme preference saved automatically

---

## Tech Stack

### Frontend (Flutter)
| Technology | Purpose |
|---|---|
| Flutter 3.x | Cross-platform UI framework |
| Riverpod 3.x | State management |
| GoRouter | Declarative routing |
| Dio | HTTP client with interceptors |
| CachedNetworkImage | Image caching & lazy loading |
| FlutterSecureStorage | Secure token persistence |
| SharedPreferences | Theme preference storage |

### Backend (Laravel 12)
| Technology | Purpose |
|---|---|
| Laravel 12 | PHP API framework |
| MySQL 8.0 | Database |
| Laravel Sanctum | Token-based API authentication |
| Eloquent ORM | Database queries with relationships |
| Repository Pattern | Data access abstraction |
| API Resources | Consistent JSON response format |

### Design System
| Element | Value |
|---|---|
| Primary Black | #111111 |
| Gold Accent | #D4AF37 |
| White | #FFFFFF |
| Surface Dark | #1F2937 |
| Gray | #6B7280 |
| Typography | SF Pro / System (negative letter-spacing) |

---

## Project Structure

```
valor/
├── lib/
│   ├── app/
│   │   ├── constants/          # Color palette
│   │   ├── router/             # GoRouter configuration
│   │   └── theme/              # Dark + Light themes
│   ├── core/
│   │   ├── models/             # 11 API data models
│   │   ├── network/            # Dio client + API constants
│   │   ├── providers/          # 10 Riverpod providers
│   │   ├── repositories/       # 12 API repositories
│   │   └── storage/            # Secure storage service
│   ├── features/
│   │   ├── auth/               # Login, Register, Splash
│   │   ├── home/               # Home screen
│   │   └── shop/               # 24 screens (products, cart, checkout, admin, etc.)
│   └── shared/
│       └── widgets/            # Reusable components
│
└── backend/
    ├── app/
    │   ├── Http/Controllers/API/   # 20 controllers
    │   ├── Http/Middleware/         # Admin middleware
    │   ├── Http/Resources/         # 10 API resources
    │   ├── Mail/                   # 3 email templates
    │   ├── Models/                 # 20 Eloquent models
    │   └── Services/               # Notification + Cache services
    ├── database/
    │   └── migrations/             # 23 migrations
    ├── routes/
    │   └── api.php                 # 76 API endpoints
    └── API_DOCUMENTATION.md        # Complete API reference
```

---

## Database Schema (20 Tables)

```
users ──────────┬── orders ──── order_items
                ├── wishlists
                ├── cart_items
                ├── addresses
                ├── reviews
                ├── notifications
                ├── posts ──── post_likes, post_comments
                ├── follows
                ├── size_recommendations
                └── stylist_sessions

categories ───── products ──── product_images
                             ├── product_sizes
                             └── product_colors

orders ────────── payment_transactions

personal_access_tokens (Sanctum)
sessions
cache / cache_locks
jobs / job_batches / failed_jobs
```

---

## Setup Guide

### Prerequisites
- PHP 8.2+
- Composer
- MySQL 8.0+
- Flutter 3.x
- Node.js (for Laravel assets)

### Backend Setup

```bash
cd backend

# Install dependencies
composer install

# Configure environment
cp .env.example .env
php artisan key:generate

# Update .env with your MySQL credentials
DB_CONNECTION=mysql
DB_HOST=127.0.0.1
DB_PORT=3306
DB_DATABASE=valor
DB_USERNAME=root
DB_PASSWORD=your_password

# Create database
mysql -u root -p -e "CREATE DATABASE valor CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# Run migrations and seeders
php artisan migrate:fresh --seed

# Start server
php artisan serve --host=0.0.0.0 --port=8000
```

### Flutter Setup

```bash
cd valor

# Install dependencies
flutter pub get

# Update API base URL in lib/core/network/api_constants.dart
# For Android emulator: http://10.0.2.2:8000/api
# For iOS simulator: http://localhost:8000/api
# For physical device: http://YOUR_IP:8000/api

# Run the app
flutter run
```

### Create Admin User

```bash
php artisan tinker
```

```php
\App\Models\User::where('email', 'your@email.com')->update(['role' => 'admin']);
```

---

## API Overview

**Base URL:** `http://localhost:8000/api`

### Authentication
| Method | Endpoint | Description |
|---|---|---|
| POST | `/auth/register` | Register new user |
| POST | `/auth/login` | Login |
| POST | `/auth/logout` | Logout (auth) |
| GET | `/auth/profile` | Get profile (auth) |
| PUT | `/auth/profile` | Update profile (auth) |

### Products
| Method | Endpoint | Description |
|---|---|---|
| GET | `/products` | List (search, filter, sort, paginate) |
| GET | `/products/featured` | Featured products |
| GET | `/products/trending` | Trending products |
| GET | `/products/{slug}` | Product detail |

### Categories
| Method | Endpoint | Description |
|---|---|---|
| GET | `/categories` | List all with product counts |
| GET | `/categories/{slug}` | Category detail |

### Cart & Wishlist
| Method | Endpoint | Description |
|---|---|---|
| GET/POST/PUT/DELETE | `/cart` | Cart CRUD |
| GET/POST/DELETE | `/wishlist` | Wishlist CRUD |

### Orders & Payments
| Method | Endpoint | Description |
|---|---|---|
| GET/POST | `/orders` | List/Create orders |
| GET | `/orders/{id}` | Order detail |
| POST | `/payments/create` | Create payment |
| GET | `/payments/history` | Payment history |

### Social
| Method | Endpoint | Description |
|---|---|---|
| GET | `/feed` | Fashion feed |
| GET/POST | `/posts` | Posts CRUD |
| POST | `/posts/{id}/like` | Toggle like |
| POST | `/posts/{id}/comment` | Add comment |
| POST | `/users/{id}/follow` | Toggle follow |

### AI Features
| Method | Endpoint | Description |
|---|---|---|
| POST | `/ai/size-recommendation` | Get size recommendation |
| POST | `/products/{id}/stylist` | Get outfit recommendations |

### Admin
| Method | Endpoint | Description |
|---|---|---|
| GET | `/admin/dashboard` | Dashboard stats |
| GET/POST/PUT/DELETE | `/admin/products` | Product management |
| GET/POST/PUT/DELETE | `/admin/categories` | Category management |
| GET/PUT | `/admin/orders` | Order management |
| GET | `/admin/customers` | Customer management |

**Full API documentation:** `backend/API_DOCUMENTATION.md`

---

## Screens

| Screen | Path | Description |
|---|---|---|
| Splash | `/` | Animated logo → auth check |
| Login | `/login` | Email/password login |
| Register | `/register` | New account creation |
| Home | `/home` | Categories, featured, trending |
| Shop | `/shop` | Product list with search/filter |
| Product Detail | `/product/{slug}` | Full product with reviews |
| Cart | `/cart` | Shopping cart with totals |
| Checkout | `/checkout` | 3-step: Address → Payment → Review |
| Orders | `/orders` | Order history |
| Wishlist | `/wishlist` | Saved products |
| Profile | `/profile` | User profile + menu |
| Settings | `/settings` | Theme toggle + account settings |
| Addresses | `/addresses` | Manage shipping addresses |
| Notifications | `/notifications` | Notification center |
| Feed | `/feed` | Social fashion feed |
| Payment History | `/payment-history` | Transaction history |
| Admin Panel | `/admin` | Dashboard + management |

---

## Security

- **Authentication:** Laravel Sanctum token-based auth
- **Admin Protection:** Role-based middleware on all admin routes
- **Ownership Checks:** All user data (orders, reviews, addresses, payments) verified against authenticated user
- **Input Validation:** Laravel validation on all endpoints
- **File Upload Validation:** Mimetype + size limits on image uploads
- **SQL Injection Prevention:** Eloquent ORM with parameterized queries

---

## Performance

- **Database Indexing:** Optimized queries with proper indexes
- **Eager Loading:** Prevents N+1 query issues
- **Pagination:** All list endpoints paginated (20 items)
- **Image Caching:** CachedNetworkImage with placeholders
- **Lazy Loading:** ListView.builder / GridView.builder for efficient rendering
- **API Caching:** CacheService with configurable TTL
- **Lazy Rendering:** const constructors and selective rebuilds

---

## Project Stats

| Metric | Count |
|---|---|
| Total Source Files | 135 |
| Database Tables | 20 |
| API Endpoints | 76 |
| API Controllers | 20 |
| Eloquent Models | 20 |
| Flutter Screens | 24 |
| Flutter Providers | 10 |
| Flutter Repositories | 12 |

---

## License

This project is for educational and portfolio purposes.

---

## Author

Built with Flutter + Laravel for premium men's fashion e-commerce.
