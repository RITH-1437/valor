<?php

namespace App\Services;

use Illuminate\Support\Facades\Cache;
use Illuminate\Support\Facades\DB;

class CacheService
{
    public static function rememberProducts(string $key, int $minutes, callable $callback)
    {
        return Cache::remember("products:{$key}", $minutes * 60, $callback);
    }

    public static function rememberCategories(int $minutes, callable $callback)
    {
        return Cache::remember('categories:all', $minutes * 60, $callback);
    }

    public static function rememberFeatured(int $minutes, callable $callback)
    {
        return Cache::remember('products:featured', $minutes * 60, $callback);
    }

    public static function rememberTrending(int $minutes, callable $callback)
    {
        return Cache::remember('products:trending', $minutes * 60, $callback);
    }

    public static function rememberProduct(string $slug, int $minutes, callable $callback)
    {
        return Cache::remember("product:{$slug}", $minutes * 60, $callback);
    }

    public static function rememberDashboard(int $minutes, callable $callback)
    {
        return Cache::remember('admin:dashboard', $minutes * 60, $callback);
    }

    public static function invalidateProduct(int $id)
    {
        Cache::forget("product:{$id}");
        Cache::forget('products:featured');
        Cache::forget('products:trending');
        Cache::forget('admin:dashboard');
    }

    public static function invalidateCategories()
    {
        Cache::forget('categories:all');
    }

    public static function getStats(string $key, int $minutes, callable $callback)
    {
        return Cache::remember("stats:{$key}", $minutes * 60, $callback);
    }

    public static function getProductCount(): int
    {
        return self::getStats('product_count', 60, fn () => DB::table('products')->where('is_active', true)->count());
    }

    public static function getOrderCount(): int
    {
        return self::getStats('order_count', 5, fn () => DB::table('orders')->count());
    }

    public static function getRevenue(): float
    {
        return self::getStats('revenue', 5, fn () => (float) DB::table('payment_transactions')->where('status', 'paid')->sum('amount'));
    }
}
