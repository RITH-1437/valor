<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\AddressResource;
use App\Models\Address;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AddressController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $addresses = Address::where('user_id', $request->user()->id)
            ->orderByDesc('is_default')
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => AddressResource::collection($addresses),
        ]);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'full_name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'country' => 'required|string|max:100',
            'city' => 'required|string|max:100',
            'district' => 'required|string|max:100',
            'street' => 'required|string|max:255',
            'postal_code' => 'nullable|string|max:20',
            'is_default' => 'boolean',
        ]);

        $user = $request->user();

        if ($validated['is_default'] ?? false) {
            Address::where('user_id', $user->id)->update(['is_default' => false]);
        }

        // If first address, make it default
        if ($user->addresses()->count() === 0) {
            $validated['is_default'] = true;
        }

        $address = Address::create([
            'user_id' => $user->id,
            ...$validated,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Address created.',
            'data' => new AddressResource($address),
        ], 201);
    }

    public function update(Request $request, Address $address): JsonResponse
    {
        if ($address->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $validated = $request->validate([
            'full_name' => 'sometimes|required|string|max:255',
            'phone' => 'sometimes|required|string|max:20',
            'country' => 'sometimes|required|string|max:100',
            'city' => 'sometimes|required|string|max:100',
            'district' => 'sometimes|required|string|max:100',
            'street' => 'sometimes|required|string|max:255',
            'postal_code' => 'nullable|string|max:20',
            'is_default' => 'boolean',
        ]);

        if ($validated['is_default'] ?? false) {
            Address::where('user_id', $request->user()->id)->update(['is_default' => false]);
        }

        $address->update($validated);

        return response()->json([
            'success' => true,
            'message' => 'Address updated.',
            'data' => new AddressResource($address),
        ]);
    }

    public function destroy(Request $request, Address $address): JsonResponse
    {
        if ($address->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $wasDefault = $address->is_default;
        $address->delete();

        if ($wasDefault) {
            $first = Address::where('user_id', $request->user()->id)->first();
            if ($first) {
                $first->update(['is_default' => true]);
            }
        }

        return response()->json([
            'success' => true,
            'message' => 'Address deleted.',
        ]);
    }

    public function setDefault(Request $request, Address $address): JsonResponse
    {
        if ($address->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        Address::where('user_id', $request->user()->id)->update(['is_default' => false]);
        $address->update(['is_default' => true]);

        return response()->json([
            'success' => true,
            'message' => 'Default address set.',
            'data' => new AddressResource($address),
        ]);
    }
}
