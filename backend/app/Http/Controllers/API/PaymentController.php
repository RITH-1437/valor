<?php

namespace App\Http\Controllers\API;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentTransactionResource;
use App\Models\Order;
use App\Models\PaymentTransaction;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;

class PaymentController extends Controller
{
    public function create(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'order_id' => 'required|exists:orders,id',
            'provider' => 'required|string|in:cod,stripe,paypal',
            'payment_method' => 'required|string',
        ]);

        $order = Order::findOrFail($validated['order_id']);

        if ($order->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $existing = PaymentTransaction::where('order_id', $order->id)
            ->where('status', 'paid')
            ->exists();

        if ($existing) {
            return response()->json(['success' => false, 'message' => 'Order already paid.'], 409);
        }

        $transaction = DB::transaction(function () use ($validated, $order, $request) {
            $transaction = PaymentTransaction::create([
                'user_id' => $request->user()->id,
                'order_id' => $order->id,
                'provider' => $validated['provider'],
                'transaction_id' => Str::uuid(),
                'amount' => $order->total,
                'currency' => 'USD',
                'status' => $validated['provider'] === 'cod' ? 'pending' : 'pending',
                'payment_method' => $validated['payment_method'],
            ]);

            if ($validated['provider'] === 'cod') {
                $order->update(['status' => 'confirmed']);
                $transaction->update(['status' => 'pending']);
            }

            return $transaction;
        });

        return response()->json([
            'success' => true,
            'message' => 'Payment initiated.',
            'data' => new PaymentTransactionResource($transaction),
        ], 201);
    }

    public function verify(Request $request, PaymentTransaction $transaction): JsonResponse
    {
        if ($transaction->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        if ($transaction->status !== 'pending') {
            return response()->json(['success' => false, 'message' => 'Transaction already processed.'], 422);
        }

        if ($transaction->provider === 'cod') {
            DB::transaction(function () use ($transaction) {
                $transaction->update([
                    'status' => 'paid',
                    'paid_at' => now(),
                ]);
                $transaction->order->update(['status' => 'confirmed']);
            });

            return response()->json([
                'success' => true,
                'message' => 'COD payment confirmed on delivery.',
                'data' => new PaymentTransactionResource($transaction->fresh()),
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Online payments must be verified via webhook.',
        ], 422);
    }

    public function history(Request $request): JsonResponse
    {
        $transactions = PaymentTransaction::with('order')
            ->where('user_id', $request->user()->id)
            ->latest()
            ->paginate(10);

        return response()->json([
            'success' => true,
            'data' => PaymentTransactionResource::collection($transactions),
            'meta' => [
                'current_page' => $transactions->currentPage(),
                'last_page' => $transactions->lastPage(),
                'total' => $transactions->total(),
            ],
        ]);
    }

    public function show(Request $request, PaymentTransaction $transaction): JsonResponse
    {
        if ($transaction->user_id !== $request->user()->id) {
            return response()->json(['success' => false, 'message' => 'Unauthorized.'], 403);
        }

        $transaction->load('order');

        return response()->json([
            'success' => true,
            'data' => new PaymentTransactionResource($transaction),
        ]);
    }

    public function statistics(): JsonResponse
    {
        $stats = PaymentTransaction::selectRaw('
            status,
            COUNT(*) as count,
            SUM(amount) as total_amount
        ')->groupBy('status')->get();

        $revenue = PaymentTransaction::where('status', 'paid')->sum('amount');
        $failed = PaymentTransaction::where('status', 'failed')->count();

        return response()->json([
            'success' => true,
            'data' => [
                'by_status' => $stats,
                'total_revenue' => (float) $revenue,
                'failed_count' => $failed,
            ],
        ]);
    }
}
