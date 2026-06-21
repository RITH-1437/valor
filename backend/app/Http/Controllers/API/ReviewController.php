<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\ReviewResource;
use App\Models\Review;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class ReviewController extends Controller
{
    public function index(Request $request, int $productId): JsonResponse
    {
        $reviews = Review::with('user')
            ->where('product_id', $productId)
            ->latest()
            ->paginate(10);

        $avg = Review::where('product_id', $productId)->avg('rating');
        $count = Review::where('product_id', $productId)->count();

        return response()->json([
            'success' => true,
            'data' => ReviewResource::collection($reviews),
            'meta' => [
                'average_rating' => round($avg, 1),
                'total_reviews' => $count,
                'current_page' => $reviews->currentPage(),
                'last_page' => $reviews->lastPage(),
            ],
        ]);
    }

    public function store(Request $request, int $productId): JsonResponse
    {
        $validated = $request->validate([
            'rating' => 'required|integer|min:1|max:5',
            'review' => 'nullable|string|max:1000',
        ]);

        $exists = Review::where('user_id', $request->user()->id)
            ->where('product_id', $productId)
            ->exists();

        if ($exists) {
            return response()->json([
                'success' => false,
                'message' => 'You have already reviewed this product.',
            ], 409);
        }

        $review = Review::create([
            'user_id' => $request->user()->id,
            'product_id' => $productId,
            ...$validated,
        ]);

        $review->load('user');

        return response()->json([
            'success' => true,
            'message' => 'Review submitted.',
            'data' => new ReviewResource($review),
        ], 201);
    }

    public function update(Request $request, Review $review): JsonResponse
    {
        if ($review->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $validated = $request->validate([
            'rating' => 'sometimes|integer|min:1|max:5',
            'review' => 'nullable|string|max:1000',
        ]);

        $review->update($validated);
        $review->load('user');

        return response()->json([
            'success' => true,
            'message' => 'Review updated.',
            'data' => new ReviewResource($review),
        ]);
    }

    public function destroy(Request $request, Review $review): JsonResponse
    {
        if ($review->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $review->delete();

        return response()->json([
            'success' => true,
            'message' => 'Review deleted.',
        ]);
    }
}
