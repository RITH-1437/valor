# VALOR API Documentation

Base URL: `http://localhost:8000/api`

## Authentication

All authenticated endpoints require `Authorization: Bearer <token>` header.

---

## Auth Endpoints

### POST /api/auth/register
Register a new user.

**Request:**
```json
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "Password123!",
  "phone": "+84901234567"
}
```

**Response (201):**
```json
{
  "user": { "id": 1, "name": "John Doe", "email": "john@example.com" },
  "token": "1|abc..."
}
```

### POST /api/auth/login
Login user.

**Request:**
```json
{
  "email": "john@example.com",
  "password": "Password123!"
}
```

**Response (200):**
```json
{
  "user": { "id": 1, "name": "John Doe", "email": "john@example.com" },
  "token": "1|abc..."
}
```

### POST /api/auth/logout
Logout (requires auth). Revokes current token.

### GET /api/auth/profile
Get authenticated user profile (requires auth).

### PUT /api/auth/profile
Update profile (requires auth).

---

## Product Endpoints

### GET /api/products
List products with pagination and filters.

**Query Parameters:**
- `page` (int) — Page number
- `per_page` (int) — Items per page (default: 20)
- `search` (string) — Search by name/description/sku
- `category` (string) — Filter by category slug
- `sort` (string) — `price_asc`, `price_desc`, `newest`
- `min_price` (float) — Minimum price
- `max_price` (float) — Maximum price

### GET /api/products/featured
Get featured products (max 12).

### GET /api/products/trending
Get trending products (max 12).

### GET /api/products/{slug}
Get product detail by slug. Includes images, sizes, colors, related products.

---

## Category Endpoints

### GET /api/categories
List all active categories with product counts.

### GET /api/categories/{slug}
Get category detail by slug.

---

## Wishlist Endpoints (auth required)

### GET /api/wishlist
List user wishlist.

### POST /api/wishlist
Add to wishlist.
```json
{ "product_id": 1 }
```

### DELETE /api/wishlist/{product_id}
Remove from wishlist.

---

## Cart Endpoints (auth required)

### GET /api/cart
List cart items with totals (subtotal, shipping, tax, total).

### POST /api/cart
Add to cart.
```json
{
  "product_id": 1,
  "quantity": 2,
  "selected_size": "M",
  "selected_color": "Navy"
}
```

### PUT /api/cart/{id}
Update quantity.
```json
{ "quantity": 3 }
```

### DELETE /api/cart/{id}
Remove from cart.

---

## Order Endpoints (auth required)

### GET /api/orders
List user orders (paginated).

### POST /api/orders
Place order from cart.
```json
{
  "shipping_address": "123 Street, City, Country",
  "payment_method": "credit_card"
}
```
Creates order, reduces stock, clears cart (all in transaction).

### GET /api/orders/{id}
Get order detail with items.

### PUT /api/orders/{id}/status
Update order status (admin).
```json
{ "status": "confirmed" }
```

---

## Address Endpoints (auth required)

### GET /api/addresses
List user addresses.

### POST /api/addresses
Create address.
```json
{
  "full_name": "John Doe",
  "phone": "+84901234567",
  "country": "Vietnam",
  "city": "Ho Chi Minh",
  "district": "District 1",
  "street": "123 Nguyen Hue",
  "postal_code": "700000",
  "is_default": true
}
```

### PUT /api/addresses/{id}
Update address.

### DELETE /api/addresses/{id}
Delete address.

### POST /api/addresses/{id}/default
Set as default address.

---

## Review Endpoints

### GET /api/products/{id}/reviews
List reviews (public, paginated).

**Response includes:** average_rating, total_reviews

### POST /api/products/{id}/reviews
Create review (auth required).
```json
{
  "rating": 5,
  "review": "Great product!"
}
```

### PUT /api/reviews/{id}
Update review (owner only).

### DELETE /api/reviews/{id}
Delete review (owner only).

---

## Payment Endpoints (auth required)

### POST /api/payments/create
Create payment.
```json
{
  "order_id": 1,
  "provider": "cod",
  "payment_method": "cash_on_delivery"
}
```
Providers: `cod`, `stripe`, `paypal`

### POST /api/payments/{id}/verify
Verify payment status.
```json
{ "status": "paid" }
```

### GET /api/payments/history
List payment history.

### GET /api/payments/{id}
Get payment detail.

---

## AI Endpoints (auth required)

### POST /api/ai/size-recommendation
Get size recommendation.
```json
{
  "height_cm": 175,
  "weight_kg": 70,
  "body_type": "athletic"
}
```

### POST /api/products/{id}/stylist
Get outfit recommendation.
```json
{ "occasion": "business_meeting" }
```
Occasions: `business_meeting`, `date_night`, `wedding`, `casual_weekend`, `office`, `formal_event`, `street_style`

---

## Notification Endpoints (auth required)

### GET /api/notifications
List notifications (paginated).

### GET /api/notifications/unread-count
Get unread count.

### PUT /api/notifications/{id}/read
Mark as read.

### PUT /api/notifications/read-all
Mark all as read.

### DELETE /api/notifications/{id}
Delete notification.

---

## Admin Endpoints (admin role required)

All admin endpoints require `Authorization: Bearer <admin_token>` header.

### GET /api/admin/dashboard
Dashboard statistics.

### Product Management
- `GET /api/admin/products` — List all products
- `POST /api/admin/products` — Create product
- `PUT /api/admin/products/{id}` — Update product
- `DELETE /api/admin/products/{id}` — Delete product
- `POST /api/admin/products/{id}/toggle-featured` — Toggle featured
- `POST /api/admin/products/{id}/toggle-trending` — Toggle trending

### Category Management
- `GET /api/admin/categories` — List all categories
- `POST /api/admin/categories` — Create category
- `PUT /api/admin/categories/{id}` — Update category
- `DELETE /api/admin/categories/{id}` — Delete category

### Order Management
- `GET /api/admin/orders` — List all orders (filter by status, search, date)
- `GET /api/admin/orders/{id}` — Order detail
- `PUT /api/admin/orders/{id}/status` — Update status

### Customer Management
- `GET /api/admin/customers` — List all customers
- `GET /api/admin/customers/{id}` — Customer detail

### Review Management
- `GET /api/admin/reviews` — List all reviews
- `DELETE /api/admin/reviews/{id}` — Delete review

### Payment Management
- `GET /api/admin/payments/statistics` — Revenue + failed count

---

## Error Responses

All errors return:
```json
{
  "success": false,
  "message": "Error description"
}
```

Status codes: 400 (validation), 401 (unauthenticated), 403 (unauthorized), 404 (not found), 409 (conflict), 422 (unprocessable), 500 (server error)
