<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AdminCustomerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = User::withCount(['orders', 'reviews']);

        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'LIKE', "%{$search}%")
                    ->orWhere('email', 'LIKE', "%{$search}%");
            });
        }

        $customers = $query->latest()->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $customers,
        ]);
    }

    public function show(User $user): JsonResponse
    {
        $user->loadCount(['orders', 'reviews', 'wishlists']);
        $user->load(['orders' => fn ($q) => $q->latest()->limit(10)]);

        return response()->json([
            'success' => true,
            'data' => $user,
        ]);
    }
}
