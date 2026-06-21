<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\PaymentTransaction;
use App\Models\Product;
use App\Models\User;
use App\Models\Review;
use Illuminate\Http\JsonResponse;

class AdminDashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $totalUsers = User::count();
        $totalProducts = Product::count();
        $totalOrders = Order::count();
        $totalRevenue = PaymentTransaction::where('status', 'paid')->sum('amount');
        $pendingOrders = Order::where('status', 'pending')->count();
        $processingOrders = Order::where('status', 'processing')->count();
        $shippedOrders = Order::where('status', 'shipped')->count();
        $deliveredOrders = Order::where('status', 'delivered')->count();
        $cancelledOrders = Order::where('status', 'cancelled')->count();
        $totalReviews = Review::count();
        $lowStockProducts = Product::where('stock', '<', 10)->where('is_active', true)->count();

        $recentOrders = Order::with('user')
            ->latest()
            ->limit(5)
            ->get()
            ->map(fn ($o) => [
                'id' => $o->id,
                'order_number' => $o->order_number,
                'total' => (float) $o->total,
                'status' => $o->status,
                'customer' => $o->user->name ?? 'Unknown',
                'created_at' => $o->created_at,
            ]);

        $topProducts = Product::withCount('orderItems')
            ->orderByDesc('order_items_count')
            ->limit(5)
            ->get()
            ->map(fn ($p) => [
                'id' => $p->id,
                'name' => $p->name,
                'sales' => $p->order_items_count,
                'stock' => $p->stock,
            ]);

        $dailySales = Order::where('status', '!=', 'cancelled')
            ->where('created_at', '>=', now()->subDays(30))
            ->selectRaw('DATE(created_at) as date, COUNT(*) as count, SUM(total) as revenue')
            ->groupBy('date')
            ->orderBy('date')
            ->get();

        $monthlySales = Order::where('status', '!=', 'cancelled')
            ->where('created_at', '>=', now()->subMonths(12))
            ->selectRaw('YEAR(created_at) as year, MONTH(created_at) as month, COUNT(*) as count, SUM(total) as revenue')
            ->groupBy('year', 'month')
            ->orderBy('year')
            ->orderBy('month')
            ->get();

        return response()->json([
            'success' => true,
            'data' => [
                'stats' => [
                    'total_users' => $totalUsers,
                    'total_products' => $totalProducts,
                    'total_orders' => $totalOrders,
                    'total_revenue' => (float) $totalRevenue,
                    'pending_orders' => $pendingOrders,
                    'processing_orders' => $processingOrders,
                    'shipped_orders' => $shippedOrders,
                    'delivered_orders' => $deliveredOrders,
                    'cancelled_orders' => $cancelledOrders,
                    'total_reviews' => $totalReviews,
                    'low_stock_products' => $lowStockProducts,
                ],
                'recent_orders' => $recentOrders,
                'top_products' => $topProducts,
                'daily_sales' => $dailySales,
                'monthly_sales' => $monthlySales,
            ],
        ]);
    }
}
