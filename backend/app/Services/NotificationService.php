<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\User;
use Illuminate\Support\Facades\Mail;
use App\Mail\OrderCreatedMail;
use App\Mail\OrderStatusMail;
use App\Mail\PaymentSuccessMail;
use App\Mail\PaymentFailedMail;
use App\Mail\WelcomeMail;

class NotificationService
{
    public function createNotification(int $userId, string $title, string $message, string $type, array $data = []): Notification
    {
        return Notification::create([
            'user_id' => $userId,
            'title' => $title,
            'message' => $message,
            'type' => $type,
            'data' => $data,
        ]);
    }

    public function sendOrderEmail(string $email, string $name, string $orderNumber, string $status): void
    {
        try {
            Mail::to($email)->send(new OrderStatusMail($name, $orderNumber, $status));
        } catch (\Exception $e) {
            \Log::error('Failed to send order email: ' . $e->getMessage());
        }
    }

    public function sendPaymentEmail(string $email, string $name, string $orderNumber, float $amount, string $status): void
    {
        try {
            Mail::to($email)->send(new PaymentSuccessMail($name, $orderNumber, $amount, $status));
        } catch (\Exception $e) {
            \Log::error('Failed to send payment email: ' . $e->getMessage());
        }
    }

    public function sendWelcomeEmail(string $email, string $name): void
    {
        try {
            Mail::to($email)->send(new WelcomeMail($name));
        } catch (\Exception $e) {
            \Log::error('Failed to send welcome email: ' . $e->getMessage());
        }
    }

    public function orderCreated(int $userId, string $orderNumber, float $total): void
    {
        $this->createNotification($userId, 'Order Placed', "Your order #$orderNumber has been placed successfully. Total: \$$total", 'order_created', ['order_number' => $orderNumber]);
    }

    public function orderStatusChanged(int $userId, string $orderNumber, string $status): void
    {
        $labels = ['confirmed' => 'confirmed', 'processing' => 'being processed', 'shipped' => 'shipped', 'delivered' => 'delivered', 'cancelled' => 'cancelled'];
        $label = $labels[$status] ?? $status;
        $this->createNotification($userId, 'Order ' . ucfirst($label), "Your order #$orderNumber has been $label.", 'order_' . $status, ['order_number' => $orderNumber, 'status' => $status]);
    }

    public function paymentSuccess(int $userId, string $orderNumber, float $amount): void
    {
        $this->createNotification($userId, 'Payment Received', "Payment of \$$amount received for order #$orderNumber.", 'payment_success', ['order_number' => $orderNumber, 'amount' => $amount]);
    }

    public function paymentFailed(int $userId, string $orderNumber): void
    {
        $this->createNotification($userId, 'Payment Failed', "Payment for order #$orderNumber has failed. Please try again.", 'payment_failed', ['order_number' => $orderNumber]);
    }

    public function lowStock(int $userId, string $productName, int $stock): void
    {
        $this->createNotification($userId, 'Low Stock Alert', "$productName is running low ($stock left in stock).", 'low_stock', ['product_name' => $productName, 'stock' => $stock]);
    }

    public function newReview(int $userId, string $productName, int $rating): void
    {
        $this->createNotification($userId, 'New Review', "Your product \"$productName\" received a $rating-star review.", 'review_received', ['product_name' => $productName, 'rating' => $rating]);
    }
}
