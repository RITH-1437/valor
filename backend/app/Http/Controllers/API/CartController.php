<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\CartResource;
use App\Models\CartItem;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $cartItems = CartItem::with('product.images')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->get();

        $subtotal = $cartItems->sum('total_price');
        $shipping = $subtotal > 200 ? 0 : 15;
        $tax = round($subtotal * 0.08, 2);

        return response()->json([
            'success' => true,
            'data' => CartResource::collection($cartItems),
            'meta' => [
                'subtotal' => round($subtotal, 2),
                'shipping' => $shipping,
                'tax' => $tax,
                'total' => round($subtotal + $shipping + $tax, 2),
                'item_count' => $cartItems->sum('quantity'),
            ],
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'selected_size' => 'nullable|string',
            'selected_color' => 'nullable|string',
        ]);

        $user = $request->user();

        $existing = CartItem::where('user_id', $user->id)
            ->where('product_id', $validated['product_id'])
            ->where('selected_size', $validated['selected_size'] ?? null)
            ->where('selected_color', $validated['selected_color'] ?? null)
            ->first();

        if ($existing) {
            $existing->update(['quantity' => $existing->quantity + $validated['quantity']]);
            $existing->load('product.images');

            return response()->json([
                'success' => true,
                'message' => 'Cart updated.',
                'data' => new CartResource($existing),
            ]);
        }

        $cartItem = CartItem::create([
            'user_id' => $user->id,
            ...$validated,
        ]);

        $cartItem->load('product.images');

        return response()->json([
            'success' => true,
            'message' => 'Product added to cart.',
            'data' => new CartResource($cartItem),
        ], 201);
    }

    public function update(Request $request, CartItem $cartItem): JsonResponse
    {
        if ($cartItem->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized.',
            ], 403);
        }

        $validated = $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $cartItem->update($validated);
        $cartItem->load('product.images');

        return response()->json([
            'success' => true,
            'message' => 'Cart updated.',
            'data' => new CartResource($cartItem),
        ]);
    }

    public function destroy(Request $request, CartItem $cartItem): JsonResponse
    {
        if ($cartItem->user_id !== $request->user()->id) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized.',
            ], 403);
        }

        $cartItem->delete();

        return response()->json([
            'success' => true,
            'message' => 'Item removed from cart.',
        ]);
    }
}
