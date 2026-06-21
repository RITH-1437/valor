<?php

use App\Http\Controllers\API\AddressController;
use App\Http\Controllers\API\AdminCategoryController;
use App\Http\Controllers\API\AdminCustomerController;
use App\Http\Controllers\API\AdminDashboardController;
use App\Http\Controllers\API\AdminOrderController;
use App\Http\Controllers\API\AdminProductController;
use App\Http\Controllers\API\AdminReviewController;
use App\Http\Controllers\API\AIController;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\CartController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\OrderController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\PaymentController;
use App\Http\Controllers\API\PostController;
use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\ProductImageController;
use App\Http\Controllers\API\ReviewController;
use App\Http\Controllers\API\SocialController;
use App\Http\Controllers\API\WishlistController;
use Illuminate\Support\Facades\Route;

// Auth
Route::post('/auth/register', [AuthController::class, 'register'])->middleware('throttle:10,1');
Route::post('/auth/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

// Public
Route::get('/categories', [CategoryController::class, 'index'])->middleware('throttle:60,1');
Route::get('/categories/{slug}', [CategoryController::class, 'show'])->middleware('throttle:60,1');

Route::get('/products', [ProductController::class, 'index'])->middleware('throttle:60,1');
Route::get('/products/featured', [ProductController::class, 'featured'])->middleware('throttle:60,1');
Route::get('/products/trending', [ProductController::class, 'trending'])->middleware('throttle:60,1');
Route::get('/products/{slug}', [ProductController::class, 'show'])->middleware('throttle:60,1');

// Reviews (public read)
Route::get('/products/{productId}/reviews', [ReviewController::class, 'index'])->middleware('throttle:60,1');

// Product images (public read)
Route::get('/products/{product}/images', [ProductImageController::class, 'index'])->middleware('throttle:60,1');

// Authenticated
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/auth/logout', [AuthController::class, 'logout']);
    Route::get('/auth/profile', [AuthController::class, 'profile']);
    Route::put('/auth/profile', [AuthController::class, 'updateProfile']);

    // Wishlist
    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist', [WishlistController::class, 'store']);
    Route::delete('/wishlist/{product}', [WishlistController::class, 'destroy']);

    // Cart
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart', [CartController::class, 'store']);
    Route::put('/cart/{cartItem}', [CartController::class, 'update']);
    Route::delete('/cart/{cartItem}', [CartController::class, 'destroy']);

    // Orders
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store'])->middleware('throttle:5,1');
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::put('/orders/{order}/status', [OrderController::class, 'updateStatus']);

    // Addresses
    Route::get('/addresses', [AddressController::class, 'index']);
    Route::post('/addresses', [AddressController::class, 'store']);
    Route::put('/addresses/{address}', [AddressController::class, 'update']);
    Route::delete('/addresses/{address}', [AddressController::class, 'destroy']);
    Route::post('/addresses/{address}/default', [AddressController::class, 'setDefault']);

    // Reviews (write)
    Route::post('/products/{productId}/reviews', [ReviewController::class, 'store'])->middleware('throttle:5,1');
    Route::put('/reviews/{review}', [ReviewController::class, 'update']);
    Route::delete('/reviews/{review}', [ReviewController::class, 'destroy']);

    // Product Images (manage)
    Route::post('/products/{product}/images', [ProductImageController::class, 'store']);
    Route::put('/product-images/{image}', [ProductImageController::class, 'update']);
    Route::delete('/product-images/{image}', [ProductImageController::class, 'destroy']);
    Route::put('/products/{product}/images/reorder', [ProductImageController::class, 'reorder']);

    // AI Features
    Route::post('/ai/size-recommendation', [AIController::class, 'recommendSize'])->middleware('throttle:10,1');
    Route::post('/products/{product}/stylist', [AIController::class, 'getOutfitRecommendation'])->middleware('throttle:10,1');

    // Payments
    Route::post('/payments/create', [PaymentController::class, 'create'])->middleware('throttle:5,1');
    Route::post('/payments/{transaction}/verify', [PaymentController::class, 'verify']);
    Route::get('/payments/history', [PaymentController::class, 'history']);
    Route::get('/payments/{transaction}', [PaymentController::class, 'show']);
    Route::get('/admin/payments/statistics', [PaymentController::class, 'statistics']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::put('/notifications/{notification}/read', [NotificationController::class, 'markAsRead']);
    Route::put('/notifications/read-all', [NotificationController::class, 'markAllAsRead']);
    Route::delete('/notifications/{notification}', [NotificationController::class, 'destroy']);

    // Social
    Route::get('/feed', [SocialController::class, 'feed']);
    Route::post('/users/{user}/follow', [SocialController::class, 'follow']);
    Route::get('/users/{user}/followers', [SocialController::class, 'followers']);
    Route::get('/users/{user}/following', [SocialController::class, 'following']);

    // Posts
    Route::get('/posts', [PostController::class, 'index']);
    Route::post('/posts', [PostController::class, 'store']);
    Route::get('/posts/{post}', [PostController::class, 'show']);
    Route::delete('/posts/{post}', [PostController::class, 'destroy']);
    Route::post('/posts/{post}/like', [PostController::class, 'like']);
    Route::post('/posts/{post}/comment', [PostController::class, 'comment']);

    // Admin Routes
    Route::prefix('admin')->middleware('admin')->group(function () {
        Route::get('/dashboard', [AdminDashboardController::class, 'index']);

        // Products
        Route::get('/products', [AdminProductController::class, 'index']);
        Route::post('/products', [AdminProductController::class, 'store']);
        Route::put('/products/{product}', [AdminProductController::class, 'update']);
        Route::delete('/products/{product}', [AdminProductController::class, 'destroy']);
        Route::post('/products/{product}/toggle-featured', [AdminProductController::class, 'toggleFeatured']);
        Route::post('/products/{product}/toggle-trending', [AdminProductController::class, 'toggleTrending']);

        // Categories
        Route::get('/categories', [AdminCategoryController::class, 'index']);
        Route::post('/categories', [AdminCategoryController::class, 'store']);
        Route::put('/categories/{category}', [AdminCategoryController::class, 'update']);
        Route::delete('/categories/{category}', [AdminCategoryController::class, 'destroy']);

        // Orders
        Route::get('/orders', [AdminOrderController::class, 'index']);
        Route::get('/orders/{order}', [AdminOrderController::class, 'show']);
        Route::put('/orders/{order}/status', [AdminOrderController::class, 'updateStatus']);

        // Customers
        Route::get('/customers', [AdminCustomerController::class, 'index']);
        Route::get('/customers/{user}', [AdminCustomerController::class, 'show']);

        // Reviews
        Route::get('/reviews', [AdminReviewController::class, 'index']);
        Route::delete('/reviews/{review}', [AdminReviewController::class, 'destroy']);
    });
});
