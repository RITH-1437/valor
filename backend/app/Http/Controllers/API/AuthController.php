<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\UserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rules\Password;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $raw = $request->getContent();
        $input = json_decode($raw, true) ?? $request->all();
        $request->merge($input);

        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'confirmed', Password::min(8)],
            'phone' => ['nullable', 'string', 'max:20'],
        ]);

        $user = User::create([
            'name' => $validated['name'],
            'email' => $validated['email'],
            'password' => Hash::make($validated['password']),
            'phone' => $validated['phone'] ?? null,
        ]);

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ], 201);
    }

    public function login(Request $request): JsonResponse
    {
        $raw = $request->getContent();
        $input = json_decode($raw, true) ?? $request->all();

        $request->merge($input);

        $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        $user = User::where('email', $input['email'] ?? '')->first();

        if (! $user || ! Hash::check($input['password'] ?? '', $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['The provided credentials are incorrect.'],
            ]);
        }

        $token = $user->createToken('auth-token')->plainTextToken;

        return response()->json([
            'user' => new UserResource($user),
            'token' => $token,
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json(['message' => 'Logged out successfully.']);
    }

    public function profile(Request $request): UserResource
    {
        return new UserResource($request->user());
    }

    public function updateProfile(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['sometimes', 'string', 'max:255'],
            'email' => ['sometimes', 'string', 'email', 'max:255', 'unique:users,email,' . $request->user()->id],
            'phone' => ['nullable', 'string', 'max:20'],
            'avatar' => ['nullable', 'string', 'max:255'],
        ]);

        $request->user()->update($validated);

        return response()->json([
            'user' => new UserResource($request->user()->fresh()),
        ]);
    }

    public function uploadAvatar(Request $request): JsonResponse
    {
        $request->validate([
            'avatar' => ['required', 'image', 'mimes:jpeg,png,jpg,webp', 'max:2048'],
        ]);

        $user = $request->user();

        if ($user->avatar) {
            $oldPath = str_replace(url('/storage') . '/', '', $user->avatar);
            if (Storage::disk('public')->exists($oldPath)) {
                Storage::disk('public')->delete($oldPath);
            }
        }

        $path = $request->file('avatar')->store('avatars', 'public');
        $avatarUrl = url('/storage/' . $path);

        $user->update(['avatar' => $avatarUrl]);

        return response()->json([
            'user' => new UserResource($user->fresh()),
            'message' => 'Avatar uploaded successfully.',
        ]);
    }

    public function deleteAvatar(Request $request): JsonResponse
    {
        $user = $request->user();

        if ($user->avatar) {
            $oldPath = str_replace(url('/storage') . '/', '', $user->avatar);
            if (Storage::disk('public')->exists($oldPath)) {
                Storage::disk('public')->delete($oldPath);
            }
        }

        $user->update(['avatar' => null]);

        return response()->json([
            'user' => new UserResource($user->fresh()),
            'message' => 'Avatar removed successfully.',
        ]);
    }
}
